__author__ = 'Nie Xiaoting'
__version__ = '1.0.0'
__date__='2015/05/28'

'''Nieh 2016/01/27 1.2.0 arrange the file for html output '''

import sys,os
paths = os.path.dirname(os.path.realpath(__file__))
if len(sys.argv) != 6:
    print "%s: DEA.xls geneid2go GO-index DEG_GO DEG_GOEnrich.xls" % sys.argv[0]
    sys.exit()

os.system('Rscript %s/goseq_topGO.r %s %s' %(paths,sys.argv[1],sys.argv[2]))

DG=sys.argv[1].split('.DEA')[0]
fdiff=open(sys.argv[1],'rU')
fgene=open(sys.argv[2],'rU')
fgo=open(sys.argv[3],'rU')
fout=open(sys.argv[4],'w')
frich=open(sys.argv[5],'w')

func={}
for line in fgo:
    word=line.strip().split('\t')
    func[word[0]]='%s\t%s' %(word[1],word[4])
fgo.close()

gene2go={}
for line in fgene:
    gene,go=line.strip().split()
    gene2go[gene]=go
fgene.close()

fout.write('Gene\tGO accession\tTerm\tOntology\tResult\tFunction\n')
for line in fdiff.readlines()[1:]:
    word=line.strip().split('\t')
    if len(word)<11:
        continue
    if word[0] in gene2go:
        for go in gene2go[word[0]].split(','):
            if go in func:
                fout.write('%s\t%s\t%s\t%s\t%s\n' %(word[0],go,func[go],word[10],word[2]))
fout.close()

fin=open(DG+'.GOseq.enriched','rU')
frich.write('GO accession\tTerm\tOntology\tSample number\tBackgroud number\tOver represented pvalue\tq value(BH adjust)\n')
# coll={'CC':'cellular_component','BP':'biological_process','MF':'molecular_function'}
for line in fin.readlines()[1:]:
    word=line.rstrip().split('\t')
    if word[0] not in func:
        term='NA\tNA'
    else:
        term=func[word[0]].replace('_',' ')
    frich.write('%s\t%s\t%s\t%s\t%s\t%s\n' %(word[0],term,word[3],word[4],word[1],word[7]))
frich.close()
