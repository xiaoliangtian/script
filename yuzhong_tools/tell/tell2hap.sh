for i in *chr11; do awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$2"\t"$3"\t"}' $i | grep 'chr11' > $i.hap;done
