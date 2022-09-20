#!/usr/bin/perl
use strict;
use warnings;
die "Usage: perl $0 in out \n" unless ( @ARGV == 2 );
open( IN,  "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" )or die "Can not open file $ARGV[1]\n";

my $header = <IN>;
my $result;
print OUT "$header";
while (<IN>) {
    chomp;
    my @line = split(/\t/,$_);
    $line[2]=~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $line[3] =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $line[4] =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    if($line[1] eq 'X' or $line[1] eq 'Y') {
        $result = join("\t",@line);
	print OUT "$result\n";
    }
    elsif($line[5] < 2 and $line[4]> 100000  and $line[6] < 1.6 ) {
	#print OUT "$_\n";
        $result = join("\t",@line);
        print OUT "$result\n";
    }
    elsif($line[5] > 2 and $line[4]> 200000 and $line[5] <=4  and $line[6] > 2.4 ) {
        $result = join("\t",@line);
	print OUT "$result\n";
        
    }
    
}
close(IN);
close(OUT);

