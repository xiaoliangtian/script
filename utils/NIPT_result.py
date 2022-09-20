#!/usr/bin/env python
# coding=utf-8

import os, sys

input = sys.argv[1]
ref = sys.argv[2]
#print (1)
hash = {}
hash_ave = {}
hash_std = {}
line_count = 0
all = 0
result = []
print ('chr',"\t","z-Score")

with open(input) as chr:
    for line in chr.readlines():
        line_count +=1
        if line_count >1:
            line = line.strip('\n')
            line1 = line.split("\t")
            all += float(line1[1])
            hash[line1[0]]=line1[1]

with open(ref) as chr1:
    for line in chr1.readlines():
        line = line.strip('\n')
        line1 = line.split("\t")
        hash_ave[line1[0]] = line1[1]
        hash_std[line1[0]] = line1[2]

def rates(x):
    rate = float(x)/all
    return(rate)

for f in hash.keys():
    rate = rates(hash[f])
    for r in hash_ave.keys():
        if f == r:
            result.append(str(f))
            zscore = (rate-float(hash_ave[r]))/float(hash_std[r])
            result.append(str(zscore))
    print('\t'.join(result))        
    result = []    
    
    
