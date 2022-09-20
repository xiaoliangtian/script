#!/usr/bin/env python

import os,sys

input = sys.argv[1]
modeIndex = sys.argv[2]
if sys.argv[3]: 
    splitLane = sys.argv[3]
else:
    splitLane = ""

# list = {}
def rev_complement(sequence):
    trantab = str.maketrans('ACGTacgtRYMKrymkVBHDvbhd', 'TGCAtgcaYRKMyrkmBVDHbvdh')     # trantab = str.maketrans(intab, outtab)   # 制作翻译表
    string = sequence.translate(trantab)
    string = (''.join(reversed(string)))     # str.translate(trantab)  # 转换字符
    return string

with open(input,'r') as file:
    lines = file.readlines()
    samplesList = []
    for line in lines:
        sampleList = []
        arrayIndex = line.strip().split("\t")
        sampleList.append(arrayIndex[0])
        if modeIndex == "PE":
            indexInfo = arrayIndex[2].replace(' ',"") + rev_complement(arrayIndex[1].replace(" ",''))
            sampleList.append(indexInfo)
            if splitLane:
                sampleList.append(arrayIndex[3])
            else:
                sampleList.append("")
            if arrayIndex[4]:
                sampleList.append(arrayIndex[4])
            else:
                sampleList.append(arrayIndex[0])
        else:
            sampleList.append(arrayIndex[1])
            if splitLane:
                sampleList.append(arrayIndex[2])
            else:
                sampleList.append("")
            if arrayIndex[3]:
                sampleList.append(arrayIndex[3])
            else:
                sampleList.append(arrayIndex[0])
        sampleInfo = "\t".join(sampleList)
        samplesList.append(sampleInfo)
    samplesInfo = "\n".join(samplesList)
    with open("index.barcode","w") as outfile:
        outfile.write(samplesInfo)

        

