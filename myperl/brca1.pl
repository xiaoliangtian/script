#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 in > out\n" unless ( @ARGV == 1 );

open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
while (<IN>) {
    chomp;
    $line = $_;
    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        if ( $line_count == 1 ) {
            print
"gene\t染色体上位置\t碱基替换\tid\texac_af\texac_af_eas\tHGMD_dna\tclnhgvs\tgeno\t突变类型\tgene_id\thgvs_c\thgvs_p\t所在外显子\texon_number\t位点解释\n";
        }
        if ( $line_count > 1 and ( $line[17] =~ 'BRCA2' | $line[17] =~ 'BRCA1' ) and ( $line[32] =~ 'NM_000059.3' | $line[32] =~ 'NM_007294.3' ) ) {
            if ( $line[-1] =~ '0/1' ) {
                $geno = '杂合';
            }
            elsif ( $line[-1] =~ '1/1' ) {
                $geno = '纯合';
            }
            ( $type1, $type2 ) = split( '\/', $line[0], 2 );
            @type3 = split( '\_', $type1 );
            $type = $type3[-1] . '>' . $type2;

            #print "\n";
            ( $one, $two )  = split( '\:', $line[33], 2 );
            ( $tre, $tre1 ) = split( '\:', $line[32], 2 );

            #($tre,$tre1) = split ('\.',$two);
            # $tre1 =~ /-?(\d+)\.?(\d+)/;
            #print "$tre1\n";
            ( $exon,  $num )  = split( '\/', $line[30], 2 );
            ( $exon1, $num1 ) = split( '\/', $line[31], 2 );
            if ( $line[17] eq 'BRCA2' and length( $line[10] ) == 1 and length( $line[30] ) == 1 ) {
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000139618\t$tre1\t"
                  . "$one" . ':' . 'p.'
                  . "$line[10]"
                  . $two
                  . $line[10]
                  . "\t$exon1\t$num1\t$line[35]\n";
            }
            if ( $line[17] eq 'BRCA1' and length( $line[10] ) == 1 and length( $line[30] ) == 1 ) {
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000012048\t$tre1\t"
                  . "$one" . ':' . 'p.'
                  . "$line[10]"
                  . $two
                  . $line[10]
                  . "\t$exon1\t$num1\t$line[35]\n";
            }

            if ( $line[17] eq 'BRCA2' and length( $line[10] ) > 1 and length( $line[30] ) == 1 ) {
                ( $aj1, $aj2 ) = split( '/', $line[10], 2 );
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000139618\t$tre1\t"
                  . "$one" . ':' . 'p.' . "$aj1"
                  . $two
                  . $aj2
                  . "\t$exon1\t$num1\t$line[35]\n";
            }

            if ( $line[17] eq 'BRCA1' and length( $line[10] ) > 1 and length( $line[30] ) == 1 ) {
                ( $aj1, $aj2 ) = split( '/', $line[10], 2 );
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000012048\t$tre1\t"
                  . "$one" . ':' . 'p.' . "$aj1"
                  . $two
                  . $aj2
                  . "\t$exon1\t$num1\t$line[35]\n";
            }
            if ( $line[17] eq 'BRCA2' and length( $line[10] ) == 1 and length( $line[30] ) > 1 ) {
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000139618\t$tre1\t"
                  . "$one" . ':' . 'p.'
                  . "$line[10]"
                  . $two
                  . $line[10]
                  . "\t$exon\t$num\t$line[35]\n";
            }
            if ( $line[17] eq 'BRCA1' and length( $line[10] ) == 1 and length( $line[30] ) > 1 ) {
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000012048\t$tre1\t"
                  . "$one" . ':' . 'p.'
                  . "$line[10]"
                  . $two
                  . $line[10]
                  . "\t$exon\t$num\t$line[35]\n";
            }

            if ( $line[17] eq 'BRCA2' and length( $line[10] ) > 1 and length( $line[30] ) > 1 ) {
                ( $aj1, $aj2 ) = split( '/', $line[10], 2 );
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000139618\t$tre1\t"
                  . "$one" . ':' . 'p.' . "$aj1"
                  . $two
                  . $aj2
                  . "\t$exon\t$num\t$line[35]\n";
            }

            if ( $line[17] eq 'BRCA1' and length( $line[10] ) > 1 and length( $line[30] ) > 1 ) {
                ( $aj1, $aj2 ) = split( '/', $line[10], 2 );
                print "$line[17]\t$line[1]\t$type\t$line[12]\t$line[44]\t$line[49]\t$line[32]\t$line[33]\t$geno\t$line[6]\tENSG00000012048\t$tre1\t"
                  . "$one" . ':' . 'p.' . "$aj1"
                  . $two
                  . $aj2
                  . "\t$exon\t$num\t$line[35]\n";
            }
        }
    }
}

