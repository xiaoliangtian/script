#!/usr/bin/perl
#use strict;
#use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
my $DIR = dirname( abs_path($0) );

die "Usage: perl $0 noneed  SegBreaks bam.txt qianhe  R.txt SegCopy cnv  all.cnv CNV1 type\n" unless ( @ARGV == 10 );

open( LIST, "$ARGV[0]" )  or die "Can not open file $ARGV[0]\n";
open( IN1,  "$ARGV[1]" )  or die "Can not open file $ARGV[1]\n";
open( IN2,  "$ARGV[2]" )  or die "Can not open file $ARGV[2]\n";
open( OUT,  ">$ARGV[3]" ) or die "Can not open file $ARGV[3]\n";
open( CNV,  ">$ARGV[4]" ) or die "Can not open file $ARGV[4]\n";
open( IN3,  "$ARGV[5]" )  or die "Can not open file $ARGV[5]\n";
open( CNV2, ">$ARGV[7]" ) or die "Can not open file $ARGV[7]\n";
open( CNV1, ">$ARGV[6]" ) or die "Can not open file $ARGV[6]\n";
open( CNV4, "$ARGV[8]" )  or die "Can not open file $ARGV[8]\n";

my $project = $ARGV[9];

while (<LIST>) {
    chomp;
    my @line = split( /\t/, $_ );
    $hash6{ $line[0] . '_' . $line[1] } = 1;
}
while (<CNV4>) {
    chomp;
    my @line8 = split( /\t/, $_ );
    $hash7{ $line8[0] . '_' . $line8[1] . '_' . $line8[2] }++;
    print $line8[0] . '_' . $line8[1] . '_' . $line8[2] . "\n";
}
my $head  = <IN1>;
my $head1 = <IN2>;
print CNV "chromosome\tstart\tend\ttest\tref\tposition\tlog2\tp.value\tcnv\tcnv.size\tcnv.log2\tcnv.p.value\tcolor\n";
print CNV2 "chromosome\tstart\tend\ttest\tref\tposition\tlog2\tp.value\tcnv\tcnv.size\tcnv.log2\tcnv.p.value\tcolor\n";
while ( defined( my $v1 = <IN1> ) and defined( my $v2 = <IN2> ) ) {
    chomp( $v1, $v2 );
    my @line1 = split( /\t/, $v1 );
    my @line2 = split( /\t/, $v2 );
    my $pos = int( ( $line1[2] + $line1[1] ) / 2 );
    my $chr = $line1[0];
    $chr =~ s/chr//;
    $hash_chr{ $line1[0] }++;
    if ( $line2[1] >= 2 ) {
        print CNV2 "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$line2[1]\t0\t0\t0\t0\t0\tblue\n";
    }
    if ( $line2[1] < 2 ) {
        print CNV2 "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$line2[1]\t0\t0\t0\t0\t0\tred\n";
    }
    if ( !exists $hash6{ $line1[0] . '_' . $line1[1] } and $line2[1] >= 2 and ( $project eq 'CNV' or $project eq 'NIPT' ) ) {
        print CNV "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$line2[1]\t0\t0\t0\t0\t0\tblue\n";
    }
    if ( !exists $hash6{ $line1[0] . '_' . $line1[1] } and $line2[1] >= 2 and $project eq 'SC' ) {
        $hap = $line2[1];
        $hap = log( $hap / 2 ) / log(2);
        print CNV "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$hap\t0\t0\t0\t0\t0\tblue\n";
    }
    if ( !exists $hash6{ $line1[0] . '_' . $line1[1] } and $line2[1] < 2 and ( $project eq 'CNV' or $project eq 'NIPT' ) ) {
        print CNV "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$line2[1]\t0\t0\t0\t0\t0\tred\n";
    }
    if ( !exists $hash6{ $line1[0] . '_' . $line1[1] } and $line2[1] > 0.25 and $line2[1] < 2 and $project eq 'SC' ) {
        $hap = $line2[1];
        $hap = log( $hap / 2 ) / log(2);
        print CNV "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t$hap\t0\t0\t0\t0\t0\tred\n";
    }
    if ( !exists $hash6{ $line1[0] . '_' . $line1[1] } and $line2[1] < 0.5 and $line2[1] > 0 and $project eq 'SC' ) {
        print CNV "$chr\t$line1[1]\t$line1[2]\t100\t100\t$pos\t-2\t0\t0\t0\t0\t0\tred\n";
    }
    if ( $line2[1] =~ /\d+/ and $line2[1] < 6 ) {
        $hash1{ $line1[0] }++;
        $hash2{ $line1[0] } += $line2[1];
    }
}
my ($sample) = ( $ARGV[2] =~ /^(.+)\.dedup.sorted.bam.txt$/ );
print OUT "$sample\tsum\tqianhe_rate\n";
foreach ( keys %hash1 ) {
    $qianhe = abs( $hash2{$_} / $hash1{$_} - 2 );
    $sum    = $hash2{$_} / $hash1{$_} * $hash_chr{$_};
    print OUT "$_\t$sum\t$qianhe\n";
}

