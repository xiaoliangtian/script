#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my $type =0;


die "Usage: perl $0 g.vcf   > out\n" unless (@ARGV == 1);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
while (<IN>) {
        chomp;
        @line = split (/\t/,$_);
	$hash{$line[0]} += $line[1];
}
foreach (keys %hash) {
	print "$_\t$hash{$_}\n";
} 
	
