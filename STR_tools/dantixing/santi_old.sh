for i in *.type; do perl /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/STR_284/dantixing/erti_type.depth.pl -i $i -o test.txt -m 1 > $i.erti;done
for i in *.type; do perl /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/STR_284/dantixing/santi_type.depth.pl -i $i -o test.txt -m 1 > $i.santi;done
paste *F_*.erti *M_*.erti *S_*.santi >  $1.santi
perl /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/STR_284/dantixing/santi_pd_v4.pl -i $1.santi -o test.txt -f 1 -m 3 -s 5 > $1.santi.pd
for i in *.type; do perl /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/test_type_depth_5.pl -i $i -o test.txt -m 1 >$i.ty;done
paste *.type.ty > $1.ty
perl /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/STR_284/dantixing/STR_fenxing_v2.pl -i $1.ty -o test.txt -f 1 -m 3 -s 5 > $1.ty.fenxing
