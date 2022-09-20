#/bin/bash
date_start=$(date +%s);

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
	cnvkit.py batch $i.dedup.sorted.bam -r /workshop/project/SA/ref/yikang_2_ref_v3_190612/ref_500K/my_reference_500K.cnn   -d results_500K/ -p 10 
	wait 
	cd results_500K/
	perl /home/tianxl/pipeline/CNV-seq/cnvkit2type_v2.pl $i.dedup.sorted.cns $i.type $i.qianhe > $i.cnv
        perl /home/tianxl/pipeline/CNV-seq/cnvkit2point.pl $i.dedup.sorted.cnr $i.cnv $i.point
	Rscript /home/tianxl/pipeline/utils/SC.R $i.point $i.point 
     echo "done!">&6
  }& 
}
done
wait
