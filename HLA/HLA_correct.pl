#!/usr/bin/perl
use strict;
use warnings;

die "Usage: perl $0 bam contig.fa\n" unless ( @ARGV == 2 );
open( BAM, "samtools view $ARGV[0]|" )  or die "Failed to open file $ARGV[0]\n";
open( SAM, ">$ARGV[0].sam" )  or die "Failed to open file $ARGV[0].sam\n";
my @bam = <BAM>;
my $out = join"",@bam;
print SAM "$out\n";

#open( SAM, "$ARGV[0].sam" )  or die "Failed to open file $ARGV[0].sam\n";
#print "$bam\n";

my %hashseq;
my $hashall;
my $totalDepth;

open( FA,  "$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";
local $/= "\n>";

while(<FA>) {
    chomp;
    my @line = split(/\n/,$_);
    my $length = length($line[1])-50;
    for(my $i=0;$i <= $length;$i=$i+30) {
        my $seq = substr($line[1],$i,50);
        #my $num = grep /"$seq"/, @bam;
        $hashseq{$line[0].'_'.$seq} = `grep '$seq' $ARGV[0].sam -c`;
        $hashseq{$line[0].'_'.$seq} =~ s/\n$//;
        $hashall++;
        #print grep /AGCT/i,  <BAM>;
        $totalDepth += $hashseq{$line[0].'_'.$seq};
        print "$line[0]_$seq\t$hashseq{$line[0].'_'.$seq}\n";
    }
}

my $meanDepth = $totalDepth/$hashall;

print "$meanDepth\n";
foreach(keys %hashseq) {
    if($hashseq{$_}/$meanDepth < 0.2) {
        print "$_\t$hashseq{$_}\n";
    }
}

`rm $ARGV[0].sam`
