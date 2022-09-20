#/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/29

#Change Log###########
#Auther: Nieh  Version: 1.2.0 Modifed: 2016/1/27 Commit: with tje new pipiline
######################
use strict;
use warnings;
use Statistics::R;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
#use Statistics::Multtest qw(BH);

die "Usage: perl $0 KEGG.xls DEG.xls DEG_KEGG DEG_KEGGEnrich\n" unless (@ARGV == 4);
open (ANNO, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (DEG, $ARGV[1]) or die "Can not open file $ARGV[1]\n";
open (DIFF, ">$ARGV[2]") or die "Can not open file $ARGV[2]\n";
open (RICH, ">$ARGV[3].xls") or die "Can not open file $ARGV[3].xls\n";
open (RIFF, ">$ARGV[3].gene") or die "Can not open file $ARGV[3].gene\n";

my %anno;my %gene_num;my %l3gene_num;
my %diff;my %diff_num;my %l3diff_num;

<ANNO>;
while(<ANNO>){
    chomp;
    my @line = split /\t/;
    my $var = join ("\t",@line[1..5]);
    if(!exists $anno{$line[0]}){
        $anno{$line[0]} = ();
    }
    $gene_num{$line[0]}=1;
    $l3gene_num{$line[5]}{$line[0]}=1;
    push @{$anno{$line[0]}}, $var;
}
close ANNO;

print DIFF "Gene\tKO ID\tAnnotaion\tKEGG L1\tKEGG L2\tKEGG L3\tResult\tFunction\n";
<DEG>;
while(<DEG>){
    chomp;
    my @line = split /\t/;
    if(exists $anno{$line[0]}){
        $diff_num{$line[0]}=1;
        foreach my $info (@{$anno{$line[0]}}){
            print DIFF $line[0],"\t",$info,"\t",$line[-1],"\t",$line[2],"\n";
            my @array=split/\t/,$info;
            $diff{$array[-2]}{$line[-1]}{$line[0]}=1;
            $l3diff_num{$array[-1]}{$line[0]}="$info\t$line[-1]";
        }
    }
}
close DEG;

my $N=keys %gene_num;
my $m=keys %diff_num;
my @p_value;my @info;
my $R=Statistics::R->new();
$R->set('m',$m);
$R->set('N',$N);
foreach my $lv (keys %l3gene_num) {
    my $p=0;
    my $k=keys %{$l3gene_num{$lv}};
    $R->set('k',$k);
    if (exists $l3diff_num{$lv}) {
        $p=keys %{$l3diff_num{$lv}};
    }
    $R->set('p',$p);
    $R->run(q`p_value<-phyper(p,k,N-k,m,lower.tail=F)`);
    my $p_value=$R->get('p_value');
    push @p_value,$p_value;
    push @info,"$lv\t$p\t$k\t$p_value";
}
$R->set('pvalue', \@p_value);
$R->run(q`qvalue<-p.adjust(pvalue,method="fdr")`);
my $qvalue=$R->get('qvalue');
print RICH "Pathway\tID\tSample number ($m)\tBackgroud number ($N)\tp value\tq value(BH adjust)\n";
print RIFF "EnrichGene\tKO ID\tAnnotaion\tKEGG L1\tKEGG L2\tKEGG L3\tResult\n";
foreach my $i (0..$#p_value) {
    if (@$qvalue[$i]<0.05){
        my ($lv,$res)=split/\t/,$info[$i],2;
        my ($ko,$l3)=($lv=~/^(\d+)\s+(.+)$/);
        print RICH "$l3\tko$ko\t$res\t@$qvalue[$i]\n";
        if (exists $l3diff_num{$lv}){
            foreach (keys %{$l3diff_num{$lv}}){
                print RIFF "$_\t$l3diff_num{$lv}{$_}\n";
            }
        }
    }
}
close RICH;
close RIFF;

my $DIR=dirname(abs_path($0));
system("Rscript $DIR/KEGGenrichscatter.r $ARGV[3].xls");
