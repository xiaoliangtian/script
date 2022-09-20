#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
#use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

die "Usage: perl $0 Qsummary.xls\n" unless (@ARGV == 1);
open(OUT,">$ARGV[0]") or die "Can not open file $ARGV[0]\n";

my $DIR=dirname(abs_path($0));

my @files = <*.rm_1.fq>;
if (length(@files)==0) {
    die "thr current floder do not have R1.fastq,please check";
}

print OUT "Sample\tRead1\tQ20\tQ30\tGC\tRead2\tQ20\tQ30\tGC\n";
foreach my $file (@files) {
    my ($sample) = ($file=~/^(.+)\_R1/);
    my $stat = `$DIR/QGC_stat $file`;
    chomp $stat;
    my $file2 = $file;
    $file2 =~s/_R1/_R2/;
    my $stat2 = "\n";
    if (-e $file2) {
        $stat2 = `$DIR/QGC_stat $file2`;
    }
    print OUT "$sample\tR1\t$stat\tR2\t$stat2";
}
close (OUT);
