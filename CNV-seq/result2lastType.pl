#!/usr/bin/perl
#use strict;
#use warnings;
die "Usage: perl $0 in out \n" unless ( @ARGV == 2 );
open( IN,  "$ARGV[0]" )  or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";


my $header = <IN>;
print OUT "cnv\tchromosome\tstart\tend\tsize\ttype\ttrue_type\tband\tchromosome.start.end\t区带起\t区带止\t变异分型\t类型\t分子核型起点\t分子核型止点\t大小\tOMIM基因\tgene_num\tgene_name\tomim_num\tgene_pheno\tDGV.GoldStandard.hg19\t1000Genomes.hg19\tDECIPHER.hg19\tHaploinsufficiency.hg19\tConrad.hg19\n";
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    $cnv  = $line[0];
    $chromosome = $line[1];
    $start = $line[2];
    $end = $line[3];
    $size = $line[4];
    $type = $line[5];
    $true_type = $line[6];
    $band = $line[7];
    @band = split/\-/,$band;
    $chromosome_start_end = $line[8];
    $band_start = $line[1].$band[0];
    $band_end = $line[1].$band[1];
    if ($type > 2) {
	$cnv_type = "Gain";
    }
    elsif($type <2) {
	$cnv_type = "Loss";
    }
    else {
	$cnv_type = "/";
    }
    $cnv_type1 = "/";
    $type_start = $start;
    $type_start=~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $type_end = $end;
    $type_end =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $type_size = $size;
    $type_size =~ s/(?<=\d)(?=(\d{3})+$)/,/g;
    $omim_num = $line[-3];
    print OUT "$cnv\t$chromosome\t$start\t$end\t$size\t$type\t$true_type\t$band\t$chromosome_start_end\t$band_start\t$band_end\t$cnv_type\t$cnv_type1\t$type_start\t$type_end\t$type_size\t$omim_num\t$line[9]\t$line[10]\t$line[-3]\t$line[-2]\t$line[11]\t$line[12]\t$line[13]\t$line[14]\t$line[-1]\n";
}

