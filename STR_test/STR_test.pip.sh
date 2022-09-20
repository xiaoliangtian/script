##version 1.0 
##version 2.0 add cutadapt
##version 3.0 cutadapt -e 0.1 changed to 0.2

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
     perl /home/tianxl/pipeline/primer_tools/PCRprimerStat.pl "$i"*R1.fastq.gz "$i"*R2.fastq.gz /home/tianxl/pipeline/STR_test/test.primer.txt  all "$i"_R1.fastq "$i"_R2.fastq  "$i" > analyse/"$i".R1.fastq
     cd analyse
     cutadapt -a TGGAATTCTCGGGTGCCAAGGAACTCCAGTCACGT -e 0.2 "$i".R1.fastq -o "$i".need.fastq -O 8
     /opt/seqtools/package/cfBEST-pipeline-master/cfbest fquniq -1 "$i".need.fastq -2 "$i".need.fastq -C -o $i
     perl /home/tianxl/pipeline/STR_tools/STR_SF/STRfq2fa.pl  $i.uniq.R1.fastq  $i.need.fasta
     ##Run MISA to identificat ssr
     perl /home/tianxl/pipeline/STR_tools/SSR.pl $i.need.fasta  3-4,4-4,5-4 50
     ##Statistical STR genotype
     perl  /home/tianxl/pipeline/STR_test/AllmisaStat.pl $i.need.fasta.misa /home/tianxl/pipeline/STR_test/test.primer.txt > $i.type
     ##Statistical genotype distribution
     perl /home/tianxl/pipeline/STR_tools/test_type_depth_5.pl -i $i.type -o $i.distrub -m 1 > $i.ty 
     #rm "$i".R1.fastq "$i".part.R1.fastq "$i".uniq.R1.fastq "$i".uniq.R2.fastq 
     echo "done!">&6
  }& 
}
done
wait
cd analyse 
perl /home/tianxl/pipeline/STR_tools/fenbu_stat.pl -o summary.fenbu.stat
##Drawing distribution curve
Rscript /home/tianxl/pipeline/utils/spline_curve.r summary.fenbu.stat distribution  type distribute,type nums
#rm *.fastq *.fasta *.statistics *.distrub
paste *.type > all.ty1
awk '{printf $1"\t";for (i=2;i<=NF;i+=2) printf $i"\t";print a}' all.ty1 > all.ty
rm all.ty1
date_end=$(date +%s);
date_total=$((date_end-date_start));
echo "pipline运行了：$date_total秒" >> time.log;
#rm *.fastq *.fasta *.statistics *.distrub
 python /home/tianxl/pipeline/STR_tools/STR_ku/var-stat.py -i all.ty
wait
