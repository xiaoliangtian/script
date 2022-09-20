#!/usr/bin/env python
# coding=utf-8
# pylint: disable=import-error

import os, sys
configDir = '/opt/seqtools/source/wh-tools/src'
sys.path.append(configDir)
from modules.MySqlConn import Mysql

if len(sys.argv) > 1:
    fqDir = sys.argv[1]
else:
    fqDir = './'

mysql = Mysql()

for file in os.listdir(fqDir):
    if '.fastq.gz.raw' in file:
        pass
    elif '_R1.fastq.gz' in file and ('LCW' in file or 'CNV' in file):
        fileName = file.split('.')[0].split('_')[0]
    elif '_R1_001.fastq.gz' in file and 'LCW' in file:
        fileName = file.split('.')[0].split('_')[0]
    else:
        fileName = ''

    if fileName:
        sample_num = '__00' + fileName.split('-')[1]
        query = "SELECT 家系编号 fam_code FROM sample.gene_test_v1 WHERE 条形码 like '" + sample_num + "'"
        queryRes = mysql.getAll(query)
        if queryRes:
            famCode = queryRes[0]['fam_code'].decode('utf-8')
            newFileName = famCode + '[' + fileName + ']'
            print(fileName, newFileName)
            os.system(' '.join(['rename', fileName, newFileName, fileName+'*']))
        else:
            print('can\'t find this code in database:', fileName)

mysql.dispose()
