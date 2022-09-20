h=$1
wh-tools cbvcf -i $1 -f `pwd` --gk3 --anno
ll
ll annovar-files/
wh-tools dbanno -f `pwd` -i QW-K33808-QW-K33811.anno.hg19_multianno.txt --panel --mito --omim --excel --local -fh
