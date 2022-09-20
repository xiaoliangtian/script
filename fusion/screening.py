#!/usr/bin/env python

import os
import sys
import json
from multiprocessing import Pool,Queue,Process
import multiprocessing
import argparse
import subprocess

# optional args
parser = argparse.ArgumentParser()
parser.add_argument('-b', '--bed', required=True, help='bed type')
parser.add_argument('-f', '--file_dir', required=True, help='fastq files dir')
parser.add_argument('-t', '--task_num', type=int, default=4, help='max task process at one time')
args = parser.parse_args()

if args.file_dir:
    fqDir = args.file_dir

# prepare
fileCheck = []
cmdList = []

toolDir = '/mnt/workshop/SC/script_hub/'
faDir = '/opt/seqtools/gatk/'
bedListFile = toolDir + 'common/bedList.json'
process = toolDir + 'common/calling_pipline.sh'
with open(bedListFile) as bed:
    bedList = json.load(bed)

if args.bed in bedList['cap'].keys():
    bedFile = bedList['cap'][args.bed]
    seqMethod = 'cap'
elif args.bed in bedList['amp'].keys():
    bedFile = bedList['amp'][args.bed]
    seqMethod = 'amp'
elif args.bed in bedList['amp'].keys():
    bedFile = bedList['amp'][args.bed]
    seqMethod = 'amp'
elif args.bed == 'bam_only':
    bedFile = 'bam_only'
    seqMethod = 'bam_only'
elif args.bed == 'fusion':
    process = 'Fusion_pipline.sh'
    bedFile = 'fusion'
    seqMethod = 'fusion'
else:
    sys.exit('-----wrong bed-----')

if args.bed == 'CYP21A2':
    ref = faDir + 'CYP21A/ucsc.hg19.CYP21A2.fasta'
elif args.bed == 'CYP21A1P':
    ref = faDir + 'CYP21A/ucsc.hg19.CYP21A1P.fasta'
elif args.bed == 'chrMT':
    ref = faDir + 'chrMT.fasta'
else:
    ref = faDir + 'ucsc.hg19.fasta'

projectDir = fqDir.split('/')
if 'project' in projectDir:
	projectIdx = projectDir.index('project') + 1
else:
	projectIdx = 0
project = projectDir[projectIdx]
if args.bed in ( 'PA', 'PA2'):
    project = 'noanno'

# functions list
def file_check(file):
    if file not in fileCheck:
        fileCheck.append(file)
        return True
    else:
        return False

def run_cmd(cmd, workDir=None):
    try:
        step = subprocess.Popen(cmd, cwd=workDir)
        step.wait()
    except:
        print(cmd, ' failed')

# code start
if __name__ == "__main__":
    for file in os.listdir(fqDir):
        if '.fastq.gz.raw' in file:
            pass
        elif '_R1.fastq.gz' in file and file_check(file):
            fileName = file.replace('_R1.fastq.gz', '')
            screenCmd = ['sh', process, fileName, ref, fqDir, bedFile, project, seqMethod]
            cmdList.append(screenCmd)
            print (screenCmd)

    pool = Pool(processes = args.task_num)
    pool.map(run_cmd, cmdList)
    pool.close()
    pool.join()
    print ('all sub done')

    # cal depth process
    if args.bed not in ('WGS', 'bam_only', 'fusion'):
        calCmd = toolDir + 'common/cal_stats.py'
        calBed = '/opt/seqtools/bed/' + bedFile + '.bed'
        calArg = ['pypy', calCmd, calBed, fqDir]
        subprocess.Popen(calArg, cwd=fqDir)

    # stat fusion results
    if args.bed == 'fusion':
        fusionCmd = toolDir + 'common/fusion-stat.py'
        fusionDir = fqDir + '/results'
        fusionArg = ['python', fusionCmd, fusionDir]
        run_cmd(fusionArg)

    # cnv_xhmm process
    if args.bed in ('IDTEx', 'IDP', 'IDT_PPGL'):
        cnvDir = fqDir + '/results/cnv_xhmm'
        bamDir = fqDir + '/results/recal_bam'
        run_cmd(['mkdir', cnvDir], workDir=fqDir)
        bamList = []
        bamText = cnvDir + '/input_bams.list'
        for file in os.listdir(bamDir):
            os.symlink(bamDir + '/' + file, cnvDir + '/' + file)
            if 'recal.dedup.sorted.bam' in file:
                bamList.append(file)
        bamStr = '\n'.join(bamList)
        with open(bamText, 'w') as bam:
            bam.write(bamStr)
        refCNV = '/mnt/workshop/SC/project/XHMM_cnv/' + args.bed
        cnvTool = toolDir + '/WES/xhmm_run.sh'
        intervals = bedFile + '.intervals'
        subprocess.Popen(['sh', cnvTool, cnvDir, intervals, refCNV], cwd=cnvDir)

    sys.exit('------process done------')
