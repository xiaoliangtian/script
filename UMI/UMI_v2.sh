/bin/bash
time_start=$(date +%s);
fqDir=$2
bed=$3
intervals=`basename $bed .bed`.intervals

mkdir $fqDir/summary $fqDir/log $fqDir/results
mkdir -p $fqDir/results/{stats,bam,depth,RAW_VCF,GVCF,dedup_bam,annovar-files,Single_Strand_bam,Double_Strand_bam,DuplexSeqMetrics}
results=$fqDir'/results'
log=$fqDir'/log'

rename _001.fastq.gz .fastq.gz *
#start to calling type
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
#Set the number of threads
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
        time_out="$i"'分析流程:'
	file_name=$i
	fastqc -t 2 -o $fqDir/summary -noextract -f fastq *R1.fastq.gz *R2.fastq.gz 2>$fqDir/log/fastqc.log &
FastqToSam=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/picard.jar FastqToSam FASTQ="$i"_R1.fastq.gz        FASTQ2="$i"_R2.fastq.gz       OUTPUT=$results/bam/$i.ubam     READ_GROUP_NAME=$i     SAMPLE_NAME=$i     LIBRARY_NAME=$i     PLATFORM_UNIT=HiseqX10  PLATFORM=illumina     RUN_DATE=`date --iso-8601=seconds`
time_out="$time_out\nFastqToSam运行了：$(($(date +%s)-FastqToSam))秒"

ExtractUmisFromBam=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar ExtractUmisFromBam     --input=$results/bam/$i.ubam      --output=$results/bam/$i.umi.ubam     --read-structure=3M2S145T 3M2S145T    --single-tag=RX   --molecular-index-tags=ZA ZB
time_out="$time_out\nExtractUmisFromBam运行了：$(($(date +%s)-ExtractUmisFromBam))秒"

bwa1_start=$(date +%s)
samtools fastq $results/bam/$i.umi.ubam | bwa mem -t 10 -p /data/hg19/reference/hs37d5.fasta /dev/stdin | samtools view -b > $results/bam/$i.umi.bam 2>$log/$i.bwa1.log
samtools flagstat $results/bam/$i.umi.bam > $results/stats/$i.mapstats

touch $results/stats/all_mapped.txt   #collect mapped data
mapstats=$results/stats/$i.mapstats
mapped=`grep 'N/A)' $mapstats| grep 'mapped' | cut -d'(' -f2 |cut -d':' -f1`
paired_mapped=`grep 'N/A)' $mapstats| grep 'paired' | cut -d'(' -f2 |cut -d':' -f1`
echo -e "$file_name\t$mapped\t$paired_mapped" >> $results/stats/all_mapped.txt;
time_out="$time_out\nbwa1运行了：$(($(date +%s)-bwa1_start))秒"


#java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar ExtractUmisFromBam     --input=$i.ubam      --output=$i.umi.ubam     --read-structure=5M145T 5M145T     --single-tag=RX     --molecular-index-tags=ZA ZB
#samtools fastq $i.umi.ubam | bwa mem -t 10 -p /data/hg19/reference/hs37d5.fasta /dev/stdin | samtools view -b > $i.umi.bam

MergeBamAlignment=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/picard.jar MergeBamAlignment R=/data/hg19/reference/hs37d5.fasta     UNMAPPED_bam=$results/bam/$i.umi.ubam      ALIGNED_bam=$results/bam/$i.umi.bam     O=$results/bam/$i.umi.merged.bam      CREATE_INDEX=true        MAX_GAPS=-1     ALIGNER_PROPER_PAIR_FLAGS=true     VALIDATION_STRINGENCY=SILENT     SO=coordinate     ATTRIBUTES_TO_RETAIN=XS
time_out="$time_out\nMergeBamAlignment运行了：$(($(date +%s)-MergeBamAlignment))秒"

GroupReadsByUmi=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar GroupReadsByUmi     --input=$results/bam/$i.umi.merged.bam     --output=$results/bam/$i.umi.group.bam      --strategy=paired  --min-map-q=20  --edits=1 --raw-tag=RX
time_out="$time_out\nGroupReadsByUmi运行了：$(($(date +%s)-GroupReadsByUmi))秒"

