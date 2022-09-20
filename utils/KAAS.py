#!/usr/bin/env python
__version__ = '2.0.1'
__date__='2015-04-27'
__doc__="""work in with Automatic Annotation Server Ver. 2.0"""
import re,requests,urllib,sys

if len(sys.argv) != 4:
    print "%s: pep.fa email query_name" % sys.argv[0]
    sys.exit()

euk='hsa, mmu, rno, dre, dme, cel, ath, sce, ago, cal, spo, ecu, pfa, cho, ehi, eco, nme, hpy, bsu, lla, mge, mtu, syn, aae, mja, ape'
prok='hsa, dme, ath, sce, pfa, eco, sty, hin, pae, nme, hpy, rpr, mlo, bsu, sau, lla, spn, cac, mge, mtu, ctr, bbu, syn, aae, mja, afu, pho, ape'

files={'file':(open(sys.argv[1],'r').read())}
payload={'prog':'BLAST','text':'','uptype':'q_file','qname':sys.argv[3],
       'mail':sys.argv[2],'dbmode':'manual','org_list':euk,
       'way':'b','mode':'compute'}

r=requests.post('http://www.genome.jp/kaas-bin/kaas_main',files=files,data=payload)
jobid=re.search('ID: (\d+?)</p>',str(r.text))
if jobid:
    print jobid.group(1)
else:
    print 'The job is not submited,please check'
