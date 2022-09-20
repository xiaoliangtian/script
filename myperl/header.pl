## Please see file perltidy.ERR
﻿#!/usr/bin/perl
#use strict;
use warnings;
my $header;
my @headin;
my @header1;
my $line;
my $head;
my @removed;
my $line1;
die "Usage: perl $0 raw.vcf multianno.txt > NEW_multianno.txt\n" unless (@ARGV == 2);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
while (<IN>) {
	if ($_ =~ /\#CHROM/){
		chomp ;
		$header = $_;
                $header =~ s/\#//;
		@headin = split (/\t/,$header);
}}
open (IN1, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
$/ = "\n";
$line1= <IN1>;
chomp $line1;
#$line1=~ s/\#//;
	@header1=split (/\t/, $line1);
    unshift (@headin, C2);
    unshift (@headin, C1); 
    push @header1,@headin;
    $head = join ("\t", @header1);
    print "$head\n";
while (<IN1>) {
    $line = $_;
    print  "$line";}

