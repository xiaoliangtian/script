#!/usr/bin/perl
#use strict;
#use warnings;
my @line;

die "Usage: perl $0 g.vcf  db > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( DB, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<IN>) {
    chomp;
    @line = split( /\t/, $_ );

    #if ($line[4] =~',') {
    #print "$_\n";
    #$line[7] = substr ($line[7],5,10);
    if ( ( $line[7] - $line[1] ) == 0 ) {

        #print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[3]\t$line[5]\t$line[6]\t$line[1]\t$line[8]\t$line[9]\n";
        $chr                     = $line[0];
        $pos                     = $line[1];
        $type                    = $line[9];
        $hash{$chr}{$pos}{$type} = 1;

        #print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[3]\t$line[5]\t$line[6]\t$line[1]\t$line[8]\t$line[9]\n";
    }
    if ( ( $line[7] - $line[1] ) ne 0 ) {
        print "$_\n";
    }
}
print "$hash{$chr}{$pos}{$type}\n";
$/ = '>';
while (<DB>) {
    chomp;
    my ( $name, $seq ) = split( /\n/, $_, 2 );
    $name =~ s/>//g;
    $seq =~ s/\s+//g;

    #print "$name\t$seq\n";
    while ( $hash{$name}{$pos}{$type} ) {
        $pos1 = substr( $seq, $pos, 1 );
        print "$name\t$pos\t\.\t$pos1\t$pos1\t\.\t\.\t$pos\t'GT'\t$type\n";
    }
}

close;

