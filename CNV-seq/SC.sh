for i in *.dedup.sorted.bam
do
 { 
samtools view -F 4 $i |  perl -lane 'print "$F[2]\t$F[3]"' > $i.hits
sed -i 's/chr//g' $i.hits && echo "done!"
}&
done
wait
