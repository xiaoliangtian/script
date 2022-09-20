#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/16

#Change Log###########
#Auther: Nieh  Version: 1.2.0 Modifed: 2016/1/27 Commit: with tje new pipiline
######################

use strict;
use warnings;

die "Usage: perl $0 express\n" unless (@ARGV == 1);
open (OUT, ">$ARGV[0]") or die "Can not open file $ARGV[0]\n";

my @files=<*.srt.bam.stat>;
if (@files == 0){
    die "the current floder do not have samtool idx2stat file,please check";
}

my @samples;
my %len;my %sum;my %reads;

print OUT "Gene\tLength";
foreach my $file (@files){
    my ($sample)=($file=~/(\S+)\.srt\.bam/);
    print OUT "\tReads\-$sample\tRPKM\-$sample";
    open(IN,$file);
    push @samples,$sample;
    while(<IN>){
        chomp;
        my @line=split /\s+/;
      #  my ($xm) = ($_ =~/\s+NM:i:(\d+)\s+/);
        next if($line[0] eq "*");
        $reads{$line[0]}{$sample}=$line[2];
        $sum{$sample}+=$line[2];
        $len{$line[0]}=$line[1];
    }
    close IN;
}
print OUT "\n";

foreach my $gene (keys %reads) {
    print OUT "$gene\t$len{$gene}";
    foreach (@samples) {
        print OUT "\t$reads{$gene}{$_}\t",$reads{$gene}{$_}/$len{$gene}/$sum{$_}*1000000000;
    }
    print OUT "\n";
}
