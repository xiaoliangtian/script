doit(){

filename=${1/.deduped.bam/}

cnvnator -root $filename.root -tree $1  -chrom $(seq -f 'chr%g' 1 22) chrX chrY
cnvnator -root $filename.root -his $2  -d /workshop/zhouhl/software/FREEC-11.4/grch_chr/
cnvnator -root $filename.root  -stat $2 2&>$filename.log
cnvnator -root $filename.root -partition $2
cnvnator -root $filename.root -call $2 > $filename.cnv.out
}

export -f doit
parallel -j 5  doit ::: `for i in *.deduped.bam; do echo $i;done` ::: $1 
