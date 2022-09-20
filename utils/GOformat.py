#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '2.2.1'
__date__='2015/10/08'
'''1.1.0 fix the bug one GOID have muti GO level2'''
'''1.2.0 fix the convert format'''
'''2.0.0 restructure'''
import sys,os,argparse
paths = os.path.dirname(os.path.realpath(__file__))
parser = argparse.ArgumentParser(description='-----------------------------------------------')
parser.add_argument('i',metavar='goanno',help='GO annotation file[File]')
parser.add_argument('-g',metavar='geneid2go',help='format result to geneid2go [File]')
parser.add_argument('-o',metavar='gene2go',help='format result to gene2go [File]')
parser.add_argument('-s',metavar='stat',help='GO level statistics[File]')
parser.add_argument('-ix',metavar='index',default='%s/GO-index' %paths ,help='GO index file,defaulted')
args = parser.parse_args()

if args.g is None and args.o is None and args.s is None:
    print 'the output parameter is none'
    # parser.print_help()
    sys.exit()

func={}
goterm={}
findex=open(args.ix,'rU')
for line in findex:
    goid,gofunc,gol2id,gol2func,orga=line.strip().split('\t')
    goterm[goid]='%s\t%s' %(gofunc,orga)
    gofc='%s\t%s\t%s' %(gofunc,gol2func,orga)
    if goid not in func:
        func[goid]={}
    func[goid][gofc]=1
findex.close()

go={}
stat={}
fgo=open(args.i,'rU')
for line in fgo:
    if line[0]=='#':
        continue
    word=line.strip().split('\t')
    if len(word)<2:
        continue
    gos=word[1].split(',')
    for goid in gos:
        if goid not in goterm:
            continue
        if word[0] not in go:
            go[word[0]]={}
        go[word[0]][goid]=1
        for gofc in func[goid]:
            gofunc,gol2func,orga=gofc.split('\t')
            if orga not in stat:
                stat[orga]={}
            if gol2func not in stat[orga]:
                stat[orga][gol2func]={}
            stat[orga][gol2func][word[0]]=1
fgo.close()

if args.g is not None:
    fgeneid=open(args.g,'w')
    for gene in go:
        fgeneid.write('%s\t%s\n' %(gene,','.join(go[gene].keys())))
    fgeneid.close()

if args.o is not None:
    fgene=open(args.o,'w')
    fgene.write('#Gene\tGO accession\tTerm\tOntology\n')
    for gene in go:
        for goid in go[gene]:
            fgene.write('%s\t%s\t%s\n' %(gene,goid,goterm[goid]))
    fgene.close()

if args.s is not None:
    fstat=open(args.s,'w')
    for orga in sorted(stat.keys()):
        for gol2func in stat[orga]:
            fstat.write('%s\t%s\t%s\n' %(orga,gol2func,len(stat[orga][gol2func])))
    fstat.close()
    os.system('Rscript %s/GOplot.r %s %s' %(paths,args.s,len(go)))

