#/bin/bash
date_start=$(date +%s);

for i in *.band_gene_v2.xls;do echo $i ;done > list
sed -i 's/.band_gene_v2.xls//' list
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
	perl /home/tianxl/pipeline/CNV-seq/single_cnv_v2.pl $i.band_gene_v2.xls $i.point  
     echo "done!">&6
  }& 
}
done
wait
for i in *X*;do Rscript /home/tianxl/pipeline/CNV-seq/single_chr.R $i $i ;done
