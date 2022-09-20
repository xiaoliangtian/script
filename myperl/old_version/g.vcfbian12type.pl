#!/usr/bin/perl
#use strict;
#use warnings;
my @line;

die "Usage: perl $0 g.vcf  db > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( DB, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<IN>) {
    chomp;
    s/\<NON_REF\>//g;
    @line = split( /\t/, $_ );

    #if ($line[4] =~',') {
    #print "$_\n";
    #$line[7] = substr ($line[7],5,10);
    if ( ( $line[7] - $line[1] ) == 0 ) {

        #print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[3]\t$line[5]\t$line[6]\t$line[1]\t$line[8]\t$line[9]\n";
        #$hash1{$chr}.="|".$chr.':'.$pos;
        $chr  = $line[0];
        $pos  = $line[1];
        $type = $line[9];

        #@type1= qw /$line[3] $line[4]/;
        $hash1{$chr} .= "|" . $chr . ':' . $pos;

        #@typ = split (/\:/,$type10);
        #@num1 = split (/\//,$typ[0]);
        #if ($typ[1] =~','){
        #@num = split (/\,/,$typ[1]);
        #foreach $num(@num) {
        #$rate .= $num/$typ[2].',';}
        #$rate = join (/\,/,@num/);
        #$type = "$line[3]\/$line[3]".':'.$rate.':'.$typ[2];
        $hash2{ $chr . ':' . $pos } = $type;
    }

    #if ($typ[1]!=~','){
    #if ($typ[1]==0) {
    #$type = './.'.':0'.':0';
    #$hash2{$chr.':'.$pos}=$type;}
    #if ($typ[1]>0) {
    #$type = "$line[3]\/$line[3]".':'.'1'.':'.$typ[1];
    # $hash2{$chr.':'.$pos}=$type;}
    #}

    #print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[3]\t$line[5]\t$line[6]\t$line[1]\t$line[8]\t$line[9]\n";
    # }
    else {
        # my $line[4] =~ s/\<NON_REF\>//g;
        $chr   = $line[0];
        $pos   = $line[1];
        $type5 = $line[9];
        @type6 = split( /\:/, $type5 );
        if ( $line[4] =~ ',' ) {
            @type2 = split( /\,/, $line[4] );

            #print @type2;
            unshift @type2, $line[3];

            #print @type2;
            if ( $type6[1] =~ ',' && $type6[2] ne 0 ) {
                @type7 = split( /\//, $type6[0] );

                #print "$type7[0]\t$type7[1]\n";
                @num1 = split( /\,/, $type6[1] );
                foreach $num1 (@num1) {
                    $rate1 .= $num1 / $type6[2] . ',';
                }
                $type  = "$type2[$type7[0]]\/$type2[$type7[1]]" . ':' . $rate1 . ':' . $type6[2];
                $rate1 = "";
                print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]\t$type\n";
            }
            if ( $type6[1] =~ ',' && $type6[2] eq 0 ) {
                $type7 = split( /\//, $type6[0] );
                $type = "$type2[$type7[0]]\/$type2[$type7[1]]" . ':' . '0' . ':' . $type6[2];
                print "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]\t$type\n";
            }
        }
    }
}
$/ = '>';
while (<DB>) {
    chomp;
    my ( $name, $seq ) = split( /\n/, $_, 2 );
    $name =~ s/>//g;
    $seq =~ s/\s+//g;

    #print "$name\t$seq\n";
    @line1 = split( /\|/, $hash1{$name} );

    #print @line1;
    shift @line1;
    foreach $line1 (@line1) {
        @line2 = split( /\:/, $line1 );
        $pos1 = substr( $seq, $line2[1] - 1, 1 );
        @typ = split( /\:/, $hash2{$line1} );
        if ( $typ[1] =~ ',' ) {
            @num = split( /\,/, $typ[1] );
            foreach $num (@num) {
                $rate .= $num / $typ[2] . ',';
            }
            $type = "$pos1\/$pos1" . ':' . $rate . ':' . $typ[2];
            print "$name\t$line2[1]\t\.\t$pos1\t$pos1\t\.\t\.\t$line2[1]\t'GT'\t$type\n";
        }

        # if ($typ[1]!=~',') {
        else {    #if ($typ[1]eq 0) {
                  #$type = './.'.':0'.':0';
                  #print "$name\t$line2[1]\t\.\t$pos1\t$pos1\t\.\t\.\t$line2[1]\t'GT'\t$type\n";}
            if ( $typ[1] > 0 ) {
                $type = "$pos1\/$pos1" . ':' . '1' . ':' . "$typ[1]";
                print "$name\t$line2[1]\t\.\t$pos1\t$pos1\t\.\t\.\t$line2[1]\t'GT'\t$type\n";
            }
            else {
                $type = './.' . ':0' . ':0';
                print "$name\t$line2[1]\t\.\t$pos1\t$pos1\t\.\t\.\t$line2[1]\t'GT'\t$type\n";
            }
        }
    }
}
