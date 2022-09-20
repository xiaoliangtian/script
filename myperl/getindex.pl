#!/usr/bin/perl
use strict;
use warnings;
die "Usage: perl $0 in out index \n" unless ( @ARGV == 3 );
open( IN,  "gzip -dc $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" )          or die "Can not open file $ARGV[1]\n";
my $index = $ARGV[2];
while (<IN>) {
    my $header = $_;
    my $seq    = <IN>;
    my $s      = <IN>;
    my $qual   = <IN>;
    if ( $header =~ /0\:$index\n$/ ) {
        print OUT "$header$seq$s$qual";
    }
}
close(IN);
close(OUT);

