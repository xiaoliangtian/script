#/bin/bash
date_start=$(date +%s);
for i in *sorted.bam;do echo $i ;done > list
sed -i 's/.sorted.bam//' list
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
perl /home/tianxl/pipeline/CNV-seq/suijiquhang.pl $i.sorted.bam | perl /workshop/project/YZ/190512-txl_190510_NB502022_0084_AHJ5CFAFXY/results/bam/print_len.pl - >$i.sam.list
Rscript /home/tianxl/pipeline/myperl/curve.r  $i.sam.list $i
     echo "done!">&6
  }& 
}
done
