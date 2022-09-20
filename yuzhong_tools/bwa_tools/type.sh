#bcftools call -Ac $1 > $1.1
sed  '/##/d' $1 > $1.1
cut -f 1-2,4-5,10- $1.1 > $1.2
#awk '{print $1"\t"$2"\t"$4"\t"$5"\t"$10"\t"$11"\t"$12"\t"$13"\t"$14"\t"$15"\t"$16"\t"$17}' $1.1 > $1.2
perl  /home/tianxl/pipeline/yuzhong_tools/bwa_tools/vcf2type.pl $1.2 $1.3
