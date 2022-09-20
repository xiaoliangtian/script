#!/usr/bin/perl
use strict;
use warnings;
die "Usage: perl $0 name.list bed type out.file > sample_list \n" unless (@ARGV == 4);
open (NAME, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
my $bed=$ARGV[1];
my $type=$ARGV[2];
my $file=$ARGV[3];
my $name;
while (<NAME>) {
	chomp;
	$name = $_;
	print "$name\tpe\t$bed\t$type\t$name\t0\t$file\n"
}
