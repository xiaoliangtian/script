for i in *.type; do perl /home/tianxl/pipeline/STR_tools/dantixing/erti_type.depth.pl -i $i -o test.txt -m 1 > $i.erti;done
paste "$1"F_*.erti  "$1"M_*.erti "$1"S*.erti > $1.erti
perl /home/tianxl/pipeline/STR_tools/dantixing/erti.pd_v5.pl -i $1.erti -o test.txt -f 1 -m 3 -s 5 > $1.erti.pd
for i in *.type; do perl /home/tianxl/pipeline/STR_tools/test_type_depth_5.pl -i $i -o test.txt -m 1 >$i.ty;done
paste *.type.ty > $1.ty
perl /home/tianxl/pipeline/STR_tools/dantixing/STR_fenxing_v3.pl -i $1.ty -o test.txt -f 1 -m 3 -s 5 > $1.ty.fenxing
