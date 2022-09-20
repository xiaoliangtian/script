#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 avinput  vep > out\n" unless ( @ARGV == 2 );
open( AVINPUT, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( VEP,     "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<AVINPUT>) {
    chomp;
    @name = split( /\t/, $_ );
    if ( $name[3] eq '-' ) {
        $name[1] = $name[1] + 1;
        $alname = "$name[0]" . "$name[1]" . '\\' . "$name[3]" . "$name[4]";
    }
    if ( $name[3] ne '-' ) {
        $alname = "$name[0]" . "$name[1]" . '\\' . "$name[3]" . "$name[4]";
    }

    # print "$alname\n";
    $hash{$alname} = $name[17];

    #print "$hash{$alname}\n";
}
while (<VEP>) {
    chomp;
    @header = split( /\t/, $_ );
    if ( $header[0] eq '#Uploaded_variation' ) {
        $header = "$_\tType\n";
    }
}
print $header;
open( VEP, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
@all = <VEP>;
foreach $all (@all) {
    chomp;
    $ou = $all;

    #print $all;
    chomp($ou);
    @line = split( /\t/, $ou );

    #if ($line[0]eq '#Uploaded_variation') {
    #$header = "$ou\tType\n";}
    # print $header;
    if ( $line[0] =~ '_' ) {
        @name1 = split( /_/, $line[0] );
        $chr = 'chr' . $name1[0];
        ##print $chr;
        $pos     = $name1[1];
        @anno    = split( '/', $name1[2] );
        $anova1  = $anno[0];
        $anova2  = $anno[1];
        $alname1 = "$chr" . "$pos" . '\\' . "$anova1" . "$anova2";

        #print "$alname1\n";
        if ( exists $hash{$alname1} ) {
            print "$ou\t$hash{$alname1}\n";
        }
    }
}

