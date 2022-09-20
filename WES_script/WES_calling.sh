#!/bin/bash
time_start=$(date +%s)

# set the tools
REF_DIR=/data/hg19/ref_elprep
GATK_options="-Xmx10g"
threads=30

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

mosdepth -n -t 4 --by /data/bed/ucsc.hg19.wgs.bed -F 0 -T 1,5,10,15,20,25,30,40,50,100 $results/depth/$1 $results/recal_bam/$1.sfm.recal.bam
wait
wh-tools qcstat -f $3 &

time_out="$time_out\nelprep运行了：$(($(date +%s)-elprep_start))秒"

haplo_start=$(date +%s)
chrList_a='MT 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y'
# chrList_b='13 14 15 16 17 18 19 20 21 22 X Y'
inputVcf=' -V '

for i in $chrList_a;do
    chrPos="chr"$i;
    outVcf=$results/GVCF/$1.$chrPos.g.vcf.gz
    inputVcf="$inputVcf$outVcf -V "
    gatk --java-options $GATK_options HaplotypeCaller \
            -R $reference \
            -I $results/recal_bam/$1.sfm.recal.bam \
            -L $chrPos \
            -ip 100 \
            -ERC GVCF \
            --native-pair-hmm-threads $threads \
            -O $outVcf 2>$log/$1.call_gvcf.log &
done
wait;

# for j in $chrList_b;do
#     chrPos="chr"$j;
#     outVcf=$results/GVCF/$1.$chrPos.g.vcf.gz
#     inputVcf="$inputVcf$outVcf -V "
#     gatk --java-options $GATK_options HaplotypeCaller \
#             -R $reference \
#             -I $results/recal_bam/$1.recal.dedup.sorted.bam \
#             -L $j \
#             -ip 100 \
#             -ERC GVCF \
#             --native-pair-hmm-threads $threads \
#             -O $outVcf 2>$log/$1.call_gvcf.log &
# done
# wait;

inputVcf=${inputVcf% -V*}
echo $inputVcf
time_out="$time_out\nhaplo运行了：$(($(date +%s)-haplo_start))秒"

<<BLOCK
combine_start=$(date +%s)
gatk --java-options $GATK_options CombineGVCFs \
        -R $reference \
        $inputVcf \
        -O $results/GVCF/$1.cohort.g.vcf.gz

time_out="$time_out\nCombine运行了：$(($(date +%s)-combine_start))秒"
BLOCK

geno_start=$(date +%s)
for i in $chrList_a;do
    gvcf="$1".'chr'"$i".g.vcf.gz;
    rawvcf="$1".'chr'"$i".raw.vcf.gz;
gatk --java-options $GATK_options GenotypeGVCFs \
        -R $reference \
        -V $results/GVCF/$gvcf \
        -O $results/RAW_VCF/$rawvcf &
done
wait;

time_out="$time_out\nGenotype运行了：$(($(date +%s)-geno_start))秒"

anno_start=$(date +%s)
for i in $chrList_a;do
    annovcf="$1".'chr'"$i".raw.vcf.gz;
    table_annovar.pl $results/RAW_VCF/$annovcf /data/hg19/annodb -buildver hg19 -out $results/annovar-files/"$1".'chr'"$i".anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_latest,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a,revel,genomicSuperDups,intervar_20180118 -operation g,f,f,f,f,f,f,f,f,f,r,f -nastring . -vcfinput -polish &
done
wait;
head -1 $results/annovar-files/"$1".chr1.anno.hg19_multianno.txt > header
cat $results/annovar-files/"$1".chrMT.anno.hg19_multianno.txt $results/annovar-files/"$1".chr{1..5}.anno.hg19_multianno.txt> $results/annovar-files/"$1".anno.hg19_multianno.txt1
cat $results/annovar-files/"$1".chr{6..13}.anno.hg19_multianno.txt > $results/annovar-files/"$1".anno.hg19_multianno.txt2
cat $results/annovar-files/"$1".chr{14..22}.anno.hg19_multianno.txt $results/annovar-files/"$1".chr{X,Y}.anno.hg19_multianno.txt > $results/annovar-files/"$1".anno.hg19_multianno.txt3
sed -i '/^Chr/d' $results/annovar-files/"$1".anno.hg19_multianno.txt1
sed -i '/^Chr/d' $results/annovar-files/"$1".anno.hg19_multianno.txt2
sed -i '/^Chr/d' $results/annovar-files/"$1".anno.hg19_multianno.txt3
wait
cat header $results/annovar-files/"$1".anno.hg19_multianno.txt1 > $results/annovar-files/"$1"-chr1-5.anno.hg19_multianno.txt
cat header $results/annovar-files/"$1".anno.hg19_multianno.txt2 > $results/annovar-files/"$1"-chr6-13.anno.hg19_multianno.txt
cat header $results/annovar-files/"$1".anno.hg19_multianno.txt3 > $results/annovar-files/"$1"-chr14-Y.anno.hg19_multianno.txt
rm $results/annovar-files/"$1".anno.hg19_multianno.txt1
rm $results/annovar-files/"$1".anno.hg19_multianno.txt2
rm $results/annovar-files/"$1".anno.hg19_multianno.txt3
for i in  $results/annovar-files/"$1"-chr*-*.anno.hg19_multianno.txt;do
    h=`basename $i`;
    wh-tools dbanno  -f $results --omim --excel --local --panel  -i $h  &
done
wait
time_out="$time_out\nAnno运行了：$(($(date +%s)-anno_start))秒"

time_out="$time_out\ncalling_pipline运行了：$(($(date +%s)-time_start))秒\n"
echo -e $time_out >> $3/time.log
