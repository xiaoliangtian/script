#!/usr/bin/perl

use strict;
use warnings;

#die "Usage: perl $0 data \n" unless(@ARGV==1);

my $data_file = "$ARGV[0]";
my $hang      = 200000 ; #"$ARGV[1]";
my $max_hang = (split/ /,`samtools view $data_file |wc -l`)[0];
#print "$max_hang\n";
if ($hang >=$max_hang) {
    $hang = $max_hang;
}

#open (OUT, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";

#print " Generating ...\n";

open FH, "samtools view $data_file|" or die "Can not open the required file $data_file !";
my @data = <FH>;
close FH;

my %hash;
while ( ( keys %hash ) < $hang ) {
    $hash{ int( rand($#data) ) } = 1;
}

#open (OUT, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
#open OUT, "$ARGV[1]" or die "Can not open the required file $ARGV[1] !";
foreach ( keys %hash ) {
    print "$data[$_]";
}
#close OUT;

#print " Complete!\7";
