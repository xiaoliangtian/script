#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = (
    "AATCACTAGGGAACCAAA_GCCTGTGTTGCTCAAGGG" => "D1S1656",
    "CCAATCTGGTCACAAACA_GTCTTGTTATTAAAGGAA" => "D10S1248",
    "GCTTCCGAGTGCAGGTCA_GGCAAAATTCAAAGGGTA" => "TH01",
    "TCCAGAGAGAAAGAATCA_CTCCATATCACTTGAGCT" => "D12S391",
    "GACTCTGACCCATCTAAC_GCCATAGGCAGCCCAAAA" => "D13S317",
    "ACTCTGAGTGACAAATTG_CTATTTCTTTTCTTTTTC" => "D18S51",
    "GTGTTTCAGGGCTGTGAT_CCTTCTGTCCTTGTCAGC" => "TPOX",
    "GGCTGTAACAAGGGCTAC_GGAGCTAAGTGGCTGTGG" => "D2S441",
    "GGATTGCAGGAGGGAAGG_GGATTTGGAAACAGAAAT" => "D2S1338",
    "TCCTAGCCTTCTTATAGC_GCGAATGTATGATTGGCA" => "D22S1045",
    "TTGCCAGCAAAAAAGAAA_AAAATTAGGCATATTTAC" => "FGA",
    "CATAGCCACAGTTTACAA_GGTGATTTTCCTCTTTGG" => "D5S818",
    "TTTCCTGTGTCAGACCCT_AATGAAGATATTAACAGT" => "CSF1PO",
    "CATATTGTGAAATTTCTC_GGATGGGTGGATCAATAG" => "D6S1043",
    "AATGTTTACTATAGACTA_AAAGGGTATGATAGAACA" => "D7S820",
    "CACGGCCTGGCAACTTAT_ATTTACCTATCCTGTAGA" => "D8S1179",
    "GGTAGAAATCCTGGCTGT_AACCTAAGCTGAAATGCA" => "DYS570",
    "CTCAGCCAAGCAACATAG_GGGAGTAATAAGCGTATT" => "DYS576",
    "TTCAATCATACACCCATA_GGTTGCAAGCAATTGCCA" => "DYS391",
    "TCTATCAATCTTCTACCT_TGATCAGTTCTTAACTCA" => "DYS533",
    "TCCATATCATCTATCCTC_TAGCAAGCACAAGAATAC" => "DYS460",
    "CTCATGAAATCAACAGAG_TATGATTCCCCCACTGCA" => "D3S1358",
    "GCACATACATTGTTTATA_CTCACTTCAAGCACCAAG" => "DYS635",
    "AGATACATAGGTGGAGAC_ATGCCTGGCTTGGAATTC" => "DYS439",
    "AGAGATAGGACAGATGAT_AAGAATAATCAGTATGTG" => "vWA",
);
my %len1 = (
"D1S1656"=>"R",
"D10S1248"=>"F",
"TH01"=>"F",
"D12S391"=>"F",
"D13S317"=>"F",
"D18S51"=>"F",
"TPOX"=>"F",
"D2S441"=>"F",
"D2S1338"=>"R",
"D22S1045"=>"F",
"FGA"=>"R",
"D5S818"=>"R",
"CSF1PO"=>"R",
"D6S1043"=>"R",
"D7S820"=>"R",
"D8S1179"=>"F",
"DYS570"=>"F",
"DYS576"=>"F",
"DYS391"=>"F",
"DYS533"=>"F",
"DYS460"=>"R",
"D3S1358"=>"F",
"DYS635"=>"R",
"DYS439"=>"F",
"vWA"=>"R",
);
my @line;
my $header;
my $adapt;
my $count;
my $effect = 0;
my @hash;
my %hash     = ();
my %hash_num = ();
my @prim;
my @hash1;
die "Usage: perl $0 fastq1 fastq2  adapt out1 out2 > out\n"
  unless ( @ARGV == 6 );
