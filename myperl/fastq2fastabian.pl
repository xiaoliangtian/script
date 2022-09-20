#!/usr/bin/perl
use strict;
use warnings;

die "Usage: perl $0 fastq fasta\n" unless ( @ARGV == 2 );
open( FILE, "$ARGV[0]" )  or die "Failed to open file $ARGV[0]\n";
open( OUT,  ">$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";

while (<FILE>) {

    #	chomp;
    my $name = $_;
    my $seq  = <FILE>;
    my $tre  = <FILE>;
    my $qual = <FILE>;
    $name =~ s/@/>/g;
    print OUT "$name$seq";
}
