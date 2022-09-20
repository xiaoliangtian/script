#/bin/bash
date_start=$(date +%s);
rename _001.fastq.gz .fastq.gz *
##start to calling type
echo -e "sample\t二聚体\tcount\t二聚体比例\t有效数据比例" > all.adapt.rate
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
mkdir clean
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
	perl /home/tianxl/pipeline/Y_hap0/Y_hap2needfq.pl $i*R1.fastq.gz $i*R2.fastq.gz all "$i"_R1.fastq "$i"_R2.fastq $i
 	cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -e  0.1 "$i"_R1.fastq.gz "$i"_R2.fastq.gz -o "$i"_R1.fastq.1.gz -p "$i"_R2.fastq.1.gz -m 30
 	cutadapt -a CATCCAACGTAGATCGGAAGA -A CATCCAACGTAGATCGGAAGA -e  0.1 "$i"_R1.fastq.1.gz "$i"_R2.fastq.1.gz -o "$i"_R1.fastq -p "$i"_R2.fastq -m 30
	cutadapt -g ACGTTGGATG -G ACGTTGGATG -e  0.1 "$i"_R1.fastq "$i"_R2.fastq -o clean/"$i"_R1.fastq -p clean/"$i"_R2.fastq 
     echo "done!">&6
  }& 
}
done
wait 
rm *.fastq.1.gz *.fastq
cd clean 
gzip *
wait 
wh-tools dryrun HBB 10 `pwd`
cd results/bam/
