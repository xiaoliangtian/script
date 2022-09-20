bwa mem  -t 8 -R "@RG\tID:$1\tLB:$1\tSM:$1\tPL:illumina" /home/xiaoliang.tian/pipeline/tools/YG_tools/database/SplitGenome/chr11.fa $1_R1.fastq.gz   | samtools view -bS - > $1.bam 
# mem -t 8 -R "@RG\tID:$1\tLB:$1\tSM:$1\tPL:illumina" exon19.ref bwa mem -t 8 -R "@RG\tID:$1\tLB:$1\tSM:$1\tPL:illumina" $2/ucsc.hg19.fasta $3/$1_R1_001.fastq.gz | samtools view -bS - > $4/$1.bam 2>$6/$1.aln.log
samtools sort -o $1.sorted.bam $1.bam 
