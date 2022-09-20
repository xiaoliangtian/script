#!/usr/bin/perl

#use strict;
die "Usage: perl $0 fastq > fasta\n" unless ( @ARGV == 1 );
open( FILE, "$ARGV[0]" ) or die "Failed to open file $ARGV[0]\n";

#open(OUT, ">$ARGV[1]") or die "Failed to open file $ARGV[1]\n";

my $head = <FILE>;
print "$head";

$num = 0;
while (<FILE>) {
    chomp;
    my @line = split( /\t/, $_ );
    foreach $i (@line) {
        $num++;
        if ( $num <= 4 ) {
            print "$i\t";
        }
        if ( $num > 4 ) {
            @type  = split( /\:/, $i );
            @depth = split( /\,/, $type[-1] );
            if ( $type[-2] > 0 ) {
                $rate = $depth[1] / $type[-2];
                print "$rate\t";
            }
        }
    }
    print "\n";
    $num = 0;
}

