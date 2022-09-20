#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '1.0.1'
__date__='2015/10/08'
import sys,re,os
if len(sys.argv) !=3:
    print '%s: pep.fa.ipr gene2go.txt' %sys.argv[0]
    sys.exit()
#os.system('iprscan -cli -appl hmmpfam -i %s -o %s.ipr -nocrc -iprlookup -goterms -format raw' %(sys.argv[1],sys.argv[1]))
fin=open(sys.argv[1],'rU')
fout=open(sys.argv[2],'w')
go={}
for line in fin:
    word=line.rstrip().split('\t')
    if word[11]=='NULL' or len(word)<14:
        continue
    if word[0] not in go:
        go[word[0]]={}
    for goterm in word[-1][:-1].split('), '):
        go[word[0]][goterm]=1
fout.write('#Gene\tGO accession\tTerm\tOntology\n')
for gene in go:
    for goterm in go[gene]:
        (lv,func,goid)=re.findall('(^.+?):(.+)\((GO:\d+)',goterm)[0]
        fout.write('%s\t%s\t%s\t%s\n' %(gene,goid,func.strip(),lv.strip()))
