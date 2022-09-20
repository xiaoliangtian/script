#!/usr/bin/perl
#Author:Tian
#Version:1.0.0
#Date:20180911

#Change Log###########

######################

#use strict;
#use warnings;

die "Usage:
perl $0 in out \n" unless (@ARGV==2);

open (IN,"$ARGV[0]");
open (OUT,">$ARGV[1]");
while(<IN>) {
    chomp;
    $lineCount++;
    $lineInfo = $_;
    @line = split("\t",$lineInfo);
    if ($lineCount == 1){
        $line[0] = 'sample';
        $header = join("\t",@line);
        print OUT "$header\n";
    }
    elsif($lineCount > 1 and $line[1] ne 'Chr'){
        ($geno) = $lineInfo =~  m/(.\/.\:)/;
        #$geno =~ s/\://;
        ($varInfo) =  $lineInfo =~ m/([0-9]+\.?[0-9]{0,}\%)/;
        # print "$varInfo\n";
        print OUT "$lineInfo\t$geno$varInfo\n";
    }

}

close IN;
close OUT;