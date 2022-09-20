#!/bin/bash
for i in $1
 do perl /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/var_pos.type.pl -i $1 -o $1_type -f $2 -m $3 -s $4 -d 0 
done
