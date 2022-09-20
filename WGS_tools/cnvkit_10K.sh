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
  echo $h
	cnvkit.py batch $i.dedup.sorted.bam -r /home/tianxl/database/ref/CNVwgsRef/WGS_ref.cnn   -d cnvkit/ -p 20
     echo "done!">&6
  }& 
}
done
wait
