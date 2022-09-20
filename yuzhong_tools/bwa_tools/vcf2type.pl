#!/usr/bin/perl
use strict;
use warnings;
die "Usage: perl $0 in out \n" unless ( @ARGV == 2 );
open( IN,  "$ARGV[0]" )  or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";

my $header = <IN>;
print OUT $header;
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    if ( $_ !~ '/1' and $_ !~ '/2' and length( $line[2] ) == 1 ) {
        if ( $line[4] =~ ',' ) {
            $line[3] =~ s/$line[3]/./;
            my $type = join( "\t", @line );
            print OUT "$type\n";
        }
    }
    elsif ( length( $line[2] ) eq 1 and length( $line[3] ) eq 1 ) {
        print OUT "$_\n";
    }
}
close(IN);
close(OUT);

