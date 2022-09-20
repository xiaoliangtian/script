#/bin/bash
date_start=$(date +%s);
rename STR-F F *
rename STR- F *
rename _001.fastq.gz .fastq.gz *
##start to calling type
#echo -e "sample\t二聚体\tcount\t二聚体比例\t有效数据比例" > all.adapt.rate
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
# mkdir cutadapt
mkdir analyse
echo -e "sample\t二聚体\tcount\t二聚体比例\t有效数据比例" > cutadapt/all.adapt.rate
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
    #  cutadapt -a CTGTCTCTTATACACATCTCCGAGCCCACGAGAC -A CTGTCTCTTATACACATCTGACGCTGCCGACGA $i*R1.fastq.gz $i*R2.fastq.gz -o cutadapt/"$i"_R1.fastq.gz -p cutadapt/"$i"_R2.fastq.gz -m 50
    #  wait;
    #  cd cutadapt
     perl /home/tianxl/pipeline/STR_SNPlinkage/script_200331/pip2/STRfq2needfq_Pool1_v3.pl $i*R1.fastq.gz $i*R2.fastq.gz all "$i"_R1.fastq "$i"_R2.fastq $i > analyse/$i.R1.fastq
     cd analyse
     /opt/seqtools/package/cfBEST-pipeline-master/cfbest fquniq -1 "$i".R1.fastq -2 "$i".R1.fastq -C -o $i
     #fastq_quality_filter -i $i.R1.fastq  -Q 33 -o $i.need.fastq -q 20 -p 80
     #perl /home/tianxl/pipeline/STR_tools/STR_SF/STRfq2fa.pl  $i.uniq.R1.fastq  $i.need.fasta
     ##Run MISA to identificat ssr
     #perl /home/tianxl/pipeline/STR_tools/SSR.pl $i.need.fasta  3-4,4-4,5-4,6-4,7-4,8-4 250
     ##Statistical STR genotype
     #perl  /home/tianxl/pipeline/STR_SNPlinkage/misaStat_v2.pl $i.need.fasta.misa  > $i.need.list
     perl /home/tianxl/pipeline/STR_SNPlinkage/script_200331/pip2/STRlociFq2STRgenoFq_v2.pl $i.uniq.R1.fastq /home/tianxl/pipeline/STR_SNPlinkage/script_200331/database2/STR43Loci_genotype.database_v2 /home/tianxl/pipeline/STR_SNPlinkage/script_200331/database2/STR46Loci_ref.list /home/tianxl/pipeline/STR_SNPlinkage/script_200331/database2/STR_match.database $i.nomatch.list /home/tianxl/pipeline/STR_SNPlinkage/script_200331/database2/matchDel.database > $i.need.fastq
     bowtie2 -x /home/tianxl/database/hg38/GRCh38_full_analysis_set_pure.fa  $i.need.fastq -k 1 -p 20 |  samtools sort -@ 20 | samtools view - > $i.sam
     perl /home/tianxl/pipeline/STR_SNPlinkage/script_200331/pip2/STRsamStat.pl $i.sam  $i.type >$i.samStat.log
     #perl /home/tianxl/pipeline/STR_tools/STR_SF/STRuniq_stat.pl "$i".uniq.R1.fastq  $i.type
     ##Statistical genotype distribution
     perl /home/tianxl/pipeline/STR_SNPlinkage/script_200331/pip2/type_depth_5.pl -i $i.type -o $i.distrub -m 2 > $i.ty
     mkdir ../result 
     mv $i.newgeno $i.log $i.type $i.ty  ../result/
     #rm "$i".R1.fastq "$i".part.R1.fastq "$i".uniq.R1.fastq "$i".uniq.R2.fastq 
     echo "done!">&6
  }& 
}
done
wait