java -jar /opt/seqtools/source/picard.jar BedToIntervalList I=$bed  O=$results/DuplexSeqMetrics/$intervals SD=/data/hg19/reference/hs37d5.dict

CollectDuplexSeqMetrics=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar  CollectDuplexSeqMetrics -i $results/bam/"$i".umi.group.bam -o $results/DuplexSeqMetrics/$i -l $results/DuplexSeqMetrics/$intervals
time_out="$time_out\nCollectDuplexSeqMetrics运行了：$(($(date +%s)-CollectDuplexSeqMetrics))秒"

CallMolecularConsensusReads=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar  CallMolecularConsensusReads     --min-reads=1     --min-input-base-quality=20     --input=$results/bam/$i.umi.group.bam     --output=$results/Single_Strand_bam/$i.consensus.ubam
time_out="$time_out\nCallMolecularConsensusReads运行了：$(($(date +%s)-CallMolecularConsensusReads))秒"

CallDuplexConsensusReads=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar  CallDuplexConsensusReads     --min-reads=1     --min-input-base-quality=20   --input=$results/bam/$i.umi.group.bam     --output=$results/Double_Strand_bam/$i.dsconsensus.ubam
time_out="$time_out\nCallDuplexConsensusReads运行了：$(($(date +%s)-CallDuplexConsensusReads))秒"

bwa2_start=$(date +%s)
samtools fastq $results/Single_Strand_bam/$i.consensus.ubam | bwa mem -t 10 -p /data/hg19/reference/hs37d5.fasta  /dev/stdin | samtools view -b - > $results/Single_Strand_bam/$i.consensus.bam 2>$log/$i.bwa2.log
samtools fastq $results/Double_Strand_bam/$i.dsconsensus.ubam | bwa mem -t 10 -p /data/hg19/reference/hs37d5.fasta  /dev/stdin | samtools view -b - > $results/Double_Strand_bam/$i.dsconsensus.bam 2>$log/$i.bwa2.log
time_out="$time_out\nbwa2运行了：$(($(date +%s)-bwa2_start))秒"

MergeBamAlignment2=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/picard.jar MergeBamAlignment R=/data/hg19/reference/hs37d5.fasta     UNMAPPED_bam=$results/Single_Strand_bam/$i.consensus.ubam      ALIGNED_bam=$results/Single_Strand_bam/$i.consensus.bam     O=$results/Single_Strand_bam/$i.consensus.merge.bam      CREATE_INDEX=true        MAX_GAPS=-1     ALIGNER_PROPER_PAIR_FLAGS=true     VALIDATION_STRINGENCY=SILENT     SO=coordinate     ATTRIBUTES_TO_RETAIN=XS
java -Xmx8G -jar /opt/seqtools/source/picard.jar MergeBamAlignment R=/data/hg19/reference/hs37d5.fasta     UNMAPPED_bam=$results/Double_Strand_bam/$i.dsconsensus.ubam      ALIGNED_bam=$results/Double_Strand_bam/$i.dsconsensus.bam     O=$results/Double_Strand_bam/$i.dsconsensus.merge.bam      CREATE_INDEX=true        MAX_GAPS=-1     ALIGNER_PROPER_PAIR_FLAGS=true     VALIDATION_STRINGENCY=SILENT     SO=coordinate     ATTRIBUTES_TO_RETAIN=XS
time_out="$time_out\nMergeBamAlignment2运行了：$(($(date +%s)-MergeBamAlignment2))秒"

FilterConsensusReads=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar FilterConsensusReads     --input=$results/Single_Strand_bam/$i.consensus.merge.bam      --output=$results/Single_Strand_bam/$i.consensus.merge.filter.bam     --ref=/data/hg19/reference/hs37d5.fasta --min-reads=3     --min-base-quality=20  --max-read-error-rate=0.05 --max-base-error-rate=0.1  
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar FilterConsensusReads     --input=$results/Double_Strand_bam/$i.dsconsensus.merge.bam      --output=$results/Double_Strand_bam/$i.dsconsensus.merge.filter.bam     --ref=/data/hg19/reference/hs37d5.fasta --min-reads 2 1 1     --min-base-quality=20  --max-read-error-rate=0.05 --max-base-error-rate=0.1
time_out="$time_out\nFilterConsensusReads运行了：$(($(date +%s)-FilterConsensusReads))秒"

