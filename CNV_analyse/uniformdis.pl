#/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/16

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 DEPTH FAI OUT\n" unless (@ARGV == 3);
open (IN, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (FAI, $ARGV[1]) or die "Can not open file $ARGV[1]\n";
open (OUT, ">$ARGV[2]") or die "Can not open file $ARGV[2]\n";

my $sum = 0;
my %len;
my %cov;

while(<FAI>){
    chomp;
    my @line = split /\s+/;
    $len{$line[0]} = $line[1];
    $sum++;
}
close FAI;

while(<IN>){
    chomp;
    my @line = split /\s+/;
    foreach my $i (($line[1]+1)..$line[2]){
        my $percent = (int($i/$len{$line[0]}*100))/100;
        next if ($percent > 1);
        $cov{$percent} += $line[3]/$sum/$len{$line[0]}*100;
    }
}
close IN;

foreach my $i (sort {$a<=>$b} keys %cov){
    print OUT $i ,"\t",$cov{$i},"\n";
}
close OUT;
