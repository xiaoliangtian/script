for i in *raw.vcf; do perl /home/xiaoliang.tian/pipeline/myperl/header.pl $i $i.anno.hg19_multianno.txt > $i.anno.hg19_multianno.txt.head ;done
