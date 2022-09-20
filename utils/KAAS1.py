#!/usr/bin/env python
__version__  =  '2.3.0'
__date__ = '2015-04-27'
'''2015-04-27 2.0.1 work in with Automatic Annotation Server Ver. 2.0'''
'''2016-05-17 2.2.0 add more option'''
'''2016-12-16 2.3.0 work in with Automatic Annotation Server Ver. 2.1'''
import re, requests, urllib, sys, argparse
import imaplib, email
import datetime, time
import subprocess
from HTMLParser import HTMLParser

parser = argparse.ArgumentParser(description = '-----------------------------------------------', epilog = 'It is used for KEGG Automatic Annotation Server', version = __version__)
parser.add_argument('-f', metavar = 'fasta', required = True, help = 'Query sequences [multi-FASTA File]')
parser.add_argument('-q', metavar = 'qname', default = 'query', help = 'Query name, [query]')
parser.add_argument('-n', '--Nucleotide', action = 'store_true', help = 'Prefer Nucleotide File over Peptide File')
parser.add_argument('-m', metavar = 'mailid', type = int, help = 'outlook mail id')
parser.add_argument('-g', metavar = 'glist', default = 'euk', choices = ('euk', 'prok', 'animalia', 'plantae', 'fungi'), help = 'GENES data set: euk, prok, animalia, plantae, fungi. [euk]')
parser.add_argument('-s', metavar = 'search', default = 'BLAST', choices = ('BLAST', 'GHOSTX', 'GHOSTZ'), help = 'Search program: BLAST,  GHOSTX,  GHOSTZ. [BLAST]')
parser.add_argument('-a', metavar = 'assignment', default = 'b', choices = ('b', 's'), help = 'Assignment method: b (BBH,  bi-directional best hit),  s (SBH,  single-directional best hit). [b]')
parser.add_argument('-t', metavar = 'time', type = int, default = 1800, help = 'Job check time [1800]')
parser.add_argument('-j', metavar = 'job', type = int, default = 5, help = 'Job submit time [5]')
args = parser.parse_args()

class parselinks(HTMLParser) :
    def __init__(self):
        self.table = []
        self.flag = False
        HTMLParser.__init__(self)
    def handle_starttag(self, tag, attrs):
        if tag == 'td':
            if len(attrs) == 0: pass
            else:
                for name, value in attrs:
                    if name == 'class' and value == 'list_a':
                        self.flag = True
    def handle_data(self, data):
        if self.flag :
            data = data.strip()
            if data :
                self.table.append(data)
    def handle_endtag(self, tag):
        if tag == 'td' or tag == 'a':
            self.flag = False

def runshell(cmd) :
    try:
        s = subprocess.check_output(cmd,shell=True)
        return s
    except subprocess.CalledProcessError as e:
        print e
        sys.exit(2)

orglist = {'euk' : 'hsa, mmu, rno, dre, dme, cel, ath, sce, ago, cal, spo, ecu, pfa, cho, ehi, eco, nme, hpy, bsu, lla, mge, mtu, syn, aae, mja, ape',
        'prok' : 'hsa, dme, ath, sce, pfa, eco, sty, hin, pae, nme, hpy, rpr, mlo, bsu, sau, lla, spn, cac, mge, mtu, ctr, bbu, syn, aae, mja, afu, pho, ape',
        'animalia' : 'hsa, ptr, rno, mmu, cjc, cge, ssc, bom, oaa, gga, mgp, asn, xla, dre, tru, pbi, acs, cmk, bfo, cin, sko, dme, dpo, api, isc, cel, aqu, tad, ola, phi, cbr, pps, cfa, spu',
        'plantae' : 'ath, aly, crb, brp, cit, tcc, vvi, csv, sly, osa, olu, ota, mis, cme, gsl, fve, gmx',
        'fungi' : 'hsa, dre, dme, sce, ago, cal, spo, ecu, pfa, cho, ehi, nme, hpy, bsu, lla, mge, mtu, syn, aae, mja, ape, cgr, clu, ncr, ssl, afm, pno, cne, mbr, ddi, tva, ncs, yli, mgr, aor, bze'}

mailid = int(runshell('ps -ef |grep KAAS.py|wc -l')) - 2 if args.m is None else args.m
em = '%02d@we-health.vip' %mailid

files = {'file' : (open(args.f, 'r').read())}
payload = {'prog' : args.s , 'text' : '' , 'uptype' : 'q_file' , 'qname' : args.q ,
       'mail' : em , 'dbmode' : 'manual' , 'org_list' : orglist[args.g] ,
       'way' : args.a , 'mode':'compute'}

if args.Nucleotide is True:
    payload['peptide2'] = 'n'

i = 0
while i < args.j :
    r = requests.post('http://www.genome.jp/kaas-bin/kaas_main', files = files, data = payload)
    flag = re.search('for confirmation', str(r.text))
    if flag :
        break
    else :
        i += 1
        time.sleep(10)

if not flag :
    print 'The job is not posted, please check !'
    sys.exit()

time.sleep(120)
mail = imaplib.IMAP4_SSL('imap.exmail.qq.com')
mail.login('xiaoliang.tian@we-health.vip', 'Whs0408bian')
# mail.list()
mail.select('inbox')
date = (datetime.date.today() - datetime.timedelta(1)).strftime('%d-%b-%Y')
result, data = mail.uid('search', None, '(SENTSINCE {date} SUBJECT "KAAS - Job request accepted" HEADER To "{em}")'.format(date=date, em=em))
latest_email_uid = data[0].split()[-1]
result, data = mail.uid('fetch', latest_email_uid, '(RFC822)')
raw_email = data[0][1]
email_message = email.message_from_string(raw_email)
email_body = email_message.get_payload(decode = True)      # [0].get_payload()
joburl = re.findall('(http.+)\(Submit\)', email_body)[0]
jobid = re.findall('id=(\d+)\&key', joburl)[0]
mail.close()
mail.logout()

print joburl

# i = 0
# while i < args.j :
#     try :

#     except urllib2.URLError :
#         i += 1
#         continue
#     else :
#         break

i = 0
while i < args.j :
    socket = urllib.urlopen(joburl).read()
    flag = re.search('is (already )*submitted', socket)
    if flag :
        break
    else :
        i += 1
        time.sleep(10)

if not flag :
    print 'The job is not submited, please check'
    sys.exit()

time.sleep(10)
url = joburl.replace('=submit', '=user')
while True:
    socket = urllib.urlopen(url).read()
    user = parselinks()
    user.feed(socket)
    num = user.table.index(jobid)
    if user.table[num+1] != 'complete':
        time.sleep(args.t)
    else:
        finput = open('query.ko','wb')
        finput.write(urllib.urlopen('http://www.genome.jp/tools/kaas/files/dl/' + jobid + '/query.ko').read())
        finput.close()
        break
