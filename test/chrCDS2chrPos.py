#!/usr/bin/env python
# coding = utf-8

import os, sys, re, rev_complement

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()
    for line in lines:
        lineinfo = line.strip().split('\t')
        if ":" in lineinfo[0]:
            chr = lineinfo[0].replace(" ", "").split(':')[0].split('-')[0].split('_')[0]
            pos = lineinfo[0].split(':')[1].split('-')[0].split('_')[0]
        else:
            chr = lineinfo[0].split('-')[0]
            pos = lineinfo[0].split('-')[1]
        ref1pos = pos
        if 'ins' in lineinfo[1]:
            ref = '-'
            alt = ''.join(re.findall(r"c.*ins(.+)", lineinfo[1]))
            if lineinfo[2] == '-1':
                alt = rev_complement.rev(rev_complement.complement(alt))
                # print(lineinfo[0], alt)
            # print(lineinfo[0], alt)
        elif 'del' in lineinfo[1]:
            ref = ''.join(re.findall(r"c.*del(.+)", lineinfo[1]))
            ref1pos = len(ref) + int(pos) - 1
            # print(lineinfo[0], ref, len(ref))
            alt = '-'
            if lineinfo[2] == '-1':
                ref = rev_complement.rev(rev_complement.complement(ref))
        else:
            ref = ''.join(re.findall(r"c.*\d+(.+)\>", lineinfo[1]))
            alt = ''.join(re.findall(r"c.*\d+.*>(.+)", lineinfo[1]))
            # print(lineinfo[0], ref)
        print(chr+'\t'+pos+'\t'+str(ref1pos)+'\t'+ref+'\t'+alt)

