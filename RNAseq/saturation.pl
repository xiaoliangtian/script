#/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/29

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 SAM/BAM SAM.dis\n" unless (@ARGV == 2);
if ($ARGV[0]=~/\.sam$/) {
    open (SAM, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
}else{
    open (SAM, "samtools view $ARGV[0] |") or die "Can not open file $ARGV[0]\n";
}
open (DIS, ">$ARGV[1]") or die "Can not open file $ARGV[1]\n";

my $step = 10000;
my $sum=0;
my %gene;
my ($samplename) = ($ARGV[0] =~ /^(\S+)\.sam/);

while(<SAM>){
    next if (/^@/);
    chomp;
    $sum++;
    my @line = split/\t/;
    next if ($line[5] eq "*");
    $gene{$line[2]}++;
    if($sum%$step == 0){
        my $gene_num = keys %gene;
        print DIS $sum,"\t",$gene_num,"\n";
    }
}
my $gene_num = keys %gene;
print DIS $sum,"\t",$gene_num,"\n";
close DIS;
