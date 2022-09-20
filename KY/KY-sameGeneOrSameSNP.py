#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import os,sys,argparse,glob
from subprocess import Popen,PIPE
from functools import  partial
from multiprocessing import Pool
import xlrd
from collections import defaultdict
import pandas as pd
import csv

parser = argparse.ArgumentParser(description='Get same Gene or same SNP for few samples',epilog='查找多个样本的共有基因或共同位点')

parser.add_argument('--version',action='version',version='%(prog)s 1.0')
Group = parser.add_mutually_exclusive_group()
Group.add_argument('--all', action = 'store_true',default=False,help="文件夹下的所有文件作为输入")
Group.add_argument('-i','--input',help="指定样本作为输入，逗号隔开")
#parser.add_argument('-f','--file_dir',help="文件所在文件夹路径")
parser.add_argument('--maf',type=float,default=0.05,help="过滤人群频率数值，默认0.05")
#parser.add_argument('-t','--task_num',type=int,default = 5,help="同时读取的文件数，默认5个")
parser.add_argument('--minNum',type=int,default=2,help="含有共有基因的最低样本数")
GroupList = parser.add_mutually_exclusive_group()
GroupList.add_argument('--listName',help="共有列的表头名称")
GroupList.add_argument('--listNum',type=int,help="共有列的列数")

args = parser.parse_args()

if args.all:
    annoFile = glob.glob('*.xlsx')
elif args.input:
    annoFile = args.input.split(",")
else:
    print ("必须要有输入文件")
    sys.exit(2)

def open_excel(file):
    try:
        data = xlrd.open_workbook(file)
        return data
    except Exception as e:
        print (str(e))

class AutoTree(dict):
    def __missing__(self, key):
        value = self[key] = type(self)()
        return value


global dictNum,dictNumPoint,dictInfo,dictPoint
dictNum,dictNumPoint,dictInfo,dictPoint = {},{},{},{}
dictInfo = AutoTree()
dictPoint = AutoTree()
for file in annoFile:
    if os.path.isfile(file):
        sample = file.replace(".xlsx","").replace(".whanno","")
        sampleList = []
        dictInfo[sample] = {}
        dictPoint[sample] = {}
        data = open_excel(file)
        sheet = data.sheet_by_name("standard")
        #print (sheet)
        #lines = sheet.readlines()
        lineCount = 0
        rows = sheet.nrows
        cols = sheet.ncols
        for line in range(rows):
            lineNum = line
            line = sheet.row_values(line)
            lineIn = []
            for i in range(cols):
                ctype = sheet.cell(lineNum, i).ctype
                no = sheet.cell(lineNum, i).value
                
                if ctype == 2 and no % 1 == 0.0:
                    # print (no)
                    no = str(int(no))
                lineIn.append(str(no))
            lineIn = "\t".join(lineIn)
            #print (lineIn + "\n" + str(line))
            lineCount += 1
            #print (line)
            if lineCount == 1:
                heads = line
                # print (heads)
                heads.insert(0,"sample")
                # print (header)
                freInfo1 = heads.index("1000g2015aug_eas")
                freInfo2 = heads.index("eas_gnomad")
                # print (freInfo1,freInfo2)
                if args.listName:
                    effInfo = heads.index(args.listName)-1
                    outFileName = args.listName + '.tsv'
                else:
                    effInfo = args.listNum - 1
                    outFileName = heads[effInfo] + '.tsv'
            else:
                lineInfo = line
                point = "_".join(str(lineInfo[0:5]))

                if ((lineInfo[freInfo1] == '.' or float(lineInfo[freInfo1]) <= args.maf )  and (lineInfo[freInfo2] == '.' or float(lineInfo[freInfo2]) <= args.maf ) ):
                    if lineInfo[effInfo] not in dictNum.keys() and sample not in dictNum.values() :
                        dictNum[lineInfo[effInfo]] = []
                        dictNum[lineInfo[effInfo]].append(sample)
                    elif sample not in dictNum[lineInfo[effInfo]]:
                        dictNum[lineInfo[effInfo]].append(sample)
                    if point not in dictNumPoint.keys() and sample not in dictNumPoint.values():
                        dictNumPoint[point] = []
                        dictNumPoint[point].append(sample)
                    elif sample not in dictNumPoint[point]:
                        dictNumPoint[point].append(sample)
                        
                    if lineInfo[effInfo] not in dictInfo[sample].keys():
                        dictInfo[sample][lineInfo[effInfo]] = []
                        dictInfo[sample][lineInfo[effInfo]].append(sample + "\t" + lineIn)
                    else:
                        dictInfo[sample][lineInfo[effInfo]].append(sample + "\t" + lineIn)

                    dictPoint[sample][point] = sample + "\t" + lineIn

outFile=[]
outFile.append("\t".join(heads))
for key in dictNum.keys():
    if len(dictNum[key]) >= args.minNum:
        for sample in dictInfo.keys():
            if key in dictInfo[sample].keys():
                outList = "\n".join(dictInfo[sample][key])
                outFile.append(outList)
Outline = "\n".join(outFile)

with open(outFileName, "w") as f:
    f.write(Outline)

OutPoint = []
OutPoint.append("\t".join(heads))
for pos in dictNumPoint.keys():
    if len(dictNumPoint[pos]) >= args.minNum:
        for sample in dictPoint.keys():
            if pos in dictPoint[sample].keys():
                OutPoint.append(dictPoint[sample][pos])
OutpointFile = "\n".join(OutPoint)


with open("pos.tsv", "w") as point:
    point.write(OutpointFile)



            

