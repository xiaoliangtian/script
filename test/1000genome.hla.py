#!/usr/bin/env python
#coding = utf-8
import os,sys,json

with open(sys.argv[1],'r') as f:
    # head = f.readline.strip().split("\t")
    line = f.readlines()
    # print(line)
    for  i in line:
        lineInfo = i.strip().split("\t")
        sample = lineInfo[1]
        typeA = "A" + "\t" + lineInfo[2] + '/' + lineInfo[3]
        typeB = "B" + "\t" + lineInfo[4] + '/' + lineInfo[5]
        typeC = "C" + "\t" + lineInfo[6] + '/' + lineInfo[7]
        typeDQB1 = "DQB1" + "\t" + lineInfo[8] + '/' + lineInfo[9]
        typeDRB1 = "DRB1" + "\t" + lineInfo[10] + '/' + lineInfo[11]
        outType = [typeA,typeB,typeC,typeDQB1,typeDRB1]
        outList = "\n".join(outType)
        with open(sample + ".1000.type", 'w') as out:
            out.write("gene"+'\t' + sample +".1000" +"\n")
            out.write(outList)