#!/bin/bash
time_start=$(date +%s)

# set the tools
REF_DIR=/data/hg19/ref_elprep
GATK_options="-Xmx10g"
threads=30
bed="$2"

# set file dir and args
results="$3"'/results'
log="$3"'/log'
summary="$3"'/summary'
cut_dir="$results"'/cut'
reference=/data/hg19/reference/ucsc.hg19.fasta
elRef="$REF_DIR"'/ucsc.hg19.elfasta'
time_out="$1分析流程:"

# prepare files for workshop
mkdir -p $summary
mkdir -p $log
mkdir -p $results/{cut,stats,bam,RAW_VCF,GVCF,recal_bam,annovar-files,depth,CNV}

fastqR1=$3/$1_R1.fastq.gz
fastqR2=$3/$1_R2.fastq.gz

cutadapt -j $threads -a AGATCGGAAGAGCACACGTCT -A AGATCGGAAGAGCGTCGTG -o $cut_dir/$1_R1.cut.fastq.gz -m 30 -p $cut_dir/$1_R2.cut.fastq.gz $fastqR1 $fastqR2 2> $log/$1.cutadapt.log
# Running process

bwa_start=$(date +%s)
bwa mem -t $threads -R "@RG\tID:$1\tLB:$1\tSM:$1\tPL:illumina" $reference $cut_dir/$1_R1.cut.fastq.gz $cut_dir/$1_R2.cut.fastq.gz | samtools view -@ $threads -bS - > $results/bam/$1.bam 2>$log/$1.aln.log
time_out="$time_out\nbwa运行了：$(($(date +%s)-bwa_start))秒"
samtools flagstat $results/bam/$1.bam > $results/stats/$1.mapstats


elprep_start=$(date +%s)

elprep sfm $results/bam/$1.bam $results/recal_bam/$1.sfm.recal.bam \
    --mark-duplicates \
    --mark-optical-duplicates $results/stats/$1.sfm.recal.metrics \
    --sorting-order coordinate \
    --bqsr $results/bam/$1.sfm.recal \
    --known-sites $REF_DIR/dbsnp_138.hg19.elsites,$REF_DIR/1000G_phase1.indels.hg19.elsites,$REF_DIR/1000G_phase1.snps.high_confidence.hg19.elsites,$REF_DIR/Mills_and_1000G_gold_standard.indels.hg19.elsites \
    --bqsr-reference $elRef \
    --timed 2>$log/$1.elprep.log

samtools index $results/recal_bam/$1.sfm.recal.bam

#for i in $results/recal_bam/*.sfm.recal.bam; do echo $i;done > $results/recal_bam/bam.list

#java -Xmx30g -jar /opt/seqtools/source/gatk-3.8.1.0/GenomeAnalysisTK.jar -T DepthOfCoverage -R  /data/hg19/reference/ucsc.hg19.fasta -o $results/recal_bam/"$1".coverage.stat -I $results/recal_bam/"$1".sfm.recal.bam --omitDepthOutputAtEachBase --omitIntervalStatistics -omitLocusTable -ct 1 -ct 5 -ct 10 -ct 20 -nt 30&

#collect dup_per data
touch $results/stats/all_dup.txt
dup=$results/stats/$1.sfm.recal.metrics
dup_file=`basename $dup`;
file_name="$(cut -d'.' -f1 <<<"$dup_file")";
file_name="$(cut -d'_' -f1 <<<"$file_name")";
awk 'NR==8 {print "'$file_name'" "\t" $9}' >> $results/stats/all_dup.txt $dup;

touch $results/stats/all_mapped.txt   #collect mapped data
mapstats=$results/stats/$1.mapstats
#file_name="$(cut -d'_' -f1 <<<"$1")";
mapped=`grep 'N/A)' $mapstats| grep 'mapped' | cut -d'(' -f2 |cut -d':' -f1`
paired_mapped=`grep 'N/A)' $mapstats| grep 'paired' | cut -d'(' -f2 |cut -d':' -f1`
echo -e "$file_name\t$mapped\t$paired_mapped" >> $results/stats/all_mapped.txt;

mosdepth -n -t 4 --by $bed -F 0 -T 1,5,10,15,20,25,30,40,50,100 $results/depth/$1 $results/recal_bam/$1.sfm.recal.bam
wait
wh-tools qcstat -f $3 &

time_out="$time_out\ncalling_pipline运行了：$(($(date +%s)-time_start))秒\n"
echo -e $time_out >> $3/time.log
