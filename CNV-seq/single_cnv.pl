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
my ($sample) = ( $ARGV[1] =~ /^(.+)\_S[0-9]+\.point$/ );

#print "$sample\n";

my $head = <IN>;
while (<IN>) {
    chomp;
    my @line = split /\t/, $_;
    if (  $line[4] > 90000 and $line[4] <900000 ) {
        $hash{ $line[9] . '_' . $line[5] } = $line[8];
    }
    if ( $line[4] >= 900000 and $line[4] <9000000 ) {
	$hash2{ $line[9] . '_' . $line[5] } = $line[8];
    }
    if ( $line[4] >= 9000000  ) {
	$hash3{ $line[9] . '_' . $line[5] } = $line[8];
    }
}

my $header1 = <CNV>;
while (<CNV>) {
    chomp;
    my @line = split /\t/, $_;
    $hash1{ $line[0] . '_' . $line[1] . '_' . $line[2] } = $_;

    #print $line[0].'_'.$line[1].'_'.$line[2]."\n";
}
foreach $i ( keys %hash ) {
    @name  = split( /\_/, $i );
    @name1 = split( /\:/, $name[0] );
    $name1[0] =~ s/chr//;

    #print "$name1[1]\n";
    $start = int( ( split /\-/, $name1[1] )[0] - ( 1000000 - ( ( split /\-/, $name1[1] )[1] - ( split /\-/, $name1[1] )[0] ) ) / 2 );
    $end   = int( ( split /\-/, $name1[1] )[1] + ( 1000000 - ( ( split /\-/, $name1[1] )[1] - ( split /\-/, $name1[1] )[0] ) ) / 2 );
    $num++;

    #print "$start\t$end\n";
    $txt = 'CNV' . $num;
    $out = $sample . '_' . $name1[0] . $hash{$i} . '(' . $name1[1] . ')X' . $name[1];
    open $txt, ">$out";
    print $txt "$header1";
    foreach $h ( sort { ( split /\_/, $a )[1] <=> ( split /\_/, $b )[1] } keys %hash1 ) {
        @cnv = split( /\_/, $h );
        if ( $cnv[0] eq $name1[0] and $cnv[1] > $start and $cnv[1] < $end ) {
            print $txt "$hash1{$h}\n";
        }
    }
}

foreach $i ( keys %hash2 ) {
    @name  = split( /\_/, $i );
    @name1 = split( /\:/, $name[0] );
    $name1[0] =~ s/chr//;
    $start = int( ( split /\-/, $name1[1] )[0] - ( 10000000 - ( ( split /\-/, $name1[1] )[1] - ( split /\-/, $name1[1] )[0] ) ) / 2 );
    $end   = int( ( split /\-/, $name1[1] )[1] + ( 10000000 - ( ( split /\-/, $name1[1] )[1] - ( split /\-/, $name1[1] )[0] ) ) / 2 );
    $num++;
    $txt = 'CNV' . $num;
    $out = $sample . '_' . $name1[0] . $hash2{$i} . '(' . $name1[1] . ')X' . $name[1];
    open $txt, ">$out";
    print $txt "$header1";
    foreach $h ( sort { ( split /\_/, $a )[1] <=> ( split /\_/, $b )[1] } keys %hash1 ) {
        @cnv = split( /\_/, $h );
        if ( $cnv[0] eq $name1[0] and $cnv[1] > $start and $cnv[1] < $end ) {
            print $txt "$hash1{$h}\n";
        }
    }
}

foreach $i ( keys %hash3 ) {
    @name  = split( /\_/, $i );
    @name1 = split( /\:/, $name[0] );
    $name1[0] =~ s/chr//;
    $start = int( ( split /\-/, $name1[1] )[0] - 1000000 );
    $end   = int( ( split /\-/, $name1[1] )[1] + 1000000 );
    $num++;
    $txt = 'CNV' . $num;
    $out = $sample . '_' . $name1[0] . $hash3{$i} . '(' . $name1[1] . ')X' . $name[1];
    open $txt, ">$out";
    print $txt "$header1";
    foreach $h ( sort { ( split /\_/, $a )[1] <=> ( split /\_/, $b )[1] } keys %hash1 ) {
        @cnv = split( /\_/, $h );
        if ( $cnv[0] eq $name1[0] and $cnv[1] > $start and $cnv[1] < $end ) {
            print $txt "$hash1{$h}\n";
        }
    }
}
