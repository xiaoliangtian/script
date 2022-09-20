#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 in type  > out\n" unless ( @ARGV == 2 );

open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
my $type = $ARGV[1];
if ( $type eq 'A' ) {
    $lenRef = 3200;
}
elsif ( $type eq 'B' ) {
    $lenRef = 3215;
}
elsif ( $type eq 'C' ) {
    $lenRef = 3215;
}

my @result;
while (<IN>) {
    chomp;
    if ( substr( $_, 0, 3 ) eq 'Chr' ) {
        #print "$_\n";
    }
    else {
        my @line = split( /\t/, $_ );
        if ( $line[1] <= $lenRef ) {
            $hash1{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] . '_' . $line[4] } = $line[8] . ',';
            $hash2{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] . '_' . $line[4] } = $line[9] . ',';
            $hash3{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] . '_' . $line[4] } = $line[-1];
        }
        elsif ( $line[1] > $lenRef ) {
            $line[1] = $line[1] - $lenRef;
		$line[2] = $line[1];
            $hash1{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] . '_' . $line[4] } .= $line[8];
            $hash2{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] . '_' . $line[4] } .= $line[9];

        }
    }
}
print "Chr\tStart\tEnd\tRef\tAlt\tExonicFunc.refGene\tAAChange.refGene\ttype\n";
foreach ( sort { ( split /\_/, $a )[1] <=> ( split /\_/, $b )[1] } keys %hash1 ) {
    my @result = split( /\_/, $_ );
    my $result = join( "\t", @result );
    $hash1{$_} =~ s/\.\,//;
    $hash1{$_} =~ s/\,\.//;
    $hash2{$_} =~ s/\.\,//;
    $hash2{$_} =~ s/\,\.//;
    if($hash1{$_} eq "") {
	$hash1{$_} = '.';
    }
    if($hash2{$_} eq "") {
        $hash2{$_} = '.';
    }
    print "$result\t$hash1{$_}\t$hash2{$_}\t$hash3{$_}\n";
}
