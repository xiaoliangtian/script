#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '2.0.0'
__date__='2015-10-07'
import sys,os,glob,re,argparse,urllib,time
from HTMLParser import HTMLParser
paths = os.path.dirname(os.path.realpath(__file__))
parser = argparse.ArgumentParser(description='-----------------------------------------------',epilog='It is use for kegg pathway analysis',version=__version__)
parser.add_argument('o',metavar='KEGG.format',help='output file[File]')
group1 = parser.add_mutually_exclusive_group()
action_i = group1.add_argument('-i',metavar='input',help='input KAAS result file: query.ko')
group1.add_argument('-j',metavar='jobid',help='KAAS jobs ID,must with -m')
group2 = parser.add_mutually_exclusive_group()
group2.add_argument('-e',metavar='email',help='KAAS receive email')
group2._group_actions.append(action_i)
parser.add_argument('-t',metavar='type',choices=['A','H','OH'],help='keep all pathway(A) Or remove Human Disease(H) Or remove Human Disease and  Organismal Systems(O)')
parser.add_argument('-s',metavar='stat',help='KEGG pathway level statistics[File]')
parser.add_argument('-ix',metavar='index',default='%s/kegg-index' %paths,help='kegg index file,defaulted')
parser.add_argument('-m','--maps',action='store_true',help="get kegg pathway picture")
args = parser.parse_args()

class parselinks(HTMLParser):
    def __init__(self):
        self.href = []
        self.img = []
        self.table = []
        self.flag = False
        HTMLParser.__init__(self)
    def handle_starttag(self,tag,attrs):
        # if tag == 'a':
        #     if len(attrs) == 0: pass
        #     else:
        #         for name,value in attrs:
        #             if name == 'href' and value.startswith('http://www.kegg.jp/kegg-bin/show_pathway?@ko'):
        #                     self.href.append(value)
        if tag == 'img':
            if len(attrs) == 0: pass
            else:
                for name,value in attrs:
                    if name == 'src' and value.startswith('/tmp/'):
                            self.img.append(value)
        if tag == 'td':
            if len(attrs) == 0: pass
            else:
                for name,value in attrs:
                    if name == 'class' and value == 'list_a':
                        self.flag = True
    def handle_data(self, data):
        if self.flag :
            data = data.strip()
            if data :
                self.table.append(data)
    def handle_endtag(self,tag):
        if tag == 'td' or tag == 'a':
            self.flag = False

def DownloadImg(url):
    try:
        socket=urllib.urlopen(url)
    except:
        print "can not open the url %s" %url
    names=url.split('/')[-1]
    if os.path.exists('map')==False:
        os.makedirs('map')
    fimg=open(os.path.join('map',names),"wb")
    fimg.write(socket.read())
    fimg.close()

if args.j is not None and args.e is not None:
    while True:
        url='http://www.genome.jp/kaas-bin/kaas_main?mode=user&id='+args.e
        socket=urllib.urlopen(url).read()
        user=parselinks()
        user.feed(socket)
        num=user.table.index(args.j)
        if user.table[num+1] != 'complete':
            time.sleep(3600)
        else:
            finput=open('query.ko','wb')
            finput.write(urllib.urlopen('http://www.genome.jp/tools/kaas/files/dl/'+args.j+'/query.ko').read())
            finput.close()
            kolist='query.ko'
            break

if args.i is not None : kolist=args.i

kegg={}
fkegg=open(args.ix,'rU')
for line in fkegg:
    word=line.rstrip().split('\t',1)
    if word[0] not in kegg:
        kegg[word[0]]=[]
    kegg[word[0]].append(word[1])

counts={}
imgs={}
fout=open(args.o,'w')
fout.write('#Gene\tKO ID\tFunction\tKEGG L1\tKEGG L2\tKEGG L3\n')
fko=open(kolist,'rU')
for line in fko:
    word=line.rstrip().split()
    if len(word) != 2: continue
    if word[1] not in kegg: continue
    for pathway in kegg[word[1]]:
        level=pathway.split('\t')
        if args.t=='H' and level[1] == 'Human Diseases':continue
        if args.t=='OH' and (level[1] == 'Human Diseases' or level[1] == 'Organismal Systems'):continue
        fout.write('%s\t%s\t%s\n' %(word[0],word[1],pathway))
        if level[1] not in counts:
            counts[level[1]]={}
        if level[2] not in counts[level[1]]:
            counts[level[1]][level[2]]={}
        counts[level[1]][level[2]][word[0]]=1
        ko=re.findall('(\d+)\s',level[3])[0]
        if ko not in imgs:
            imgs[ko]={}
        imgs[ko][word[1]]=1
fout.close()

if args.s is not None:
    fcount=open(args.s,'w')
    for level1 in sorted(counts.keys()):
        for level2 in counts[level1]:
            fcount.write('%s\t%s\t%s\n' %(level1,level2,len(counts[level1][level2])))
    fcount.close()
    os.system('Rscript %s/KEGGplot.r %s' %(paths,args.s))

if args.maps is True:
    for ko in imgs:
        urls='http://www.kegg.jp/kegg-bin/show_pathway?@ko'+ko+'/reference%3dwhite/default%3d%23bfffbf/'+'/'.join(imgs[ko].keys())
        pictures=parselinks()
        try:
            pictures.feed(urllib.urlopen(urls).read())
            for i in pictures.img:
                DownloadImg('http://www.kegg.jp'+i)
                time.sleep(10)
        except:
            print 'the url is wrong'
