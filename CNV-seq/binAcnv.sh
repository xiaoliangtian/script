#/bin/bash
date_start=$(date +%s);

for i in *.band_gene_v2.xls;do echo $i ;done > list
sed -i 's/.band_gene_v2.xls//' list
mkdir binAcnv_result 
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
	perl  /home/tianxl/pipeline/CNV-seq/binAndCnv_v2.pl "$i".band_gene_v2.xls ../cnvtools/"$h"/"$h".cnv > binAcnv_result/"$i".cnv
	perl /home/tianxl/pipeline/CNV_analyse/../utils/pos2band.pl binAcnv_result/"$i".cnv > binAcnv_result/"$i".band
	awk '{print $2":"$3"-"$4}' binAcnv_result/"$i".band | sed 's/^/chr/' - > binAcnv_result/"$i".intervals
	pseq . loc-intersect --group refseq --locdb /data/hg19/pseq_data/locdb --file binAcnv_result/$i.intervals --out binAcnv_result/$i --noweb
	python /home/tianxl/pipeline/CNV_analyse/../utils/cnv-annotated.py binAcnv_result/$i.intervals binAcnv_result/$i.loci
	paste binAcnv_result/"$i".band  "$i".intervals.result > binAcnv_result/"$i".band_gene_v2.xls
     echo "done!">&6
  }& 
}
done
wait
