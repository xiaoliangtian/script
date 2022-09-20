#!/usr/bin/env python
# coding=utf-8
# pylint: disable=import-error

import os, sys, copy
import gzip
import argparse
import json
import traceback
import pandas as pd
from multiprocessing import Pool,Queue,Process

from Config import DIR_SET
from modules import dbQuery
from modules.MySqlConn import Mysql

# optional args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", help="input file")
parser.add_argument("-maf", "--minor_allele_frequency", type=float, help="minor allele frequency for filter snps[0.05]")
parser.add_argument("-f", "--results_dir", help="base file path")
parser.add_argument("-fh", "--fix_header", action="store_true", default=False, help="fix annovar file header")
parser.add_argument("--local", action="store_true", default=False, help="access local database instead of sql")
parser.add_argument("--excel", action="store_true", default=False, help="xlsx output")
parser.add_argument("--tab", action="store_true", default=False, help="tab txt output")
parser.add_argument("--panel", action="store_true", default=False, help="internal panel datebase")
parser.add_argument("--mito", action="store_true", default=False, help="mito panel datebase")
parser.add_argument("--omim", action="store_true", default=False, help="omim datebase")
parser.add_argument("--scut", type=float, default=0.8, help="spliceai cut-off, default 0.8")
parser.add_argument("--no_web", action="store_true", default=False, help="no cross over with remote databases")
parser.add_argument("--not_vcf", action="store_true", default=False, help="not annovar file from vcf")
parser.add_argument("--no_filter", action="store_true", default=False, help="do not filter var")
parser.add_argument("--debug", action="store_true", default=False, help="enter debug mode")
parser.add_argument("--multi", help="put mulitple samples' data into one file")
parser.add_argument("-nt", "--num_of_threads", type=int, default=10, help="process usage for whole task, default 10")
parser.add_argument("--chunks", type=int, default=10000, help="chunk size for every task, default 10000 ")
parser.add_argument("--suffix", default="whanno", help="suffix name, default 'whanno'")
args = parser.parse_args()

if args.minor_allele_frequency:
    maf = args.minor_allele_frequency
else:
    maf = 0.05

if args.results_dir:
    baseDir = args.results_dir
else:
    baseDir = './'

threads = args.num_of_threads

unform_chr = []
# function list
def sort_pos(item):
    if 'Start' in item:
        return (0, 0)
    else:
        chrList = item.split('\t')
        sort_item = chrList[0].replace("chr", '')
        pos_int = chrList[1]
        if sort_item == 'X':
            sort_key = 23
        elif sort_item == 'Y':
            sort_key = 24
        elif sort_item == 'MT' or sort_item == 'M':
            sort_key = 0
        else:
            try:
                sort_key = int(sort_item)
            except ValueError:
                if chrList[0] not in unform_chr:
                    print('[WARNNING] UnNormal chromosome tag:', chrList[0])
                    unform_chr.append(chrList[0])
                sort_key = 99
        return (sort_key, int(pos_int))

def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def all_same(items):
    return all(x == '.' for x in items)

def max_fre(snp, freIdx, addList):
    freList = []
    for i in freIdx:
        try:
            freList.append(float(snp[i]))
        except ValueError:
            freList.append(0)
    if len(addList) > 0:
        freList += addList
    return max(freList)

def fix_header(oldLine, file, mode):
    try:
        title = oldLine
        if mode == 'gz':
            with gzip.open(file, 'r') as raw:
                for line in raw:
                    line = line.decode("utf8")
                    if '#CHROM' in line:
                        title += '\tQUAL\tDP\t' + line.strip()
                        break
        elif mode == 'vcf':
            with open(file) as raw:
                for line in raw:
                    if '#CHROM' in line:
                        title += '\tQUAL\tDP\t' + line.strip()
                        break
        return title
    except:
        print ('raw vcf failed')

