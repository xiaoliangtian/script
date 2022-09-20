
if [ $3 == "SE" ];then
    r2prim="/storage/project/SNP_genotyping/WKDC4/primerR_SE.fa"
    r1prim="/storage/project/SNP_genotyping/WKDC4/primerF.fa"
else
    r2prim="/storage/project/SNP_genotyping/WKDC4/primerR.fa"
    r1prim="/storage/project/SNP_genotyping/WKDC4/primerF.fa"
fi


sh /storage/project/SNP_genotyping/WKDC4/WKDC4_primer.sh $1

mkdir -p $2/cutprimer/
mkdir -p $2/cutada/

cutprim(){
    echo $1
    fq=`basename $1`
    sample=${fq/_R1*/} 
    
    cutadapt -a TGGAATTCTCGGGTGCCAAGGAACTCCAGTCACGT -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTG -o $4/cutada/"$sample"_R1.fastq.gz -p $4/cutada/"$sample"_R2.fastq.gz $4/"$sample"_R1*.fastq.gz $4/"$sample"_R2*.fastq.gz 
    wait;
    cutadapt -a file:"$2"_3 -A file:"$3"_3 -g file:$2 -G file:$3 -j 10 -o $4/cutprimer/"$sample"_R1.fastq.gz -p $4/cutprimer/"$sample"_R2.fastq.gz  $4/cutada/"$sample"_R1*.fastq.gz $4/cutada/"$sample"_R2*.fastq.gz --discard-untrimmed
}
export -f cutprim

parallel --xapply -j 10 cutprim ::: `for i in $2/*R1*fastq.gz; do  echo $i;done` ::: $r1prim ::: $r2prim ::: $2


cd $2/cutprimer/

analyse="$2/cutprimer/"

# wh-tools screen -b /storage/project/SNP_genotyping/WKDC4/WKDC4.bed -f $analyse --no_cut -t $1 -s amp --no_dedup --no_recal  --no_geno --no_anno -aln $3
####20.10.14 更换使用sentieon软件
cd $analyse
sentieon_pip -m --depth  -b /storage/project/SNP_genotyping/WKDC4/WKDC4.bed --qcstat -t 5  --aln $3
wait
cd -

mkdir -p $analyse/results/RAW_VCF/
mkdir -p $analyse/results/annovar-files/

for i in $analyse/results/bam/*.sorted.bam; do h=`basename $i`;j=${h/.sorted.bam/}; echo $j;done |parallel -j 10  "samtools mpileup -A -d 1000000 -l /storage/project/SNP_genotyping/WKDC4/WKDC4.snp.bed  -f /data/hg19/reference/hs37d5.fasta results/bam/"{}".sorted.bam  | java -Xmx20g -jar /opt/seqtools/source/VarScan.jar mpileup2cns --min-var-freq 0.15 --min-freq-for-hom 0.85 --output-vcf 1  -  > $analyse/results/RAW_VCF/"{}".snp.raw.vcf"

for i in $analyse/results/bam/*.sorted.bam; do h=`basename $i`;j=${h/.sorted.bam/}; echo $j;done |parallel -j 10  "samtools mpileup -A -d 1000000 -l /storage/project/SNP_genotyping/WKDC4/WKDC4.exon.bed  -f /data/hg19/reference/hs37d5.fasta results/bam/"{}".sorted.bam  | java -Xmx20g -jar /opt/seqtools/source/VarScan.jar mpileup2cns --min-var-freq 0.15 --min-freq-for-hom 0.85 --output-vcf 1 --variants -  > $analyse/results/RAW_VCF/"{}".exon.raw.vcf"

parallel -j 10 " table_annovar.pl {} /data/hg19/annodb -buildver hg19 -out $analyse/results/annovar-files/"\`basename {} .raw.vcf\`".anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_latest,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a,revel,genomicSuperDups,intervar_20180118 -operation g,f,f,f,f,f,f,f,f,f,r,f -nastring . -vcfinput -polish" ::: `for i in $analyse/results/RAW_VCF/*.raw.vcf;do echo $i;done`
wait;

<<BLOCK
for i in $analyse/results/annovar-files/*exon.anno.hg19_multianno.txt;do
  annoName=`basename $i .anno.hg19_multianno.txt`
  python /workshop/project/SNP_genotyping/RJYY/filter-vcf.py /workshop/project/SNP_genotyping/RJYY/RJYY_SNP_targets.bed $i > $analyse/results/$annoName.txt
done
wait;
BLOCK

parallel -j 10 "wh-tools dbanno -f $analyse/results -i \`basename {}\` -fh --panel  --omim --excel --local -maf 100 --no_filter" ::: `for i in $analyse/results/annovar-files/*exon.anno.hg19_multianno.txt;do echo $i;done`
wait;

cd $analyse/results/annovar-files/
perl /storage/project/SNP_genotyping/WKDC4/WKDC4.snp.stat.pl -anno  /storage/project/SNP_genotyping/WKDC4/WKDC4.rs.anno -o ../WKDC4.snp.txt 

cd -

Date=`date +%Y.%m.%d`
iconv  -t GBK $analyse/results/WKDC4.snp.txt -o $analyse/results/WKDC4.snp."$Date".xls
for i in $analyse/results/*.xlsx; do j=`basename $i`; h=${j/.whanno.xlsx/}; xlsx2csv -s 1 -d tab $i |sed "s/^/$h\t/" ;  done > $analyse/results/WKDC4.exon.xls
perl /home/tianxl/pipeline/SNP_genotyping/WKDC4.exon.combine.pl $analyse/results/WKDC4.exon.xls  $analyse/results/WKDC4.exon1.xls
iconv  -t GBK $analyse/results/WKDC4.exon1.xls -o $analyse/results/WKDC4.exon."$Date".xls
#for i in $analyse/results/*.xlsx; do echo $i; xlsx2csv -s 1 -d tab $i  ;echo "";  done > $analyse/results/WKDC4.exon.xls
#iconv  -t GBK $analyse/results/WKDC4.exon.xls -o $analyse/results/WKDC4.exon."$Date".xls
rm -rf $analyse/results/annovar-files/*vcf $analyse/results/annovar-files/*avinput $analyse/results/WKDC4.exon.xls $analyse/results/WKDC4.exon1.xls $analyse/results/WKDC4.snp.txt

wait;
