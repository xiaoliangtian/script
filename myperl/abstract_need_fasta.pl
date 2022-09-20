#/usr/bin/perl
use strict;

die "Usage: perl $0 fasta list > out.fa\n" unless ( @ARGV == 2 );

#  perl

my $fasta = $ARGV[0];
my $list  = $ARGV[1];

my %hash = ();

open( LIST, "$list" ) || die "cannot open $list\n";
while (<LIST>) {
    chomp;
    if (/\>(\S+)/) {
        $hash{$_} = 1;
    }
    elsif (/(\S+)/) {
        $hash{$_} = 1;
    }
    else {
        warn "not match: $_\n";
    }
}
close(LIST);

local $/ = '>';
open( FASTA, "$fasta" ) || die "cannot open $fasta\n";
while (<FASTA>) {
    chomp;
    my ( $gene, $seq ) = split( /\n/, $_, 2 );

    #my ($name) = $gene =~ /^(\S+)/;
    #next unless ($name && $seq);
    #	$seq =~ s/\n//g;
    #	$seq =~ s/^\s+//g;
    #	$seq =~ s/\s+$//g;

    if ( exists $hash{$gene} ) {
        print ">$gene\n$seq";
    }
}
close(FASTA);

