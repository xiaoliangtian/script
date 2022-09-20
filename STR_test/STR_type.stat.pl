#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl $0 in out \n" unless (@ARGV==2);

########################

open IN, "<$ARGV[0]"
  or die "Cannot open file $ARGV[0]!\n";
open OUT, ">$ARGV[1]"
  or die "Cannot open file $ARGV[1]!\n";

$header = <IN>;

print OUT "chr\tscore1\tmean1\tscore2\tmean2\tscore3\tmean3\n";
while(<IN>){
    chomp;
    @line = split(/\t/,$_);
    if ($line[1] eq 'NA'){
        next;
    }
    @type = split(/\//,$line[1]);
    $maxRatio = (split /\|/,$type[0])[-1];
    ($chr) = $line[0] =~ /(D([0-9]+|X|Y))/;
    $chr =~ s/D/chr/;
    # print "$line[0]\t$chr\n";
    $hash{$chr}++;
    $hashRatio{$chr} += $maxRatio;

    if ($maxRatio >=0.85 ){
        $hashchrTS1{$chr} += 1;
        $hashchrSTRNum1{$chr} += 1; 
    }
    elsif ($maxRatio >= 0.4 and $maxRatio < 0.8){
        $hashchrTS1{$chr} += 2;
        $hashchrSTRNum1{$chr} += 1;
        $hashchrSTRratio1{$chr} += $maxRatio;
        $hashchrSTRratioNum1{$chr}++ ;
    }
    elsif ($maxRatio >= 0.2 and $maxRatio < 0.4){
        $hashchrTS1{$chr} += 3;
        $hashchrSTRNum1{$chr} += 1;
    }
    if(scalar(@type) == 1 ){
        $hashchrTS2{$chr} += 1;
        $hashchrSTRNum2{$chr} += 1;
    }
    elsif (scalar(@type) == 2 ){
        $hashchrTS2{$chr} += 2;
        $hashchrSTRNum2{$chr} += 1;
        $hashchrSTRratio2{$chr} += $maxRatio;
        $hashchrSTRratioNum2{$chr}++ ;
    }
    elsif(scalar(@type) >=3 ){
        $hashchrTS2{$chr} += 3;
        $hashchrSTRNum2{$chr} += 1;
    }
    if (scalar(@type) == 1 and $maxRatio >=0.85 ){
        $hashchrTS3{$chr} += 1;
        $hashchrSTRNum3{$chr} += 1;
    }
    elsif (scalar(@type) == 2 ){
        if ($maxRatio >=0.85 ){
            $hashchrTS3{$chr} += 1;
            $hashchrSTRNum3{$chr} += 1;
        }
        elsif($maxRatio >= 0.4 and $maxRatio < 0.85){
            $hashchrTS3{$chr} += 2;
            $hashchrSTRNum3{$chr} += 1;
            $hashchrSTRratio3{$chr} += $maxRatio;
            $hashchrSTRratioNum3{$chr}++;
        }
    }
    elsif(scalar(@type) >= 3 ){
        if($maxRatio >= 0.85 ){
            $hashchrTS3{$chr} += 1;
            $hashchrSTRNum3{$chr} += 1;
        }
        elsif($maxRatio >= 0.4 and $maxRatio < 0.85){
            $hashchrTS3{$chr} += 2;
            $hashchrSTRNum3{$chr} += 1;
            $hashchrSTRratio3{$chr} += $maxRatio;
            $hashchrSTRratioNum3{$chr}++;
        }
        elsif($maxRatio >= 0.2 and $maxRatio < 0.4){
            $hashchrTS3{$chr} += 3;
            $hashchrSTRNum3{$chr} += 1;
        }
    }
    elsif(scalar(@type) == 4){
        $hashchrTS3{$chr} += 4;
        $hashchrSTRNum3{$chr} += 1;
    }

    foreach $ty(@type){
        @typeInfo = split(/\|/,$ty);
        $ratio = $typeInfo[-1];
        $allTy++;
        for ($i=0.1;$i<1;$i+=0.1){
            # print "$i\n";
            if ($ratio >= $i and $ratio < ($i + 0.1)){
                $hashTyStat{$i}++;
                # print "test\n";
            }
        }
    }
}

foreach $chr(sort{ (split /chr/,$a)[1] <=> (split /chr/,$b)[1] } keys %hash){
    # print "$chr\n";
    if (exists $hashchrSTRNum1{$chr}){
        $score1 = $hashchrTS1{$chr}/$hashchrSTRNum1{$chr};
        if (exists $hashchrSTRratioNum1{$chr}){
            $mean1 = $hashchrSTRratio1{$chr}/$hashchrSTRratioNum1{$chr};
        }
        else{
            $mean1 = "NA";
        }
    }
    else{
        $score1 = 'NA';
        $mean1 = "NA";
    }
    if (exists  $hashchrSTRNum2{$chr}){
        $score2 = $hashchrTS2{$chr}/$hashchrSTRNum2{$chr};
        if (exists $hashchrSTRratioNum2{$chr}){
            $mean2 = $hashchrSTRratio2{$chr}/$hashchrSTRratioNum2{$chr};
        }
        else{
            $mean2 = "NA";
        }
    }
    else{
        $score2 = 'NA';
        $mean2 = "NA";
    }
    if (exists  $hashchrSTRNum3{$chr}){
        $score3 = $hashchrTS3{$chr}/$hashchrSTRNum3{$chr};
        if (exists $hashchrSTRratioNum3{$chr}){
            $mean3 = $hashchrSTRratio3{$chr}/$hashchrSTRratioNum3{$chr};
        }
        else{
            $mean3 = "NA";
        }
    }
    else{
        $score3 = 'NA';
        $mean3 = "NA";
    }
    print OUT "$chr\t$score1\t$mean1\t$score2\t$mean2\t$score3\t$mean3\n";
}

foreach (sort keys %hashTyStat){
    $ratio = $hashTyStat{$_}/$allTy;
    print "$_\t$ratio\n";

}

