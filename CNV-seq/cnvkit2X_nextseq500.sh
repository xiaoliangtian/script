#/bin/bash
date_start=$(date +%s);

#for i in *.dedup.sorted.bam;do echo $i ;done > list
#sed -i 's/.dedup.sorted.bam//' list

#mkdir -p project2/analyse/pic
#mkdir -p project2/result
if [ -f  list2 ];then
mkdir -p project2/analyse/pic
mkdir -p project2/result

for j in `cat list2`; do
        cd project2
        ln -s ../"$j"*dedup.sorted.bam* ./
        h=${j//-/.}
        ln -s ../CNV/$h*.point ./
        #Rscript /home/tianxl/pipeline/utils/SC.R $h*.point $h*.point
done
cd project2
else 
mkdir -p analyse/pic
mkdir -p result
#mv *point.pdf result/
fi

for i in *.dedup.sorted.bam;do echo $i ;done > list
sed -i 's/.dedup.sorted.bam//' list

##Set the number of threads
thread_num=$1;
tempfifo="my_temp_fifo"
mkfifo ${tempfifo}
exec 6<>${tempfifo}
rm -f ${tempfifo}
for ((i=1;i<=${thread_num};i++))
do
{
    echo "start $i..."
}
done >&6
for i in `cat list`; do 
 { read -u6
   { sleep 1
	h=${i//./-}
	cnvkit.py batch $i.dedup.sorted.bam -r /storage/project/CNV-seq/200402-txl_200401_NB500986_0477_AXXXXXXXXX/project/my_reference_25KFM.cnn   -d analyse/ -p 10 
	wait 
	cd analyse/
	perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $i.dedup.sorted.cns $i.type $i.qianhe > $i.cnv
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $i.dedup.sorted.cnr $i.cnv $i.point
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$i".cnv > "$i".band
        perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$i".type > "$i".all.band
        awk '{print $2":"$3"-"$4}' "$i".all.band | sed 's/^/chr/' - > $i.all.intervals
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $i.all.intervals --out $i.all --noweb
        sed -i 's/\.$/NoneGene/' $i.all.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $i.all.intervals $i.all.loci
        paste "$i".all.band  "$i".all.intervals.result > pic/"$i".all.band_gene_v2.xls
        awk '{print $2":"$3"-"$4}' "$i".band | sed 's/^/chr/' - > $i.intervals
        awk '{print $2"\t"$3"\t"$4}' "$i".band | sed '/start/d' - > $i.bed
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $i.intervals --out $i --noweb
        sed -i 's/\.$/NoneGene/' $i.loci
        python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $i.intervals $i.loci
        paste "$i".band  "$i".intervals.result > pic/"$i".band_gene_v2.xls
        mv $i.point pic/
        Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $i.bed
        mv $i.cnv_anno.txt pic/
        rm "$i".band $i.intervals "$i".intervals.result $i.loci $i.log $i.all.loci $i.all.log "$i".all.intervals.result "$i".all.band $i.all.intervals 
        cd pic
        #Rscript /home/tianxl/pipeline/CNV-seq/cnv_annotation.R $i.bed
        paste "$i".band_gene_v2.xls $i.cnv_anno.txt > $i.band_gene_v2.cnv_anno.xls  
        perl /home/tianxl/pipeline/CNV-seq/result2lastType_v3.pl $i.band_gene_v2.cnv_anno.xls $i.cnv_anno.xls
        #perl /home/tianxl/pipeline/CNV-seq/single_cnv_v2.pl $i.band_gene_v2.xls $i.point
	Rscript /home/tianxl/pipeline/utils/CNV.R $i.point $i
	mv $i.png ../../result/
     echo "done!">&6
  }& 
}
done
wait
for i in *point; do Rscript /home/tianxl/pipeline/utils/SC.R $i $i ;done
mv *point.png result/
cd analyse/pic/
#for i in *X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
mv *X*.png *.all.band_gene_v2.xls *.cnv_anno.xls ../*qianhe  ../../result/
rm ../../result/*v2.cnv_anno.xls
