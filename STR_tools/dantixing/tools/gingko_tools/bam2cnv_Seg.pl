#!/usr/bin/perl
#use strict;
#use warnings;
use File::Basename;
use Getopt::Long;
my %len=(
);
my @line;
my $header;
my @band;
my $qu1="";
my $qu2="";
my $qu;
my $rate;
my $i;
#my $head = <IN>;
my %hash;
my %hash1;
my $h;
die "Usage: perl $0 in in1 > out\n" unless (@ARGV == 2);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
my @head = split(/\t/,<IN>);
print "$head[$ARGV[1]]\n";
my @key;
while (<IN>) {
	chomp;
	my @line=split(/\t/,$_);
	if (abs(abs($line[$ARGV[1]])-2) != 0 or abs(abs($line[$ARGV[1]])-2) == 0) {
		#push @key, $line[0].'_'.$line[1];
		$hash{$line[0].'_'.$line[1].'_'.$line[2]}=$line[$ARGV[1]];
		$line[0] =~ s/"//g;
		$line[0] =~ s/chr//g;
		$hash1{$line[0]} = 1; 
	}
}
print "cnv\tchromosome\tstart\tend\tsize\tlog2\n";
#shift @key;
my $cnv_num = 0;
foreach $h(sort {$a <=> $b} keys %hash1) {
	#print "$h\n";
	foreach $i(sort {(split /\_/,$a)[1] <=> (split /\_/,$b)[1]} keys %hash) {
		if ((split /\_/,$i)[0] eq 'chr'.$h) {
			$num++;
			if($num ==1){
				$type = $hash{$i};
				$start = (split /\_/,$i)[1];
				$end = (split /\_/,$i)[2];
				$chr = (split /\_/,$i)[0];
				print 'CNVR'."$cnv_num\t$chr\t$start\t";
				$num++;
			}
            		if(($num >1 and ((split /\_/,$i)[1]-$end) > 1) or ($num >1 and $hash{$i} != $type) ){
				$cnv_num++;
				$num++;
				#$type = $hash{$i};
				$lens = $end-$start;
				#print "$type\n";
				print "$end\t$lens\t$type\n".'CNVR'.$cnv_num."\t".(split /\_/,$i)[0]."\t".(split /\_/,$i)[1]."\t";
				$type = $hash{$i};
				$start = (split /\_/,$i)[1];
				$end = (split /\_/,$i)[2];                      
            		}
	    		elsif($num >1 and ((split /\_/,$i)[1]-$end) <= 1 and $hash{$i} == $type){
	   	 		$end = (split /\_/,$i)[2];
				$num++;
			}
		}
	}
	$last = $end-$start;
	print "$end\t".$last."\t".($type)."\n";
	$cnv_num++;
	$num=0;
}
