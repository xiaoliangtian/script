#/bin/bash
date_start=$(date +%s);
rename _001.fastq.gz .fastq.gz *
##start to calling type
for i in *R1.fastq.gz ;do echo $i ;done > list
sed -i 's/_R1.fastq.gz//' list
mkdir analyse
mkdir log 
##Set the number of threads
thread_num=$1;
tempfifo="my_temp_fifo"
mkfifo ${tempfifo}
exec 6<>${tempfifo}
rm -f ${tempfifo}
for ((i=1;i<=${thread_num};i++))
do
{
    echo "start $i..."
}
done >&6
for i in `cat list`; do 
 { read -u6
   { sleep 1
	/workshop/project/NIPT/software/NIPT/fastq_trim -e 36 -m 36 -1 "$i"_R1.fastq.gz -2 "$i"_R2.fastq.gz -o analyse/$i 2>&1 > log/"$i".trim.log
	/workshop/project/NIPT/software/NIPT/bowtie-1.2.2-linux-x86_64/bowtie -t -k 1 -m 1 -v 0 -l 36 -y -p 8 -X 500 -S --quiet --chunkmbs 256 --no-unal -q /home/tianxl/database/hg19/NIPT_ref/human_g1k_v37.mask.fasta -1 analyse/"$i".trim_1.fq -2 analyse/"$i".trim_2.fq --un analyse/"$i".un.fq 2>log/"$i".bowtie.log | samtools view -bh -F0x4 - -o analyse/"$i".pair.bam
	cat analyse/"$i".un_1.fq analyse/"$i".un_2.fq | /workshop/project/NIPT/software/NIPT/bowtie-1.2.2-linux-x86_64/bowtie -t -c -k 1 -m 1 -v 0 -l 36 -y -p 8 -S --quiet --chunkmbs 256 --best --strata -q /home/tianxl/database/hg19/NIPT_ref/human_g1k_v37.mask.fasta - 2>log/"$i".un.log | samtools view -bh - -o analyse/"$i".single.bam
	samtools cat -o analyse/"$i".bam analyse/"$i".pair.bam analyse/"$i".single.bam
	#rm RHWL16009861_L1_50.single.bam RHWL16009861_L1_50.pair.bam RHWL16009861_L1_50.un_1.fq RHWL16009861_L1_50.un_2.fq
	/workshop/project/NIPT/software/NIPT/bam2block_uniq -m 36 -U /workshop/project/NIPT/software/NIPT/uniqBin.bin2pos.gz -C /workshop/project/NIPT/software/NIPT/wgEncodeCrgMapabilityAlign36mer_1.sort.b37.BedGraph.gz analyse/"$i".bam -o analyse/"$i" > analyse/"$i".blk 2> analyse/"$i".log
	/workshop/project/NIPT/software/NIPT/fastq_count analyse/*.trim_1.fq analyse/*.trim_2.fq > analyse/fastq_count.tsv
     echo "done!">&6
  }& 
}
done
wait
cd analyse
Rscript /workshop/project/NIPT/software/NIPT/plotNRCvsGC.R ./ resultNIPT .trim_1.fq
