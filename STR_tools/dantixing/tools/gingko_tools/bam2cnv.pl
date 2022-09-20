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
die "Usage: perl $0 in > out\n" unless (@ARGV == 1);
open (IN, "$ARGV[0]") or die "Can not open file $ARGV[0]\n";
my $head = <IN>;
my @key;
while (<IN>) {
	chomp;
	my @line=split(/\t/,$_);
	if (abs(abs($line[6])-2) > 0.5) {
		#push @key, $line[0].'_'.$line[1];
		$hash{$line[0].'_'.$line[1].'_'.$line[2]}=$line[6];
		$line[0] =~ s/"//g;
		#$line[0] =~ s/chr//g;
		$hash1{$line[0]} = 1; 
	}
}
print "cnv\tchromosome\tstart\tend\tsize\tlog2\n";
#shift @key;
my $cnv_num = 0;
foreach $h(sort {$a <=> $b} keys %hash1) {
	#print "$h\n";
	foreach $i(sort {(split /\_/,$a)[1] <=> (split /\_/,$b)[1]} keys %hash) {
		#print "$i\n";
		if ((split /\_/,$i)[0] eq $h) {
		#	print "yes\t$i\n";
			$num++;
			if($num ==1){
				#$cnv_num++;
				$start = (split /\_/,$i)[1];
				$end = (split /\_/,$i)[2];
				#print $end."\n";
				$chr = (split /\_/,$i)[0];
				print 'CNVR'."$cnv_num\t$chr\t$start\t";
				$num1++;
				$sum += log($hash{$i}/2)/log(2);
				#print log($hash{$i})/log(2)."\n";
				$sum2 += $hash{$i}; 
			}
			if($num >1 and ((split /\_/,$i)[1]-$end) > 1){
				#$end = (split /\_/,$i)[1]+ 2500000;
				#$num1++;
				#$sum += $hash{$i};
				#print "$num1\t$sum\n";
				$cnv_num++;
				print "$end\t".($end-$start)."\t".($sum2/$num1)."\n".'CNVR'.$cnv_num."\t".(split /\_/,$i)[0]."\t".(split /\_/,$i)[1]."\t";
				#print "$num1\t$sum\n";
				$num1 = 0;
				$sum = 0;
				$sum2 = 0;
				$num1++;
				$sum += log($hash{$i}/2)/log(2);
				$sum2 += $hash{$i};
				#$cnv_num++;
				$start = (split /\_/,$i)[1];
				$end = (split /\_/,$i)[2];
				
				
			}
			elsif($num >1 and ((split /\_/,$i)[1]-$end) <= 1 and abs($sum + log($hash{$i}/2)/log(2))< abs($sum)) {
				$cnv_num++;
				#print log($hash{$i}/2)/log(2)."\n";
				print "$end\t".($end-$start)."\t".($sum2/$num1)."\n".'CNVR'.$cnv_num."\t".(split /\_/,$i)[0]."\t".(split /\_/,$i)[1]."\t";
				$num1 = 0;
                                $sum = 0;
				$sum2 = 0;
                                $num1++;
                                $sum += log($hash{$i}/2)/log(2);
				$sum2 += $hash{$i};
                                #$cnv_num++;
                                $start = (split /\_/,$i)[1];
                                $end = (split /\_/,$i)[2];
			}
			else {
				$num1++;
                                $sum += log($hash{$i}/2)/log(2);
				$sum2 += $hash{$i};
				$end = (split /\_/,$i)[2];
				#$cnv_num++;
				#$start = (split /\_/,$i)[1];
			}
		}
	   }
	print "$end\t".($end-$start)."\t".($sum2/$num1)."\n";
#	print "$num1\t$sum\n";
	$cnv_num++;
	$num = 0;
	$num1 =0;
	$sum =0;
	$sum2 = 0;
}
