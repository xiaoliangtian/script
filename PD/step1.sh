echo -e "sample\t二聚体\tcount\t二聚体比例\t有效数据比例" > all.adapt.rate
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
mkdir analyse
for i in `cat list`; do perl /home/tianxl/pipeline/PD/PDfq2needfq_v1.pl $i*R1.fastq.gz $i*R2.fastq.gz all  "$i"_R1.fastq "$i"_R2.fastq $i;done
