#!/usr/bin/perl
use strict;
use warnings;
my %len;
my @line;
my $thousand = 0;
die "Usage: perl $0 in > out\n" unless ( @ARGV == 1 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    if ( $line[8] > 0 && $line[8] < 1000 ) {
        my $len = $line[8];
        $len{$len}++;
    }

    if ( $line[8] >= 1000 ) {
        $thousand++;
    }
}

#print ">1000\t$thousand\n";}
local $/ = "\n";
foreach ( sort { $a <=> $b } keys %len ) {
    print "$_\t$len{$_}\n";
}
print "1000\t$thousand\n";
