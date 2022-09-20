#/bin/bash
date_start=$(date +%s);
##start to calling type
rename _001.fastq.gz .fastq.gz * 
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list

threads=10
results="$3"'/results'
log="$3"'/log'
type=$1
if [ "$1" == "A" ];then
    ref='/home/tianxl/database/HBV_ref/A/HBV-Aafr.fasta'
    #echo $ref
elif [ "$1" == "B" ];then
    ref='/home/tianxl/database/HBV_ref/B/HBV-Bj.fasta'
elif [ "$1" == "C" ];then
    ref='/home/tianxl/database/HBV_ref/C/HBV-C.fasta'
fi

mkdir -p $3/results/cutAdapt 
mkdir -p $3/results/bam
mkdir -p $3/results/dedupBam
mkdir -p $3/results/gvcf
mkdir -p $3/results/rawVcf
mkdir -p $3/results/anno
mkdir -p $3/results/stats
mkdir $3/summary
mkdir $3/log


#fastqc -t 5 -o $3/summary -noextract -f fastq *R1.fastq.gz  2>$3/log/fastqc.log &

##Set the number of threads
thread_num=$2;
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
     cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC  $3/"$i"_R1.fastq.gz -o $results/cutAdapt/"$i"_R1.trim.fastq.gz  -m 30 -j 10
     wait
     bwa mem -t $threads -R "@RG\tID:$i\tLB:$i\tSM:$i\tPL:illumina" $ref -p $results/cutAdapt/"$i"_R1.trim.fastq.gz  | samtools sort -@ $threads -o $results/bam/$i.sorted.bam - 2>$log/$i.aln-sort.log
     wait
     samtools index $results/bam/$i.sorted.bam&
     samtools flagstat $results/bam/$i.sorted.bam > $results/stats/$i.mapstats&
     sambamba markdup --overflow-list-size=20000000 --io-buffer-size=256 -t $threads -r $results/bam/$i.sorted.bam $results/dedupBam/$i.dedup.sorted.bam 2>$log/$i.rmdup.log
     wait
     samtools depth -d 1000000 $results/dedupBam/$i.dedup.sorted.bam  > $results/depth/$i.depth&
     bcftools mpileup --threads $threads  -a DP,AD -L 1000000 -d 1000000  -f $ref $results/dedupBam/$i.dedup.sorted.bam | bcftools call  --threads $threads -mv -Oz - -o $results/rawVcf/$i.raw.vcf.gz
     wait
     if [ "$type" != "B" ];then
         perl /workshop/tianxl/project/HBV/A/results/rawVcf/HBVrawVcf2doubleVcf.pl  $results/rawVcf/$i.raw.vcf.gz $type > $results/rawVcf/$i.raw.vcf
     fi
     if [ "$type" == "B" ];then
         gunzip -c $results/rawVcf/$i.raw.vcf.gz > $results/rawVcf/$i.raw.vcf
     fi
     wait
     #rm $results/rawVcf/$i.raw.vcf.gz
     table_annovar.pl $results/rawVcf/$i.raw.vcf /workshop/tianxl/project/HBV/ -buildver Hepatitis"$type" -out $results/anno/$i.anno   -remove -protocol refGene -operation g -nastring . -vcfinput -thread 10 -maxgenethread 10
     wait
     perl /workshop/tianxl/project/HBV/A/results/anno/HBVanno2singleAnno.pl  $results/anno/"$i".anno.Hepatitis"$type"_multianno.txt $type > $results/anno/$i.anno.txt
     echo "done!">&6
  }& 
}
done
