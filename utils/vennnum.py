__author__ = 'Nie Xiaoting'
__version__ = '1.0.0'
__date__='2015/11/05'

import sys

if len(sys.argv) != 3:
    print '%s: venn.table venn.num.table' % sys.argv[0]
    sys.exit(2)

fin=open(sys.argv[1],'rU')
fout=open(sys.argv[2],'w')

header=fin.readline()
fout.write(header)
for line in fin:
    word=line.strip().split('\t')
    a=map(int,word[1:])
    for i in range(max(a)):
        fout.write('%s_s%s' %(word[0],i))
        for j in range(len(a)):
            if a[j]>0:
                fout.write('\t1')
                a[j]-=1
            else:
                fout.write('\t0')
        fout.write('\n')
fin.close()
fout.close()
