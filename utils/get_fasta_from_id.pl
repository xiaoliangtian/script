#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/10/09

#Change Log###########
#Auther:  Version:  Modifed:  Commit:
######################

die "Usage: perl $0 fasta id out\n" unless (@ARGV == 3);
open (FA, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (IN, $ARGV[1]) or die "Can not open file $ARGV[1]\n";
open (OUT, ">$ARGV[2]") or die "Can not open file $ARGV[2]\n";
my %seq;
while (<IN>) {
    chomp;
    my @line=split /\s+/;
    $seq{$line[0]}=1;
}
close (IN);

local $/="\n>";
while (<FA>) {
    chomp;
    s/\>//g;
    my ($name,$seq)=split/\n/,$_,2;
    if (exists $seq{$name}) {
        print OUT "\>$name\n$seq\n";
    }
}
close (FA);
close (OUT);
