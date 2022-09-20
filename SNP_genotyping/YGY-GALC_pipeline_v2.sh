
if [ $3 == "SE" ];then
    r2prim="/storage/project/SNP_genotyping/YGY-GALC/primerR_SE.fa"
    r1prim="/storage/project/SNP_genotyping/YGY-GALC/primerF.fa"
else
    r2prim="/storage/project/SNP_genotyping/YGY-GALC/primerR.fa"
    r1prim="/storage/project/SNP_genotyping/YGY-GALC/primerF.fa"
fi

mkdir -p $2/cutprimer/



cutprim(){
    echo $1
    fq=`basename $1`
    sample=${fq/_R1*/} 
    cutadapt -g file:$2 -G file:$3 -j 10 -o $4/cutprimer/"$sample"_R1.fastq.gz -p $4/cutprimer/"$sample"_R2.fastq.gz  $4/"$sample"_R1*.fastq.gz $4/"$sample"_R2*.fastq.gz 
}
export -f cutprim

parallel --xapply -j 10 cutprim ::: `for i in $2/*R1*fastq.gz; do  echo $i;done` ::: $r1prim ::: $r2prim ::: $2
#for i in $2/*R1*fastq.gz; do  h=`basename $i`;j=${i/_R1*/} ;echo $j;done | parallel -j 10 " perl /home/tianxl/pipeline/primer_tools/PCRprimerStat.pl "{}"_R1*.fastq.gz "{}"_R2*.fastq.gz /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.primer.txt all test1 test2 "{}" > "{}"_R1.fastq "

wait;

#rm $2/*.fastq

cd $2/cutprimer/

analyse="$2/cutprimer/"

mkdir -p $analyse/results/bed_cov
wh-tools screen -b /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed -f $analyse -t $1 -s cap  -aln $3 --gatk --gap 0
wait;

mkdir -p $analyse/results/RAW_VCF/
mkdir -p $analyse/results/GVCF/
mkdir -p $analyse/results/annovar-files/

for i in $analyse/results/dedup_bam/*.sorted.bam; do  h=`basename $i`;  bedtools coverage -b $i -a /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed > $analyse/results/bed_cov/$h.coverage;done
for i in $analyse/results/dedup_bam/*.sorted.bam; do  h=`basename $i`; bedtools coverage -b $i -a /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed -mean |awk '{print $NF}' - | paste $analyse/results/bed_cov/$h.coverage - > $analyse/results/bed_cov/$h.cov ;rm $analyse/results/bed_cov/$h.coverage;done
rm $analyse/results/bed_cov/all.cov
grep 'chr14' $analyse/results/bed_cov/*cov > $analyse/results/bed_cov/all.cov
mv $analyse/results/bed_cov/all.cov $analyse/results/

#for i in $2/results/bam/*.sorted.bam; do h=`basename $i`;j=${h/.sorted.bam/}; echo $j;done |parallel -j 10  "samtools mpileup -A -d 1000000 -l /storage/project/SNP_genotyping/WKDC4/WKDC4.snp.bed  -f /data/hg19/reference/hs37d5.fasta results/bam/"{}".sorted.bam  | java -Xmx20g -jar /opt/seqtools/source/VarScan.jar mpileup2cns --min-var-freq 0.15 --min-freq-for-hom 0.85 --output-vcf 1  -  > $2/results/RAW_VCF/"{}".snp.raw.vcf"

#for i in $2/results/bam/*.sorted.bam; do h=`basename $i`;j=${h/.sorted.bam/}; echo $j;done |parallel -j 10  "samtools mpileup -A -d 1000000 -l /storage/project/SNP_genotyping/WKDC4/WKDC4.exon.bed  -f /data/hg19/reference/hs37d5.fasta results/bam/"{}".sorted.bam  | java -Xmx20g -jar /opt/seqtools/source/VarScan.jar mpileup2cns --min-var-freq 0.15 --min-freq-for-hom 0.85 --output-vcf 1 --variants -  > $2/results/RAW_VCF/"{}".exon.raw.vcf"
<<BLOCK
gatk(){
    bamName=`basename $1 .recal.dedup.sorted.bam`
    gatk --java-options '-Xmx4g' HaplotypeCaller \
            -R /data/hg19/reference/hs37d5.fasta \
            -I $i \
            -L /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.intervals \
            -ERC GVCF \
            -O $2/results/GVCF/$bamName.g.vcf.gz 2>$2/log/$bamName.call_gvcf.log
    wait;
    gatk --java-options '-Xmx4g' GenotypeGVCFs \
                -R /data/hg19/reference/hs37d5.fasta \
                -V $2/results/GVCF/$bamName.g.vcf.gz \
                -O $2/results/RAW_VCF/$bamName.raw.vcf.gz
    wait;
    table_annovar.pl $2/results/RAW_VCF/$bamName.raw.vcf.gz /data/hg19/annodb -buildver hg19 -out $2/results/annovar-files/"$bamName".anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_latest,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a,revel,genomicSuperDups,intervar_20180118 -operation g,f,f,f,f,f,f,f,f,f,r,f -nastring . -vcfinput -polish
    wait;
    wh-tools dbanno -f $2/results -i "$bamName".anno.hg19_multianno.txt -fh --panel --mito --omim --excel --local -maf 100 --no_filter 
}
export -f gatk


parallel --xapply  -j 10 gatk ::: `for i in $analyse/results/bam/*.recal.dedup.sorted.bam;do echo $i;done` ::: $analyse
wait;

<<BLOCK
for i in $2/results/annovar-files/*exon.anno.hg19_multianno.txt;do
  annoName=`basename $i .anno.hg19_multianno.txt`
  python /workshop/project/SNP_genotyping/RJYY/filter-vcf.py /workshop/project/SNP_genotyping/RJYY/RJYY_SNP_targets.bed $i > $2/results/$annoName.txt
done
wait;
BLOCK



#for i in *KY-CES*.xlsx; do echo $i; xlsx2csv -s 3 $i | grep -E  '^Chr|SLC12A3' - ;echo "";  done > SLC12A3.csv
Date=`date +%Y.%m.%d`
for i in $analyse/results/*.xlsx; do j=`basename $i`; h=${j/.whanno.xlsx/}; xlsx2csv -s 1 -d tab $i |sed "s/^/$h\t/" ;echo "";  done > $analyse/results/YGY.GALC.xls
iconv  -t GBK $analyse/results/YGY.GALC.xls -o $analyse/results/YGY.GALC."$Date".xls
rm -rf $analyse/results/annovar-files/*vcf $analyse/results/annovar-files/*avinput $analyse/results/YGY.GALC.xls 

wait;
