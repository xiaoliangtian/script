#!/usr/bin/env perl
use Getopt::Long;
die "Usage:
    perl [script] -i [input]/--all --maf [eas_af]  "

GetOptions(
    "i=s" => \$input,
    "all" => \$all,
    "maf=f" => \$maf,
    "minNum=i" => \$minNum,
    "col=i" => \$col,
    "o=s" => \$output,
);

if ($all) {
   @files = <*anno.hg19_multianno.txt>; 
   if (scalar(@files) == 0 ){
       die "不存在注释文件";
   }
}
elsif ($input){
    @files = split(/\,/,$input);
}
else {
    die "必须要有输入参数";
}

foreach $file(@files){
    if (-e $file) {
        open (ANNO,$file);
    }
    else {
        die "不存在 $file 文件\n";
    }
    while (<ANNO>){
        chomp;
        
        
    }
    
}