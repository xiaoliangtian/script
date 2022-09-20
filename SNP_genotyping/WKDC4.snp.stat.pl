#!/usr/bin/perl
#Author:Tian
#Version:1.0.0
#Date:20180911

#Change Log###########

######################

use strict;
use warnings;

use Getopt::Long;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

#use Spreadsheet::WriteExcel;
use Excel::Writer::XLSX;

my $output;
my $anno;
GetOptions(
    "anno=s" => \$anno,
    "o=s"    => \$output,
    "help|?" => \&USAGE,
) or &USAGE;
&USAGE unless ($output);

my %others = ( "chr6:160560897" => "rs36056065", );

open(OUT, ">$output") or die "Can not open file $output\n";
my %anno;
open( ANNO, "$anno" ) or die "Can not open file $anno\n";

while (<ANNO>) {
    chomp;
    my @line = split( /\t/, $_ );
    $anno{ $line[0].'_'.$line[1] } = $line[2];
}
close(ANNO);

my %hash;
my %hashnum;
my %plot;
my $file3;
my @file;
my $snum = 1;

#my $row = 0;
my @files = <*.snp.anno.hg19_multianno.txt>;

#print " @files\n";
if ( scalar(@files) == 0 ) {
    die "the current floder do not have .snp.anno.hg19_multianno.txt,please cheack";
}


my @sample;
my $geno;
my $c;
my $var;
my $for_fre;
my $for_dep;
my $rev_dep;
my $rev_fre;
my $gene;
my $header = "sample\tChr\tStart\tEnd\tRS\tGene\tref\talt\tgenotype\tgeno\tvar ratio\n";
print OUT "$header";

foreach my $file (@files) {
    my ($sample) = ( $file =~ /^(.+)(_S[0-9]+|_combined).snp.anno.hg19_multianno.txt$/ );
    push @sample, $sample;

    #print "$sample\n";
    open( FILE, "$file" ) or die "Can not open file $file\n";
    @file = <FILE>;
    chomp(@file);
    foreach (@file) {
        my @line  = split( /\t/, $_ );
        if ($line[0] ne "Chr") {
        my $pos   = $line[0] . "_" . $line[1];
        my @line1 = split( /:/, $line[-1] );
        my $rs = $anno{$pos};
        $gene = $line[6];
        print OUT "$sample\t";
        if ( $line1[0] ne './.' ) {
            
            my @geno    = ("$line[3]","$line[4]");
            #print "@geno\n";
            $geno = $geno[(split/\//,$line1[0])[0]].$geno[(split/\//,$line1[0])[1]];
            my $format = $line1[0].":".$line1[4].':'.$line1[5].':'.$line1[3];
            my $var_ratio = $line1[6];
            print OUT "$line[0]\t$line[1]\t$line[2]\t$rs\t$gene\t$line[3]\t$line[4]\t$geno\t$format\t$var_ratio\n";
        }
        else {
            print OUT "$line[0]\t$line[1]\t$line[2]\t$rs\t$gene\t$line[3]\t.\t.\t./.\t.\n";
        }}
    }
    #print OUT "\n";
}


sub USAGE {
    my $usage = <<"USAGE";
USAGE:
    $0 [options]  -o summary.out
    -anno <annofile> in

    -o <outputfile>  Output summary

    -h  --help       Help

USAGE
    print $usage;
    exit;
}
