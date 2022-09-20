#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my @line2;
my $header;
my @line3;
my @line4;

die "Usage: perl $0 in in1 > out\n" unless ( @ARGV == 2 );
open( IN,  "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( IN1, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<IN>) {
    chomp;
    @line  = split( /\t/, $_ );
    @line2 = split( /\t/, <IN> );
    if ( $line[0] eq $line2[0] && abs( $line2[1] - $line[2] ) > 300 ) {
        print "$line[0]\t" . ( $line[2] + 1 ) . "\t" . ( $line[2] + 150 ) . "\n$line[0]\t" . ( $line2[1] - 150 ) . "\t" . ( $line2[1] - 1 ) . "\n";
    }
    if ( $line[0] eq $line2[0] && abs( $line2[1] - $line[2] ) <= 300 ) {
        print "$line[0]\t" . ( $line[2] + 1 ) . "\t" . ( $line2[1] - 1 ) . "\n";
    }
    if ( $line[0] ne $line2[0] ) {
        print "$line[0]\t" . ( $line[2] + 1 ) . "\t" . ( $line[2] + 150 ) . "\n$line2[0]\t" . ( $line2[1] - 150 ) . "\t" . ( $line2[1] - 1 ) . "\n";
    }
}
$header = <IN1>;
while (<IN1>) {
    chomp;

    #$header = <IN>;
    @line3 = split( /\t/, $_ );
    @line4 = split( /\t/, <IN1> );
    if ( $line3[0] eq $line4[0] && abs( $line4[1] - $line3[2] ) > 300 ) {
        print "$line3[0]\t"
          . ( $line3[2] + 1 ) . "\t"
          . ( $line3[2] + 150 )
          . "\n$line3[0]\t"
          . ( $line4[1] - 150 ) . "\t"
          . ( $line4[1] - 1 ) . "\n";
    }
    if ( $line3[0] eq $line4[0] && abs( $line4[1] - $line3[2] ) <= 300 ) {
        print "$line3[0]\t" . ( $line3[2] + 1 ) . "\t" . ( $line4[1] - 1 ) . "\n";
    }
    if ( $line3[0] ne $line4[0] ) {
        print "$line3[0]\t"
          . ( $line3[2] + 1 ) . "\t"
          . ( $line3[2] + 150 )
          . "\n$line4[0]\t"
          . ( $line4[1] - 150 ) . "\t"
          . ( $line4[1] - 1 ) . "\n";
    }
}

