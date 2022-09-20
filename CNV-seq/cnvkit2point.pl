#!/usr/bin/perl
#use strict;
#use warnings;
die "Usage: perl $0 cnr CNV out \n" unless ( @ARGV == 3 );
open( IN,  "$ARGV[0]" )  or die "Can not open file $ARGV[0]\n";
open( CNV, "$ARGV[1]" )  or die "Can not open file $ARGV[1]\n";
open( OUT, ">$ARGV[2]" ) or die "Can not open file $ARGV[2]\n";

while (<CNV>) {
    chomp;
    $line_count++;
    if ( $line_count > 1 ) {
        @line = split( /\t/, $_ );
        $hash{ $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[5];
    }
}

my ( $cnv, $type, $true_type, $size );
my $header  = <IN>;
my $cnv_num = 0;
print OUT "chromosome\tstart\tend\ttest\tref\tposition\tlog2\tyline\tp.value\tcnv\tcnv.size\tcnv.log2\tcnv.p.value\tcolor\n";
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    $chr   = $line[0];
    $start = $line[1];
    $end   = $line[2];
    $test  = 100;
    $ref   = 100;
    $pos   = int( $start + ( $end - $start ) / 2 );

    if ( $line[0] eq 'Y' ) {
        $log2 = 2**$line[5] * 1;
    }
    else {
        $log2 = 2**$line[5] * 2;
    }
    foreach $i ( keys %hash ) {
        @cnv = split( /\_/, $i );
        if ( $line[0] eq $cnv[0] and $line[1] >= $cnv[1] and $line[2] <= $cnv[2] ) {
            $yline = $hash{$i};
            $cnv_num++;
        }
    }
    #print "$cnv_num\n";
    if ( $cnv_num == 0 ) {
        $yline   = 2;
        $cnv_num = 0;
    }
    if ( $log2 >= 2 ) {
        $color = "blue";
    }
    else {
        $color = "red";
    }
    print OUT "$chr\t$start\t$end\t$test\t$ref\t$pos\t$log2\t$yline\t0\t0\t0\t0\t0\t$color\n";
    $cnv_num = 0;
}
close(IN);
close(OUT);

