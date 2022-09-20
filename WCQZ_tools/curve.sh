for i in *.dedup.sorted.bam
do
samtools view $i |  head -100000 - | perl /home/tianxl/pipeline/myperl/print_len.pl - >$i.sam.list
Rscript /home/tianxl/pipeline/myperl/curve.r  $i.sam.list $i
done
