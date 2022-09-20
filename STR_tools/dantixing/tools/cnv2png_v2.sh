#perl /mnt/workshop/SC/project/WGS/180726-txl_180725_NB502022_0051_AH5YCYAFXY/CNV/log2Totwo.pl $1 > $1.1
#perl /mnt/workshop/SC/project/WGS/180726-txl_180725_NB502022_0051_AH5YCYAFXY/CNV/need.cnv.list.pl /home/xiaoliang.tian/pipeline/tools/SC_tools/need.list $1.1 $1.qianhe > $1.need
#Rscript /home/xiaoliang.tian/pipeline/tools/STR_misa_tools/STR_284/dantixing/test.R $1.need $1.need > $1.result
perl /mnt/workshop/SC/project/WGS/180726-txl_180725_NB502022_0051_AH5YCYAFXY/CNV/pos2qu.pl $1 > $1.band
awk '{print $2":"$3"-"$4}' $1 > $1.intervals
sed -i '/chr\:Inf/d' $1.intervals
sed -i "/chr\tInf/d" $1.band
pseq . loc-intersect --group refseq --locdb /home/xiaoliang.tian/software/plinkseq/hg19/locdb --file $1.intervals --out $1 --noweb
cat /mnt/workshop/SC/project/WGS/180726-txl_180725_NB502022_0051_AH5YCYAFXY/CNV/header1 $1.loci > $1.loci.1
python /home/xiaoliang.tian/software/ginkgo/uploads/180822_NB502022_0067_AH7WJVAFXY_100K/cnv-annotated.py $1.intervals $1.loci 
paste $1.band $1.intervals.result > $1.band_gene_v2.xls

