#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len;
my @line;
my %hash=();
my %hash1=();
my $type;
my $value;
my $ty;
die "Usage: perl $0 in > out\n" unless (@ARGV == 1);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
my $header = <IN>;
while (<IN>) {
	chomp;
	my @line = split (/\t/,$_);
	foreach $type(@line){
		if ($type ne 'NA' and $type ne 'F' and $type !~ 'D') {
			my @type = split(/\//,$type);
			foreach $value(@type){
				$hash{$line[0]}++;
				$hash1{$value}++;
			}
		}
	}
	foreach $ty(keys %hash1) {
	#	if ($ty ne "") {
		my $rate = $hash1{$ty}/$hash{$line[0]};
		print "$line[0]".'_'."$ty\t$rate\t$hash{$line[0]}\n";
	#	}
	}
	%hash1=();
	%hash =();
}


