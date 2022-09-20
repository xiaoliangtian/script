for i in *.type; do perl /home/tianxl/pipeline/STR_tools/dantixing/erti_type.depth.pl -i $i -o test.txt -m 1 > $i.erti;done
for i in *.type; do perl /home/tianxl/pipeline/STR_tools/dantixing/siti_type.depth.pl -i $i -o test.txt -m 1 > $i.siti;done
paste *F_*.erti *M_*.erti *S_*.siti >  $1.siti
perl /home/tianxl/pipeline/STR_tools/dantixing/siti_pd_v6.pl -i $1.siti -o test.txt -f 1 -m 3 -s 5 > $1.siti.pd
for i in *.type; do perl /home/tianxl/pipeline/STR_tools/test_type_depth_5.pl -i $i -o test.txt -m 1 >$i.ty;done
paste *.type.ty > $1.ty
perl /home/tianxl/pipeline/STR_tools/dantixing/STR_fenxing_v3.pl -i $1.ty -o test.txt -f 1 -m 3 -s 5 > $1.ty.fenxing
