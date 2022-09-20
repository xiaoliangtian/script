sh /home/tianxl/pipeline/PGD_STR/STR_analyse_new_lowQual.sh 10
wait
cd analyse/
rm *.ty all.paternity.type  
for i in *.type; do h=${i/.type/}; perl /home/tianxl/pipeline/PGD_STR/test_type_depth_v6.pl -i $i -o test -m 1  > $h.ty ;done
wait
paste /home/tianxl/pipeline/PGD_STR/ref.type *.type > all.paternity.type
paste *.ty > all.test.ty
python /home/tianxl/pipeline/PGD_STR/var-stat_v2.py -i all.paternity.type
python /home/tianxl/pipeline/PGD_STR/var-statSameStat.py -i all.test.ty
grep '\%' var-report.txt > result.xls
sh /home/tianxl/pipeline/PGD_STR/PGD_paternity.sh
