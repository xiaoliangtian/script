#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 in > out\n" unless ( @ARGV == 1 );

open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
while (<IN>) {
    chomp;
    @line = split( /\t/, $_ );
    if ( $line[-1] = '0/1' or $line[-1] = '1/0' ) {
        $last = '0/1' . ':' . $line[2] . ',' . $line[5] . ':' . ( $line[2] + $line[5] );
        print "$last\n";
    }
    if ( $line[-1] = '0/0' ) {
        $last1 = '0/0' . ':' . ( $line[2] + $line[5] ) . ',' . '0' . ':' . ( $line[2] + $line[5] );
        print "$last1\n";
    }
    if ( $line[-1] = '1/1' ) {
        $last2 = '1/1' . ':' . '0' . ',' . ( $line[2] + $line[5] ) . ':' . ( $line[2] + $line[5] );
        print "$last2\n";
    }

}

