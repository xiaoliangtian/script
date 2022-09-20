#!/usr/bin/perl
#use strict;
#use warnings;
my @line;

die "Usage: perl $0 bed  db > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( DB, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
$/ = "\n";
while (<IN>) {
    chomp;
    @line  = split( /\t/, $_ );
    $name1 = $line[0];
    $pos   = $line[1];
    $end   = $line[2];
    $/     = '>';
    while (<DB>) {
        chomp;
        my ( $name, $seq ) = split( /\n/, $_, 2 );
        $name =~ s/>//g;
        $seq =~ s/\s+//g;
        for ( $name eq $name1 ) {
            $seq1 = substr( $seq, $pos - 1, $end - $pos + 1 );

            #	while ($pos<=$end) {
            #	$seq1 = substr ($seq, $pos-1,1);
            print "$name\t$pos\t$seq1\n";

            #	$pos++;
            #	}
        }
    }
}

