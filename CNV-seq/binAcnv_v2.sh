#/bin/bash
date_start=$(date +%s);

for i in *.dedup.sorted.cns.cnv;do echo $i ;done > list
sed -i 's/.dedup.sorted.cns.cnv//' list
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
	perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl "$i".dedup.sorted.cns.cnv > "$i".band
	awk '{print $2":"$3"-"$4}' "$i".band | sed 's/^/chr/' - > $i.intervals
        pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file $i.intervals --out $i --noweb
	python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py $i.intervals $i.loci
	paste "$i".band  "$i".intervals.result > "$i".band_gene_v2.xls
     echo "done!">&6
  }& 
}
done
wait
