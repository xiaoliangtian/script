awk '{print $1"\t"$2"\t"$3}' SegBreaks > SegBreaks.3
for i in *.bam.txt; do paste SegBreaks.3 $i > $i.1;done
for i in *bam.txt.1; do perl ~/software/ginkgo/uploads/new_run_123/gingko2cnvseq.pl $i > $i.2;done
sed -i "s/'/\"/g" *.txt.1.2
for i in *bam.txt.1.2; do perl /mnt/workshop/SC/project/WGS/180726-txl_180725_NB502022_0051_AH5YCYAFXY/CNV/need.cnv.list.pl /home/xiaoliang.tian/pipeline/tools/SC_tools/need.list $i $i.qianhe > $i.3;done
sed -i "s/'/\"/g" *.txt.1.2.3
