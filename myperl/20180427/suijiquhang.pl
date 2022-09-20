#!/usr/bin/perl

use strict;
use warnings;

my $data_file = "$ARGV[0]";
#open (OUT, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";

#print " Generating ...\n";

open FH, "$data_file" or die "Can not open the required file $data_file !";
my @data = <FH>;
close FH;

        my %hash;
        while ((keys %hash) < $ARGV[1]) {
                 $hash{int(rand($#data))} = 1;
        }
	#open (OUT, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
        #open OUT, "$ARGV[1]" or die "Can not open the required file $ARGV[1] !";
        foreach (keys %hash) {
                 print  "$data[$_]";
        }
        close OUT;
#print " Complete!\7";
