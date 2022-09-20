#!/usr/bin/perl
use strict;
use warnings;

die "Usage: perl $0 fasta reverse\n" unless ( @ARGV == 2 );
open( FILE, "$ARGV[0]" )  or die "Failed to open file $ARGV[0]\n";
open( OUT,  ">$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";

while (<FILE>) {

    chomp;
    my $name = $_;
    my $seq  = <FILE>;
    #$name =~ s/$/-R/g;
    my $name1 = $name;
    $name1 =~ s/$/-R/;
    my $seq1 = reverse($seq);
    $seq1 =~ tr/ACGTacgt/TGCAtgca/;
    print OUT "$name\n$seq$name1$seq1\n";
}
