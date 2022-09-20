 bcftools mpileup -T /workshop/project/Y_hapO/190311-txl_190307_NB500986_0194_AXXXXXXXXX/v5_cutadapt_all/analyse/results/bam/chrY.bed --thread 20 -f /data/hg19/reference/ucsc.hg19.fasta -a DP,AD -L 1000000 -d 1000000 *sorted.bam > all.g.vcf
for i in *.g.vcf; do bcftools call -Ac $i -o $i.2;done
for i in *.g.vcf.2; do perl /home/tianxl/pipeline/Y_hap0/need_list.pl $i /home/tianxl/pipeline/Y_hap0/Y_hap.list > $i.need;done
for i in *.2.need; do sed -i "s/^/$i\t/" $i; done
wait
cat *.need > all.result
#sed -i '/#CHROM/d' all.result
sed  "s/.*.need\t//" all.result > all.result.last
#cat /workshop/project/PD/190129-txl_190128_NB502022_0080_AHFHGYAFXY/results/GVCF/header  all.result > all.result.last
wait
