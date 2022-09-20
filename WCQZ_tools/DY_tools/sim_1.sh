#!/bin/bash
for i in $1
do perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/var_simality.pl -i $1 -o $1.sim_1 -f $2 -m $3 -s $4 -d 0 
done
