#!/usr/bin/perl
#use strict;
#use warnings;

die "Usage: perl $0 list in > out\n" unless ( @ARGV == 2 );

open( LIST, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( IN,   "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
while (<LIST>) {
    chomp;
    $name = $_;
    $hash{$name} = 1;
}
while (<IN>) {
    chomp;
    $line = $_;
    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        if ( $line_count == 1 ) {
            print
"Chrom\tGene Name\tExon|Intron\tdbSNP ID\tCodon Change\tref\talt1\talt2\talt3\tref_fre\tAlt_fre1\talt_fre2\talt_fre3\tAA Change\tEff Effect\n";
        }
        if ( $line_count > 1 ) {
            $Chrom  = $line[0];
            @chrom  = split( /\_/, $Chrom );
            $Chrom1 = 'chr' . $chrom[0];
            $gene   = $line[17];
            $exon   = $line[30];
            $intron = $line[31];
            $ei     = $exon . '|' . $intron;
            $dbSnp  = $line[12];
            $codon  = $line[32];
            @codon  = split( /\:/, $codon );
            @codon1 = split( /\./, $codon[0] );

            if ( exists $hash{ $codon1[0] } ) {

                @alt  = split( /\:/, $line[-1] );
                @alt1 = split( /\,/, $alt[1] );
                foreach $alt1 (@alt1) {
                    $rate .= $alt1 / $alt[2] . ',';

                    #$rate=sprintf "%.2f",$rate;
                    $Alt_fre = $rate;
                    @Alt_fre = split( ',', $Alt_fre );
                }
                $rate   = "";
                $change = $line[33];
                @change = split( /\:/, $change );
                if ( $change =~ '%' ) {

                    #	@change = split (/\:/, $change);
                    $aa = substr( $change[1], 2, 3 );
                    $change[1] =~ s/%3D/$aa/g;
                }
                else {
                    $change[1] = $change[1];
                }
                $eff = $line[6];
                print
"$Chrom1\t$gene\t$ei\t$dbSnp\t$codon[1]\t$alt1[0]\t$alt1[1]\t$alt1[2]\t$alt1[3]\t$Alt_fre[0]\t$Alt_fre[1]\t$Alt_fre[2]\t$Alt_fre[3]\t$change[1]\t$eff\n";
            }
        }
    }
}

