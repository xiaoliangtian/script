#! /usr/bin/perl #-w
use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
        -o  output
        -m  mother_data_column
        -s  son_data_column
        -f  father_column
        -d  min_var_depth"  
unless @ARGV>=1;

########################

my $in;
my $out;
my $mom;
my $son;
my $dad;
my $min;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'm:i' => \$mom,
   's:i' => \$son,
   "f:i" => \$dad,
   "d:i" => \$min,
   
);


open IN, "<$in"
     or die "Cannot open file $in!\n";   
open OUT, ">>$out"
     or die "Cannot open file $out!\n";


my $line_count=0;
my $snp_ms=0;
my $snp_f=0;
my @result;
my $line;
while(<IN>) {
 chomp;
 $line=$_;

 if(substr($line,0,2)ne"##") {
  $line_count++;
  my @line=split/\t/,$line;
  push @line,0;
  my @mom=split/\:/,$line[$mom];
#  my @mom_var=split/\,/,$mom[1];
#  my $mom_var=$mom_var[1]/$mom[2];
  my @son=split/\:/,$line[$son];
#  my @son_var=split/\,/,$son[1];
#  my $son_var=$son_var[1]/$son[2];
  my @dad=split/\:/,$line[$dad];
#  my @dad_var=split/\,/,$dad[1];
#  my $dad_var=$dad_var[1]/$dad[2];

  if($line_count>1 and substr($line[$mom],0,3)ne"./." and substr($line[$son],0,3)ne"./." and substr($line[$dad],0,3)ne"./." ) {
  #my @line=split/\t/,$line;
 # print $line."\n";
#  my @mom=split/\:/,$line[$mom];  
  my @mom_var=split/\,/,$mom[1];
 # my $mom_var=$mom_var[1]/$mom[2]; 
#  my @son=split/\:/,$line[$son];
  my @son_var=split/\,/,$son[1];
 # my $son_var=$son_var[1]/$son[2];
#  my @dad=split/\:/,$line[$dad];
  my @dad_var=split/\,/,$dad[1];
 # my $dad_var=$dad_var[1]/$dad[2];
#  print $line."\n";

  if( ($mom[0]eq "0/0" or $mom[0]eq "1/1") and ($dad[0] eq "0/1")) {  

 #if($line[10]*1<0.1){   
     $line[$#line]=1;
  
    $line = $line."\t".'-';
    push @result,$line;
 } elsif($line_count==1) {
  push  @result,$line;
} }}}
my $result=join"\n",@result;
#print "$result\n";
print OUT "$result";
#my $match_fre=$snp_f/$snp_ms;
#print $snp_ms."\t"."$snp_f"."\t$match_fre\n";

