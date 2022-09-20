#!/bin/bash
time_start=$(date +%s)

# set the tools
FUSION=/opt/seqtools/source/STAR-Fusion-v1.4.0/STAR-Fusion
threads=10

for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
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
# set file dir and args
results="$2"/results/"$i"
summary="$2"/summary
log="$2"/log
STAR_FUSION_GENOME_INDEX=/data/tool_data/STAR-fusion/GRCh37_v19_CTAT_lib_Feb092018/ctat_genome_lib_build_dir/
#PICARD=/opt/seqtools/picard/picard.jar
#REF_FLAT=/mnt/workshop/SC/pipeline/database/rRNA-index/ref_flat.txt
#RIBOSOMAL_INTERVALS=/mnt/workshop/SC/pipeline/database/rRNA-index/hg19.rRNA.interval_list

# prepare files for workshop
mkdir -p $summary
mkdir -p $log
mkdir -p $results

fastqR1=$2/"$i"_R1.fastq.gz
fastqR2=$2/"$i"_R2.fastq.gz

# Running process

$FUSION --CPU $threads --genome_lib_dir $STAR_FUSION_GENOME_INDEX --left_fq $fastqR1 --right_fq $fastqR2 --output_dir $results

     echo "done!">&6
     }& 
}
done
wait
time_end=$(date +%s);
echo "$((time_end-time_start))"
