#!/bin/bash
for i in $1
 do perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/DY_tools/var_pos.type_dy.pl -i $1 -o $1_type -f $2 -m $3 -m2 $7 -s $4 -d 0 
done
