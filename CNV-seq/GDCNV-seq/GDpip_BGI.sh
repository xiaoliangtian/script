#/bin/bash
if [ $2 == '1M' ];then 
        mkdir  -p  analyse
        mkdir  -p  1M/result
        cp result/Mapping/Mapping.xls 1M/
	cnvkit.py batch $1.dedup.sorted.bam -r /home/tianxl/pipeline/CNV-seq/GDCNV-seq/Xtenref/1M/my_reference_1Mnext500.cnn    -d analyse/ -p 10 
elif [ $2 == '100K' ];then
        mkdir  -p  analyse
        mkdir  -p  100K/result
        cp result/Mapping/Mapping.xls 100K/
        cnvkit.py batch $1.dedup.sorted.bam -r  /home/tianxl/pipeline/CNV-seq/GDCNV-seq/BGIse100ref/reference_25K.cnn   -d analyse/ -p 10
elif [ $2 == 'others' ] && [ ! $3 ];then
        mkdir  -p  analyse
        mkdir  -p  others/result
        cp result/Mapping/Mapping.xls others/
        cnvkit.py batch $1.dedup.sorted.bam -r  /home/tianxl/pipeline/CNV-seq/GDCNV-seq/BGIse100ref/reference_25K.cnn   -d analyse/ -p 10
fi
	wait 
        
	cd analyse/
	perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $1.dedup.sorted.cns $1.type $1.qianhe > $1.cnv
        chr=`grep '^chr' $1.qianhe -c`
        if [ $chr == 25 ];then
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $1.dedup.sorted.cnr $1.cnv $1.point
        Rscript /home/tianxl/pipeline/utils/CNV.R $1.point $1.point
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".cnv > "$1".band
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".type > "$1".all.band
        awk '{print $2":"$3"-"$4}' "$1".all.band | sed 's/^/chr/' - > $1.all.intervals
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.all.intervals --out $1.all --noweb
        sed -i 's/\.$/NoneGene/' $1.all.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated_v2.py  $1.all.loci > "$1".all.intervals.result
        paste "$1".all.band  "$1".all.intervals.result > "$1".all.band_gene_v2.xls
        awk '{print $2":"$3"-"$4}' "$1".band | sed 's/^/chr/' - > $1.intervals
	awk '{print $2"\t"$3"\t"$4}' "$1".band | sed '/start/d' - > $1.bed
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.intervals --out $1 --noweb
        sed -i 's/\.$/NoneGene/' $1.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated_v2.py  $1.loci > "$1".intervals.result
        paste "$1".band  "$1".intervals.result > "$1".band_gene_v2.xls
        rm "$1".band $1.intervals "$1".intervals.result $1.loci $1.log $1.all.loci $1.all.log "$1".all.intervals.result "$1".all.band $1.all.intervals 
              
        Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $1.bed
	paste "$1".band_gene_v2.xls $1.cnv_anno.txt > $1.band_gene_v2.cnv_anno.xls
        perl /home/tianxl/pipeline/CNV-seq/result2lastType_v4.pl $1.band_gene_v2.cnv_anno.xls $1.cnv_anno.xlsx

        if [ $2 == '100K' ];then
            mv $1.point.png $1.all.band_gene_v2.xls $1.cnv_anno.xlsx $1.qianhe  ../100K/result/
           
        elif [ $2 == '1M' ];then
            mv $1.point.png $1.all.band_gene_v2.xls $1.cnv_anno.xlsx $1.qianhe  ../1M/result/
            
        elif [ $2 == 'others' ];then
            mv  $1.point.png $1.all.band_gene_v2.xls $1.cnv_anno.xlsx $1.qianhe  ../others/result/
            
        fi
      else 
        cd ../ 
        sh /home/tianxl/pipeline/CNV-seq/GDCNV-seq/GDpip_BGI.sh $1 $2 
      fi 
