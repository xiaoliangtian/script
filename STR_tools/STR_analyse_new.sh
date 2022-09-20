#/bin/bash
date_start=$(date +%s);
rename _001.fastq.gz .fastq.gz *
##start to calling type
echo -e "sample\t二聚体\tcount\t二聚体比例\t有效数据比例" > all.adapt.rate
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
mkdir analyse
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
     ##Packed into the required fasta mode
     perl /home/tianxl/pipeline/STR_tools/STRfq2needfq_v3_new.pl "$i"*R1.fastq.gz "$i"*R2.fastq.gz all  > analyse/"$i".R1.fastq
     cd analyse
     fastq_quality_filter -i $i.R1.fastq  -Q 33 -o $i.need.fastq -q 20 -p 80
     perl /home/tianxl/pipeline/myperl/fastq2fastabian.pl  $i.R1.fastq  $i.need.fasta
     ##Run MISA to identificat ssr
     perl /home/tianxl/pipeline/STR_tools/SSR.pl $i.need.fasta  3-4,4-4,5-4 50
     ##Statistical STR genotype
     perl /home/tianxl/pipeline/STR_tools/misa2str_type_v3_new_all.pl $i.need.fasta.misa > $i.type
     ##Statistical genotype distribution
     perl /home/tianxl/pipeline/STR_tools/test_type_depth_5.pl -i $i.type -o $i.distrub -m 1 > $i.ty 
     echo "done!">&6
  }& 
}
done
wait
cd analyse 
perl /home/tianxl/pipeline/STR_tools/fenbu_stat.pl -o summary.fenbu.stat
##Drawing distribution curve
Rscript /home/tianxl/pipeline/utils/spline_curve.r summary.fenbu.stat distribution  type distribute,type nums
rm *.fastq *.fasta *.statistics *.distrub
