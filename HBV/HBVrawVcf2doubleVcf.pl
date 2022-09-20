#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 in type  > out\n" unless ( @ARGV == 2 );

open( IN, "gzip -dc $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
my $type = $ARGV[1];
if ($type eq 'A') {
    $lenRef = 3200;
}
elsif($type eq 'B') {
    $lenRef = 3215;
}
elsif($type eq 'C') {
    $lenRef = 3215;
}

my @result;
while (<IN>) {
    chomp;
    if(substr($_,0,1) eq '#') {
	print "$_\n";
    }
    else {
    	my @line = split( /\t/, $_ );
	print "$_\n";
	$line[1] = $line[1] + $lenRef;
	#$line[2] = $line[1];
	my $out = join("\t",@line);
	push @result, $out;
    }
}
my $result = join("\n",@result);
print "$result\n";
