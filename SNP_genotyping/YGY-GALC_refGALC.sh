
# if [ $3 == "SE" ];then
#     r2prim="/storage/project/SNP_genotyping/YGY-GALC/primerR_SE.fa"
#     r1prim="/storage/project/SNP_genotyping/YGY-GALC/primerF.fa"
# else
#     r2prim="/storage/project/SNP_genotyping/YGY-GALC/primerR.fa"
#     r1prim="/storage/project/SNP_genotyping/YGY-GALC/primerF.fa"
# fi

mkdir -p $2/cutprimer/



# cutprim(){
#     echo $1
#     fq=`basename $1`
#     sample=${fq/_R1*/} 
#     cutadapt -g file:$2 -G file:$3 -j 10 -o $4/cutprimer/"$sample"_R1.fastq.gz -p $4/cutprimer/"$sample"_R2.fastq.gz  $4/"$sample"_R1*.fastq.gz $4/"$sample"_R2*.fastq.gz 
# }
# export -f cutprim

# parallel --xapply -j 10 cutprim ::: `for i in $2/*R1*fastq.gz; do  echo $i;done` ::: $r1prim ::: $r2prim ::: $2
# #for i in $2/*R1*fastq.gz; do  h=`basename $i`;j=${i/_R1*/} ;echo $j;done | parallel -j 10 " perl /home/tianxl/pipeline/primer_tools/PCRprimerStat.pl "{}"_R1*.fastq.gz "{}"_R2*.fastq.gz /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.primer.txt all test1 test2 "{}" > "{}"_R1.fastq "

# wait;

#rm $2/*.fastq

cd $2/cutprimer/

analyse="$2/cutprimer/"

mkdir -p $analyse/results/bed_cov
wh-tools screen -b /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed --ref /storage/project/SNP_genotyping/YGY-GALC/200728-txl_Project_s1360g01085_544Samples_20200728_1595909549/refToGALC/ref/GALC.fa -f $analyse -t $1 -s cap  -aln $3 --gatk --gap 0 --no_cut
wait;

mkdir -p $analyse/results/RAW_VCF/
mkdir -p $analyse/results/GVCF/
mkdir -p $analyse/results/annovar-files/

for i in $analyse/results/dedup_bam/*.sorted.bam; do  h=`basename $i`;  bedtools coverage -b $i -a /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed > $analyse/results/bed_cov/$h.coverage;done
for i in $analyse/results/dedup_bam/*.sorted.bam; do  h=`basename $i`; bedtools coverage -b $i -a /storage/project/SNP_genotyping/YGY-GALC/YGY-GALC.bed -mean |awk '{print $NF}' - | paste $analyse/results/bed_cov/$h.coverage - > $analyse/results/bed_cov/$h.cov ;rm $analyse/results/bed_cov/$h.coverage;done
rm $analyse/results/bed_cov/all.cov
grep 'chr14' $analyse/results/bed_cov/*cov > $analyse/results/bed_cov/all.cov
mv $analyse/results/bed_cov/all.cov $analyse/results/

#for i in *KY-CES*.xlsx; do echo $i; xlsx2csv -s 3 $i | grep -E  '^Chr|SLC12A3' - ;echo "";  done > SLC12A3.csv
Date=`date +%Y.%m.%d`
for i in $analyse/results/*.xlsx; do j=`basename $i`; h=${j/.whanno.xlsx/}; xlsx2csv -s 1 -d tab $i |sed "s/^/$h\t/" ;echo "";  done > $analyse/results/YGY.GALC.xls
iconv  -t GBK $analyse/results/YGY.GALC.xls -o $analyse/results/YGY.GALC."$Date".xls
rm -rf $analyse/results/annovar-files/*vcf $analyse/results/annovar-files/*avinput $analyse/results/YGY.GALC.xls 

wait;
