#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/15

#Change Log###########
#Auther:  Version:  Modifed:  Commit:
######################

use strict;
use warnings;

die "Usage: perl $0 COV_BED OUT\n" unless (@ARGV == 2);
open (BED, $ARGV[0]) or die "Can not open file $ARGV[0]\n";
open (OUT, ">$ARGV[1]") or die "Can not open file $ARGV[1]\n";

my ($zero, $one, $two, $three, $four, $five, $six, $seven, $eight, $nine) = (0,0,0,0,0,0,0,0,0,0);
my $fwid = "";

while(<BED>){
    chomp;
    my @line = split /\t/;
    last if($line[0] eq "genome");
    if($line[0] ne $fwid){
        if($line[1] == 0){
            my $cov = 1 - $line[-1];
            if($cov<=0.1){$zero++}
            if($cov>0.1&&$cov<=0.2){$one++}
            if($cov>0.2&&$cov<=0.3){$two++}
            if($cov>0.3&&$cov<=0.4){$three++}
            if($cov>0.4&&$cov<=0.5){$four++}
            if($cov>0.5&&$cov<=0.6){$five++}
            if($cov>0.6&&$cov<=0.7){$six++}
            if($cov>0.7&&$cov<=0.8){$seven++}
            if($cov>0.8&&$cov<=0.9){$eight++}
            if($cov>0.9){$nine++}
        }
        else{
            $nine++;
        }
    $fwid = $line[0];
    }
}
close BED;
print OUT "0-10%($zero)\t$zero\n";
print OUT "10%-20%($one)\t$one\n";
print OUT "20%-30%($two)\t$two\n";
print OUT "30%-40%($three)\t$three\n";
print OUT "40%-50%($four)\t$four\n";
print OUT "50%-60%($five)\t$five\n";
print OUT "60%-70%($six)\t$six\n";
print OUT "70%-80%($seven)\t$seven\n";
print OUT "80%-90%($eight)\t$eight\n";
print OUT "90%-100%($nine)\t$nine\n";
close OUT;
