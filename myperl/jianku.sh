bwa index $1
samtools faidx $1
java -XX:ParallelGCThreads=1 -jar /opt/seqtools/source/fusioncatcher/tools/picard/picard.jar CreateSequenceDictionary R=$1 O=$1.dict
