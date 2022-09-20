#!/usr/bin/perl

#use strict;
die "Usage: perl $0 in depth diff > out\n" unless ( @ARGV == 3 );
open( FILE, "$ARGV[0]" ) or die "Failed to open file $ARGV[0]\n";

#open(OUT, ">$ARGV[1]") or die "Failed to open file $ARGV[1]\n";

#my $head = <FILE>;
#print "$head";

$num = 0;
while (<FILE>) {
    chomp;
    if ( substr( $_, 0, 2 ) ne '##' ) {
        $line_count++;
        @line = split( /\t/, $_ );
        if ( $line_count == 1 ) {
            print "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$line[9]\t$line[10]\n";
        }
        if ( $line_count > 1 ) {
            @tumor  = split( /\:/, $line[10] );
            @normal = split( /\:/, $line[9] );
            $tumor[5] =~ s/\%//;
            $normal[5] =~ s/\%//;
            $diff = abs( $tumor[5] - $normal[5] );
            if (    $diff > $ARGV[2]
                and $tumor[2] >= $ARGV[1]
                and $normal[2] >= $ARGV[1]
                and ( ( $tumor[5] > 95 or $tumor[5] < 5 ) or ( $normal[5] > 95 or $normal[5] < 5 ) ) )
            {
                print "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$line[9]\t$line[10]\n";
            }
        }

    }
}

