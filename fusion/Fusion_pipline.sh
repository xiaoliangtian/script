#!/bin/bash
time_start=$(date +%s)

# set the tools
FUSION=/mnt/workshop/yujie.wang/software/STAR-Fusion-v1.4.0/STAR-Fusion
threads=10

# set file dir and args
results="$3"'/results/'"$1"
summary="$3"'/summary'
log="$3"'/log'
bam=$results/bam
STAR_FUSION_GENOME_INDEX=/mnt/workshop/yujie.wang/software/GRCh37_v19_CTAT_lib_Feb092018/CTAT_Lib/ctat_lib_no_rRNA
PICARD=/opt/seqtools/picard2.5/picard.jar
REF_FLAT=/opt/seqtools/ref_database/human/GRCh37/ref_genome/ref_flat.txt
RIBOSOMAL_INTERVALS=/opt/seqtools/ref_database/human/GRCh37/rRNA_index/hg19.rRNA.interval_list

# prepare files for workshop
mkdir -p $summary
mkdir -p $log
mkdir -p $results

fastqR1=$3/$1_R1.fastq.gz
fastqR2=$3/$1_R2.fastq.gz

# Running process
md5sum $fastqR1 >> $results/$1_R1.txt
md5sum $fastqR2 >> $results/$1_R2.txt
fastqc -t $threads -o $summary -noextract -f fastq $fastqR1 $fastqR2 2>$log/$1.fastqc.log

$FUSION --CPU $threads --genome_lib_dir $STAR_FUSION_GENOME_INDEX --left_fq $fastqR1 --right_fq $fastqR2 --output_dir $results

samtools view -H $results/std.STAR.bam > $bam/raw.header.sam

sed $'s/ID:GRPundef/ID:GRPundef\tLB:GRPundef\tSM:GRPundef\tPL:illumina/' $bam/raw.header.sam > $bam/corrected.header.sam

samtools reheader $bam/corrected.header.sam $results/std.STAR.bam > $bam/$1.STAR.corrected.bam

java -Xmx30g -jar $PICARD CollectRnaSeqMetrics I=$bam/$1.STAR.corrected.bam O=$results/$1.RNA_Metrics REF_FLAT=$REF_FLAT  STRAND=SECOND_READ_TRANSCRIPTION_STRAND RIBOSOMAL_INTERVALS=$RIBOSOMAL_INTERVALS

rm -rf $bam

time_end=$(date +%s);
echo "$((time_end-time_start))"