def access_genedb():
    outDict = {'mut': {}, 'site': {}, 'gene': {}}
    with open(DIR_SET['HGMD_PRO']) as genes:
        for ln in genes:
            line = ln.strip().split('\t')
            line = ['.' if x == '\\N' else x for x in line]
            chrPos = 'chr' + line[11] + ':' + line[12]
            mut = chrPos + ':' + line[13] + "-" + line[14]

            pubMedStr = ''
            if line[21] != '.':
                pubMedStr += line[21]
            if line[22] != '.':
                pubMedStr += ',' + line[22].replace(' ', '')

            mutInfo = '|'.join([line[2], pubMedStr, line[17], line[4], line[15] + ':' + line[16], line[20], line[19]])

            if mut not in  outDict['mut'].keys():
                outDict['mut'][mut] = []
            outDict['mut'][mut].append(mutInfo)

            if chrPos not in outDict['site'].keys():
                outDict['site'][chrPos] = []
            outDict['site'][chrPos].append(mutInfo)

            if line[4] not in outDict['gene'].keys():
                outDict['gene'][line[4]] = {"diseases": []}
            if line[19] not in outDict['gene'][line[4]]['diseases']:
                outDict['gene'][line[4]]['diseases'].append(line[19])
            if "ref_seq" not in outDict['gene'][line[4]].keys():
                outDict['gene'][line[4]]['ref_seq'] = line[15]
    return outDict

def access_panel(file, lineNum):
    panelDB = {}
    with open(file, 'r') as panel:
        for ln in panel:
            line = ln.strip().split('\t')
            if lineNum > 0:
                try:
                    annoGene = line[lineNum]
                except IndexError:
                    annoGene = line[8]
                lineInfo = line[12].replace('"', '') + '\t' + line[13].replace('"', '')
            else:
                annoGene = line[0]
                lineInfo = line[1]
            if annoGene not in panelDB.keys():
                panelDB[annoGene] = lineInfo
            else:
                geneDis = panelDB[annoGene].split(';')
                if lineInfo not in geneDis:
                    panelDB[annoGene] += ';' + lineInfo
    return panelDB

def nor_str(item):
    if item.strip() == '.':
        return False
    else:
        return True

def form_data(snpLine, keys):
    tmp_dict = {}
    title = keys
    snpInfo = snpLine.split('\t')
    if len(title) != len(snpInfo):
        print(snpInfo)
    for i in range(0, len(title)):
        try:
            snpInfo[i] = float(snpInfo[i])
        except:
            pass
        tmp_dict[title[i]] = snpInfo[i]
    return tmp_dict

def anno_panel(gene, panel, isLocal, count, panelName=None):
    if isLocal:
        if gene not in panel.keys() or gene == '.':
            total = 0
            s = []
            while total < count:
                s.append('.')
                total += 1
            return ('\t'.join(s))
        else:
            return panel[gene]
    else:
        return dbQuery.panel_query(mysql.getAll, panelName, gene)

def filtered_rules(snpLine):
    global excList
    if nor_str(snpLine[HGMDIdx]):
        return True
    elif nor_str(snpLine[clivarIdx]) and snpLine[clivarIdx].strip() not in ('Benign', 'Likely_benign', 'Benign|Likely_benign', 'Benign/Likely_benign'):
        return True
    elif nor_str(snpLine[snvIdx]) and float(snpLine[snvIdx]) >= 0.6 and nor_str(snpLine[omimIdx]):
        return True
    elif nor_str(snpLine[omimIdx]) and ('exonic' in snpLine[funcIdx] or \
    'splicing' in snpLine[funcIdx]) and snpLine[exFuncIdx] != 'synonymous SNV' and \
    snpLine[clivarIdx].strip() not in ('Benign', 'Likely_benign', 'Benign|Likely_benign', 'Benign/Likely_benign'):
        return True
    elif snpLine[rsIdx] in excList:
        return True
    else:
        return False

def add_rules(snpLine):
    clivarStr = snpLine[clivarIdx].strip()
    if nor_str(snpLine[HGMDIdx]):
        return True
    if nor_str(clivarStr) and clivarStr not in ('Benign', 'Likely_benign', 'Benign|Likely_benign', 'Benign/Likely_benign'):
        return True
    else:
        return False

def is_indel(ref, alt):
    if len(ref) == 1 and len(alt) == 1 and '-' not in (ref, alt):
        return False
    else:
        return True

