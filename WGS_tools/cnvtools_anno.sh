h=${1/.cnv/}
perl /home/tianxl/pipeline/WGS_tools/pos2band_wgs.pl $1 > "$h".band
awk '{print $2":"$3"-"$4}' "$h".band | sed 's/^/chr/' - > $h.intervals
awk '{print $2"\t"$3"\t"$4}' "$h".band | sed '/start/d' - > $h.bed
pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $h.intervals --out $h --noweb
sed -i 's/\.$/NoneGene/' $h.loci
python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $h.intervals $h.loci
paste "$h".band  "$h".intervals.result > "$h".band_gene_v2.xls
#rm "$1".band $1.intervals "$1".intervals.result $1.loci $1.log $1.all.loci $1.all.log "$1".all.intervals.result "$1".all.band $1.all.intervals 
              
Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $h.bed
paste "$h".band_gene_v2.xls $h.cnv_anno.txt > $h.band_gene_v2.cnv_anno.xls
perl /home/tianxl/pipeline/CNV-seq/result2lastType_v3.pl $h.band_gene_v2.cnv_anno.xls $h.cnv_anno.xls
rm "$h".band $h.intervals $h.bed $h.loci "$h".band_gene_v2.xls "$h".intervals.result $h.band_gene_v2.cnv_anno.xls $h.cnv_anno.txt $h.log 
