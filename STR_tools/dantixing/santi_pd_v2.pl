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
my %hash;
my @line3="";


 
#my $header = <IN>;
#$header =~s/\n//;
$header = "pos\tdad_type\tpos\tmom_type\tpos\tson_type\t".'M1M1M1'."\t"."M1M1M2\tM1M1P1\tM1M2P1\tP1P1P1\tP1P1P2\tP1P1M1\tP1P2M1\tMMM\tMMP\tPPP\tPPM\n";
print "$header";
while(<IN>) {
 chomp;
 $line=$_;
 
 if(substr($line,0,2)ne"##" ) {
  $line_count++;
  my @line=split/\t/,$line;
  if($line[0]=~/^\D[0-9]+/){
  $line[0]=~/^\D[0-9]+/;
   $chr = $&;
  }
  elsif ($line[0]=~'DX'){
  $chr = 'DX';
  }
  #print "$chr\n";
  #$hash4{$chr}++;
  push @line,0;
  #print "dad\tmom\tson\tson_from_dm\tson_from_dad\tson_from_mom\tson_off_dm\n";
  my @mom=split/\//,$line[$mom];
  my @son=split/\//,$line[$son];
  my @dad=split/\//,$line[$dad];
  if($line_count>=1 ) {
  #my @mom_var=split/\,/,$mom[3];
      foreach $each_mom(@mom) {
		if( $line[$mom] eq 'NA' or $line[$mom] eq "" or $line[$mom] eq 'F'){
		$sum_mom=0;}
		else {
          my @mom_var=split/\|/,$each_mom;
          if ($mom_var[0] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$mom_var[0]);
                 shift @sum_type;
                 $mom_var3 = join("\+",@sum_type);
                 push @mom_var1,$mom_var3;
                 push @mom_var2,$mom_var[2];
                 }
                 else {
				push @mom_var1,$mom_var[0];
				push @mom_var2,$mom_var[2];
				}
		$hashmom{$line[$mom-1].'_'.$mom_var[0]}=$mom_var[1];
		$sum_mom+=$mom_var[1];}}
      foreach $each_son(@son) {
		if( $line[$son] eq 'NA' or $line[$son] eq "" or $line[$son] eq 'F'){
			$sum_son=0;}
		else {
			my @son_var=split/\|/,$each_son;
			if ($son_var[0] =~ /[0-9]\(/ ){
				@sum_type = split(/\D+/,$son_var[0]);
				shift @sum_type;
				$son_var3=join("\+",@sum_type);
				push @son_var1,$son_var3;
				push @son_var2,$son_var[2];
			}
			else {
				push @son_var1,$son_var[0];
				push @son_var2,$son_var[2];
			}
         $hashson{$line[$son-1].'_'.$son_var[0]}=$son_var[1];
	     $hashson1{$son_var[0]}=$son_var[2];
         $sum_son+=$son_var[1];}}
		shift @son_var1;
	$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;


@son_var1="";
     foreach $each_dad(@dad){
		if( $line[$dad] eq 'NA' or $line[$dad] eq "" or $line[$dad] eq 'F'){
			$sum_dad=0;}
		else {
         	my @dad_var=split/\|/,$each_dad;
			if ($dad_var[0]=~ /[0-9]\(/ ){
				@sum_type = split(/\D+/,$dad_var[0]);
				shift @sum_type;
				$dad_var3 = join("\+",@sum_type);
				push @dad_var1,$dad_var3;
				push @dad_var2,$dad_var[2];
			}
			else {
				push @dad_var1,$dad_var[0];
				push @dad_var2,$dad_var[2];
			}
            $hashdad{$line[$dad-1].'_'.$dad_var[0]}=$dad_var[1];
			#print "$line[$dad-1]".'_'."$dad_var[0]\n";
			$hashdad1{$dad_var[0]}=$each_dad;
            $sum_dad+=$dad_var[1];}}
			shift @mom_var1;
			shift @dad_var1;
			my @mom_dad = (M1.'_'.$mom_var1[0],M2.'_'.$mom_var1[1],P1.'_'.$dad_var1[0],P2.'_'.$dad_var1[1]);
			#print "@mom_dad\n";
			@mom_var1 ="";
			@dad_var1="";
foreach $mom_dad1(@mom_dad) {
	foreach $mom_dad2(@mom_dad) {
		foreach $mom_dad3(@mom_dad) {
			$hash1{$mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3}=1;
			#print $mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3."\n";
		}
	}
}
			if($sum_dad>50 and $sum_mom>=50 and $sum_son> 50) {
				$hash4{$chr}++;
				foreach (keys %hash) {
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
print "$line\t";
if (exists ($hash3{M1M1M1}) or exists ($hash3{M2M2M2} )) {
	print "yes\t";
	$hash5{$chr.'_'.M1M1M1}++;
}
if (!exists ($hash3{M1M1M1}) and !exists($hash3{M2M2M2})) {
	print "NO\t";
}
if(exists $hash3{M1M1M2} or exists $hash3{M1M2M1} or exists $hash3{M1M2M2} or exists $hash3{M2M1M1} or exists $hash3{M2M1M2} or exists $hash3{M2M2M1}) {
	print "yes\t";
	$hash5{$chr.'_'.M1M1M2}++;
}
if(!exists $hash3{M1M1M2} and !exists $hash3{M1M2M1} and !exists $hash3{M1M2M2} and !exists $hash3{M2M1M1} and !exists $hash3{M2M1M2} and !exists $hash3{M2M2M1}) {
	print "NO\t";
}
if(exists $hash3{M1M1P1} or exists $hash3{M1M1P2} or exists $hash3{M1P1M1}  or exists $hash3{M1P2M1} or exists $hash3{M2M2P1} or exists $hash3{M2M2P2} or exists $hash3{M2P1M2} or exists $hash3{M2P2M2} or exists $hash3{P1M1M1} or exists $hash3{P1M2M2} or exists $hash3{P2M1M1} or exists $hash3{P2M2M2}) {
	print "YES\t";
	$hash5{$chr.'_'.M1M1P1}++;
}
if(!exists $hash3{M1M1P1} and !exists $hash3{M1M1P2} and !exists $hash3{M1P1M1}  and !exists $hash3{M1P2M1} and !exists $hash3{M2M2P1} and !exists $hash3{M2M2P2} and !exists $hash3{M2P1M2} and !exists $hash3{M2P2M2} and !exists $hash3{P1M1M1} and !exists $hash3{P1M2M2} and !exists $hash3{P2M1M1} and !exists $hash3{P2M2M2}) {
	print "NO\t";
}
if(exists $hash3{M1M2P1}  or exists $hash3{M1M2P2} or exists $hash3{M1P1M2} or exists $hash3{M1P2M2} or exists $hash3{M2M1P1} or exists $hash3{M2M1P2} or exists $hash3{M2P1M1} or exists $hash3{M2P2M1} or exists $hash3{P1M1M2} or exists $hash3{P1M2M1} or exists $hash3{P2M1M2}  or exists  $hash3{P2M2M1} ){
	print "YES\t";
	$hash5{$chr.'_'.M1M2P1}++;
}
if(!exists $hash3{M1M2P1}  and !exists $hash3{M1M2P2} and !exists $hash3{M1P1M2} and !exists $hash3{M1P2M2} and !exists $hash3{M2M1P1} and !exists $hash3{M2M1P2} and !exists $hash3{M2P1M1} and !exists $hash3{M2P2M1} and !exists $hash3{P1M1M2} and !exists $hash3{P1M2M1} and !exists $hash3{P2M1M2}  and !exists  $hash3{P2M2M1} ){
	print "NO\t";
}
if(exists $hash3{P1P1P1}  or exists $hash3{P1P2P2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1P1}++;
}
if(!exists $hash3{P1P1P1}  and !exists $hash3{P1P2P2} ) {
	print "NO\t";
}
if(exists $hash3{P1P1P2} or exists $hash3{P1P2P1} or exists $hash3{P1P2P2} or exists $hash3{P2P1P1} or exists $hash3{P2P1P2} or exists $hash3{P2P2P1}) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1P2}++;
}
if(!exists $hash3{P1P1P2} and !exists $hash3{P1P2P1} and !exists $hash3{P1P2P2} and !exists $hash3{P2P1P1} and !exists $hash3{P2P1P2} and !exists $hash3{P2P2P1}) {
	print "NO\t";
} 
if(exists $hash3{M1P1P1} or exists $hash3{M1P2P2} or exists $hash3{M2P1P1} or exists $hash3{M2P2P2} or exists $hash3{P1M1P1} or exists $hash3{P1M2P1} or exists $hash3{P1P1M1} or exists $hash3{P1P1M2} or exists $hash3{P2M1P2} or exists $hash3{P2M2P2} or exists $hash3{P2P2M1}  or exists $hash3{P2P2M2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1M1}++;
}
if(!exists $hash3{M1P1P1} and !exists $hash3{M1P2P2} and !exists $hash3{M2P1P1} and !exists $hash3{M2P2P2} and !exists $hash3{P1M1P1} and !exists $hash3{P1M2P1} and !exists $hash3{P1P1M1} and !exists $hash3{P1P1M2} and !exists $hash3{P2M1P2} and !exists $hash3{P2M2P2} and !exists $hash3{P2P2M1}  and !exists $hash3{P2P2M2} ) {
	print "NO\t";
}
if(exists $hash3{M1P1P2} or exists $hash3{M1P2P1} or exists $hash3{M2P1P2} or exists $hash3{M2P2P1} or exists $hash3{P1M1P2} or exists $hash3{P1M2P2} or exists $hash3{P1P2M1} or exists $hash3{P1P2M2} or exists $hash3{P2M1P1} or exists $hash3{P2M2P1} or exists $hash3{P2P1M1} or exists $hash3{P2P1M2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P2M1}++;
}
if(!exists $hash3{M1P1P2} and !exists $hash3{M1P2P1} and !exists $hash3{M2P1P2} and !exists $hash3{M2P2P1} and !exists $hash3{P1M1P2} and !exists $hash3{P1M2P2} and !exists $hash3{P1P2M1} and !exists $hash3{P1P2M2} and !exists $hash3{P2M1P1} and !exists $hash3{P2M2P1} and !exists $hash3{P2P1M1} and !exists $hash3{P2P1M2} ) {
	print "NO\t";
}
if (exists ($hash3{M1M1M1}) or exists ($hash3{M2M2M2}) or exists $hash3{M1M1M2} or exists $hash3{M1M2M1} or exists $hash3{M1M2M2} or exists $hash3{M2M1M1} or exists $hash3{M2M1M2} or exists $hash3{M2M2M1}) {
	print "yes\t";
	$hash5{$chr.'_'.MMM}++;
}
if (!exists ($hash3{M1M1M1}) and !exists ($hash3{M2M2M2}) and !exists $hash3{M1M1M2} and !exists $hash3{M1M2M1} and !exists $hash3{M1M2M2} and !exists $hash3{M2M1M1} and !exists $hash3{M2M1M2} and !exists $hash3{M2M2M1}) {
	print "NO\t";
}
if(exists $hash3{M1M1P1} or exists $hash3{M1M1P2} or exists $hash3{M1P1M1}  or exists $hash3{M1P2M1} or exists $hash3{M2M2P1} or exists $hash3{M2M2P2} or exists $hash3{M2P1M2} or exists $hash3{M2P2M2} or exists $hash3{P1M1M1} or exists $hash3{P1M2M2} or exists $hash3{P2M1M1} or exists $hash3{P2M2M2} or exists $hash3{M1M2P1}  or exists $hash3{M1M2P2} or exists $hash3{M1P1M2} or exists $hash3{M1P2M2} or exists $hash3{M2M1P1} or exists $hash3{M2M1P2} or exists $hash3{M2P1M1} or exists $hash3{M2P2M1} or exists $hash3{P1M1M2} or exists $hash3{P1M2M1} or exists $hash3{P2M1M2}  or exists  $hash3{P2M2M1}) {
	print "YES\t";
	$hash5{$chr.'_'.MMP}++;
}
if(!exists $hash3{M1M1P1} and !exists $hash3{M1M1P2} and !exists $hash3{M1P1M1}  and !exists $hash3{M1P2M1} and !exists $hash3{M2M2P1} and !exists $hash3{M2M2P2} and !exists $hash3{M2P1M2} and !exists $hash3{M2P2M2} and !exists $hash3{P1M1M1} and !exists $hash3{P1M2M2} and !exists $hash3{P2M1M1} and !exists $hash3{P2M2M2} and !exists $hash3{M1M2P1}  and !exists $hash3{M1M2P2} and !exists $hash3{M1P1M2} and !exists $hash3{M1P2M2} and !exists $hash3{M2M1P1} and !exists $hash3{M2M1P2} and !exists $hash3{M2P1M1} and !exists $hash3{M2P2M1} and !exists $hash3{P1M1M2} and !exists $hash3{P1M2M1} and !exists $hash3{P2M1M2}  and !exists  $hash3{P2M2M1}) {
	print "NO\t";
}
if(exists $hash3{P1P1P1}  or exists $hash3{P1P2P2} or exists $hash3{P1P1P2} or exists $hash3{P1P2P1} or exists $hash3{P1P2P2} or exists $hash3{P2P1P1} or exists $hash3{P2P1P2} or exists $hash3{P2P2P1} ) {
	print "YES\t";
	$hash5{$chr.'_'.PPP}++;
}
if(!exists $hash3{P1P1P1}  and !exists $hash3{P1P2P2} and !exists $hash3{P1P1P2} and !exists $hash3{P1P2P1} and !exists $hash3{P1P2P2} and !exists $hash3{P2P1P1} and !exists $hash3{P2P1P2} and !exists $hash3{P2P2P1} ) {
	print "NO\t";
}
if(exists $hash3{M1P1P2} or exists $hash3{M1P2P1} or exists $hash3{M2P1P2} or exists $hash3{M2P2P1} or exists $hash3{P1M1P2} or exists $hash3{P1M2P2} or exists $hash3{P1P2M1} or exists $hash3{P1P2M2} or exists $hash3{P2M1P1} or exists $hash3{P2M2P1} or exists $hash3{P2P1M1} or exists $hash3{P2P1M2} or exists $hash3{M1P1P1} or exists $hash3{M1P2P2} or exists $hash3{M2P1P1} or exists $hash3{M2P2P2} or exists $hash3{P1M1P1} or exists $hash3{P1M2P1} or exists $hash3{P1P1M1} or exists $hash3{P1P1M2} or exists $hash3{P2M1P2} or exists $hash3{P2M2P2} or exists $hash3{P2P2M1}  or exists $hash3{P2P2M2}) {
	print "YES\t";
	$hash5{$chr.'_'.PPM}++;
}
if(!exists $hash3{M1P1P2} and !exists $hash3{M1P2P1} and !exists $hash3{M2P1P2} and !exists $hash3{M2P2P1} and !exists $hash3{P1M1P2} and !exists $hash3{P1M2P2} and !exists $hash3{P1P2M1} and !exists $hash3{P1P2M2} and !exists $hash3{P2M1P1} and !exists $hash3{P2M2P1} and !exists $hash3{P2P1M1} and !exists $hash3{P2P1M2} and !exists $hash3{M1P1P1} and !exists $hash3{M1P2P2} and !exists $hash3{M2P1P1} and !exists $hash3{M2P2P2} and !exists $hash3{P1M1P1} and !exists $hash3{P1M2P1} and !exists $hash3{P1P1M1} and !exists $hash3{P1P1M2} and !exists $hash3{P2M1P2} and !exists $hash3{P2M2P2} and !exists $hash3{P2P2M1}  and !exists $hash3{P2P2M2}) {
	print "NO\t";
}

print "\n";
			}
			$sum_dad=0;
			$sum_mom=0;
			$sum_son=0;
			%hash="";
			%hash1="";
			%hash2="";
			%hash3="";
  }
 }
}
$header1 = "chr\tnum\tM1M1M1\tM1M1M2\tM1M1P1\tM1M2P1\tP1P1P1\tP1P1P2\tP1P1M1\tP1P2M1\tMMM\tMMP\tPPP\tPPM\n";
print "$header1";
foreach $chr1(sort {(split /D/,$a)[1] <=> (split /D/,$b)[1]} keys %hash4) {
	if($chr1 ne "" and $chr1 ne "DX") {
        $chr_2 = $chr1;
        $chr_2 =~ s/D/Chr/;
        print "$chr_2\t$hash4{$chr1}\t";
	#print "$chr1\t$hash4{$chr1}\t";
	$hash_all += $hash4{$chr1};
	$hash_M1M1M1 += $hash5{$chr1.'_'.M1M1M1};
	$hash_M1M1M2 += $hash5{$chr1.'_'.M1M1M2};
	$hash_M1M1P1 += $hash5{$chr1.'_'.M1M1P1};
	$hash_M1M2P1 += $hash5{$chr1.'_'.M1M2P1};
	$hash_P1P1P1 += $hash5{$chr1.'_'.P1P1P1};
	$hash_P1P1P2 += $hash5{$chr1.'_'.P1P1P2};
	$hash_P1P1M1 += $hash5{$chr1.'_'.P1P1M1};
	$hash_P1P2M1 += $hash5{$chr1.'_'.P1P2M1};
	$hash_MMM += $hash5{$chr1.'_'.MMM};
	$hash_MMP += $hash5{$chr1.'_'.MMP};
	$hash_PPP += $hash5{$chr1.'_'.PPP};
	$hash_PPM += $hash5{$chr1.'_'.PPM};
	$rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M1}/$hash4{$chr1})*100 .'%';
	$rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M2}/$hash4{$chr1})*100 .'%';
	$rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1P1}/$hash4{$chr1})*100 .'%';
	$rate4 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2P1}/$hash4{$chr1})*100 .'%';
	$rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P1}/$hash4{$chr1})*100 .'%';
	$rate6 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P2}/$hash4{$chr1})*100 .'%';
	$rate7 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1M1}/$hash4{$chr1})*100 .'%';
	$rate8 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2M1}/$hash4{$chr1})*100 .'%';
	$rate9 = sprintf("%.2f",$hash5{$chr1.'_'.MMM}/$hash4{$chr1})*100 .'%';
	$rate10 = sprintf("%.2f",$hash5{$chr1.'_'.MMP}/$hash4{$chr1})*100 .'%';
	$rate11 = sprintf("%.2f",$hash5{$chr1.'_'.PPP}/$hash4{$chr1})*100 .'%';
	$rate12 = sprintf("%.2f",$hash5{$chr1.'_'.PPM}/$hash4{$chr1})*100 .'%';
	print "$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate6\t$rate7\t$rate8\t$rate9\t$rate10\t$rate11\t$rate12\n";
	}
	if($chr1 eq 'DX') {
        #$hash_all += $hash4{$chr1};
        #$hash_M1M1M1 += $hash5{$chr1.'_'.M1M1M1};
        #$hash_M1M1M2 += $hash5{$chr1.'_'.M1M1M2};
        #$hash_M1M1P1 += $hash5{$chr1.'_'.M1M1P1};
        #$hash_M1M2P1 += $hash5{$chr1.'_'.M1M2P1};
        #$hash_P1P1P1 += $hash5{$chr1.'_'.P1P1P1};
        #$hash_P1P1P2 += $hash5{$chr1.'_'.P1P1P2};
        #$hash_P1P1M1 += $hash5{$chr1.'_'.P1P1M1};
        #$hash_P1P2M1 += $hash5{$chr1.'_'.P1P2M1};
        #$hash_MMM += $hash5{$chr1.'_'.MMM};
        #$hash_MMP += $hash5{$chr1.'_'.MMP};
        #$hash_PPP += $hash5{$chr1.'_'.PPP};
        #$hash_PPM += $hash5{$chr1.'_'.PPM};
        $rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M1}/$hash4{$chr1})*100 .'%';
        $rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M2}/$hash4{$chr1})*100 .'%';
        $rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1P1}/$hash4{$chr1})*100 .'%';
        $rate4 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2P1}/$hash4{$chr1})*100 .'%';
        $rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P1}/$hash4{$chr1})*100 .'%';
        $rate6 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P2}/$hash4{$chr1})*100 .'%';
        $rate7 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1M1}/$hash4{$chr1})*100 .'%';
        $rate8 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2M1}/$hash4{$chr1})*100 .'%';
        $rate9 = sprintf("%.2f",$hash5{$chr1.'_'.MMM}/$hash4{$chr1})*100 .'%';
        $rate10 = sprintf("%.2f",$hash5{$chr1.'_'.MMP}/$hash4{$chr1})*100 .'%';
        $rate11 = sprintf("%.2f",$hash5{$chr1.'_'.PPP}/$hash4{$chr1})*100 .'%';
        $rate12 = sprintf("%.2f",$hash5{$chr1.'_'.PPM}/$hash4{$chr1})*100 .'%';
	$chrX = "ChrX\t$hash4{$chr1}\t$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate6\t$rate7\t$rate8\t$rate9\t$rate10\t$rate11\t$rate12\n";
	}
}
$rate_M1M1M1 = sprintf("%.2f",$hash_M1M1M1/$hash_all)*100 .'%';
$rate_M1M1M2 = sprintf("%.2f",$hash_M1M1M2/$hash_all)*100 .'%';
$rate_M1M1P1 = sprintf("%.2f",$hash_M1M1P1/$hash_all)*100 .'%';
$rate_M1M2P1 = sprintf("%.2f",$hash_M1M2P1/$hash_all)*100 .'%';
$rate_P1P1P1 = sprintf("%.2f",$hash_P1P1P1/$hash_all)*100 .'%';
$rate_P1P1P2 = sprintf("%.2f",$hash_P1P1P2/$hash_all)*100 .'%';
$rate_P1P1M1 = sprintf("%.2f",$hash_P1P1M1/$hash_all)*100 .'%';
$rate_P1P2M1 = sprintf("%.2f",$hash_P1P1M1/$hash_all)*100 .'%';
$rate_MMM = sprintf("%.2f",$hash_MMM/$hash_all)*100 .'%';
$rate_MMP = sprintf("%.2f",$hash_MMP/$hash_all)*100 .'%';
$rate_PPP = sprintf("%.2f",$hash_PPP/$hash_all)*100 .'%';
$rate_PPM = sprintf("%.2f",$hash_PPM/$hash_all)*100 .'%';
print '总计'."\t$hash_all\t$rate_M1M1M1\t$rate_M1M1M2\t$rate_M1M1P1\t$rate_M1M2P1\t$rate_P1P1P1\t$rate_P1P1P2\t$rate_P1P1M1\t$rate_P1P2M1\t$rate_MMM\t$rate_MMP\t$rate_PPP\t$rate_PPM\n$header1$chrX";
