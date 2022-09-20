#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/10/24

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 BlastTab OUT_prefix\n" unless (@ARGV == 2);
open (IN, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "Can not open file $ARGV[1]\n";
open (CNT, ">$ARGV[1].stat") or die "Can not open file $ARGV[1]\n";

my %count;
print OUT "#Gene\tNR ID\tFunction\tSpcies\tEvalue\n";

<IN>;
while(<IN>){
    chomp;
    my @line=split /\t/;
    my $name=(split/\s+/,$line[0])[0];
    my $evlaue=$line[7];
    # pdb sp pir
    if ($line[5]=~/(gi\|\d+\|)?(gb|ref|emb|dbj|tpd|tpe|tpg)(\|\S+)\s+(.+?)\s+\[([A-Z][a-z].+?)\]/) {
        my ($gi,$db,$id,$nranno,$spcies)=($1,$2,$3,$4,$5);
        if ($gi) {
            $id="$gi$db$id";
        }else{
            $id="$db$id";
        }
        print OUT "$name\t$id\t$nranno\t$spcies\t$evlaue\n";
        $count{$spcies}+=1;
    }
}
close (IN);
close (OUT);

foreach  (sort {$count{$b}<=>$count{$a}} keys %count) {
    print CNT "$_\t$count{$_}\n";
}
close (CNT);


