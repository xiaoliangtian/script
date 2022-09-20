#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = (
    "GGCGTACTCAAGTTGC_GCTGTCTCTCCCGCCC" => "PD1",
    "AGGTGGAATTGAACCT_TCCTGGGAAGGGAAAT" => "PD2",
    "CCTCCACCAGGATGAA_CCGAGAGAAAGATCGC" => "PD3",
    "ACCACAGGAGCAATGA_ACCTGCTTACGACGCC" => "PD4",
    "TGCCTGTGCATCATGG_AATTGGTGAATCATTG" => "PD5",
    "TTGCCCCTTGCTAGAA_AGCTGAAGATTTGGTC" => "PD6",
    "CCCATCCGTGCCCTCG_ACCTTCATCCTCGACC" => "PD7",
    "CTGCGTAAGCGGCTCC_ACGCGGCCCTGTTCCA" => "PD8",
    "AACAACAGTTCCCCAA_GTGTTTTGGTATGCAC" => "PD9",
    "CCCCACACGGAGATCC_CCACAGGAGGATAAAC" => "PD10",
    "GCTCCTTAGGCCAATC_CTCTAATTGAGTCGCA" => "PD11",
    "CACATTCAAATGCTCT_ATAAAGGACATTAGGT" => "PD12",
    "GCATGGAATTGTGAAC_AAAGTTGTTCGCAATC" => "PD13",
    "AGCACTGCCTCCTAAA_AAGTTTCTGTAGCCTT" => "PD15",
    "GCCCTGATCCTGACCT_CCAAGGTGCTGACTGG" => "PD16",
    "AGCTGCGGAGGGAGTT_AGCGCCAGCTGCATTA" => "PD17",
    "TGGAGGCTGGAGCGTG_AGCTGCATCCTCTCCA" => "PD18",
    "ATGGATAAATGGGTAC_GCCCCAGCCAAGAAAG" => "PD20",
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
die "Usage: perl $0 fastq1 fastq2  adapt out1 out2 > out\n" unless ( @ARGV == 6 );
open( IN1,   "gzip -dc $ARGV[0]|" )    or die "Can not open file $ARGV[0]\n";
open( IN2,   "gzip -dc $ARGV[1]|" )    or die "Can not open file $ARGV[1]\n";
open( ADAPT, ">>$ARGV[2].adapt.rate" ) or die "Can not open file $ARGV[2].adatp.rate\n";

#open (OUT1, ">$ARGV[3]") or die "Can not open file $ARGV[3]\n";
#open (OUT2, ">$ARGV[4]") or die "Can not open file $ARGV[4]\n";
open( PRIM, ">$ARGV[5].primer" ) or die "Can not open file $ARGV[5].primer\n";

foreach ( keys %len ) {
    @hash = split( /\_/, $_ );
    $hash{ $hash[0] } = $len{$_} . '_F';
    $hash{ $hash[1] } = $len{$_} . '_R';
}

$/ = "\n@";
while ( defined( my $v1 = <IN1> ) and defined( my $v2 = <IN2> ) ) {

    #print $v1;
    $count++;
    my @fastq1 = split( /\n/,    $v1 );
    my @header = split( /(\s+)/, $fastq1[0] );
    my @fastq2 = split( /\n/,    $v2 );
    my $seq_a = substr( $fastq1[1], 0, 16 );
    my $seq_b = substr( $fastq2[1], 0, 16 );
    if ( exists $hash{$seq_a} ) {
        $hash_num{ $hash{$seq_a} }++;
    }
    if ( exists $hash{$seq_b} ) {
        $hash_num{ $hash{$seq_b} }++;
    }
    if ( $v1 =~ 'GGGGGGGGGGGGGGGGGGGGGG' ) {
        $adapt++;
    }
    elsif ( exists $len{ $seq_a . '_' . $seq_b } ) {
        $effect++;
        $hash_num{ $len{ $seq_a . '_' . $seq_b } }++;
        $header = '@' . $header[0] . '_' . $len{ $seq_a . '_' . $seq_b };

        #print OUT1 "@"."$header[0]\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
        #print OUT2 "@"."$header[0]\n$fastq2[1]\n$fastq2[2]\n$fastq2[3]\n";
    }
}
my ($sample) = ( $ARGV[0] =~ /^(.+)\_R1\.fastq.gz$/ );
print ADAPT "$sample\t$adapt\t$count\t" . $adapt / $count . "\t" . $effect / $count . "\n";
print PRIM "pos\t$sample" . '_' . "F\t$sample" . '_' . "R\t$sample" . '_' . "F_R\n";
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

    print PRIM "$len{$_}\t$hash_num{$len{$_}.'_F'}\t$hash_num{$len{$_}.'_R'}\t$hash_num{$len{$_}}\n";
}
