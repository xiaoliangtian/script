#!usr/bin/perl

use strict;
use warnings;

die "usage:perl $0 infastq outfastq start end\n" if ( @ARGV != 4 );

open( INFQ,  "gzip -dc $ARGV[0]|" ) || die "can't open file $ARGV[0]";
open( OUTFQ, ">$ARGV[1]" )          || die "can't open file $ARGV[0]";

my $start   = $ARGV[2];
my $endsite = $ARGV[3];
my $seqlen  = 0;
my $needlen = 0;
my $sublen  = 0;
my $seqtag  = '';
my $seq     = '';
my $subseq  = '';
my $qual    = '';
my $subqual = '';
my $i       = 0;

$needlen = $endsite - $start;
if ( $needlen > 0 ) {
    while (<INFQ>) {
        $seqtag = $_;
        $_      = <INFQ>;
        $seq    = $_;
        chomp $seq;
        $seqlen = length $seq;
        if ( $endsite <= $seqlen ) {
            $sublen = $endsite - $start + 1;
            print OUTFQ $seqtag;
            $subseq = substr( $seq, ( $start - 1 ), $sublen );
            print OUTFQ "$subseq\n";
            ##### +
            $_ = <INFQ>;
            print OUTFQ $_;
            ##### qual
            $_    = <INFQ>;
            $qual = $_;
            chomp $qual;
            $subqual = substr( $qual, ( $start - 1 ), ( $needlen + 1 ) );
            print OUTFQ "$subqual\n";
        }
        elsif ( ( $start <= $seqlen ) && ( $endsite > $seqlen ) ) {
            print OUTFQ $seqtag;
            $sublen = $seqlen - $start + 1;
            $subseq = substr( $seq, ( $start - 1 ), $sublen );
            print OUTFQ "$subseq\n";
            ##### +
            $_ = <INFQ>;
            print OUTFQ $_;
            ##### qual
            $_    = <INFQ>;
            $qual = $_;
            chomp $qual;
            $subqual = substr( $qual, ( $start - 1 ), ( $needlen + 1 ) );
            print OUTFQ "$subqual\n";
        }
    }
}
