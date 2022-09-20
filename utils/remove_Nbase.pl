#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 fq_in fq_out \n" unless (@ARGV == 2);
open (IN,"gzip -dc $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "Can not open file $ARGV[1]\n";

my $allnum=0;my $Nnum=0;
while (<IN>) {
    my $title=$_;
    my $seq=<IN>;
    chomp $seq;
    <IN>;
    my $qual=<IN>;
    chomp $qual;
    next unless ($title=~/^@/ && length($seq)==length($qual));
    my $len=length($seq);
    if ($seq=~/N/) {
        $Nnum++;
        my @seq=split//,$seq;
        my @qual=split//,$qual;
        ($seq,$qual)=("","");
        for (my $i=0;$i<@seq;$i++) {
            if ($seq[$i] ne "N") {
                $seq.=$seq[$i];
                $qual.=$qual[$i];
            }
        }
        next if ($seq eq "");
        next if (length($seq)*10<9*$len);
    }
    print OUT "$title$seq\n+\n$qual\n";
}
close IN;
close OUT;
