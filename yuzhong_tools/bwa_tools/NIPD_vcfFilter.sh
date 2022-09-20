i=$1

gatk --java-options -Xmx10g VariantRecalibrator -R /data/hg19/reference/ucsc.hg19.fasta -V $1 -mode SNP --max-gaussians 4 -O "$i".snp.recal  --tranches-file "$i".snp.tranches  -an QD  -an MQRankSum -an ReadPosRankSum -an FS -an SOR -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 --resource:hapmap,known=false,training=true,truth=true,prior=15.0 /data/hg19/gatk/hapmap_3.3.hg19.sites.vcf  --resource:omni,known=false,training=true,truth=false,prior=12.0 /data/hg19/gatk/1000G_omni2.5.hg19.sites.vcf --resource:1000G,known=false,training=true,truth=false,prior=10.0 /data/hg19/gatk/1000G_phase1.snps.high_confidence.hg19.sites.vcf --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 /data/hg19/gatk/dbsnp_138.hg19.vcf
wait
gatk --java-options -Xmx10g  ApplyVQSR -R /data/hg19/reference/hs37d5.fasta -V $1 -mode SNP -O "$i".snp.vqsr.vcf --recal-file "$i".snp.recal  --tranches-file "$i".snp.tranches  --truth-sensitivity-filter-level 99.0
wait

grep -E '^#|PASS' "$i".snp.vqsr.vcf > $i.1
sh /home/tianxl/pipeline/yuzhong_tools/bwa_tools/type.sh $i.1
sed -i 's/|0/\/0/g' $i.1.3
sed -i 's/|1/\/1/g' $i.1.3
sed -i 's/|2/\/2/g' $i.1.3
sed -i 's/\:0,0/\:0,0\:0/g' $i.1.3
