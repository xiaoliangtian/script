#/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/29

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 mismatch.stat\n" unless (@ARGV == 1);
open (OUT, ">$ARGV[0]") or die "Can not open file $ARGV[0]\n";

my @sam = <*.sam>;
my @files = <*.bam>;
if (@sam == 0 && @files == 0) {
    die "the current floder do not have SAM or BAM file,please check";
}
if (@sam != 0) {
    @files = @sam;
}
my %hash;
foreach my $file (@files) {
    my ($sample) = ($file =~/(^\S+)\.bam/);
    $hash{0}{$sample}=$sample;
    if ($file =~/sam$/) {
        open (SAM,$file);
    }else{
        open (SAM, "samtools view $file |");
    }
    while(<SAM>){
        next if (/^@/);
        chomp;
        $hash{1}{$sample}++;
        my @line = split/\t/;
        next if ($line[5] eq "*");
        $hash{2}{$sample}++;
        unless (/\s+(XS:\S+)\s+/){
            $hash{4}{$sample}++;
        }else{
            $hash{5}{$sample}++;
        }
        my ($xm) = ($_ =~/\s+NM:i:(\d+)\s+/);
        if ($xm == 0) {
            $hash{6}{$sample}++;
        }elsif ($xm <= 5) {
            $hash{7}{$sample}++;
        }
    }
    $hash{3}{$sample}=$hash{1}{$sample}-$hash{2}{$sample};
    close SAM;
}

my @header = ("Sample","Total reads","Total mapped","Total unmapped","Unique match","Mutliple match","Perfect match","<=5bp mismatch");
foreach my $i (sort {$a<=>$b} keys %hash) {
    print OUT "$header[$i]";
    foreach  (sort keys %{$hash{$i}}) {
        if ($i>1) {
            my $per = sprintf("%.2f",$hash{$i}{$_}/$hash{1}{$_}*100);
            $hash{$i}{$_}.="($per\%)";
        }
        print OUT "\t$hash{$i}{$_}";
    }
    print OUT "\n";
}

