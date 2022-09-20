#!/usr/bin/perl
#use strict;
#use warnings;
use File::Basename;
use Getopt::Long;
use Math::Round;

die "Usage: perl $0 ginkgo cnvtools\n" unless ( @ARGV == 2 );
open( IN,  $ARGV[0] )   or die "Can not open file $ARGV[0]\n";
open( CNV, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
my %len;

my $head = <IN>;
$num=0;
print "cnv\tchr\tstart\tend\tlen\ttype\ttrue_type\tfalse_num\n";
while (<IN>) {
    chomp;
    my @line = split /\t/, $_;
    if ( ($line[1] eq "X" or $line[1] eq "Y") and $line[4] > 90000 ) {
	$num++;
        print 'CNVR'."$num\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\n";
    }
    elsif ( $line[4] > 90000 and $line[5] != 2 ) {
        for ( $i = $line[2] ; $i <= $line[3] ; $i++ ) {
            $hash{ $line[1] . '_' . $i } = $line[5];
        }
    }
}

my $header1 = <CNV>;
while (<CNV>) {
    chomp;
    my @line = split /\t/, $_;
    if ( $line[3] > 90000 and $line[0] ne 'chrX' and $line[0] ne 'chrY' ) {
        for ( $h = $line[1] ; $h <= $line[2] ; $h++ ) {
            $line[0] =~ s/chr//;
            if ( exists $hash{ $line[0] . '_' . $h } ) {
                $inter++;
                $type = $hash{ $line[0] . '_' . $h };
            }
        }
        if ( ( $inter / $line[3] ) > 0.5 ) {
            $type_CNV = round($line[-1] * 2 );
	    $num++;
            print 'CNVR'."$num\t$line[0]\t$line[1]\t$line[2]\t$line[3]\t$type_CNV\t$type\t\n";
        }
    }
    $inter = 0;
}
