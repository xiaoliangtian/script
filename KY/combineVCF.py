#!/usr/bin/env python
#coding = utf-8

import os, sys, argparse, subprocess, subprogram3, openpyxl, time

parser = argparse.ArgumentParser("combine vcf")

parser.add_argument('-i', '--input', help = 'combine vcf sample barcode,example:A_B_C,D_E_F')
parser.add_argument('-f', '--file', help = 'excel file from YC')
parser.add_argument('--path',default = '/storage/project/WES/combine_vcf', help = 'combine vcf path')
parser.add_argument('--mail',metavar="mail", default = 'liang.xu@we-health.vip,feng.wang@we-health.vip,xushi.xie@we-health.vip',help = 'mail to someone ,separate by comma')
# parser.add_argument('-b', '--bed', default = WES)

args = parser.parse_args()

run = subprogram3.run
gvcfDir = os.path.join(args.path, 'results/GVCF/') 
if args.file:
    title = args.file.strip('.xlsx')
else:
    title = time.strftime("%Y-%m-%d")
if args.file:
    title = args.file.strip('.xlsx')
    if args.file.endswith('.xlsx'):
        wb = openpyxl.load_workbook(args.file)
    else:
        print('input file is not excel, please check')
        sys.exit(2)
    ws = wb.active
    # print(ws)
    famAll = {}
    # print(ws.max_row)
    for r in range(2, ws.max_row + 1):
        # print(r)
        famNum = ws.cell(row=r,column=1).value
        # print(famNum)
        sample = ws.cell(row=r,column=3).value[-5:]
        # print(sample)
        samplePath = ws.cell(row=r,column=5).value.split('/storage')[1].replace('', '')
        # print(samplePath)
        searchS = sample + '.*.g.vcf.gz'
        cmd = 'locate -ir ' + searchS
        try:
            sampleList = subprocess.check_output(cmd, shell=True).decode('utf-8').split('\n')
        except subprocess.CalledProcessError as e:
            print('Error:cannot find sample:',  sample)
            continue
        while '' in sampleList:
            sampleList.remove('')
        if len(sampleList) > 2:
            print(sampleList)
            for lns in sampleList:
                if samplePath in lns:
                    run('ln -s %s %s' %(lns,gvcfDir),1)
        else:
            run('ln -s %s %s %s' %(sampleList[-1],sampleList[-2],gvcfDir),1)
        if famNum not in famAll.keys():
            famAll[famNum] = []
        famAll[famNum].append(sample)
        famAllList = []
    for key in famAll.keys():
        famSinStr = '_'.join(famAll[key])
        famAllList.append(famSinStr)
    famAllStr = ','.join(famAllList)
    print(famAllStr)
    run('sentieon_pip --skip -b WES --cbvcf %s' %famAllStr, 1, args.path)

elif args.input:
    famFormat = args.input.split(',')
    for fam in famFormat:
        famList = fam.split('_')
        for i in famList:
            searchS = i + '.*.g.vcf.gz'
            cmd = 'locate -ir ' + searchS
            try:
                sample = subprocess.check_output(cmd, shell=True).decode('utf-8').split('\n')
                # print(sample)
            except subprocess.CalledProcessError as e:
                print('Error:cannot find sample:',  i)
                continue
            while '' in sample:
                sample.remove('')
            if len(sample) > 2:
                print(sample)
            run('ln -s %s %s %s' %(sample[-1],sample[-2],gvcfDir),1)

    run('sentieon_pip --skip -b WES --cbvcf %s' %args.input, 1, args.path)

if args.mail:
    mailStr = args.mail.replace(',' ,' ')
    # date = time.strftime("%Y-%m-%d")
    run('echo "结果见:%s" | mail -s "%s家系vcf合并" -c xiaoliang.tian@we-health.vip  %s ' %(args.path + '/results',title,mailStr),1)
