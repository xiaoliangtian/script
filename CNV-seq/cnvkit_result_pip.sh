for i in *.dedup.sorted.cnr;do echo $i ;done > list
sed -i 's/.dedup.sorted.cnr//' list

mkdir pic
mkdir pic/result
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
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $i.dedup.sorted.cns $i.type $i.qianhe > $i.cnv
	perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $i.dedup.sorted.cnr $i.cnv $i.point
	perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$i".cnv > "$i".band
	perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$i".type > "$i".all.band
	awk '{print $2":"$3"-"$4}' "$i".all.band | sed 's/^/chr/' - > $i.all.intervals
	pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $i.all.intervals --out $i.all --noweb
	python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $i.all.intervals $i.all.loci
	paste "$i".all.band  "$i".all.intervals.result > pic/"$i".all.band_gene_v2.xls
	awk '{print $2":"$3"-"$4}' "$i".band | sed 's/^/chr/' - > $i.intervals
	pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $i.intervals --out $i --noweb
	python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $i.intervals $i.loci
	paste "$i".band  "$i".intervals.result > pic/"$i".band_gene_v2.xls
	mv $i.point pic/
	rm "$i".band $i.intervals "$i".intervals.result $i.loci $i.log $i.all.loci $i.all.log "$i".all.intervals.result "$i".all.band $i.all.intervals 
	cd pic
	Rscript /home/tianxl/pipeline/CNV-seq/cnv_anno.tab.R $i.band_gene_v2.xls	
	perl /home/tianxl/pipeline/CNV-seq/result2lastType.pl $i.band_gene_v2.cnv_anno.xls $i.cnv_anno.xls
	perl /home/tianxl/pipeline/CNV-seq/single_cnv_v2.pl $i.band_gene_v2.xls $i.point
     echo "done!">&6
  }& 
}
done
wait
cd pic/
for i in *X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
mv *X*.pdf *.all.band_gene_v2.xls *.cnv_anno.xls ../*qianhe  result/
