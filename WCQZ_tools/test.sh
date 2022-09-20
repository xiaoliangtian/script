#!/bin/bash
perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/my_PI.pl -i $1 -o $1.rate.cpi -f $2 -m $3 -s $4 -d 0
perl  /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/var_simality.pl -i $1 -o $1.sim -f $2 -m $3 -s $4 -d 0
perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/var_simality.pl -i $6 -o $6.sim_1 -f $5 -m $3 -s $4 -d 0
perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/var_pos.type.pl -i $1 -o $1_type -f $2 -m $3 -s $4 -d 0
for i in *.rate
do
  cat $i $i\_1 > $i.ka
  Rscript /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/kafang.R $i.ka > $i.out
  grep 'p-value' $i.out > $i.ka.last
  cat $i.ka $i.ka.last $i.cpi > $i.last.txt
done