# variables
isRunning = True
rawDir = os.path.join(baseDir, 'RAW_VCF')
hgmdDataSet = {}
eyeDataSet, rpDataSet, fevrDataSet = {}, {}, {}
mitoDataSet, endoDataSet, nervDataSet = {}, {}, {}
aborDataSet, aborCoreDataSet = {}, {}
results, filterRes, additionRes = [], [], []
dfRes, dfFilRes, dfAddRes = [], [], []
sfGenes = ['BRCA1','BRCA2','TP53','STK11','MLH1','MSH2','MSH6','PMS2','APC','MUTYH','VHL','MEN1','RET','PTEN','RB1','SDHD','SDHAF2','SDHC','SDHB','TSC1','TSC2','WT1','NF2','COL3A1','FBN1','TGFBR1','TGFBR2','SMAD3','ACTA2','MYH11','MYBPC3','MYH7','TNNT2','TNNI3','TPM1','MYL3','ACTC1','PRKAG2','GLA','MYL2','LMNA','RYR2','PKP2','DSP','DSC2','TMEM43','DSG2','KCNQ1','KCNH2','SCN5A','LDLR','APOB','PCSK9','RYR1','CACNA1S','BMPR1A','SMAD4','ATP7B','OTC']

def main_anno(chunkList):
    global newHeads
    mysql = Mysql()
    chunkRes, chunkFilRes, chunkAddRes = [], [], []
    chunkFormRes, chunkFormFilRes, chunkFormAddRes = [], [], []
    snpCount = 0
    for line in chunkList:
        snpLine = line.strip()
        snp = snpLine.split('\t')
        geneFunc = snp[5].strip()
        gene = snp[6].split(';')
        chrSite = snp[0] + ':' + snp[1]
        mutation = chrSite + ':' + snp[3] + '-' + snp[4]
        rsCode = '.'
        addList = []
        isMafFit = False
        isAddFit = False
        if args.debug:
            print('origin:', snp, len(snp))

        # multiple data will be got from local server database
        try:
            chrNum = snp[chrIdx].replace('chr','')
            pos = snp[posIdx]
            ref = snp[refIdx]
            altList = snp[altIdx].split(',')
        except:
            chrNum = snp[0].replace('chr','')
            pos = snp[1]
            ref = snp[3]
            altList = snp[4].split(',')

        if len(altList) <= 1:
            mutation = snp[0] + ':' + pos + ':' + ref + '-' + altList[0]

        vcfSite = snp[0] + ':' + pos
        if len(altList) > 1:
            alt = altList[snpCount]
            if snpCount == (len(altList) - 1):
                snpCount = 0
            else:
                snpCount += 1
        else:
            alt = altList[0]

        if not args.no_web:
            dataOut = dbQuery.multi_query(mysql.getAll, chrNum, pos, ref, alt)
            if dataOut:
                if dataOut['all_fre'] is not None:
                    addList.append(dataOut['all_fre'])
                if dataOut['eas_fre'] is not None:
                    addList.append(dataOut['eas_fre'])
                if dataOut['rs'] is not None:
                    rsCode = str(dataOut['rs'].decode('utf-8'))
                    if rsCode == 'NULL':
                        rsCode == '.'

        snp.insert(rsIdx, rsCode)
        maxFre = max_fre(snp, freLines, addList)

        # HGMD annotation
        if mutation not in hgmdDataSet['mut'].keys():
            snp.append('.')
        else:
            snp.append(';'.join(hgmdDataSet['mut'][mutation]))

        if vcfSite not in hgmdDataSet['site'].keys():
            snp.append('.')
        else:
            snp.append(';'.join(hgmdDataSet['site'][vcfSite]))

        gene_dis = []
        ref_seq = '.'
        for item in gene:
            if (item != '.') and (item in hgmdDataSet['gene'].keys()):
                ref_seq = hgmdDataSet['gene'][item]['ref_seq']
                gene_dis.append(';'.join(hgmdDataSet['gene'][item]['diseases']))
            else:
                gene_dis.append('.')
        if all_same(gene_dis):
            geneDisStr = '.'
        else:
            geneDisStr = ';'.join(gene_dis)
        snp.append(geneDisStr)

        if ref_seq != '.':
            if snp[aaRefIdx] not in ('.', "UNKNOWN"):
                transcripts = snp[aaRefIdx].split(',')
                for item in transcripts:
                    trans_id = item.split(':')[1]
                    if trans_id in ref_seq:
                        ref_seq = item
                        break
            elif snp[geneRefIdx] not in ('.', "UNKNOWN"):
                transcripts = snp[geneRefIdx].split(';')
                for item in transcripts:
                    trans_id = item.split(':')[0]
                    if trans_id in ref_seq:
                        ref_seq = item
                        break
        snp.append(ref_seq)

        # omim annotation
        if args.omim:
            isOmimGene = False
            for item in gene:
                if item != '.' and item in omimDataSet.keys():
                    omimAnno = omimDataSet[item]
                    isOmimGene = True
                    break
            if isOmimGene:
                snp += omimAnno.split('\t')
            else:
                snp += ['.', '.']

        # count preds
        if len(predLines) > 0:
            predHigh = 0
            predLow = 0
            for pred in predLines:
                if snp[pred] and (snp[pred] != '.'):
                    if (snp[pred] == 'D') or (snp[pred] == 'A') or (snp[pred] == 'H'):
                        predHigh += 1
                    else:
                        predLow += 1
            if predHigh > 0 or predLow > 0:
                predCounts =  predHigh + predLow
                predRatio = round((predHigh/predCounts)*100, 2)
                predStats = str(predRatio) + '%\t' + str(predHigh) + '|' + str(predCounts)
            else:
                predStats = '.\t.'
            snp.append(predStats)

        if not args.no_filter and args.omim and ((maxFre > 0.01 and add_rules(snp))):
            isAddFit = True
        elif maxFre <= maf or (rsCode in excList):
            isMafFit = True

        if isAddFit or isMafFit:

            if not args.no_web:
                # gnomad freq access
                if dataOut and dataOut['all_fre'] is not None:
                    allGnomad = str(dataOut['all_fre']) + '\t' + str(dataOut['all_hom'])
                    snp.append(allGnomad)
                else:
                    snp.append('.\t.')

                if dataOut and dataOut['eas_fre'] is not None:
                    easGnomad = str(dataOut['eas_fre']) + '\t' + str(dataOut['eas_hom'])
                    snp.append(easGnomad)
                else:
                    snp.append('.\t.')

                # local freq access
                isHighLocal = False
                if dataOut and dataOut['local_fre']:
                    freqStr = str(dataOut['local_fre']['af']) + '\t' + str(dataOut['local_fre']['ac']) + '/' + str(dataOut['local_fre']['an'])
                    if dataOut['local_fre']['af'] >= 0.02:
                        isHighLocal = True
                    snp.append(freqStr)
                else:
                    snp.append('.\t.')

                # spliceai data access
                maxSplice = 0
                if dataOut and dataOut['splice']:
                    spliceRes = dataOut['splice'][0]

                    if len(dataOut['splice']) > 1:
                        for item in dataOut['splice']:
                            if item[-1] in gene:
                                spliceRes = item
                                break

                    maxSplice = max(spliceRes[:4])
                    spliceList = [ str(x) for x in spliceRes[:4] ]
                    spliceStr = '\t'.join(spliceList)
                    snp.append(spliceStr)
                else:
                    snp.append('\t'.join(['.', '.', '.', '.']))

                # find positive snp from remote database
                if dataOut and dataOut['samples']:
                    snp.append(dataOut['samples'])
                else:
                    snp.append('.')

            # internal panel annotation
            if args.panel:
                eyeAnno = '.'
                rpAnno = '.'
                fevrAnno = '.'
                endoAnno = '.'
                nervAnno = '.'
                for item in gene:
                    if item != '.' and item in eyeDataSet.keys():
                        eyeAnno = eyeDataSet[item]
                    if item != '.' and item in rpDataSet.keys():
                        rpAnno = rpDataSet[item]
                    if item != '.' and item in fevrDataSet.keys():
                        fevrAnno = fevrDataSet[item]
                    if item != '.' and item in endoDataSet.keys():
                        endoAnno = endoDataSet[item]
                    if item != '.' and item in nervDataSet.keys():
                        nervAnno = nervDataSet[item]
                panelAnnoStr = '\t'.join([eyeAnno, rpAnno, fevrAnno, endoAnno, nervAnno])
                snp.append(panelAnnoStr)

            if args.mito and snp[0] in ('chrMT', 'chrM'):
                mitoChange = ''
                if snp[3].strip() != '-':
                    mitoChange = snp[3].strip()
                mitoChange += snp[1].strip() + snp[4].strip()
                mitoAnno = anno_panel(mitoChange, mitoDataSet, args.local, 1, 'mito')
                snp.append(mitoAnno)
            elif args.mito:
                snp.append('.')

            # dup regions annotation
            dupRegion = '.'
            if gene[0] in dupList.keys():
                posList = dupList[gene[0]].split(':')[1].split('-')
                if int(posList[0]) <= int(pos) <= int(posList[1]):
                    dupRegion = dupList[gene[0]]
            snp.append(dupRegion)

            # adjust interVar display
            intervarList = []
            filterSnp = copy.deepcopy(snp)
            if len(intervarIdx) > 0:
                intervarIdx.sort()
                for idx in intervarIdx:
                    try:
                        if int(snp[idx]) == 1 :
                            intervarList.append(heads[idx])
                    except ValueError:
                        continue
                del snp[intervarIdx[0]:intervarIdx[-1]+1]
                snp[(pvsIdx-1)] = snp[(pvsIdx-1)].strip().replace(' ', '_')
                if len(intervarList) > 0:
                    snp.insert(pvsIdx, '|'.join(intervarList))
                else:
                    snp.insert(pvsIdx, '.')
            if args.multi:
                snp.insert(0, sampleName.split('.')[0].split('_')[0])
            newSnpLine = '\t'.join(snp)

            # filter with splice_ai
            isSpliceai = False
            if geneFunc in ('intronic', 'UTR3', 'UTR5') and maxSplice >= args.scut:
                isSpliceai = True

            chunkRes.append(newSnpLine)
            if args.debug:
                print('process:', snp, len(snp))
            if args.excel:
                exlData = form_data(newSnpLine, newHeads)
                chunkFormRes.append(exlData)

            if not args.no_filter:
                # filter with additional rules
                if isAddFit:
                    chunkAddRes.append(newSnpLine)
                    if args.excel:
                        chunkFormAddRes.append(exlData)

                # filter with filtered rules
                if args.omim and ((maxFre <= 0.01 and filtered_rules(filterSnp)) or (rsCode in excList)) or isSpliceai:
                    isExceptGene = False
                    for item in gene:
                        if item in ("HTT","ATXN1","ATXN7","ATXN2","ATXN3","CACNA1A","ATXN8OS","PPP2R2B", "HLA") or 'HLA-' in item:
                            isExceptGene = True
                    if not isExceptGene and not (isHighLocal and is_indel(snp[3], snp[4])):
                        chunkFilRes.append(newSnpLine)
                        if args.excel:
                            chunkFormFilRes.append(exlData)

    mysql.dispose()
    return (chunkRes, chunkFilRes, chunkAddRes, chunkFormRes, chunkFormFilRes, chunkFormAddRes)

