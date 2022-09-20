#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my @gene;
my @detail;
my $bian;
my $bian1;
my $bian2;
my $bian3;
my $bian4;
my $gene;
my $detail;
die "Usage: perl $0 in > out\n" unless ( @ARGV == 1 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";

while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );

    #my $num = @line;
    if ( $line[6] =~ /,/ ) {
        my @gene   = split( /,/, $line[6] );
        my @detail = split( /,/, $line[9] );
        foreach $gene (@gene) {
            foreach $detail (@detail) {
                $bian  = join( "\t", @line[ 0 .. 5 ] );
                $bian1 = $gene;
                $bian2 = join( "\t", @line[ 7 .. 8 ] );
                $bian3 = $detail;
                $bian4 = join( "\t", @line[ 10 .. 1000 ] );

                #chomp;
                print "$bian\t$bian1\t$bian2\t$bian3\t$bian4\n";
            }
        }
    }
    else {
        print "$_\n";
    }
}