ClipBam=$(date +%s)
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar ClipBam     --input=$results/Single_Strand_bam/$i.consensus.merge.filter.bam       --output=$results/Single_Strand_bam/$i.consensus.merge.filter.clip.bam     --ref=/data/hg19/reference/hs37d5.fasta  --soft-clip=false --clip-overlapping-reads=true
java -Xmx8G -jar /opt/seqtools/source/fgbio-0.8.1.jar ClipBam     --input=$results/Double_Strand_bam/$i.dsconsensus.merge.filter.bam       --output=$results/Double_Strand_bam/$i.dsconsensus.merge.filter.clip.bam     --ref=/data/hg19/reference/hs37d5.fasta  --soft-clip=false --clip-overlapping-reads=true
time_out="$time_out\nClipBam运行了：$(($(date +%s)-ClipBam))秒"

depth_start=$(date +%s)
samtools depth -d 0 $results/Single_Strand_bam/$i.consensus.merge.filter.clip.bam > $results/depth/$i.depth
samtools depth -d 0 $results/Double_Strand_bam/$i.dsconsensus.merge.filter.clip.bam > $results/depth/"$i"_2_1_1.ds.depth
time_out="$time_out\ndepth运行了：$(($(date +%s)-depth_start))秒"

#call_snp=$(date +%s)
/opt/seqtools/source/VarDict-1.6.0/bin/VarDict -G /data/hg19/reference/hs37d5.fasta -f 0.02 -N $i -b $results/Single_Strand_bam/$i.consensus.merge.filter.clip.bam -c 1 -S 2 -E 3  -g 4 -r 1  /opt/seqtools/bed/wehealth_SNP_UMI.bed  | /opt/seqtools/source/VarDict-1.6.0/bin/teststrandbias.R | /opt/seqtools/source/VarDict-1.6.0/bin/var2vcf_valid.pl -N $i -E -q 25 -m 4.25 -f 0.02 > $results/RAW_VCF/$i.vardict.vcf
/opt/seqtools/source/VarDict-1.6.0/bin/VarDict -G /data/hg19/reference/hs37d5.fasta -f 0.02 -N $i -b $results/Double_Strand_bam/$i.dsconsensus.merge.filter.clip.bam -c 1 -S 2 -E 3  -g 4 -r 1 /opt/seqtools/bed/wehealth_SNP_UMI.bed  | /opt/seqtools/source/VarDict-1.6.0/bin/teststrandbias.R | /opt/seqtools/source/VarDict-1.6.0/bin/var2vcf_valid.pl -N $i -E -q 25 -m 4.25 -f 0.02 > $results/RAW_VCF/$i.2_1_1.dsvardict.vcf
#bcftools mpileup --thread 20 -f /data/hg19/reference/hs37d5.fasta -a DP,AD  -T /data/bed/IDT_PPGL_Target.bed -L 100000 -d 100000 -Oz  $results/Single_Strand_bam/$i.consensus.merge.filter.clip.bam  -o $results/GVCF/$i.g.vcf.gz 
#bcftools mpileup --thread 20 -f /data/hg19/reference/hs37d5.fasta -a DP,AD  -T /data/bed/IDT_PPGL_Target.bed -L 100000 -d 100000 -Oz  $results/Double_Strand_bam/$i.dsconsensus.merge.filter.clip.bam  -o $results/GVCF/$i.ds.vcf.gz
# bcftools call -mv -Oz $results/GVCF/$i.g.vcf.gz  > $results/RAW_VCF/$i.raw.vcf.gz
# bcftools call -mv -Oz $results/GVCF/$i.ds.vcf.gz  > $results/RAW_VCF/$i.dsraw.vcf.gz
time_out="$time_out\ncall_snp运行了：$(($(date +%s)-call_snp))秒"

time_out="$time_out\ncalling_pipline运行了：$(($(date +%s)-time_start))秒\n"
echo -e $time_out >> $fqDir/time.log
     echo "done!">&6
  }& 
}
done
wait
pypy /opt/seqtools/source/wh-tools/dist/common/qc-apply.py -b $bed -f $fqDir -rq
date_end=$(date +%s);
date_total=$((date_end-time_start));
echo "pipline运行了：$date_total秒" >> $fqDir/time.log;
