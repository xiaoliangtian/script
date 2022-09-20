#! /usr/bin/perl #-w
#use strict;
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
my $ref;
my $rate;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'm:i' => \$mom,
   's:i' => \$son,
   "f:i" => \$dad,
   "d:i" => \$min,
   "r:f"=> \$rate,
   
);


open IN, "<$in"
     or die "Cannot open file $in!\n";   
open OUT, ">$out"
     or die "Cannot open file $out!\n";

my @son_ty;
my $son1;
my $mom_dad1;
my $mom_dad2;
my $mom_dad3;
my %hash1;
my $son_ty1;
my $son_ty2;
my $son_ty3;
my %hash2;
my @line3="";


 
my $header = <IN>;
$header =~s/\n//;
$header = $header."\t".'M1M1M1'."\t"."M1M1M2\tM1M1P1\tM1M2P1\tP1P1P1\tP1P1P2\tP1P1M1\tP1P2M1\n";
print "$header";
while (<IN>) {
	chomp;
	my @line=(split/\t/,$_);
	my @mom=split/\//,$line[$mom];
	my @son=split/\//,$line[$son];
	my @dad=split/\//,$line[$dad];
	my $mom1 = M1.'_'.$mom[0];
	my $mom2 = M2.'_'.$mom[1];
	my $dad1 = P1.'_'.$dad[0];
	my $dad2 = P2.'_'.$dad[1];
	my @mom_dad = ($mom1,$mom2,$dad1,$dad2);
	$hash2{M1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{M2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P1.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.M2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P1.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.M2.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P1.'_'.$son[2]}=1;
$hash2{P2.'_'.$son[0].'|'.P2.'_'.$son[1].'|'.P2.'_'.$son[2]}=1;

#shift @mom_dad;
shift @son_ty;
foreach $mom_dad1(@mom_dad) {
	foreach $mom_dad2(@mom_dad) {
		foreach $mom_dad3(@mom_dad) {
			$hash1{$mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3}=1;
			#print $mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3."\n";
		}
	}
}
foreach (keys %hash2) {
	if (exists $hash1{$_}) {
		#print $_."\n";
		my @line1 = split (/\|/,$_);
		foreach $line1(@line1){
			my @line2 = split (/\_/,$line1);
			push @line3,$line2[0];
		}
	shift @line3;
	my $line3 = join ("",@line3);
	#print $line3."\n";
	$hash3{$line3}++;
	@line3 ="";
	}
}
print "$_\t";
if (exists ($hash3{M1M1M1}) or exists ($hash3{M2M2M2} )) {
	print "yes\t";
}
if (!exists ($hash3{M1M1M1}) and !exists($hash3{M2M2M2})) {
	print "NO\t";
}
if(exists $hash3{M1M1M2} or exists $hash3{M1M2M1} or exists $hash3{M1M2M2} or exists $hash3{M2M1M1} or exists $hash3{M2M1M2} or exists $hash3{M2M2M1}) {
	print "yes\t";
}
if(!exists $hash3{M1M1M2} and !exists $hash3{M1M2M1} and !exists $hash3{M1M2M2} and !exists $hash3{M2M1M1} and !exists $hash3{M2M1M2} and !exists $hash3{M2M2M1}) {
	print "NO\t";
}
if(exists $hash3{M1M1P1} or exists $hash3{M1M1P2} or exists $hash3{M1P1M1}  or exists $hash3{M1P2M1} or exists $hash3{M2M2P1} or exists $hash3{M2M2P2} or exists $hash3{M2P1M2} or exists $hash3{M2P2M2} or exists $hash3{P1M1M1} or exists $hash3{P1M2M2} or exists $hash3{P2M1M1} or exists $hash3{P2M2M2}) {
	print "YES\t";
}
if(!exists $hash3{M1M1P1} and !exists $hash3{M1M1P2} and !exists $hash3{M1P1M1}  and !exists $hash3{M1P2M1} and !exists $hash3{M2M2P1} and !exists $hash3{M2M2P2} and !exists $hash3{M2P1M2} and !exists $hash3{M2P2M2} and !exists $hash3{P1M1M1} and !exists $hash3{P1M2M2} and !exists $hash3{P2M1M1} and !exists $hash3{P2M2M2}) {
	print "NO\t";
}
if(exists $hash3{M1M2P1}  or exists $hash3{M1M2P2} or exists $hash3{M1P1M2} or exists $hash3{M1P2M2} or exists $hash3{M2M1P1} or exists $hash3{M2M1P2} or exists $hash3{M2P1M1} or exists $hash3{M2P2M1} or exists $hash3{P1M1M2} or exists $hash3{P1M2M1} or exists $hash3{P2M1M2}  or exists  $hash3{P2M2M1} ){
	print "YES\t";
}
if(!exists $hash3{M1M2P1}  and !exists $hash3{M1M2P2} and !exists $hash3{M1P1M2} and !exists $hash3{M1P2M2} and !exists $hash3{M2M1P1} and !exists $hash3{M2M1P2} and !exists $hash3{M2P1M1} and !exists $hash3{M2P2M1} and !exists $hash3{P1M1M2} and !exists $hash3{P1M2M1} and !exists $hash3{P2M1M2}  and !exists  $hash3{P2M2M1} ){
	print "NO\t";
}
if(exists $hash3{P1P1P1}  or exists $hash3{P1P2P2} ) {
	print "YES\t";
}
if(!exists $hash3{P1P1P1}  and !exists $hash3{P1P2P2} ) {
	print "NO\t";
}
if(exists $hash3{P1P1P2} or exists $hash3{P1P2P1} or exists $hash3{P1P2P2} or exists $hash3{P2P1P1} or exists $hash3{P2P1P2} or exists $hash3{P2P2P1}) {
	print "YES\t";
}
if(!exists $hash3{P1P1P2} and !exists $hash3{P1P2P1} and !exists $hash3{P1P2P2} and !exists $hash3{P2P1P1} and !exists $hash3{P2P1P2} and !exists $hash3{P2P2P1}) {
	print "NO\t";
} 
if(exists $hash3{M1P1P1} or exists $hash3{M1P2P2} or exists $hash3{M2P1P1} or exists $hash3{M2P2P2} or exists $hash3{P1M1P1} or exists $hash3{P1M2P1} or exists $hash3{P1P1M1} or exists $hash3{P1P1M2} or exists $hash3{P2M1P2} or exists $hash3{P2M2P2} or exists $hash3{P2P2M1}  or exists $hash3{P2P2M2} ) {
	print "YES\t";
}
if(!exists $hash3{M1P1P1} and !exists $hash3{M1P2P2} and !exists $hash3{M2P1P1} and !exists $hash3{M2P2P2} and !exists $hash3{P1M1P1} and !exists $hash3{P1M2P1} and !exists $hash3{P1P1M1} and !exists $hash3{P1P1M2} and !exists $hash3{P2M1P2} and !exists $hash3{P2M2P2} and !exists $hash3{P2P2M1}  and !exists $hash3{P2P2M2} ) {
	print "NO\t";
}
if(exists $hash3{M1P1P2} or exists $hash3{M1P2P1} or exists $hash3{M2P1P2} or exists $hash3{M2P2P1} or exists $hash3{P1M1P2} or exists $hash3{P1M2P2} or exists $hash3{P1P2M1} or exists $hash3{P1P2M2} or exists $hash3{P2M1P1} or exists $hash3{P2M2P1} or exists $hash3{P2P1M1} or exists $hash3{P2P1M2} ) {
	print "YES\t";
}
if(!exists $hash3{M1P1P2} and !exists $hash3{M1P2P1} and !exists $hash3{M2P1P2} and !exists $hash3{M2P2P1} and !exists $hash3{P1M1P2} and !exists $hash3{P1M2P2} and !exists $hash3{P1P2M1} and !exists $hash3{P1P2M2} and !exists $hash3{P2M1P1} and !exists $hash3{P2M2P1} and !exists $hash3{P2P1M1} and !exists $hash3{P2P1M2} ) {
	print "NO\t";
}
print "\n";	
@son_ty ="";
%hash1="";
%hash2="";
%hash3="";
}

	
	
