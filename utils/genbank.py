#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '1.0.0'
__date__='2015/07/03'
import sys
from Bio import SeqIO

if len(sys.argv) != 3:
    print "%s: *.gbk feature" % sys.argv[0]
    sys.exit()

genbank_file = sys.argv[1]
fna = open(sys.argv[2]+'.fna','w')
ffn = open(sys.argv[2]+'.ffn','w')
faa = open(sys.argv[2]+'.faa','w')
anno = open(sys.argv[2]+'.anno','w')
# rna = open(sys.argv[2]+'.rRNA','w')

for record in SeqIO.parse(genbank_file, 'genbank'):
    fna.write('>%s\n%s\n' %(record.id.split('.')[0],record.seq))
    for feature in record.features:
        if feature.type == 'CDS':
            if 'locus_tag' in feature.qualifiers:
                locus_tag = feature.qualifiers['locus_tag'][0]
            elif 'protein_id' in feature.qualifiers:
                locus_tag = feature.qualifiers['protein_id'][0]
            product = ''
            if 'product' in feature.qualifiers:
                product = feature.qualifiers['product'][0]
            cds = feature.extract(record.seq)
            ffn.write('>%s\n%s\n' %(locus_tag,cds))
            if 'translation' in feature.qualifiers:
                translation = feature.qualifiers['translation'][0]
                faa.write('>%s\n%s\n' %(locus_tag,translation))
            gene = ''
            if 'gene' in feature.qualifiers:
                gene = feature.qualifiers['gene'][0]
            anno.write('%s\t%s\t%s\t%s\t%s\n' %(locus_tag,record.id.split('.')[0],feature.location,product,gene))
        # if feature.type == 'rRNA':
        #     locus_tag = feature.qualifiers['locus_tag'][0]
        #     product = feature.qualifiers['product'][0]
        #     rRNA = feature.extract(record.seq)
        #     rna.write('>%s  %s\n%s\n' %(locus_tag,product,rRNA))

print locus_tag.split('_')[0],record.annotations['source']
