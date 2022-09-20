__author__ = 'Nie Xiaoting'
__version__ = '1.1.3'
__date__='2015/06/18'
'''1.1.3 add max hit num option'''
import sys
from Bio.Blast import NCBIXML
if len(sys.argv) != 4 and len(sys.argv) != 5:
    print '%s: blast.out.xml blast.tsv indent_cov max_hit_num' % sys.argv[0]
    sys.exit(2)
hitnum=''
handle=open(sys.argv[1],'rU')
fout=open(sys.argv[2],'w')
cutoff=float(sys.argv[3])
if len(sys.argv)==5:
    hitnum=int(sys.argv[4])

fout.write('Query Name\tQuery Length\tSbjct Length\tQuery Alignment\tSbjct Alignment\tAnnotation\tBit Score\tE Value\tIdentity\tIdentity_Rate\tQueryStart\tQueryEnd\tSubjectStart\tSubjectEnd\n')
for blast_record in NCBIXML.parse(handle):
    for alignment in blast_record.alignments:
        if hitnum and len(alignment.hsps)>hitnum:
            alignment.hsps=alignment.hsps[:hitnum]
        for hsp in alignment.hsps:
            qident=round(float(hsp.identities)/float(blast_record.query_letters)*100,2)
            if qident<cutoff:
                continue
            anno=alignment.hit_def
            if alignment.hit_id[:2]=='gi':
                anno=alignment.title
            indent=round(float(hsp.identities)/float(hsp.align_length)*100,2)
            sindet=round(float(hsp.identities)/float(alignment.length)*100,2)
            fout.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s/%s\t%s\t%s\t%s\t%s\t%s\n' %(blast_record.query,blast_record.query_letters,alignment.length,qident,sindet,anno,hsp.bits,hsp.expect,hsp.identities,hsp.align_length,indent,hsp.query_start,hsp.query_end,hsp.sbjct_start,hsp.sbjct_end))

