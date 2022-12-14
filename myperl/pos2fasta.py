#!/usr/bin/env python
# usages: python extract_seq_by_pos.py input.fasta id_start_end > result.fasta
import sys
import re

FASTA= sys.argv[1]
BED= sys.argv[2]

fasta= open(FASTA, 'U')
fasta_dict= {}
for line in fasta:
    line= line.strip()
    if line == '':
        continue
    if line.startswith('>'):
        seqname= line.lstrip('>')
        seqname= re.sub('\..*', '', seqname)
        fasta_dict[seqname]= ''
    else:
        fasta_dict[seqname] += line
fasta.close()

bed= open(BED, 'U')
for line in bed:
    line= line.strip().split('\t')
    outname= line[0] + ':' + line[1] + '-' + line[2]
    print('>' + outname)
    s= int(line[1])-1
    e= int(line[2])-1
    print(fasta_dict[line[0]][s:e])
bed.close()
sys.exit()