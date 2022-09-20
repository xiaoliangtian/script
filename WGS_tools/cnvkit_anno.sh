sed -i 's/^chr//' $1.dedup.sorted.cns $1.dedup.sorted.cnr 
perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $1.dedup.sorted.cns $1.type $1.qianhe > $1.cnv
h=$1
perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl $1.cnv > "$h".band
perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".type > "$1".all.band
awk '{print $2":"$3"-"$4}' "$1".all.band | sed 's/^/chr/' - > $1.all.intervals
pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.all.intervals --out $1.all --noweb
sed -i 's/\.$/NoneGene/' $1.all.loci
python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated_v2.py   $1.all.loci > "$1".all.intervals.result
paste "$1".all.band  "$1".all.intervals.result > "$1".all.band_gene_v2.xls
awk '{print $2":"$3"-"$4}' "$h".band | sed 's/^/chr/' - > $h.intervals
awk '{print $2"\t"$3"\t"$4}' "$h".band | sed '/start/d' - > $h.bed
pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $h.intervals --out $h --noweb
sed -i 's/\.$/NoneGene/' $h.loci
python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated_v2.py  $h.loci > "$h".intervals.result
paste "$h".band  "$h".intervals.result > "$h".band_gene_v2.xls
rm "$1".band $1.intervals "$1".intervals.result $1.loci $1.log $1.all.loci $1.all.log "$1".all.intervals.result "$1".all.band $1.all.intervals 
              
Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $h.bed
paste "$h".band_gene_v2.xls $h.cnv_anno.txt > $h.band_gene_v2.cnv_anno.xls
perl /home/tianxl/pipeline/CNV-seq/result2lastType_v4.pl $h.band_gene_v2.cnv_anno.xls $h.cnv_anno.xlsx
rm "$h".band $h.intervals $h.bed $h.loci "$h".band_gene_v2.xls "$h".intervals.result $h.band_gene_v2.cnv_anno.xls $h.cnv_anno.txt $h.log 
