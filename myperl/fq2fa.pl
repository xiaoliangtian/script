#!/usr/bin/perl

use strict;
die "Usage: perl $0 fastq fasta\n" unless ( @ARGV == 2 );
open( FILE, "$ARGV[0]" )  or die "Failed to open file $ARGV[0]\n";
open( OUT,  ">$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";

my $line = '';
my $seq  = '';
my $id   = '';
while ( my $line = <FILE> ) {
    if ( $line =~ m/^@(\S+)/ ) {
        $id = $1;
    }
    if ( $line =~ m/^([w])$/i ) {
        chomp $line;
        $seq = $seq . $line;
    }
    if ( $line =~ m/^\+/ ) {
        print OUT ">$id\n";
        print OUT "$seq\n";
        $seq = '';
    }
}

