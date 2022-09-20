#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther:Nieh  Version:1.0.1  Modifed:2015/09/10  Commit:fix the length count and replace the R script path
######################

use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

die "Usage: perl $0 Trinity.fasta contig.fa(unigene.fa) Trinity.stat\n" unless (@ARGV == 3);
open (IN, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "Can not open file $ARGV[1]\n";
open (OUT1, ">$ARGV[2]") or die "Can not open file $ARGV[2]\n";
open (DIS, ">$ARGV[0].dis") or die "Can not open file $ARGV[0].dis\n";
open (DIS1, ">$ARGV[1].dis") or die "Can not open file $ARGV[1].dis\n";

my $DIR=dirname(abs_path($0));
my $trintyversion=1;
my ($fwtrans,$fwtag,$fwlength);
my ($trans,$tag,$length);
my @translen;my @unigenelen;

local $/="\n>";
my $tmp=<IN>;
chomp $tmp;
my ($name,$fwseq)=split/\n/,$tmp,2;
$name=~s/>//g;
if ($name=~/^(TR\d+)(\S+)\s+len\=(\d+)\s/) {
    $trintyversion=2;
    ($fwtrans,$fwtag,$fwlength)=($1,$2,$3);
}else{
    ($fwtrans,$fwtag,$fwlength)=($name=~/^(\S+_seq)(\d+)\s+len\=(\d+)\s/);
}
push @translen,$fwlength;

while (<IN>) {
    chomp;
    s/>//g;
    my ($name,$seq)=split/\n/,$_,2;
    if ($trintyversion==2) {
        ($trans,$tag,$length)=($name=~/^(TR\d+)(\S+)\s+len\=(\d+)\s/);
    }else{
        ($trans,$tag,$length)=($name=~/^(\S+_seq)(\d+)\s+len\=(\d+)\s/);
    }
    push @translen,$length;
    if ($fwtrans ne $trans) {
        push @unigenelen,$fwlength;
        if ($trintyversion==2) {
            print OUT ">$fwtrans\n$fwseq\n";
        }else{
            print OUT ">$fwtrans$fwtag\n$fwseq\n";
        }
        ($fwtrans,$fwtag,$fwlength,$fwseq)=($trans,$tag,$length,$seq);
    }else{
        if ($length>$fwlength){
            ($fwtrans,$fwtag,$fwlength,$fwseq)=($trans,$tag,$length,$seq);
        }else{
            next;
        }
    }
}
push @unigenelen,$fwlength;
if ($trintyversion==2) {
    print OUT ">$fwtrans\n$fwseq\n";
}else{
    print OUT ">$fwtrans$fwtag\n$fwseq\n";
}
local $/="\n";
my ($usum,$unum,$uave,$udis)=&lengthdis(@unigenelen);
print DIS1 $udis;
close DIS1;
my ($tsum,$tnum,$tave,$tdis)=&lengthdis(@translen);
print DIS $tdis;
close DIS;
my ($un50,$un90,$umin,$umax)=&lengthcount($usum,@unigenelen);
my ($tn50,$tn90,$tmin,$tmax)=&lengthcount($tsum,@translen);
print OUT1 "Stat\tTranscript\tUnigene\n";
print OUT1 "Number\t$tnum\t$unum\n";
print OUT1 "Average length\t$tave\t$uave\n";
print OUT1 "Min Length\t$tmin\t$umin\n";
print OUT1 "Max Length\t$tmax\t$umax\n";
print OUT1 "N50 Length\t$tn50\t$un50\n";
print OUT1 "N90 Length\t$tn90\t$un90\n";

sub lengthcount {
    my $sum=shift @_;
    my @array=@_;
    my $Nsum=0;
    my ($n50,$n90)=(0,0);
    @array=sort {$b<=>$a} @array;
    my $min=$array[-1];
    my $max=$array[0];
    foreach (@array) {
        $Nsum+=$_;
        if ($Nsum*2>=$sum and $n50==0) {
            $n50=$_;
        }
        if ($Nsum*10>=$sum*9 and $n90==0) {
            $n90=$_;
        }
    }
    return $n50,$n90,$min,$max;
}

sub lengthdis {
    my @array=@_;
    my $num=@array;
    my ($sum,$ave)=(0,0);
    my ($two_three, $three_four, $four_five, $five_six, $six_seven, $seven_eight,
    $eight_nine, $nine_ten, $ten_twelve, $twelve_fourteen, $fourteen_sixteen, $sixteen_eighteen,
    $eighteen_twenty, $twenty_twentyfive, $twentyfive_thirty, $thirty_thirtyfive,
    $thirtyfive_fourty, $above_fourty) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
    foreach my $seqlen (@array){
        $sum+=$seqlen;
        if($seqlen>=200&&$seqlen<300){$two_three++}
        if($seqlen>=300&&$seqlen<400){$three_four++}
        if($seqlen>=400&&$seqlen<500){$four_five++}
        if($seqlen>=500&&$seqlen<600){$five_six++}
        if($seqlen>=600&&$seqlen<700){$six_seven++}
        if($seqlen>=700&&$seqlen<800){$seven_eight++}
        if($seqlen>=800&&$seqlen<900){$eight_nine++}
        if($seqlen>=900&&$seqlen<1000){$nine_ten++}
        if($seqlen>=1000&&$seqlen<1200){$ten_twelve++}
        if($seqlen>=1200&&$seqlen<1400){$twelve_fourteen++}
        if($seqlen>=1400&&$seqlen<1600){$fourteen_sixteen++}
        if($seqlen>=1600&&$seqlen<1800){$sixteen_eighteen++}
        if($seqlen>=1800&&$seqlen<2000){$eighteen_twenty++}
        if($seqlen>=2000&&$seqlen<2500){$twenty_twentyfive++}
        if($seqlen>=2500&&$seqlen<3000){$twentyfive_thirty++}
        if($seqlen>=3000&&$seqlen<3500){$thirty_thirtyfive++}
        if($seqlen>=3500&&$seqlen<4000){$thirtyfive_fourty++}
        if($seqlen>=4000){$above_fourty++}
    }
    $ave=$sum/$num;
    my $lines="200-300\t$two_three\n";
    $lines.="300-400\t$three_four\n";
    $lines.="400-500\t$four_five\n";
    $lines.="500-600\t$five_six\n";
    $lines.="600-700\t$six_seven\n";
    $lines.="700-800\t$seven_eight\n";
    $lines.="800-900\t$eight_nine\n";
    $lines.="900-1000\t$nine_ten\n";
    $lines.="1000-1200\t$ten_twelve\n";
    $lines.="1200-1400\t$twelve_fourteen\n";
    $lines.="1400-1600\t$fourteen_sixteen\n";
    $lines.="1600-1800\t$sixteen_eighteen\n";
    $lines.="1800-2000\t$eighteen_twenty\n";
    $lines.="2000-2500\t$twenty_twentyfive\n";
    $lines.="2500-3000\t$twentyfive_thirty\n";
    $lines.="3000-3500\t$thirty_thirtyfive\n";
    $lines.="3500-4000\t$thirtyfive_fourty\n";
    $lines.=">4000\t$above_fourty\n";
    return $sum,$num,$ave,$lines;
}
