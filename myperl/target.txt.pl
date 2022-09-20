#!/usr/bin/perl
#use strict;
#use warnings;
my @line1;
my $on;
my @line3;
my $near;
my $snum;
my $rate1;
my $rate2;
my $off;
my $rate3;
die "Usage: perl $0 in in1 in2 > out\n" unless ( @ARGV == 3 );
open( IN,  "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( IN1, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
open( IN2, "$ARGV[2]" ) or die "Can not open file $ARGV[2]\n";

while (<IN>) {
    chomp;

    #@line = split (//, $_);
    @line1 = split( /\t/, <IN> );
}
$on = $line1[2];
print $on;

print $on;
while (<IN1>) {
    chomp;

    #@line2 = split (/\n/, $_);
    @line3 = split( /\t/, <IN1> );
    $near = $line3[2];
}
while (<IN2>) {
    $_ =~ s/\s+//g;
    $_ =~ s/Sum=//g;
    $snum = $_;
}
print "\n$snum";

$rate1 = $on / $snum;
print $rate1;
$rate2 = sprintf( "%.2f", $near / $snum );
$off   = $snum - $on - $near;
$rate3 = sprintf( "%.2f", $off / $snum );
print "\t$line1[0]\non target\t$on\nnear target(1-150)\t$near($rate2)\noff target\t$off($rate3)\n";

