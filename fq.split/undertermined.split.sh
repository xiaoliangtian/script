name=${1/_*/}
fq1=$1
fq2=${1/R1/R2}
parallel --will-cite --xapply -j 20 "zgrep -A3 '1:N:0:{2}' $fq1  | grep -v '^--$' | gzip - > {1}_combine_R1.fastq.gz" ::: `awk '{print $1}' bar.txt` ::: `awk '{print $2}' bar.txt`
parallel --will-cite --xapply -j 20 "zgrep -A3 '2:N:0:{2}' $fq2  | grep -v '^--$' | gzip - > {1}_combine_R2.fastq.gz" ::: `awk '{print $1}' bar.txt` ::: `awk '{print $2}' bar.txt`
wait;