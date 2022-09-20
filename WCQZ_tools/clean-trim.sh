#!/bin/bash

read1=$1
read2=$2
q=$3
if [ -n "$3" ]
then

java -jar /home/xiaoliang.tian/pipeline/third-party/trimmomatic-0.32.jar  PE -threads 30 -phred$q $read1  $read2  $read1.pe $read1.ue  $read2.pe $read2.ue ILLUMINACLIP:/home/xiaoliang.tian/pipeline/tools/WCQZ_tools/adaptor.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:10 MINLEN:15
else
  echo parameter read1 read2  q exists !
fi

