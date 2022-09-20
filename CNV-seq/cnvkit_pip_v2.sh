#/bin/bash
if [ $2 == 'project1' ];then 
        mkdir  -p  analyse
        mkdir  -p  project1/result
        cp result/Mapping/Mapping.xls project1/
	cnvkit.py batch $1.dedup.sorted.bam -r  /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_100K/my_reference_100K.cnn   -d analyse/ -p 10 
elif [ $2 == 'project2' ];then
        mkdir  -p  analyse
        mkdir  -p  project2/result
        cp result/Mapping/Mapping.xls project2/
        cnvkit.py batch $1.dedup.sorted.bam -r  /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_25K/my_reference_25K.cnn   -d analyse/ -p 10
elif [ $2 == 'project3' ];then
        mkdir  -p  analyse
        mkdir  -p  project3/result
        cp result/Mapping/Mapping.xls project3/
        cnvkit.py batch $1.dedup.sorted.bam -r  /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_25K/my_reference_25K.cnn   -d analyse/ -p 10
elif [ $2 == 'others' ] && [ ! $3 ];then
        mkdir  -p  analyse
        mkdir  -p  others/result
        cp result/Mapping/Mapping.xls others/
        cnvkit.py batch $1.dedup.sorted.bam -r  /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_100K/my_reference_100K.cnn   -d analyse/ -p 10
else
	mkdir  -p  analyse
	mkdir  -p  others/result
        cp result/Mapping/Mapping.xls others/
	cnvkit.py batch $1.dedup.sorted.bam -r /workshop/project/SA/hongfangzi_ref/ref_v2/ref_100K/my_reference_100K.cnn   -d analyse/ -p 10
fi
	wait 
	cnvkit.py batch $1.dedup.sorted.bam -r /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_500K/my_reference_500K.cnn   -d results_500K/ -p 10
	wait
	cd results_500K/
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $1.dedup.sorted.cns $1.type $1.qianhe > $1.cnv
        chr1=`grep '^chr' $1.qianhe -c`
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $1.dedup.sorted.cnr $1.cnv $1.point
        Rscript /home/tianxl/pipeline/utils/SC.R $1.point $1.point
        sed '/^X/d' $1.point > $1.point.noXY
        sed -i '/^Y/d' $1.point.noXY
        Rscript /home/tianxl/pipeline/utils/SC.R $1.point.noXY $1.point.noXY
        
	cd ../analyse/
	perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $1.dedup.sorted.cns $1.type $1.qianhe > $1.cnv
        chr=`grep '^chr' $1.qianhe -c`
        if [ $chr == 25 ] && [ $chr1 == 25 ];then
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $1.dedup.sorted.cnr $1.cnv $1.point
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".cnv > "$1".band
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$1".type > "$1".all.band
        awk '{print $2":"$3"-"$4}' "$1".all.band | sed 's/^/chr/' - > $1.all.intervals
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.all.intervals --out $1.all --noweb
        sed -i 's/\.$/NoneGene/' $1.all.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $1.all.intervals $1.all.loci
        paste "$1".all.band  "$1".all.intervals.result > "$1".all.band_gene_v2.xls
        awk '{print $2":"$3"-"$4}' "$1".band | sed 's/^/chr/' - > $1.intervals
	awk '{print $2"\t"$3"\t"$4}' "$1".band | sed '/start/d' - > $1.bed
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $1.intervals --out $1 --noweb
        sed -i 's/\.$/NoneGene/' $1.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $1.intervals $1.loci
        paste "$1".band  "$1".intervals.result > "$1".band_gene_v2.xls
        rm "$1".band $1.intervals "$1".intervals.result $1.loci $1.log $1.all.loci $1.all.log "$1".all.intervals.result "$1".all.band $1.all.intervals 
              
        Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $1.bed
	paste "$1".band_gene_v2.xls $1.cnv_anno.txt > $1.band_gene_v2.cnv_anno.xls
	perl /home/tianxl/pipeline/CNV-seq/result2lastType_v3.pl $1.band_gene_v2.cnv_anno.xls $1.cnv_anno.xls
        CNV=`grep '^CNVR' $1.cnv_anno.xls -c`
        #echo $CNV
        if [ $CNV -lt 50 ];then
            perl /home/tianxl/pipeline/CNV-seq/single_cnv_v2.pl $1.band_gene_v2.xls $1.point
        fi
        h=${1/\_S*/}
        h=${h/\_com*/}

        if [ $2 == 'project1' ];then
            for i in "$h"*X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
            mv ../results_500K/$1.point.png ../results_500K/$1.point.noXY.png "$h"*X*.png "$h"*X*.pdf $1.all.band_gene_v2.xls $1.cnv_anno.xls $1.qianhe  ../project1/result/
           
        elif [ $2 == 'project2' ];then
            for i in "$h"*X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
            mv ../results_500K/$1.point.png ../results_500K/$1.point.noXY.png "$h"*X*.png "$h"*X*.pdf $1.all.band_gene_v2.xls $1.cnv_anno.xls $1.qianhe  ../project2/result/
            
        elif [ $2 == 'project3' ];then
            for i in "$h"*X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
            mv ../results_500K/$1.point.png ../results_500K/$1.point.noXY.png "$h"*X*.png "$h"*X*.pdf $1.all.band_gene_v2.xls $1.cnv_anno.xls $1.qianhe  ../project3/result/
            
        else 
            for i in "$h"*X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
            if [ $3 ];then
                Rscript /home/tianxl/pipeline/SA_tools/CNV_SA.R $1.point $1 $3
                mv  $1.png  $1.all.band_gene_v2.xls $1.cnv_anno.xls $1.qianhe  ../others/result/
            else
                Rscript /home/tianxl/pipeline/utils/CNV.R $1.point $1
                mv  $1.png  $1.all.band_gene_v2.xls $1.cnv_anno.xls $1.qianhe  ../others/result/
            fi
            mv "$h"*X*.png  "$h"*X*.pdf ../others/result/
        fi
      else 
        if [ $3 ];then
            sh /home/tianxl/pipeline/CNV-seq/cnvkit_pip_v2.sh $1 $2 $3
        else 
             sh /home/tianxl/pipeline/CNV-seq/cnvkit_pip_v2.sh $1 $2 
        fi
      fi 
