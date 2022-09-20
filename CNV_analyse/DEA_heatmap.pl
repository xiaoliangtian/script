#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther: Nieh  Version: 1.2.0 Modifed: 2016/1/27 Commit: with tje new pipiline
######################
use strict;
use warnings;

my @files=<*.vs.*.DEA.xls>;
if (length(@files) == 0) {
    die "thr current floder do not have DEA results,*.vs.*.DEA.xls,please check";
}
my $type="rpkm";

die "Usage: perl $0 out (log)\n" unless (@ARGV == 1 or @ARGV == 2);
open (OUT, ">$ARGV[0]") or die "Can not open file $ARGV[0]\n";

$type="log" if (@ARGV == 2);
my @groups;my %sample;my %log;my %rpkm;my %result;

foreach my $file (@files) {
    my ($sampleA,$sampleB)=($file=~/^(\S+)\.vs\.(\S+)\.DEA\.xls$/);
    $sample{$sampleA}=1;
    $sample{$sampleB}=1;
    my $vs="$sampleA\.vs\.$sampleB";
    push @groups,$vs;
    open (IN,$file);
    <IN>;
    while (<IN>) {
        chomp;
        my @line=split/\t/;
        push @{$log{$line[0]}},$line[7];
        $rpkm{$line[0]}{$sampleA}=$line[4];
        $rpkm{$line[0]}{$sampleB}=$line[6];
        if ($line[-1] eq "up" | $line[-1] eq "down") {
            $result{$line[0]}++;
        }
    }
    close (IN);
}

my @samples=keys %sample;

if ($type eq "rpkm") {
    print OUT "\t",join("\t",@samples),"\n";
}else{
    print OUT "\t",join("\t",@groups),"\n";
}
foreach my $gene (keys %result) {
    next if ($result{$gene} != @files);
    print OUT $gene;
    if ($type eq "rpkm") {
        foreach (@samples) {
            print OUT "\t$rpkm{$gene}{$_}";
        }
    }else{
        print OUT "\t",join ("\t",@{$log{$gene}})
    }
    print OUT "\n";
}
close (OUT);
