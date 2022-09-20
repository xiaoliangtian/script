start=$[$2-100];
end=$[$2+100];
/opt/seqtools/bin/samtools view -h $1 $5:$start-$end  > $1.$2.sam
start1=$[$2-25];
end1=$[$2+25];
echo $5:$start1:$end1 > test.bed
sed -i 's/\:/\t/g' test.bed
/opt/seqtools/source/bedtools2-2.25.0/bin/bedtools getfasta -fi /data/hg19/reference/hs37d5.fasta -bed test.bed -fo test 
str=`sed '/>/d' test | tr 'a-z' 'A-Z'`
#echo ${str:2:1}
#echo $str $str
#ref=`/opt/seqtools/source/bedtools2-2.25.0/bin/bedtools getfasta -fi /data/hg19/reference/hs37d5.fasta -bed test.bed | sed '/>/d' | tr 'a-z' 'A-Z' |sed "s/${str:0:24+${#3}}/${str:0:24}$3/"`
#alt=`/opt/seqtools/source/bedtools2-2.25.0/bin/bedtools getfasta -fi /data/hg19/reference/hs37d5.fasta -bed test.bed | sed '/>/d' | tr 'a-z' 'A-Z' |sed "s/${str:0:24+${#3}}/${str:0:24}$4/"`
if [ $3 ];then
ref=`sed '/>/d' test | tr 'a-z' 'A-Z' |sed "s/${str:0:24+${#3}}/${str:0:24}$3/"`
alt1=`sed '/>/d' test | tr 'a-z' 'A-Z' |sed "s/${str:0:24+${#3}}/${str:0:24}$4/"`
if [ $6 ];then
  alt2=`sed '/>/d' test | tr 'a-z' 'A-Z' |sed "s/${str:0:24+${#3}}/${str:0:24}$6/"`
fi
else 
  echo "\$3 can not be embty!"
fi
echo $ref $alt1 $alt2
#ref=`sed "s/${str:39:${#3}}/$3/" `
#alt=`sed "s/${str:39:${#3}}/$4/" $str`
if [ $6 ];then
  grep -E "$alt1|$alt2" $1.$2.sam |awk 'BEGIN{FS="\t";OFS="\t"}{if ($5>=0) $5=60}1' - > $1.$2.sam.need
else
  grep -E "$ref|$alt1" $1.$2.sam |awk 'BEGIN{FS="\t";OFS="\t"}{if ($5>=0) $5=60}1' - > $1.$2.sam.need
fi
grep '^@' $1.$2.sam > header
cat header $1.$2.sam.need | /opt/seqtools/bin/samtools view -bS - > $1.$2.sam.need.bam
/opt/seqtools/bin/samtools index $1.$2.sam.need.bam
rm $1.$2.sam  test.bed $1.$2.sam.need  
