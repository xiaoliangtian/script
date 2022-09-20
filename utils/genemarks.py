#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '1.0.0'
__date__='2015/10/26'
import re,requests,urllib,sys,time

if len(sys.argv) == 2:
    types='prok'
elif len(sys.argv) == 3:
    types=sys.argv[2]
else:
    print "%s: scaffold.fa type(prok defalut,euk,virus,phage,est)" % sys.argv[0]
    sys.exit()

files={'file':(open(sys.argv[1],'r').read())}
payload={'sequence':'','submit':'Start GeneMarkS','mode':types,
        'format':'LST','fnn':'fnn','faa':'faa',
        'subject':'GeneMarkS'}
url='http://exon.gatech.edu/genemark/'
r=requests.post(url+'genemarks.cgi',files=files,data=payload)
#time.sleep(120)
gms_out=re.search('tmp/genemarks\S+gms.out?',str(r.text))

def downloadfile(urls,files):
    try:
        socket=urllib.urlopen(urls)
        f=open(files,'wb')
        f.write(socket.read())
        f.close
    except:
        print 'the url is wrong'

if gms_out:
    downloadfile(url+gms_out.group(0),'gms.out')
    downloadfile(url+gms_out.group(0)+'.faa','gms.out.faa')
    downloadfile(url+gms_out.group(0)+'.fnn','gms.out.ffn')
