#!/usr/bin/env python
#coding = utf-8
import os,sys,json

samplehla = {}
for file in os.listdir(sys.argv[1]):
    if "1000.type" in file or 'xhla.type' in file:
        sample= file.split(".")[0]
        with open(file,'r') as f:
            line = f.readlines()
            lineCount = 0
            for i in line:
                lineCount += 1
                if lineCount > 1:
                    lineInfo = i.strip().split("\t")
                    if lineInfo[1] == "/" or lineInfo[1] == 'NA':
                        lineInfo[1] = ""
                    if lineInfo[0] not in samplehla.keys():
                        samplehla[(lineInfo[0])] = {}
                    if sample not in samplehla[(lineInfo[0])].keys():
                        samplehla[lineInfo[0]][sample] = []
                        samplehla[lineInfo[0]][sample].append(lineInfo[1])
                    else :
                        samplehla[lineInfo[0]][sample].append(lineInfo[1])

for i in samplehla.keys():
    sampleTypeNum = 0
    sameSampleTypeNum = 0
    for j in samplehla[i].keys():
        hlaList = samplehla[i][j]
        if hlaList[0] != "" and hlaList[1] != "":
            sameNum = 0
            sampleTypeNum += 2
            for m in hlaList[0].split("/"):
                for n in hlaList[1].split("/"):
                    if m == n:
                        sameNum += 1
            if sameNum >= 2:
                sameSampleTypeNum += 2
            elif sameNum >= 1:
                sameSampleTypeNum += 1
            else:
                sameSampleTypeNum += 0
    gene = i
    print (gene + "\t" + str(sampleTypeNum) + "\t" + str(sameSampleTypeNum) )

            
                


                    

