#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = (
"GGTGACAGAGCAAGACCC_AAAAGCTATTCCCAGGTG"=>"D3S1358",
"AAGCCCTAGTGGATGATA_AGATGATAGATACATAGG"=>"vWA",
"GCTCTTCCTCTTCCCTAG_TGCCATAGACTTAAAAAC"=>"D16S539",
"CCTGTGTCTCAGTTTTCC_CTCTTCCACACACCACTG"=>"CSF1PO",
"GACTGGCACAGAACAGGC_CTCAAACGTGAGGTTGAC"=>"TPOX",
"CACACGGCCTGGCAACTT_AGCTGTCAAAAACCGTAT"=>"D8S1179",
"CCATAAATATGTGAGTCA_AGATGTTGTATTAGTCAA"=>"D21S11",
"CACTGCACTTCACTCTGA_GGACATGTTGGCTTCTCT"=>"D18S51",
"ACAAAAGGCTGTAACAAG_CACACCCAGCCATAAATA"=>"D2S441",
"TGCACCCATTACCCGAAT_TTTTTTAAAATTAGCCAG"=>"D19S433",
"GAGTGCAGGTCACAGGGA_CTAGTCAGCACCCCAACC"=>"TH01",
"TCCAAAAGTCAAATGCCC_CACTCGGTTGTAGGTATT"=>"FGA",
"CCCTGTCCTAGCCTTCTT_AAGTCCCTAAGGCTCTCT"=>"D22S1045",
"ATAGCAAGTATGTGACAA_TAGGCTGTTGAGGTAGTT"=>"D5S818",
"CTCTCTGGACTCTGACCC_GATAACAGTCTGAAAGTA"=>"D13S317",
"AGGCTGACTATGGAGTTA_GAGGTCTTAAAATCTGAG"=>"D7S820",
"TTGTCTTGTTATTAAAGG_CAAGCTTAGTACTTAACT"=>"D10S1248",
"AGTTCAAGCCTGTGTTGC_TTCCACCGCAGCACAAAA"=>"D1S1656",
"CTCCAGAGAGAAAGAATC_CATCAGTTTCCCTGGTTT"=>"D12S391",
"GTGGATTTGGAAACAGAA_CTGGCTTCTTCCCTGTCT"=>"D2S1338",
"AATAGTGTGCAAGGATGG_TTGGACTGAGATTTACAC"=>"D6S1043",
"CTGGGCGACTGAGCAAGA_TGAGGAAAATAATACTCA"=>"Penta-E",
"GCCTAGGTGACAGAGCAA_ATATCTAAGAAATATTTG"=>"Penta-D",
"TGGGCTCTGTAAAGAATA_ACATTTTACCGGATGGGA"=>"Ame",
"ACCTATCATCCATCCTTA_AGCATCTCTGGGCTCCAC"=>"DYS391",
"GCTCATCTTGCTCCTCAG_TGTGTTCAGTCACTGGTT"=>"DYS456",
"CCCTGCATTTTGGTACCC_AGAAAAGTCCTGAGACAG"=>"DYS390",
"TGCTAGATAAATAGATAG_TCATTATACCTACTTCTG"=>"DYS389-I/II",
"TGCAGACTGAGCAACAGG_CGCCCGGCTAATTTTTGT"=>"DYS458",
"CAAGGAGTCCATCTGGGT_GACAAGCCCAAAGTTCTT"=>"DYS19",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385-a/b",
"ATTCCTAATGTGGTCTTC_GCCAGATAACGTGTGTGG"=>"DYS393",
"GGTGATAGATATACAGAT_TTTTAGTGGAGACGGGGT"=>"DYS439",
"CCAGCCCAAATATCCATC_TGTCTCACTTCAAGCACC"=>"DYS635",
"CAAGTGTTTGTTATTTAA_TGAAAATTATGGAAGCTA"=>"DYS392",
"ATGTTATGCTGAGGAGAA_CATTTCCTCTGATGGTGA"=>"GATA-H4",
"CTGGGACTATGGGCGTGA_GCCTGAGGAACAGAGGAA"=>"DYS437",
"CTGATGCAAGAAAGATTC_GGTGGCAGACGCCTATAA"=>"DYS438",
"AGACAGAAAGGGAGATAG_TGTTGGAGACCTTTTCTT"=>"DYS448",
"AGGGGGAGAAGAAGGGGG_AGTCTCACTTTTTTGCCC"=>"DYS481",
"ATCTATCAATCTTCTACC_GCTAATATAATTAACTTG"=>"DYS533",
"TACTTTGAGAGACTGAGG_GGGAGCTAGAATTCAAGA"=>"DYS576",
"GTAAATCTGTCCAGTAGT_CAAGAATACCAGAGGAAT"=>"DYS460",
"GTAGACATAGCAATTAGG_ATCTTTCTTGCTTAATAT"=>"DYS549",
"TGTTTAAAAAGTTCCCCC_CACCATTGCACTCTAGGT"=>"DYS449",
"TGACTAGGTAGAAATCCT_TGTCCTGCACATCTTGGG"=>"DYS570",
"GGTCACAGCATGGCTTGG_TGCAAGCTCCCAATGGTG"=>"DYS447",
"CTCCACTTTAACCAGTAT_GCTTTGGTCTGGCTGTCT"=>"DYS444",
);
my %len1 = (
"D3S1358"=>"R",
"vWA"=>"F",
"D16S539"=>"F",
"CSF1PO"=>"F",
"TPOX"=>"F",
"D8S1179"=>"F",
"D21S11"=>"F",
"D18S51"=>"F",
"D2S441"=>"F",
"D19S433"=>"R",
"TH01"=>"F",
"FGA"=>"F",
"D22S1045"=>"F",
"D5S818"=>"F",
"D13S317"=>"F",
"D7S820"=>"F",
"D10S1248"=>"R",
"D1S1656"=>"F",
"D12S391"=>"F",
"D2S1338"=>"F",
"D6S1043"=>"F",
"Penta-E"=>"F",
"Penta-D"=>"F",
"DYS391"=>"F",
"DYS456"=>"F",
"DYS390"=>"F",
"DYS389-I/II"=>"R",
"DYS458"=>"F",
"DYS19"=>"R",
"DYS385-a/b"=>"F",
"DYS393"=>"F",
"DYS439"=>"F",
"DYS635"=>"R",
"DYS392"=>"F",
"GATA-H4"=>"F",
"DYS437"=>"F",
"DYS438"=>"F",
"DYS448"=>"F",
"DYS481"=>"R",
"DYS533"=>"F",
"DYS576"=>"F",
"DYS460"=>"R",
"DYS549"=>"F",
"DYS449"=>"F",
"DYS570"=>"F",
"DYS447"=>"F",
"DYS444"=>"F",
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

my $i = 0;
my $seqname1;my $seqname2;my $seq1;my $seq2;my $flag1;my $flag2;my $qual1;my $qual2;
while ( defined( my $v1 = <IN1> ) and defined( my $v2 = <IN2> ) ) {
    chomp($v1,$v2);
    if ($i == 0){
        $seqname1 = $v1;
        $seqname2 = $v2;
    }
    if ($i == 1){
        $seq1 = $v1;
        $seq2 = $v2;
    }
    if ($i == 2){
        $flag1 = $v1;
        $flag2 = $v2;
    }
    if ($i == 3){
        $qual1 = $v1;
        $qual2 = $v2;
    }
    $i++;
    if ($i == 4) {
        $count++;
        my @fastq1 = ($seqname1,$seq1,$flag1,$qual1);
        my @fastq2 = ($seqname2,$seq2,$flag2,$qual2);
        my @header = split( /(\s+)/, $fastq1[0] );
        my $seq_a = substr( $fastq1[1], 0, 18 );
        my $seq_b = substr( $fastq2[1], 0, 18 );
        if ( exists $hash{$seq_a} ) {
            $hash_num{ $hash{$seq_a} }++;
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
            $header = $header[0] . '_' . $len{ $seq_a . '_' . $seq_b };
            if($len1{$len{ $seq_a . '_' . $seq_b }} eq 'R') {
                $fastq1[1] =  reverse($fastq1[1]);
                $fastq1[1] =~ tr/ACGTacgt/TGCAtgca/;
                $fastq1[2] = reverse($fastq1[2]);
            }
            print "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
        }
        $i = 0;
    }
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

