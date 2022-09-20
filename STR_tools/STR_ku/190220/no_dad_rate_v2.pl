#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my $type = 0;

die "Usage: perl $0 genotype fre   > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( DB, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<IN>) {
    chomp;
    $num++;
    if ( $num == 1 ) {
        @line = split( /\t/, $_ );
        foreach (@line) {
            $hash2{$_} = 1;
        }
    }

    #@line1 = split(/\_/,$line[0]);
    #$hash{$line1[0]} = 1;
    #$hash1{$line[0].'_'.$num}=$line[1];
}

while (<DB>) {
    chomp;
    @line = split( /\t/, $_ );
    foreach ( keys %hash2 ) {
        if ( $line[0] =~ $_ ) {
            $num++;
            @line1 = split( /\_/, $line[0] );
            $hash{ $line1[0] } = 1;
            $hash1{ $line[0] . '_' . $num } = $line[1];
        }
    }
}

foreach $str ( keys %hash ) {
    foreach $type ( keys %hash1 ) {
        if ( $type =~ $str ) {
            @type = split( /\_/, $type );
            $pe1 += $hash1{$type} * ( 1 - $hash1{$type} )**2;

            #print "$pe1\n";
            foreach $type2 ( keys %hash1 ) {
                @type2 = split( /\_/, $type2 );
                if ( $type2 =~ $str and $type[2] < $type2[2] ) {
                    $pe2 +=
                      $hash1{$type}**2 *
                      $hash1{$type2}**2 *
                      ( 4 - 3 * $hash1{$type} - 3 * $hash1{$type2} );

                    #print "$pe2\n";
                }
            }
        }
    }
    $pe = $pe1 - $pe2 / 2;

    #print "$str\t$pe\n";
    $pe1 = 0;
    $pe2 = 0;
    push @pe, $pe;
}
my $pe3 = 1;
foreach (@pe) {
    if ( $_ ne "" ) {

        #print "$_\n";
        $pe3 *= ( 1 - $_ );

        #print "$pe3\n";
    }
}
$cpe = ( 1 - $pe3 );
print "CPE = $cpe\n";

