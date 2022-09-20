#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2016/01/15

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;
use Getopt::Long;

my $fasta;
my ($minlen,$window)=(10000,5000);
my $output="circos";

GetOptions(
    "f=s" => \$fasta,
    "m:s" => \$minlen,
    "w:s"=> \$window,
    "o:s" => \$output,
    "help|?" =>\&USAGE,
)or &USAGE;
&USAGE unless ($fasta);

open (IN, $fasta) or die "Can not open file $fasta\n";
open (KA, ">$output.karyotype.txt") or die "Can not open file $output.karyotype.txt\n";
open (RU, ">$output.rules.txt") or die "Can not open file $output.rules.txt\n";
open (GC, ">$output.gc.txt") or die "Can not open file $output.gc.txt\n";
open (GCSKEW, ">$output.gcskew.txt") or die "Can not open file $output.gcskew.txt\n";

my %counts;
my $color=0;

local $/="\n>";
while (<IN>) {
    chomp;
    s/>//g;
    my ($chr,$seq)=split/\n/,$_,2;
    $chr=(split/[\|\s]/,$chr)[0];
    $seq=~s/\s+//g;
    my $len=length($seq);
    next if ($len < $minlen);
    $color++;
    $color=1 if ($color==8) ;
    print KA "chr - $chr $chr 0 $len set1-7-qual-$color\n";
    print RU "<rule>\ncondition = _CHR1_ eq \"$chr\"\ncolor = set1-7-qual-$color\_a5\n</rule>\n";

    my @seqs=split "",$seq;
    %counts=("A",0,"T",0,"C",0,"G",0);
    my ($bincount,$length,$lastend,$firstn,$bandstart,$bandnum)=(0,0,0,0,0,0);
    foreach my $i (@seqs) {
        $i=uc($i);
        $counts{$i}++;
        $bincount++;
        $length++;
        if ($bincount==$window) {
            my $gc=($counts{"G"}+$counts{"C"})/($counts{"G"}+$counts{"C"}+$counts{"A"}+$counts{"T"})*100;
            my $gcskew=($counts{"G"}-$counts{"C"})/($counts{"G"}+$counts{"C"})*100;
            $bincount=0;
            %counts=("A",0,"T",0,"C",0,"G",0);
            print GC "$chr $lastend $length $gc\n";
            print GCSKEW "$chr $lastend $length $gcskew\n";
            $lastend=$length;
        }

        if ($i eq "N") {
            if ($firstn==0) {
                $firstn=1;
                $bandstart=$length;
            }
        }else {
            if ($firstn==1) {
                $firstn=0;
                $bandnum++;
                print KA "band $chr band$bandnum band$bandnum $bandstart $length black\n"
            }
        }
    }

    my $gc=($counts{"G"}+$counts{"C"})/($counts{"G"}+$counts{"C"}+$counts{"A"}+$counts{"T"})*100;
    my $gcskew=($counts{"G"}-$counts{"C"})/($counts{"G"}+$counts{"C"})*100;
    print GC "$chr $lastend $length $gc\n";
    print GCSKEW "$chr $lastend $length $gcskew\n";
}
local $/="\n>";
close (IN);
close (KA);
close (RU);
close (GC);
close (GCSKEW);

sub USAGE {
    my $usage=<<"USAGE";
USAGE:
    $0 [options]  -o summary.out

    -f  <fasta>      A fasta file of the assembled scaffolds

    -m  --minlen     The minimum length for a scaffold to allow for end-end connections.
                     Default=10000

    -w  --window     The bin size for GC/GCskew calculations,Default=5000

    -o <outputfile>  Output Prefix,Default=circos

    -h  --help       Help

USAGE
    print $usage;
    exit;
}
