#/usr/bin/perl
use strict;

die "Usage: perl $0 fastq list > out.fa\n" unless ( @ARGV == 2 );

my $fastq     = $ARGV[0];
my $list      = $ARGV[1];
my $solexatag = '';
my $seq       = '';
my $symbol    = '';
my $qual      = '';
my $i         = 0;
my @line;
my @line1;

my %listhash = ();

open( list, "$list" );
while (<list>) {
    chomp;
    if (/(@.*)/) {
        @line = split( /\|/, $_ );

        $listhash{ $line[0] } = $_;
    }
}
close(list);

open( fastq, "gzip -dc $fastq|" );
while (<fastq>) {
    chomp;
    if ( $i == 0 ) {
        @line1 = split( /(\s+)/, $_ );
        $solexatag = $line1[0];
    }
    if ( $i == 1 ) {
        $seq = $_;
    }
    if ( $i == 2 ) {
        $symbol = $_;
    }
    if ( $i == 3 ) {
        $qual = $_;
    }
    $i = $i + 1;

    if ( $i == 4 && $listhash{$solexatag} ) {
        print "$listhash{$solexatag}\n$seq\n$symbol\n$qual\n";
        $i = 0;
    }

    elsif ( $i == 4 && !$listhash{$solexatag} ) {
        $i = 0;
    }
}
close(fastq);
