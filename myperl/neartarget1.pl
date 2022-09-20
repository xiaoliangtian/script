#!/usr/bin/perl
use strict;
use warnings;
my @line;
my @line2;
my $rock;
my @rock;
my $header;
my $rock1;
my @rock1;

die "Usage: perl $0 in in1 > out\n" unless ( @ARGV == 2 );
open( IN,  "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( IN1, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
@rock   = <IN>;
$header = <IN1>;
@rock1  = <IN1>;

#print "@rock\n";
foreach $rock (@rock) {
    chomp($_);
    @line = split( /\t/, $_ );
    foreach $rock1 (@rock1) {
        chomp($_);
        @line2 = split( /\t/, $_ );
        if ( $line[0] eq $line2[0] && abs( $line2[1] - $line[2] ) > 300 ) {
            print "$line[0]\t"
              . ( $line[2] + 1 ) . "\t"
              . ( $line[2] + 150 )
              . "\n$line[0]\t"
              . ( $line2[1] - 150 ) . "\t"
              . ( $line2[1] - 1 ) . "\n";
        }
        if ( $line[0] eq $line2[0] && abs( $line2[1] - $line[2] ) <= 300 ) {
            print "$line[0]\t" . ( $line[2] + 1 ) . "\t" . ( $line2[1] - 1 ) . "\n";
        }
        if ( $line[0] ne $line2[0] ) {
            print "$line[0]\t"
              . ( $line[2] + 1 ) . "\t"
              . ( $line[2] + 150 )
              . "\n$line2[0]\t"
              . ( $line2[1] - 150 ) . "\t"
              . ( $line2[1] - 1 ) . "\n";
        }
    }
}

