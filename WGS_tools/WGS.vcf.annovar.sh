#for i in *.diff ;do awk '{print $1"\t"$2"\t"$2"\t"$3"\t"$4}' $i > $i.avinput;done
#mkdir -p "$1"/annovar-files
for i in "$1"/RAW_VCF/*raw.vcf.gz; do h=`basename $i`; j=${h/.raw.vcf.gz/}; table_annovar.pl $i /data/hg19/annodb -buildver hg19 -out "$1"/annovar-files/$j.anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_latest,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a,revel,genomicSuperDups,intervar_20180118 -operation g,f,f,f,f,f,f,f,f,f,r,f -nastring . -vcfinput -polish;done
wait
for i in "$1"/annovar-files/*.anno.hg19_multianno.txt;do h=`basename $i`; wh-tools dbanno -f $1 --omim --excel --local --panel -i $h -fh ;done
