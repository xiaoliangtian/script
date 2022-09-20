perl /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/var_flt_qzjbeifen1.pl -i $1 -o $1.F -f $2 -m $3 -s $4 -d 0 
perl /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/var_flt_qzj_danbeixing.pl -i $1.F -o test.txt -f $2 -m $3 -s $4 -s2 $5 -d 0 > $1.F.result
perl /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/var_flt_qzjbeifen1.pl -i $1 -o $1.M -f $3 -m $2 -s $4 -d 0
perl /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/var_flt_qzj_danbeixing_f.pl -i $1.M -o test.txt -f $2 -m $3 -s $4 -s2 $5 -d 0 > $1.M.result
