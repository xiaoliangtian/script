#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my $type = 0;

die "Usage: perl $0 g.vcf   > out\n" unless ( @ARGV == 1 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";

#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";
while (<IN>) {
    chomp;
    @line  = split( /\t/,  $_ );
    @type  = split( /\_/,  $line[0] );
    @type1 = split( /\D+/, $type[1] );
    foreach (@type1) {
        $type += $_;
    }

    #print "$type\n";
    $type[1] =~ s/\([A-Z]+\)//g;

    #print $type[1]."\n";
    @type2 = split( /[0-9]+/, $type[1] );
    $num = @type2;
    if ( $num >= 1 ) {
        foreach (@type2) {
            if ( $_ ne "" ) {
                $type += int( length($_) / 4 );

                #print "$type\n";
                $type_last = $type . '.' . length($_) % 4;
            }
            else {
                #print "$type\n";
                $type_last = $type;
            }
        }
    }
    else {
        #print "$type\n";
        $type_last = $type;
    }
    print "$type[0]" . '_' . "$type_last\t$line[1]\t$line[2]\n";
    $type = 0;
}