open( IN1, "gzip -dc $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
open( IN2, "gzip -dc $ARGV[1]|" ) or die "Can not open file $ARGV[1]\n";
open( ADAPT, ">>$ARGV[2].adapt.rate" )
  or die "Can not open file $ARGV[2].adatp.rate\n";
#open( OUT1, ">$ARGV[3]" )        or die "Can not open file $ARGV[3]\n";
#open( OUT2, ">$ARGV[4]" )        or die "Can not open file $ARGV[4]\n";
open( PRIM, ">$ARGV[5].primer" ) or die "Can not open file $ARGV[5].primer\n";

foreach ( keys %len ) {
    @hash = split( /\_/, $_ );
    $hash{ $hash[0] } = $len{$_} . '_F';
    
    $hash{ $hash[1] } = $len{$_} . '_R';
}

$/ = "\n\@N";
while ( defined( my $v1 = <IN1> ) and defined( my $v2 = <IN2> ) ) {

    #print $v1;
    $count++;
    my @fastq1 = split( /\n/,    $v1 );
    my @header = split( /(\s+)/, $fastq1[0] );
    my @fastq2 = split( /\n/,    $v2 );
    my $seq_a = substr( $fastq1[1], 0, 18 );
    my $seq_b = substr( $fastq2[1], 0, 18 );
    #print "$seq_a\t$seq_b\n";
    if ( exists $hash{$seq_a} ) {
        $hash_num{ $hash{$seq_a} }++;

        #print "$hash{$seq_a}\t$hash_num{ $hash{$seq_a} }\n";
    }
    if ( exists $hash{$seq_b} ) {
        $hash_num{ $hash{$seq_b} }++;
    }
    if ( $fastq1[1] =~ 'GGGGGGGGGGGGGGGGGGGGGG' ) {
        $adapt++;
    }
    elsif ( exists $len{ $seq_a . '_' . $seq_b } ) {
        $effect++;
        $hash_num{ $len{ $seq_a . '_' . $seq_b } }++;
        $header = '@M' . $header[0] . '_' . $len{ $seq_a . '_' . $seq_b };
        if($len1{$len{ $seq_a . '_' . $seq_b }} eq 'R') {
            $fastq1[1] =  reverse($fastq1[1]);
            $fastq1[1] =~ tr/ACGTacgt/TGCAtgca/;
            $fastq1[2] = reverse($fastq1[2]);
        }
        print "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
    }
    #elsif ( exists $len{ $seq_b . '_' . $seq_a }) {
#	$effect++;
#	$hash_num{ $len{ $seq_b . '_' . $seq_a } }++;
#	$header = '@' . $header[0] . '_' . $len{ $seq_b . '_' . $seq_a };
#	print "$header\n$fastq2[1]\n$fastq2[2]\n$fastq2[3]\n";
#    }
}
my ($sample) = ( $ARGV[0] =~ /^(.+)\_R1/ );
print ADAPT "$sample\t$adapt\t$count\t"
  . $adapt / $count . "\t"
  . $effect / $count . "\n";
print PRIM "pos\t$sample" . '_'
  . "F\t$sample" . '_'
  . "R\t$sample" . '_' . "F_R\n";
foreach ( sort { $len{$a} cmp $len{$b} } keys %len ) {
    @prim = split( /\_/, $_ );
    if ( !exists $hash_num{ $len{$_} . '_F' } ) {
        $hash_num{ $len{$_} . '_F' } = 0;
    }
    if ( !exists $hash_num{ $len{$_} . '_R' } ) {
        $hash_num{ $len{$_} . '_R' } = 0;
    }
    if ( !exists $hash_num{ $len{$_} } ) {
        $hash_num{ $len{$_} } = 0;
    }

    print PRIM
"$len{$_}\t$hash_num{$len{$_}.'_F'}\t$hash_num{$len{$_}.'_R'}\t$hash_num{$len{$_}}\n";
}

