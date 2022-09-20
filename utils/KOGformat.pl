#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/10/24

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

die "Usage: perl $0 IN KOGs.tag\n" unless (@ARGV == 2);
open (IN, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (TYPE, $ARGV[1]) or die "Can not open file $ARGV[1]\n";
open (OUT, ">$ARGV[0].anno") or die "Can not open file $ARGV[0].anno\n";
open (CNT, ">$ARGV[0].stat") or die "Can not open file $ARGV[0].stat\n";

my %kog_cato;my %col;my %kog;my %count;

while (<TYPE>) {
    chomp;
    next if (/^\#/);
    my @line=split /\t/;
    $kog_cato{$line[-1]}=$line[0];
    $col{$line[-1]}=$line[1];
}
close (TYPE);

print OUT "#Gene\tKOG ID\tKOG Function\tKOG Category\tKOG Abbr.\n";

<IN>;
while(<IN>){
    chomp;
    my @line=split /\t/;
    my $name=(split /\s+/,$line[0])[0];
    # gnl|CDD|39274 KOG4071, KOG4071, KOG4071, Uncharacterized conserved protein [Function unknown, Energy production and conversion].
    if ($line[5]=~/^(.+)\s\[([A-Z].+)\]\.$/) {
        my ($part1,$kog_cato)=($1,$2);
        $kog_cato=(split /\,\s+[A-Z]/,$kog_cato)[0]; #use the frist KOG Type
        $count{$kog_cato}++;
        my ($kog,$anno)=($part1=~/(KOG\d+\,\s)+(.+)$/);
        $kog=(split/\,/,$kog)[0]; #use thr frist KOG ID too
        print OUT "$name\t$kog\t$anno\t$kog_cato\t$kog_cato{$kog_cato}\n";
    }
}
close (IN);
close (OUT);

foreach (sort {$kog_cato{$a} cmp $kog_cato{$b}} keys %kog_cato){
    if (!exists $count{$_}) {
        $count{$_}=0;
    }
    print CNT "$kog_cato{$_}\t$count{$_}\t$_\t$col{$_}\n";
}
close (CNT);

my $DIR=dirname(abs_path($0));
`Rscript $DIR/COG.r $ARGV[0].stat KOG`;
