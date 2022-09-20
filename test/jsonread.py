#!/usr/bin/env python
# coding = utf-8

import os,sys,json

for file in os.listdir(sys.argv[1]):
    sample = file.split
    if "json" in file:
        with open(file,'r') as f:
            loadDict = json.load(f)
            sample = loadDict["subject_id"]
            hla = loadDict["hla"]["alleles"]
            hlaTypeA,hlaTypeB,hlaTypeC,hlaTypeDQB1,hlaTypeDRB1 = [],[],[],[],[]
            for i in hla:
                if 'A*' in i:
                    i= i.replace("A*","")
                    # print (i)
                    hlaTypeA.append(i)
                elif 'B*' in i:
                    i= i.replace("B*","")
                    hlaTypeB.append(i)
                elif 'C*' in i:
                    i = i.replace("C*","")
                    hlaTypeC.append(i)
                elif 'DQB1*' in i:
                    i = i.replace("DQB1*","")
                    hlaTypeDQB1.append(i)
                elif 'DRB1*' in i:
                    i = i.replace("DRB1*","")
                    hlaTypeDRB1.append(i)
                else:
                    pass
            if len(hlaTypeA)>0:
                hlaA = 'A' + "\t" +'/'.join(hlaTypeA)
            else:
                hlaA = "A" +"\t" + "NA"
            if len(hlaTypeB)>0:
                hlaB = "B" + '\t' + "/".join(hlaTypeB)
            else:
                hlaB= "B" + '\t' + "NA"
            if len(hlaTypeC)>0:
                hlaC = "C" + "\t" + '/'.join(hlaTypeC)
            else:
                hlaC = "C" + "\t" + "NA"
            if len(hlaTypeDQB1)>0:
                hlaDQB1 = "DQB1" + '\t' + '/'.join(hlaTypeDQB1)
            else:
                hlaDQB1 = "DQB1" + '\t' + "NA"
            if len(hlaTypeDRB1)>0:
                hlaDRB1 = "DRB1" + '\t' + '/'.join(hlaTypeDRB1)
            else:
                hlaDRB1 = "DRB1" + '\t' + "NA"    
            typeList = [hlaA,hlaB,hlaC,hlaDQB1,hlaDRB1]
            typeOut = "\n".join(typeList)
            with open(sample+".xhla.type",'w') as out:
                out.write("gene"+ '\t'+ sample +".xhla" +"\n")
                out.write(typeOut)
            