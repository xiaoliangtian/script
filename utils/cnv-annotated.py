#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

inputFile = sys.argv[1]
geneFile = sys.argv[2]
omimFile = '/data/local/internal/omim_gene_pheno_cn.txt'

def access_omim(filename):
    items = {}
    with open(filename) as omim:
        omim.readline()
        for line in omim:
            line = line.strip()
            lines = line.split('\t')
            if len(lines) > 7:
                gene = lines[14]
                if gene not in items.keys():
                    items[gene] = []
                phenoStr = lines[13]
                items[gene].append(phenoStr)
    return items

def access_loc(filename):
    items = {}
    omim_db = access_omim(omimFile)
    with open(filename) as locFile:
        for line in locFile:
            line = line.strip().split('\t')
            loc = line[0].replace('..', '-')
            if loc not in items.keys():
                items[loc] = line[1] + '\t' + line[2]
            genes = line[2].split('|')
            geneList = []
            for gene in genes:
                if gene in omim_db.keys():
                    genePheno = gene + '(' + ', '.join(omim_db[gene]) + ')'
                    geneList.append(genePheno)
            if len(geneList) >= 0:
                geneStr = '|'.join(geneList)
                items[loc] = line[1] + '\t' + line[2] + '\t' + str(len(geneList)) + '\t' + geneStr
        return items

res = []
loc_db = access_loc(geneFile)

with open(inputFile) as inputs:
    header = inputs.readline().strip() + '\tgene_num\tgene_name\tomim_num\tgene_pheno'
    res.append(header)
    for line in inputs:
        line = line.strip()
        lines = line.split('\t')
        loc = lines[0]
        if loc in loc_db.keys():
            line += '\t' + loc_db[loc]
            res.append(line)

outResults = '\n'.join(res)
cnvFile = inputFile.split('/')[-1] + '.result'
with open(cnvFile, 'w') as outfile:
    outfile.write(outResults)
