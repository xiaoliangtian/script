#!/usr/bin/perl

use strict;
use warnings;

my $data_file = "$ARGV[0]";

print " Generating ...\n";

open FH, "$data_file" or die "Can not open the required file $data_file !";
my @data = <FH>;
close FH;

for (1..100) {
        my %hash;
        while ((keys %hash) < 1280) {
                 $hash{int(rand($#data))} = 1;
        }
        open OUT, ">random$_.txt" or die "Can not open the required file random$_.txt !";
        foreach (keys %hash) {
                 print OUT "$data[$_]";
        }
        close OUT;
}
print " Complete!\7";
