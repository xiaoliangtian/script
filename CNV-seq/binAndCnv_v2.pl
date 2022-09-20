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
$num = 0;
print "cnv\tchr\tstart\tend\tlen\ttype\ttrue_type\tfalse_num\n";
while (<IN>) {
    chomp;
    my @line = split /\t/, $_;
    if ( ( $line[1] eq "X" or $line[1] eq "Y" ) and $line[4] > 90000 ) {
        $num++;
        print 'CNVR' . "$num\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\n";
    }
    elsif ( $line[4] > 90000 and $line[5] != 2 ) {
        $hash{ $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[5];

    }
}

sub cnv {
    $in = 0;
    my ( $var1, $var2 ) = @_;
    for ( $h = $$var2[1] ; $h <= $$var2[2] ; $h++ ) {
        if ( $h >= $$var1[1] and $h <= $$var1[2] ) {
            $in++;
          
        }
    }
    return $in;
    #$in = 0;
}

my $header1 = <CNV>;
while (<CNV>) {
    chomp;
    my @line = split /\t/, $_;
    if ( $line[3] > 90000 and $line[0] ne 'chrX' and $line[0] ne 'chrY' ) {
        foreach $j ( keys %hash ) {
            $line[0] =~ s/chr//;
            @group = split /\_/, $j;
            if ( $group[0] eq $line[0]
                and ( ( $group[1] >= $line[1] and $group[1] <= $line[2] ) or ( $line[1] >= $group[1] and $line[1] <= $group[2] ) ) )
            {
                $sum += $line[3];
                $inter += &cnv( \@group, \@line );
		#print "$inter\n";
                $type = $hash{$j};
            }
        }
        if ( ( $inter / $sum ) > 0.5 ) {
            $type_CNV = round( $line[-1] * 2 );
            $num++;
            print 'CNVR' . "$num\t$line[0]\t$line[1]\t$line[2]\t$line[3]\t$type_CNV\t$type\t\n";
        }
    }
    $inter = 0;
    $sum   = 0;
}

