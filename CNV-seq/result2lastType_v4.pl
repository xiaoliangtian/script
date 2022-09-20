#!/usr/bin/perl
#use strict;
#use warnings;

use Excel::Writer::XLSX;
use Encode;

die "Usage: perl $0 in out \n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";

#open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
$output = $ARGV[1];

my $workbook1  = Excel::Writer::XLSX->new("$output");
my $worksheet1 = $workbook1->add_worksheet("cnv");

my $header = <IN>;
$headLine =
"cnv\tchromosome\tstart\tend\tsize\ttype\ttrue_type\tband\tchromosome.start.end\tVariant\t区带起\t区带止\t变异分型\t类型\t分子核型起点\t分子核型止点\t大小\tOMIM基因\tgene_num\tgene\tomim_num\tomim_en\tomim_cn\tomim_gene\tpa_region\tregion_Name\tHI_score\tTS_score\tHI/TS_gene_num\tHI/TS_gene\tConrad.Common.CNV\tDGV.GoldStandard.Common.CNV\t1000Genomes.Common.CNV\tDECIPHER.Common.CNV\tHaploinsufficiency(LOD)\tExAC.genes.constraints\tExAC.pLI\tdecipher_urls";

$row = 0;
@headLine = split( /\t/, $headLine );
for my $c ( 0 .. $#headLine ) {
    $worksheet1->write( $row, $c, decode('utf-8',$headLine[$c]) );
}

$row++;

while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    $cnv        = $line[0];
    $chromosome = $line[1];
    $start      = $line[2];
    $end        = $line[3];
    $size       = $line[4];
    $type       = $line[5];
    $true_type  = $line[6];
    $band       = $line[7];
    $line[7] =~ s/\-//;
    @band = split /\-/, $band;
    $chromosome_start_end = $line[8];
    $line[8] =~ s/\:/\:g\. /;
    $line[8] =~ s/\-/\_/;
    $band_start = $line[1] . $band[0];
    $band_end   = $line[1] . $band[1];

    if ( $type > 2 ) {
        $cnv_type = "Gain";
        $CNV_type = 'seq[GRCh37]dup(' . $chromosome . ')(' . $line[7] . ')' . $line[8] . 'dup';
    }
    elsif ( $type < 2 ) {
        $cnv_type = "Loss";
        $CNV_type = 'seq[GRCh37]del(' . $chromosome . ')(' . $line[7] . ')' . $line[8] . 'del';
    }
    else {
        if ( $chromosome eq 'Y' ) {
            $cnv_type = "Gain";
            $CNV_type = 'seq[GRCh37]dup(' . $chromosome . ')(' . $line[7] . ')' . $line[8] . 'dup';
        }
        else {
            $cnv_type = "/";
            $CNV_type = "/";
        }
    }
    $cnv_type1  = "/";
    $type_start = $start;
    $type_start =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $type_end = $end;
    $type_end =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $type_size = $size;
    $type_size =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $omim_num = $line[11];
    $out1 = join( "\t", @line[ 9 .. 21 ] );

    $out2 = join("\t",@line[25..32]);
    $lineOut =
"$cnv\t$chromosome\t$start\t$end\t$size\t$type\t$true_type\t$band\t$chromosome_start_end\t$CNV_type\t$band_start\t$band_end\t$cnv_type\t$cnv_type1\t$type_start\t$type_end\t$type_size\t$omim_num\t$out1\t$out2";
    @lineOut = split( /\t/, $lineOut );
    for $c ( 0 .. $#lineOut ) {
        $worksheet1->write( $row, $c, decode('utf-8',$lineOut[$c]) );
    }
    $row++;

}

