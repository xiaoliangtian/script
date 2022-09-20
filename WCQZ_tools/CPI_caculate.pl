#! /usr/bin/perl -w
use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [snp.site] -o [output_file] -m [mother_column] -s [son_column] -f [father_column]

        -i  input: selected mom and son's site conclude but in spite of father site
        -o  output
        -m  mother_data_column
        -s  son_data_column
        -f  father_column"  
unless @ARGV>=1;

########################

my $in;
my $out;
my $mom;
my $son;
my $dad;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'm:i' => \$mom,
   's:i' => \$son,
   "f:i" => \$dad,
   
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
my $Pmin;
my $CPI;
my $PI1=1;
my $PI2=1;
my $PI3=1;
my $PI4=1;
my $PI5=1;
my $PI6=1;
my $PI7=1;
my $PI8=1;
my $PI9=1;
my $PI10=1;
my $PI11=1;
my $PI12=1;
my $PI13=1;
my $PI14=1;
my $PI15=1;
my $PI16=1;
my $PI17=1;
my $PI18=1;

while(<IN>) {
 chomp;
 $line=$_;

 if(substr($line,0,3)eq"chr") {
  $line_count++;
  my @line=split/\t/,$line;
  push @line,0;
  $Pmin = $line[11];

  if ($line_count>1){
  my @mom=split/\:/,$line[$mom];
  my @son=split/\:/,$line[$son];
  my @dad=split/\:/,$line[$dad];

  my @son_var=split/\,/,$son[1];
  my $son_var=$son_var[1]/$son[2];

 
   if(($mom[0] ne $dad[0] and $son_var<0.5 && $dad[0] eq '1/1'&& $Pmin ne '.' )){
      $PI1 *=  1/$Pmin;}
  
   if(($mom[0] ne $dad[0] and $son_var<0.5 && $dad[0] eq '0/1'&& $Pmin ne '.' )){
   $PI4 *=  1/(2*$Pmin);}

   if(($mom[0] ne $dad[0] and $son_var>0.5 && $dad[0] eq '0/1'&& $Pmin ne '.' )){
   $PI7 *=  1/(2*(1-$Pmin));}

   if(($mom[0] ne $dad[0] and $son_var>0.5 && $dad[0] eq '0/0'&& $Pmin ne '.' )){
     $PI10 *=  1/(1-$Pmin);}

    
   if ($mom[0] eq $dad[0] and $dad[0] eq '1/1' and $Pmin ne '.' and $Pmin ne '1') {
     $PI13 *=  0.0001/(1-$Pmin);}  

    if ($mom[0] eq $dad[0] and $dad[0] eq '0/0' and $Pmin ne '.' and $Pmin ne '0'){
     $PI16 *=  0.0001/$Pmin;}
}
 }  
  }  

 $CPI = $PI1*$PI2*$PI3*$PI4*$PI5*$PI6*$PI7*$PI8*$PI9*$PI10*$PI11*$PI12*$PI13*$PI14*$PI15*$PI16*$PI17*$PI18;
 $CPI =~ s/e/E/;
#print $PI1.','.$PI2.','.$PI3.','.$PI4.','.$PI5.','.$PI6.','.$PI7.','.$PI8.','.$PI9.','.$PI10.','.$PI11.','.$PI12.','.$PI13.','.$PI14.','.$PI15.','.$PI16.','.$PI17.','.$PI18."\n";
print  OUT "The CPI is ". "$CPI";
    
