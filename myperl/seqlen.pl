#!/usr/bin/perl
#use strict;
#use warnings;
use File::Basename;
use Getopt::Long;

#my ($opt_i,$opt_o);
#GetOptions(
#	   "i=s" => \$opt_i,
#      "o=s" => \$opt_o)
#my $OUTPUT_PATH = $opt_o ? $opt_o : "./";
die "Usage: perl $0 in out\n" unless ( @ARGV == 2 );
open( IN,  $ARGV[0] )    or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
my %len;
local $/ = "\n>";
while (<IN>) {
    chomp;
    s/>//;
    my ( $name, $seq ) = split /\n/, $_, 2;
    $seq =~ s/\s+//g;
    my $len = length($seq);
    $len{$len}++;
}
close(IN);

foreach (sort {$a <=> $b} keys %len){
        print OUT "$_\t$len{$_}\n";
}
close(OUT);