#my ($sample)=($ARGV[2]=~/^(.+)\.dedup.sorted.bam.txt$/);
if ( $project eq 'CNV' or $project eq 'NIPT' ) {
    `Rscript $DIR/CNV.R $ARGV[4] $sample `;
}
if ( $project eq 'SC' ) {
    `Rscript $DIR/SC.R $ARGV[4] $sample `;
}

#print "$sample\n";

open( CNV3, $ARGV[7] );
while ( defined( my $v3 = <IN3> ) and defined( my $v4 = <CNV3> ) ) {
    chomp( $v3, $v4 );
    $line_count++;
    my @line3 = split( /\t/, $v3 );
    my @line4 = split( /\t/, $v4 );

    #print "@line3\n";
    if ( $line_count == 1 ) {

        #print "$line_count\n";
        foreach $r (@line3) {

            #print "$r\n";
            $list++;
            if ( $r =~ $sample ) {
                $dam = $list - 1;
            }
        }
    }

    #print "$dam\n";
    if ( $line_count > 1 ) {
        if ( abs( abs( $line3[$dam] ) - 2 ) != 0 or abs( abs( $line3[$dam] ) - 2 ) == 0 or $line3[0] eq 'chrX' or $line3[0] eq 'chrY' ) {
            $hash3{ $line4[0] . '_' . $line4[1] . '_' . $line4[2] } = $line3[$dam];
            $hash5{ $line4[0] . '_' . $line4[1] . '_' . $line4[2] } = $line4[6];
            $line3[0] =~ s/"//g;
            $line3[0] =~ s/chr//g;
            $hash4{ $line3[0] } = 1;
        }
    }
}
print CNV1 "cnv\tchromosome\tstart\tend\tsize\ttype\ttrue_type\tfalse_num\n";
my $cnv_num = 0;
foreach $h ( sort { $a <=> $b } keys %hash4 ) {
    foreach $i ( sort { ( split /\_/, $a )[1] <=> ( split /\_/, $b )[1] } keys %hash5 ) {
        if ( ( split /\_/, $i )[0] eq $h ) {
            $num++;
            if ( $num == 1 ) {
                $type   = $hash3{$i};
                $sum = 0;
                $start  = ( split /\_/, $i )[1];
                $end    = ( split /\_/, $i )[2];
                $chrome = ( split /\_/, $i )[0];
                print CNV1 'CNVR' . "$cnv_num\t$chrome\t$start\t";
                $num++;
                $num1++;
                $sum += $hash5{$i};
            }
            if ( ( $num > 1 and ( ( split /\_/, $i )[1] - $end ) > 1 ) or ( $num > 1 and $hash3{$i} != $type ) ) {
                $cnv_num++;
                $num++;
                $lens      = $end - $start;
                $true_type = $sum / $num1;
                print CNV1 "$end\t$lens\t$type\t$true_type\t"
                  . $hash7{ 'chr' . $h . '_' . $start . '_' . $end } . "\n" . 'CNVR'
                  . $cnv_num . "\t"
                  . ( split /\_/, $i )[0] . "\t"
                  . ( split /\_/, $i )[1] . "\t";
                $type = $hash3{$i};
                $num1 = 0;
                $sum  = 0;
                $num1++;
                $sum += $hash5{$i};
                $start = ( split /\_/, $i )[1];
                $end   = ( split /\_/, $i )[2];
            }
            elsif ( $num > 1 and ( ( split /\_/, $i )[1] - $end ) <= 1 and $hash3{$i} == $type ) {
                $end = ( split /\_/, $i )[2];
                $num++;
                $num1++;
                $sum += $hash5{$i};
            }
        }
    }
    $last = $end - $start;

    #print "$num1\n";
    $true_type = $sum / $num1;
    print CNV1 "$end\t" . $last . "\t" . ($type) . "\t$true_type\t" . $hash7{ 'chr' . $h . '_' . $start . '_' . $end } . "\n";
    $cnv_num++;
    $num  = 0;
    $sum  = 0;
    $num1 = 0;
}

