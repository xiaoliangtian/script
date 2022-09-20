#参数1:intervals
#参数2:输入文件bam
sample=${2/.dedup.sorted.bam/}
out=${1/.intervals/}
gatk  HaplotypeCaller -R /data/hg19/reference/hs37d5.fasta  -L  $1 -I $2 -O test.vcf -ERC GVCF -ip 100 --native-pair-hmm-threads  10 -bamout "$sample"."$out".bam
