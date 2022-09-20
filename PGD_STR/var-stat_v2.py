#!/usr/bin/env python

import os
import argparse
from subprocess import Popen, PIPE

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="input file")
parser.add_argument("-f", "--dir", help="file dir")
parser.add_argument("-q", "--qc", help="if cal qc file")
args = parser.parse_args()

if args.dir:
    fileDir = args.dir
else:
    fileDir = '.'

if args.input:
    inputFile = fileDir + '/' + args.input

if args.qc:
    qcFile = fileDir + '/' + args.qc

inputData = '/workshop/project/STR/STR_new_rate_txl_190220/analyse/all.erti.ty.rate' 
headIdx = []
fatherIdx = {}
sonIdx = {}
son2Idx = {}
momIdx = {}
heteroStats = {}
calOut = []
calPosOut = []
calNegOut = []
calOtherOut = []
cal_script = '/home/tianxl/pipeline/PGD_STR/misa_result_PGS.pl'

def statsHetero(line):
    global headIdx, heteroStats, heads
    for idx in headIdx:
        varLine = line[idx].split(':')
        varGeno = varLine[0]

        if heads[idx] not in heteroStats.keys():
            heteroStats[heads[idx]] = {}
            heteroStats[heads[idx]]['0/0'] = 0
            heteroStats[heads[idx]]['1/1'] = 0
            heteroStats[heads[idx]]['0/1'] = 0
            heteroStats[heads[idx]]['allSnp'] = 0

        heteroStats[heads[idx]]['allSnp'] += 1

        if varGeno == '0/0':
            heteroStats[heads[idx]]['0/0'] += 1
        elif varGeno == '1/1':
            heteroStats[heads[idx]]['1/1'] += 1
        elif varGeno == '0/1':
            heteroStats[heads[idx]]['0/1'] += 1
        else:
            continue

def loop_cal(mcol, scol, head=False):
    cmd = ['perl', cal_script, '-i', inputFile,  '-o2', 'test',  '-m', mcol, '-s', scol]
    #if not head:
        #cmd.append('-noheader')
    p = Popen(cmd, stdout=PIPE, stderr=PIPE)
    p.wait()
    stdout, stderr = p.communicate()
    outMsg = stdout.decode('utf-8')
    return outMsg

def isPos(outRes, famIdx):
    out = outRes.strip().split('\t')
    famStr = famIdx + '\n' + outRes.strip()
    calPosOut.append(famStr)
    #if len(out) > 2 and float(out[2]) >= 0.9 and int(out[0]) > 150:
    #    calPosOut.append(famStr)
    #elif len(out) > 2 and float(out[2]) <= 0.8 and int(out[0]) > 150:
    #    calNegOut.append(famStr)
    #else:
        #calOtherOut.append(famStr)

with open(inputFile) as textFile:
    header = textFile.readline()
    heads = header.strip().split('\t')
    for head in heads:
        sample = head.split('_')
        #print(sample) 
        idx = heads.index(head)
        if len(sample) >= 1  and idx > 0:
            #print(head)
            headIdx.append(idx)
            #if 'STR-' in sample[0]:
            sample_fix = sample[0]
            #else:
            #    sample_fix = sample[0][1:].split('-')[0]
            if 'PGD' in sample_fix :
                print (idx)
                sonIdx[sample_fix] = str(idx)
            else:
                son2Idx[sample_fix] = str(idx)
            #elif 'M' in sample_fix:
            #    momIdx[sample_fix] = str(idx)
            #elif 'F' in sample_fix:
            #    fatherIdx[sample_fix] = str(idx)
 #   for row in textFile:
  #      rowLine = row.strip().split('\t')
   #     statsHetero(rowLine)

# Hetero percetage
if args.qc:
    qcRaw = []
    with open(qcFile) as qc:
        header = qc.readline()
        heads = header.strip().split('\t')
        heads.insert(7, '0/1\t0/0\t1/1')
        newheader = '\t'.join(heads)
        qcRaw.append(newheader)
        for row in qc:
            rowLine = row.strip().split('\t')
            for sample in heteroStats.keys():
                sampleName = sample.split('_')[0]
                if sampleName == rowLine[0]:
                    heteroRatio = round(heteroStats[sample]['0/1']/heteroStats[sample]['allSnp']*100, 2)
                    homoRatio = round(heteroStats[sample]['0/0']/heteroStats[sample]['allSnp']*100, 2)
                    homoSNPRatio = round(heteroStats[sample]['1/1']/heteroStats[sample]['allSnp']*100, 2)
                    ratioStr = str(heteroRatio) + '\t' + str(homoRatio) + '\t' + str(homoSNPRatio)
                    rowLine.insert(7, ratioStr)
                    newLine = '\t'.join(rowLine)
                    qcRaw.append(newLine)

    result = '\n'.join(qcRaw)
    with open(qcFile, "w") as text_file:
        text_file.write(result)

# cal-var report
for i in sonIdx.keys():
    iRes = i + ' Reports:' + '\n'
    #for j in fatherIdx.keys():
        #for k in momIdx.keys():
    for h in son2Idx.keys():
                #if i[:4] == j[:4] and i[:4]==k[:4] and i[:4]==h[:4]:
        famOut = loop_cal(son2Idx[h], sonIdx[i])
        print (famOut)
        isPos(famOut, h)
    for j in sonIdx.keys():
        if i != j:
            famOut = loop_cal(sonIdx[i], sonIdx[j])
            print (famOut)
            isPos(famOut, j)
    #for l in momIdx.keys():
     #   if i[:4]==l[:4]:
      #      for m in fatherIdx.keys():
       #         out = loop_cal(fatherIdx[m], momIdx[l], son2Idx[i], True)
        #        iRes += out
         #   calOut.append(iRes)

faidx = ' '.join(fatherIdx.values()) + '\n\n'
#print (faidx)
calPosRes = '\n'.join(calPosOut)
calPosRes = 'Positive Family:' + '\n' + calPosRes + '\n\n'
#calNegRes = '\n'.join(calNegOut)
#calNegRes = 'Negative Family:' + '\n' + calNegRes + '\n\n'
#calOtherRes = '\n'.join(calOtherOut)
#calOtherRes = 'Other Family:' + '\n' + calOtherRes + '\n\n'
#reportOut = '\n'.join(calOut)
varReport = fileDir + '/' + 'var-report.txt'
with open(varReport, 'w') as text_file:
    text_file.write(faidx)
    text_file.write(calPosRes)
    #text_file.write(calNegRes)
    #text_file.write(calOtherRes)
    #text_file.write(reportOut)
