#!/usr/bin/perl
use strict;
use warnings;

die "Usage: perl $0 hap2 hap3\n" unless ( @ARGV == 2 );
open( FILE, "$ARGV[0]" )  or die "Failed to open file $ARGV[0]\n";
open( OUT,  ">$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";

my $header = <FILE>;
print OUT $header;
while (<FILE>) {

    chomp;
    my @line = split(/\t/,$_);
    if ($line[0] ne "chrY") {
	$line[6] = $line[6]*1.5;
	my $result = join("\t",@line);
	print  OUT "$result\n";
    }
    else {
	print OUT "$_\n";
    }
}
