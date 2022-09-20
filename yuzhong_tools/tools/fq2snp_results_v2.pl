#! usr/bin/perl -w
use strict;

my $snp_results="./snp_results";
mkdir($snp_results,0777);
my $rest_fq="./rest_fq";
mkdir($rest_fq,0777);

my $sh="CRC27fq2snp_new.sh";
open SH,">>$sh" or die "Error in opening file $sh\n";

my $dir="./";
opendir DIR, "$dir" or die "Error in opening $dir\n";
my $filename;
while($filename=readdir(DIR)) {
   if($filename=~/R1\.fastq.gz/) {
      my $len=length($filename);
      my $sample=substr($filename,0,$len-12);
      my $r_fq=$sample."_R2.fastq.gz";
      my $f_rest=$sample."_R1_rest.fq";
      my $r_rest=$sample."_R2_rest.fq";
      my $results=$sample.".txt";
      print SH "perl /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/snp_chip_v4.pl $filename $r_fq /home/xiaoliang.tian/pipeline/tools/yuzhong_tools/tools/yuzhong.100.fasta $rest_fq/$f_rest $rest_fq/$r_rest $snp_results/$results\n";

    }
}

