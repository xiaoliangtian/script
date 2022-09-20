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

die "Usage: perl $0 IN COGs.tag\n" unless (@ARGV == 2);
open (IN, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (TYPE, $ARGV[1]) or die "Can not open file $ARGV[1]\n";
open (OUT, ">$ARGV[0].anno") or die "Can not open file $ARGV[0].anno\n";
open (CNT, ">$ARGV[0].stat") or die "Can not open file $ARGV[0].stat\n";

my %cog_cato;my %col;my %cog;my %count;

while (<TYPE>) {
    chomp;
    next if (/^\#/);
    my @line=split /\t/;
    $cog_cato{$line[-1]}=$line[0];
    $col{$line[-1]}=$line[1];
}
close (TYPE);

print OUT "#Gene\tCOG ID\tCOG Function\tCOG Category\tCOG Abbr.\n";

<IN>;
while(<IN>){
    chomp;
    my @line=split /\t/;
    my $name=(split /\s+/,$line[0])[0];
    # gnl|CDD|30968 COG0623, FabI, Enoyl-[acyl-carrier-protein].
    # gnl|CDD|30899 COG0553, HepA, Superfamily II DNA/RNA helicases, SNF2 family [Transcription / DNA replication..].
    if ($line[5]=~/^(.+)\s\[([A-Z].+)\]\.$/) {
        my ($part1,$cog_cato)=($1,$2);
        $cog_cato=(split /\s+\//,$cog_cato)[0]; #use the frist COG Type
        $count{$cog_cato}++;
        my ($cog,$anno)=($part1=~/(COG\d+\,\s)+(.+)$/);
        $cog=(split/\,/,$cog)[0]; #use thr frist COG ID too
        print OUT "$name\t$cog\t$anno\t$cog_cato\t$cog_cato{$cog_cato}\n";
    }
}
close (IN);
close (OUT);

foreach (sort {$cog_cato{$a} cmp $cog_cato{$b}} keys %cog_cato){
    if (!exists $count{$_}) {
        $count{$_}=0;
    }
    print CNT "$cog_cato{$_}\t$count{$_}\t$_\t$col{$_}\n";
}
close (CNT);

my $DIR=dirname(abs_path($0));
`Rscript $DIR/COG.r $ARGV[0].stat`;
