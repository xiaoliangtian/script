cnv-seq.pl --test $1 --ref $2 --window-size 1000000 --genome human  --global-normalization 
Rscript /home/tianxl/pipeline/CNV-seq/test.R $1-vs-$2.window-1000000.minw-4.cnv $1-vs-$2.window-1000000.minw-4.cnv > $1-vs-$2.window-1000000.minw-4.cnv.result
 
