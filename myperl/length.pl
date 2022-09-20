#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len;
my @line;
die "Usage: perl $0 in > out\n" unless ( @ARGV == 1 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    if ( $line[6] eq "\=" ) {
        my $len = abs( $line[3] - $line[7] );
        $len{$len}++;
        print "$len{$len}\n";
    }
}
local $/ = "\n";
foreach ( sort { $a <=> $b } keys %len ) {
    print "$_\t$len{$_}\n";
}

