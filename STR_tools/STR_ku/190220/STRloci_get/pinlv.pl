#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my $type =0;


die "Usage: perl $0 rate  > out\n" unless (@ARGV == 1);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
while (<IN>) {
        chomp;
        @line = split (/\t/,$_);
        @str = split(/\_/,$_);
	$hash{$str[0]} += $line[1]**2;
        $hash1{$str[0]} = $line[2]/700;
}
foreach (keys %hash) {
        $hete = 1- $hash{$_};
	print "$_\t$hete\t$hash1{$_}\n";
} 
	
