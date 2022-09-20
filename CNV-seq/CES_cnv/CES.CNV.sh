i=$1
cnvkit.py batch  -m amplicon $i.dedup.sorted.bam -r /home/tianxl/pipeline/CNV-seq/CES_cnv/my_reference200813.cnn   -d analyse/ -p 10
        wait
        mkdir analyse/
        cd analyse/
        sed -i 's/^chr//' $i.dedup.sorted.cns $i.dedup.sorted.cnr
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $i.dedup.sorted.cns $i.type $i.qianhe > $i.cnv
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $i.dedup.sorted.cnr $i.cnv $i.point
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".cnv > "$1".band
        awk '{print $2":"$3"-"$4}' "$1".band | sed 's/^/chr/' - > $1.intervals
        awk '{print $2"\t"$3"\t"$4}' "$1".band | sed '/start/d' - > $1.bed
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.intervals --out $1 --noweb
        sed -i 's/\.$/NoneGene/' $1.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $1.intervals $1.loci
        paste "$1".band  "$1".intervals.result > "$1".band_gene_v2.xls
        perl /home/tianxl/pipeline/CNV-seq/single_cnv_v2.pl $1.band_gene_v2.xls $1.point
        wait
        #for i in "$h"*X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
        wait
        Rscript /home/tianxl/pipeline/utils/CNV.R $i.point $i
