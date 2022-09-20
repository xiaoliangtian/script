#!/usr/bin/perl
use strict;
use warnings;

die "Usage: perl $0 database > fasta \n" unless ( @ARGV == 1 );

open( IN, "$ARGV[0]" );

my $num = 0;
my $strFa;
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    my @strL = split( / /,  $line[2] );
    $num = 0;
    $line[-1] =~ s/ //g;
    #print "@strL\n";
    foreach my $i (@strL) {
        $num++;
        $i =~ s/-//g;
        if ( defined( $strL[$num] ) and $strL[$num] =~ /^[0-9]+/ ) {
            $strFa .= "$i" x "$strL[$num]";
            $strFa =~ tr/a-z/A-Z/;
        }
        elsif ( defined( $strL[ $num - 1 ] ) and $strL[ $num - 1 ] =~ /[A-Z]+/i ) {
            $strFa .= $i;
            $strFa =~ tr/a-z/A-Z/;
        }
    }

    print ">$line[0]_$line[1]_$line[-1]\n$strFa\n";
    $strFa = undef;
}
close(IN);

