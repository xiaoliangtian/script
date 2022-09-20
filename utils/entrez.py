#!/usr/bin/env python
__author__ = 'Nie Xiaoting'
__version__ = '1.0.0'
__date__='2015/10/25'

import sys,os
from Bio import Entrez
if len(sys.argv) != 2:
    print '%s: acclist ' %sys.argv[0]
    sys.exit()

accs         = sys.argv[1].split(',')
db           = 'nuccore'
Entrez.email = 'next1014@gmail.com'
handle       = Entrez.esearch(db=db,term=' '.join(accs))
giList       = Entrez.read(handle)['IdList']

for i in range(len(accs)):
    filename=accs[i]+'.gbk'
    if not os.path.isfile(filename):
        out_handle = open(filename, 'w')
        net_handle = Entrez.efetch(db=db,id=giList[i],rettype='gbwithparts',retmode='text')
        out_handle.write(net_handle.read())
        out_handle.close()
        net_handle.close()
