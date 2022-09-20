#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/19

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################

use strict;
use warnings;
use Getopt::Long;

my $anno;my $output;my %anno;my %len;
my $lenfile = "contig.fa.fai";
my ($log,$rpkm,$pvalue,$qvlaue)=(1,20,0.001,0.001);

GetOptions(
    "a:s" => \$anno,
    "c:s" => \$lenfile,
    "l:s" => \$log,
    "r:s" => \$rpkm,
    "p:s" => \$pvalue,
    "q:s" => \$qvlaue,
    "o=s" => \$output,
    "help|?" =>\&USAGE,
)or &USAGE;
&USAGE unless ($output and $anno);

sub USAGE {
    my $usage=<<"USAGE";
USAGE:
    $0 [options]  -o summary.out

    [-a anno]     = annotation file and location,example:Annotation.final,8
                    location index begin from 0,and the gene index must be 0

    [-c length]   = the file contain genelength,such es contig.fa.fai or GeneExpress

    [-l log2]     = the log2 cutoff,default 1

    [-r rpkm]     = the RPKM cutoff,default 20

    [-p pvalue]   = the pvalue cutoff,default 0.001

    [-q qvalue]   = the qvalue cutoff,default 0.001

    -o <output>   = Output DEG summary

    -h  --help      Help

USAGE
    print $usage;
    exit;
}

my @files = <*.vs.*.DEGseq/output_score.txt>;
if (length(@files) == 0) {
    die "thr current floder do not have DEGseq results,DEGseq/output_score.txt,please check";
}

my ($annofile,$loc) = split(/\,/,$anno);
open(ANNO,$annofile) or die "Can not open file $annofile";
while(<ANNO>){
    chomp;
    my @line = split /\t/;
    if ($loc < @line) {
        $anno{$line[0]} = $line[$loc];
    }
}
close ANNO;

open(FAI,$lenfile) or die "Can not open file $lenfile" ;
while (<FAI>) {
    chomp;
    my @line = split /\t/;
    $len{$line[0]} = $line[1];
}
close FAI;

open(STAT,">$output");
print STAT "DEGs\tup(%)\tdown(%)\n";

foreach my $file (@files) {
    open(DEG,$file);
    <DEG>;
    my %exp = ();
    my ($sumA,$sumB,$up,$down) = (0,0,0,0);
    while (<DEG>) {
        chomp;
        my @line = split /\t/;
        if ($line[1] eq "NA") { $line[1] = 0}
        if ($line[2] eq "NA") { $line[2] = 0}
        $sumA += $line[1];
        $sumB += $line[2];
        if ($line[1] == 0) { $line[1] = 0.5 }
        if ($line[2] == 0) { $line[2] = 0.5 }
        if ($line[6] eq "NA") { $line[6] = 1}
        if ($line[7] eq "NA") { $line[7] = 1}
        $exp{$line[0]} = "$line[1]\t$line[2]\t$line[6]\t$line[7]";
    }
    close DEG;

    my ($sampleA,$sampleB)=($file=~/^(\S+)\.vs\.(\S+)\.DEGseq/);
    open(OUT,">$sampleA.vs.$sampleB.DEA.xls");
    open(DIFF,">$sampleA.vs.$sampleB.DEG.xls");
    my $header = "#Gene\tLength\tFunction\tread $sampleA\tRPKM $sampleA\tread $sampleB\tRPKM $sampleB\tlog2(Fold change)\tp value\tq value(BH adjust)\tResult\n";
    print OUT  $header;
    print DIFF $header;
    foreach my $gene (keys %exp) {
        my @line = split/\t/,$exp{$gene};
        if (!exists $anno{$gene}) { $anno{$gene} = "";}
        my $RPKMA = $line[0]/$len{$gene}/$sumA*1000000000;
        my $RPKMB = $line[1]/$len{$gene}/$sumB*1000000000;
        my $log2 = &log_two($RPKMA/$RPKMB);
        print OUT "$gene\t$len{$gene}\t$anno{$gene}\t$line[0]\t$RPKMA\t$line[1]\t$RPKMB\t$log2\t$line[2]\t$line[3]\t";
        if (($line[2] < $pvalue) && ($line[3] < $qvlaue)) {
            if (($RPKMA >= $rpkm)||($RPKMB >= $rpkm)) {
                if ($log2 > $log) {
                    $up++;
                    print OUT "up\n";
                    print DIFF "$gene\t$len{$gene}\t$anno{$gene}\t$line[0]\t$RPKMA\t$line[1]\t$RPKMB\t$log2\t$line[2]\t$line[3]\tup\n";
                } elsif ( -$log2 > $log) {
                    $down++;
                    print OUT "down\n";
                    print DIFF "$gene\t$len{$gene}\t$anno{$gene}\t$line[0]\t$RPKMA\t$line[1]\t$RPKMB\t$log2\t$line[2]\t$line[3]\tdown\n";
                } else {print OUT "\n";}
            } else {print OUT "\n";}
        } else {print OUT "\n";}
    }
    close OUT;
    close DIFF;
    print STAT "$sampleA.vs.$sampleB\t$up(",sprintf("%.2f",$up/($up+$down)*100),"%)\t$down(",sprintf("%.2f",$down/($up+$down)*100),"%)\n";
}

sub log_two {
    my ($value) = shift;
    return log($value)/log(2);
}