if __name__ == '__main__':
    print ('maf set:', maf)
    if not args.local and args.mito:
        sys.exit('Error: no mito database in cloud service for now')

    with open(DIR_SET['EXCLUDE_LIST_PANEL'], 'r') as j:
        excList = list(json.load(j).keys())
    print ('Num of exception snps in database:', len(excList))

    with open(DIR_SET['DUP_REGION_BP'], 'r') as j:
        dupList = json.load(j)
    print ('Num of dup regions from bp in database:', len(dupList))

    if 'annovar-files' in args.input:
        file_name = os.path.join(baseDir, args.input)
    else:
        file_name = os.path.join(baseDir, 'annovar-files', args.input)

    fileName = os.path.basename(file_name)

    # handle file head
    totalLines = []
    with open(file_name) as f:
        oldLine = f.readline().strip()
        omimDataSet = access_panel(DIR_SET['OMIM_CN'], 14)
        sampleName = fileName.split('.anno.hg19_multianno')[0]
        newLine = oldLine
        if args.fix_header:
            rawName = sampleName.split('_')[0]
            print(rawName)
            for rawVcf in os.listdir(rawDir):
                nameList = rawVcf.split('.')
                if rawName in nameList[0] and nameList[-1] in ('gz', 'vcf'):
                    rawFile = os.path.join(rawDir, rawVcf)
                    newLine = fix_header(oldLine, rawFile, nameList[-1])
                    print(oldLine,rawVcf,rawFile,nameList[-1])
                    print ('header fixed from RAW vcf!')
                    break
        elif not args.not_vcf:
            newLine = oldLine + '\tQUAL\tDP\t#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t' + sampleName

        newLine += '\tmut_dis\tsite_dis\tgene_dis\tref_seq'

        if args.local:
            eyeDataSet = access_panel(DIR_SET['EYE_PANEL'], 0)
            rpDataSet = access_panel(DIR_SET['RP_LCA_PANEL'], 0)
            fevrDataSet = access_panel(DIR_SET['FEVR_PANEL'], 0)
            endoDataSet = access_panel(DIR_SET['ENDO_PANEL'], 0)
            nervDataSet = access_panel(DIR_SET['NEVR_PANEL'], 0)
            mitoDataSet = access_panel(DIR_SET['MITO_PANEL'], 0)
            hgmdDataSet = access_genedb()

        printStr = 'geneDb '

        if args.omim:
            newLine += '\tomim\tomim_cn\tpred_ratio\tpred_stats'
            printStr += 'OMIM pred_stat '

        if not args.no_web:
            newLine += '\tall_gnomad\tall_hom\teas_gnomad\teas_hom\tlocal_fre\tfre_count\tDS_AG\tDS_AL\tDS_DG\tDS_DL\tlocal_var'
            printStr += 'gnomad local_freq '

        if args.panel:
            newLine += '\teye\tRP/LCA\tFEVR\tendo\tnerv'
            printStr += 'internal_panel(eye,endo,nerv) '

        if args.mito:
            newLine += '\tMito'
            printStr += 'Mito_panel '

        newLine += '\tdup_region'
        print('Databases annotated:', printStr)

        heads = newLine.split('\t')
        intervarHeads = ["PVS1", "PS1", "PS2", "PS3", "PS4", "PM1", "PM2", "PM3", "PM4", "PM5", "PM6", "PP1", "PP2", "PP3", "PP4", "PP5", "BA1", "BS1", "BS2", "BS3", "BS4", "BP1", "BP2", "BP3", "BP4", "BP5", "BP6", "BP7"]
        intervarIdx = []
        predLines = []
        freLines = []

        # get idx of specific column
        rsIdx = 10
        heads.insert(rsIdx, 'dbSNP')
        for head in heads:
            if head == 'Func.refGene':
                funcIdx = heads.index(head)
                print('funcIdx:', funcIdx)
            elif head == 'ExonicFunc.refGene':
                exFuncIdx = heads.index(head)
                print('exFuncIdx:', exFuncIdx)
            elif head == 'GeneDetail.refGene':
                geneRefIdx = heads.index(head)
                print('geneRefIdx:', geneRefIdx)
            elif head == 'AAChange.refGene':
                aaRefIdx = heads.index(head)
                print('aaRefIdx:', aaRefIdx)
            elif '1000g2015aug' in head or 'gnomAD' in head:
                freLines.append(heads.index(head))
            elif head == 'dbscSNV_ADA_SCORE':
                snvIdx = heads.index(head)
                print('snvIdx:', snvIdx)
            elif head == 'CLNSIG':
                clivarIdx = heads.index(head)
                print('clivarIdx:', clivarIdx)
            elif head == 'mut_dis':
                HGMDIdx = heads.index(head)
                print('HGMDIdx:', HGMDIdx)
            elif args.omim and head == 'omim':
                omimIdx = heads.index(head)
                print('omimIdx:', omimIdx)
            elif args.omim and '_pred' in head:
                predIdx = heads.index(head)
                if predIdx not in predLines:
                    predLines.append(predIdx)
            elif head in intervarHeads:
                interIdx = heads.index(head)
                if head == 'PVS1':
                    pvsIdx = interIdx
                if interIdx not in intervarIdx:
                    intervarIdx.append(interIdx)
            elif head == 'Otherinfo':
                otherIdx = heads.index('Otherinfo')
                chrIdx = otherIdx + 2
                posIdx = chrIdx + 1
                refIdx = posIdx + 2
                altIdx = refIdx + 1

        print ('maf idx:', freLines)
        print ('predIdx:', predLines)
        print ('intervarIdx:', intervarIdx)
        if args.debug:
            print('head:', heads, len(heads))

        # adjust heads display
        newHeads = copy.deepcopy(heads)
        if len(intervarIdx) > 0:
            intervarIdx.sort()
            del newHeads[intervarIdx[0]:intervarIdx[-1]+1]
            newHeads.insert(pvsIdx, 'InterVar_proof')

        if args.multi:
            newHeads.insert(0, 'sample')
        results.insert(0, '\t'.join(newHeads))
        additionRes.insert(0, '\t'.join(newHeads))
        filterRes.insert(0, '\t'.join(newHeads))

        totalLines = list(chunks(f.readlines(), args.chunks))
        print('Total List:', len(totalLines), '\nChunk Size:', args.chunks, '\nMin Size:', len(totalLines[-1]))

    if len(totalLines) > 0:
        pool = Pool(processes = threads)
        poolRes = pool.map(main_anno, totalLines)
        for result in poolRes:
            results += result[0]
            filterRes += result[1]
            additionRes += result[2]
            if args.excel:
                dfRes += result[3]
                dfFilRes += result[4]
                dfAddRes += result[5]

        pool.close()
        pool.join()

    isRunning = False
    print(len(results)-1, len(filterRes)-1, len(additionRes)-1)
    if args.multi:
        outName = tar_files[0].split('.')[0].split('_')[0] + '-' + tar_files[-1].split('.')[0].split('_')[0] + '.' + args.suffix
    else:
        outName = fileName.split('.')[0] + '.' + args.suffix
    print(outName)
    results = sorted(results, key=sort_pos)
    filterRes = sorted(filterRes, key=sort_pos)
    additionRes = sorted(additionRes, key=sort_pos)

    if args.excel:
        # secondary gene annotation
        def highlight_gene(data):
            for gene in sfGenes:
                if data == gene:
                    return 'color: #DC143C'
            return ''

        def highlight(data):
            rowData = pd.Series(data, index=data.index)
            if rowData['CLNSIG'] in ('Pathogenic', 'Likely_pathogenic', 'Pathogenic/Likely_pathogenic'):
                return pd.Series('background-color: {}'.format('#ddd9c4'), rowData.index)
            elif rowData['local_var'] != '.':
                return pd.Series('background-color: {}'.format('#ffff00'), rowData.index)
            else:
                return pd.Series('', rowData.index)

        def generate_xlxs(data, filename, filData, addData):
            df = pd.DataFrame(data, columns=data[0].keys())
            df.sort_values(['Chr', 'Start'], ascending=[True, True])
            writer = pd.ExcelWriter(filename, engine='xlsxwriter')
            writer.book.use_zip64()
            if len(filData) > 0:
                df_filter = pd.DataFrame(filData, columns=filData[0].keys())
                df_filter.sort_values(['Chr', 'Start'], ascending=[True, True])
                df_filter.style.\
                    applymap(highlight_gene, subset=['Gene.refGene']).\
                    apply(highlight, axis=1).\
                    to_excel(writer,'filtered', index=False)

                worksheet1 = writer.sheets['filtered']
                worksheet1.autofilter('A1:DZ1')
                worksheet1.freeze_panes(1, 0)
                worksheet1.set_column(21, 86, None, None, {'hidden': True})
                worksheet1.set_column(91, 91, None, None, {'hidden': True})
                worksheet1.set_column(93, 98, None, None, {'hidden': True})

            if len(addData) > 0:
                df_add = pd.DataFrame(addData, columns=addData[0].keys())
                df_add.sort_values(['Chr', 'Start'], ascending=[True, True])
                df_add.style.\
                    applymap(highlight_gene, subset=['Gene.refGene']).\
                    to_excel(writer,'addition', index=False)

            df.style.\
                applymap(highlight_gene, subset=['Gene.refGene']).\
                to_excel(writer,'standard', index=False)

            worksheet2 = writer.sheets['standard']
            worksheet2.autofilter('A1:FA1')
            worksheet2.freeze_panes(1, 0)
            worksheet2.set_column(21, 86, None, None, {'hidden': True})
            worksheet2.set_column(91, 91, None, None, {'hidden': True})
            worksheet2.set_column(93, 98, None, None, {'hidden': True})

            writer.save()

        xl_output = os.path.join(baseDir, outName + '.xlsx')
        generate_xlxs(dfRes, xl_output, dfFilRes, dfAddRes)

    if args.tab:
        filResults = '\n'.join(filterRes)
        output = os.path.join(baseDir, outName + '.txt')
        outResults = '\n'.join(results)
        with open(output, 'w', encoding='utf-16') as text_file:
            text_file.write(outResults)
        if len(filterRes) > 1:
            filResults = '\n'.join(filterRes)
            filOutput = os.path.splitext(output)[0] + '.filtered.txt'
            with open(filOutput, 'w', encoding='utf-16') as text_file:
                text_file.write(filResults)
        if len(additionRes) > 1:
            addResults = '\n'.join(additionRes)
            addOutput = os.path.splitext(output)[0] + '.addition.txt'
            with open(addOutput, 'w', encoding='utf-16') as text_file:
                text_file.write(addResults)
