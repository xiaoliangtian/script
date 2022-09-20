for i in *.diff ;do awk '{print $1"\t"$2"\t"$2"\t"$3"\t"$4}' $i > $i.avinput;done
for i in *.avinput; do table_annovar.pl $i /data/hg19/annodb -buildver hg19 -out $i.anno -remove -protocol refGene,1000g2015aug_all,1000g2015aug_eas,dbscsnv11,cosmic70,clinvar_latest,avsnp150,esp6500siv2_all,esp6500siv2_ea,dbnsfp33a,revel,genomicSuperDups -operation g,f,f,f,f,f,f,f,f,f,f,r -nastring . -polish;done
for i in *.avinput.anno.hg19_multianno.txt;do python /home/nicky/apps/wh-tools/src/WES/db_anotations.py -i $i --panel --omim --tab --local -maf 100 --no_filter;done
