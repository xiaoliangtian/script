parallel --xapply -j 10 "wh-tools dbanno -f {2}/results/ --omim --excel --local --panel -i {1}" ::: `for i in $1/results/annovar-files/*anno.hg19_multianno.txt; do h=\`basename $i\`;echo $h;done` ::: $1
wait
python /workshop/ywu/tools/mitomap/mitomap.py  $1/results/samples.txt $1
wait
python /opt/seqtools/source/wh-tools/src/WES/deca-annotated.py $1/results/cnv_xhmm/analyzed/DECA.gff3 $1/results/cnv_xhmm/analyzed/annotated_targets.refseq.loci $1/results/cnv_xhmm $1/results/dedup_bam
wait
python /home/nicky/snipt_code/stat-classify.py  $1/results/ $1/results/QC-report.txt $1/results/smncnv_results.txt
wait
cd $1/results/
python /workshop/ywu/tools/refill.py $1/results/samples.txt Y Y
wait
