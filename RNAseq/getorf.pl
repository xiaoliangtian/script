#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/14

#Change Log###########
#Auther:  Version:  Modifed:  Commit:
######################

use strict;
use warnings;

die "Usage: perl $0 contig.fa cds.fa pep.fa\n" unless (@ARGV == 3);

my %codon=();
    $codon{GCT}="A";    $codon{GCC}="A";    $codon{GCA}="A";    $codon{GCG}="A";    $codon{TTA}="L";    $codon{TTG}="L";
    $codon{CTT}="L";    $codon{CTC}="L";    $codon{CTA}="L";    $codon{CTG}="L";    $codon{CGT}="R";    $codon{CGC}="R";
    $codon{CGA}="R";    $codon{CGG}="R";    $codon{AGA}="R";    $codon{AGG}="R";    $codon{AAA}="K";    $codon{AAG}="K";
    $codon{AAT}="N";    $codon{AAC}="N";    $codon{ATG}="M";    $codon{GAT}="D";    $codon{GAC}="D";    $codon{TTT}="F";
    $codon{TTC}="F";    $codon{TGT}="C";    $codon{TGC}="C";    $codon{CCT}="P";    $codon{CCC}="P";    $codon{CCA}="P";
    $codon{CCG}="P";    $codon{CAA}="Q";    $codon{CAG}="Q";    $codon{TCT}="S";    $codon{TCC}="S";    $codon{TCA}="S";
    $codon{TCG}="S";    $codon{AGT}="S";    $codon{AGC}="S";    $codon{GAA}="E";    $codon{GAG}="E";    $codon{ACT}="T";
    $codon{ACC}="T";    $codon{ACA}="T";    $codon{ACG}="T";    $codon{GGT}="G";    $codon{GGC}="G";    $codon{GGA}="G";
    $codon{GGG}="G";    $codon{TGG}="W";    $codon{CAT}="H";    $codon{CAC}="H";    $codon{TAT}="Y";    $codon{TAC}="Y";
    $codon{ATT}="I";    $codon{ATC}="I";    $codon{ATA}="I";    $codon{GTT}="V";    $codon{GTC}="V";    $codon{GTA}="V";
    $codon{GTG}="V";    $codon{TAG}="*";    $codon{TGA}="*";    $codon{TAA}="*";

`getorf -sequence=$ARGV[0] -outseq=getorf.temp -sformat=fasta -table=0 -minsize=90 -find=2 -osformat=fasta -auto -stdout`;
&GetLongOrf("getorf.temp",$ARGV[1]);
&TranslateFasta($ARGV[1],$ARGV[2]);

sub GetLongOrf{
    my @seqarray=@_;
    my %info=();
    my @order=();
    open(IN,"$seqarray[0]") or die "Can not open file $seqarray[0]\n";
    open(OUT,">$seqarray[1]") or die "Can not open file $seqarray[1]\n";
    local $/ = ">";
    while (<IN>) {
        chomp;
        my ($head,$seq) = split(/\n/,$_,2);
        next unless($head && $seq);
        my ($id,$start,$end) = ($head =~ /(\S+)_\d+\s+\[(\d+)\s-\s(\d+)\]/);
        my $len = abs($end - $start) + 1;
        if(exists $info{$id}) {
            $info{$id} = [">$id [$start - $end]\n$seq",$len] if($len > $info{$id}[1]);
        }else{
            $info{$id} = [">$id [$start - $end]\n$seq",$len];
            push(@order,$id);
        }
    }
    close(IN);
    local $/ = "\n";
    foreach my $id (@order) {
        print OUT $info{$id}[0];
    }
    close(OUT);
}

sub TranslateFasta{
    my @seqarray=@_;
    my %seq=();
    my @order=();
    open(IN,"$seqarray[0]") or die "Can not open file $seqarray[0]\n";
    open(OUT,">$seqarray[1]") or die "Can not open file $seqarray[1]\n";
    local $/ = ">";
    while (<IN>) {
        chomp;
        my ($head,$seq) = split(/\n/,$_,2);
        next unless($head && $seq);
        $seq=~s/\s+//g;$seq=uc($seq);
        $head=~s/\s+$//;
        push(@order,$head);
        $seq{$head}=$seq;
    }
    close(IN);
    local $/ = "\n";
    foreach my $id (@order) {
        my $neutmp=$seq{$id};
        my $aminotmp="";
        my $lentmp=length($neutmp)/3;
        for(my $j=0;$j<$lentmp;$j++) {
            my $codetmp=substr($neutmp,3*$j,3);
            if(exists $codon{$codetmp}) {
                $aminotmp="$aminotmp"."$codon{$codetmp}";
            }else{
                $aminotmp="$aminotmp"."X";
            }
        }
        print OUT ">$id\n$aminotmp\n";
    }
    close(OUT);
}
