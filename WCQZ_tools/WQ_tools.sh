for i in *R1.fastq.gz; do echo $i ;done > name
perl /home/xiaoliang.tian/pipeline/myperl/sample_list.pl name wesv3 cap 180127_NB502022_0014_AHVWJTAFXX-0128_WQ_txl > sample_list.txt
perl /home/xiaoliang.tian/pipeline/tools/wes_cmd_my1.pl -i sample_list.txt -o cmd.txt -s /home/xiaoliang.tian/pipeline/tools -g /opt/seqtools/gatk -f ./
