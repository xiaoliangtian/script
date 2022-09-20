#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/14

#Change Log###########
#Auther:Nieh  Version:1.0.1  Modifed:2015/09/16  Commit:fix the output style.
#Auther: Nieh  Version: 1.2.0 Modifed: 2016/1/27 Commit: with tje new pipiline
######################

use strict;
#use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

die "Usage: perl $0 SNP\n" unless (@ARGV == 1);
open (OUT, ">$ARGV[0].xls") or die "Can not open file $ARGV[0].xls\n";
open (STAT, ">$ARGV[0]Stat.xls") or die "Can not open file $ARGV[0]Stat.xls\n";
open (PLOT, ">$ARGV[0].plot") or die "Can not open file $ARGV[0].plot\n";

my $DIR=dirname(abs_path($0));
my %transition = ("A","G","G","A","C","T","T","C");
my %stat;my %snp;my %plot;my @samples;my @chr;
my @files=<*.raw.vcf>;
if (@files == 0){
    die "the current floder do not have VCF file,please check";
}
print OUT "#Chr";#refloci\trefbase";
foreach my $file (@files){
    my ($sample) = ($file =~/(^\S+)\.vcf/);
    open(VCF,$file);
    push @samples,$sample;
    # print OUT "\t$sample\t\t\t\t\t";
    while(<VCF>){
        chomp;
        next if(/^\#/);
        $stat{0}{$sample}++;
        my @line = split /\s+/;
        my $alt = (split /\,/, $line[4])[0];
        my $chr="$line[0]\t$line[1]\t$line[2]";
       # my @chr=split (/\t/, $chr);
        my $snpchange="$line[3]\>$alt";
        $plot{$snpchange}{$sample}++;
        my ($flagtransition,$flaghomo)=(1,1);
        if($transition{$line[3]} eq $alt){
            $stat{1}{$sample}++;
        }else{
            $stat{2}{$sample}++;
            $flagtransition = 0;
        }
        if ($line[7] =~ /FQ=\d+/){
            $stat{3}{$sample}++;
        }else{
            $stat{4}{$sample}++;
            $flaghomo = 0;
        }
        my @basecov = ($line[7] =~ /DP4=(\d+),(\d+),(\d+),(\d+)\;/);

        my $snp = $alt.",".($basecov[0]+$basecov[1]).",".($basecov[2]+$basecov[3]);
        # my $snp = "$alt\t".($basecov[0]+$basecov[1]+$basecov[2]+$basecov[3])."\t".($basecov[0]+$basecov[1])."\t".($basecov[2]+$basecov[3])."\t$flagtransition\t$flaghomo";
        $snp{$chr}{$sample} = $snp;
    }
    close VCF;
}

print OUT "\t",join("\t",@samples),"\n";
# print OUT "\n\t\t","\tALTbase\tBaseCov\tRefCov\tALTcov\tTransition\tHomozygotes" x @samples,"\n";
foreach my $chr (keys %snp) {
    my @chr=split (/\t/, $chr);
    print OUT "$chr[0]".'_'."$chr[1]".'_'."$chr[2]";
    foreach my $sample (@samples) {
        if (!exists $snp{$chr}{$sample}) {
            # $snp{$chr}{$sample}="\t\t\t\t\t";
            $snp{$chr}{$sample}="0";
        }
        print OUT "\t$snp{$chr}{$sample}";
    }
    print OUT "\n";
}
close OUT;

print STAT "Sample\t",join("\t",@samples),"\n";
my @header=("SNP number","Transition Number","Transversion Number","Heterozygotes number","Homozygotes number");
foreach my $i (0..4) {
    print STAT "$header[$i]";
    foreach (@samples){
        print STAT "\t$stat{$i}{$_}";
    }
    print STAT "\n";
}
close STAT;

print PLOT "\t",join("\t",@samples),"\n";
foreach my $i (keys %plot) {
    print PLOT "$i";
    foreach (@samples){
        print PLOT "\t$plot{$i}{$_}";
    }
    print PLOT "\n";
}
close PLOT;
