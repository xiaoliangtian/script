#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther: Nieh  Version: 1.2.0 Modifed: 2016/1/27 Commit: with tje new pipiline
######################
use strict;
use warnings;

my @files=<*.vs.*.DEA.xls>;
if (length(@files) == 0) {
    die "thr current floder do not have DEA results,*.vs.*.DEA.xls,please check";
}

die "Usage: perl $0 out\n" unless (@ARGV == 1);
open (OUT, ">$ARGV[0]") or die "Can not open file $ARGV[0]\n";

my @groups;my %flag;my %result;

foreach my $file (sort @files) {
    my $vs=(split /\.DEA/,$file)[0];
    push @groups,$vs;
    open (IN,$file);
    <IN>;
    while (<IN>) {
        chomp;
        my @line=split/\t/;
        if ($line[-1] eq "up" | $line[-1] eq "down") {
            $flag{$line[0]}{$vs}=$line[7];
            $result{$line[0]}=0;
        }else{
            $flag{$line[0]}{$vs}=0;
        }
    }
    close (IN);
}

print OUT "\t",join("\t",@groups),"\n";
foreach my $gene (keys %result) {
	print OUT "$gene";
	foreach  (@groups) {
		print OUT "\t$flag{$gene}{$_}";
	}
	print OUT "\n";
}
close (OUT);
