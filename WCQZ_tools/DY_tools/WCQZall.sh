#!/bin/bash
sh /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/cpi.sh $1 $2 $3 $4
sh /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/sim.sh $1 $2 $3 $4
sh /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/sim_1.sh $6 $5 $3 $4
sh /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/DY_tools/type.sh $1 $2 $3 $4 $7
sh /home/xiaoliang.tian/pipeline/tools/WCQZ_tools/WCQZ.sh 


