#!/usr/bin/perl
#use strict;
#use warnings;
my @line;

die "Usage: perl $0 bed  db > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";

#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
#$/ = '>';
while (<IN>) {
    chomp;
    @line = split( /\t/, $_ );

    #print "$_";
    open( DB, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
    $/ = '>';
    seek( DB, 0, 0 );
    while (<DB>) {
        chomp;
        my ( $name, $seq ) = split( /\n/, $_, 2 );
        $name =~ s/>//g;

        # print "$name";
        $seq =~ s/\s+//g;
        if ( $name eq $line[0] ) {
            while ( $line[1] <= $line[2] ) {
                $seq1 = substr( $seq, $line[1] - 1, 1 );
                print "$name\t$line[1]\t$seq1\n";
                $line[1]++;
            }
        }
    }
}

#close (DB);
#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
#print <DB>;

