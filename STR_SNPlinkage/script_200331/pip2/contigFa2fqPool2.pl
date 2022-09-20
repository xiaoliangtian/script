#!/usr/bin/perl
# use strict;
# use warnings;
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
"CTGGGCGACTGAGCAAGA_TGAGGAAAATAATACTCA"=>"PentaE",
"GCCTAGGTGACAGAGCAA_ATATCTAAGAAATATTTG"=>"PentaD",
"TGGGCTCTGTAAAGAATA_ACATTTTACCGGATGGGA"=>"Ame",
"ACCTATCATCCATCCTTA_AGCATCTCTGGGCTCCAC"=>"DYS391",
"GCTCATCTTGCTCCTCAG_TGTGTTCAGTCACTGGTT"=>"DYS456",
"CCCTGCATTTTGGTACCC_AGAAAAGTCCTGAGACAG"=>"DYS390",
"TGCTAGATAAATAGATAG_TCATTATACCTACTTCTG"=>"DYS389I-II",
"TGCAGACTGAGCAACAGG_CGCCCGGCTAATTTTTGT"=>"DYS458",
"CAAGGAGTCCATCTGGGT_GACAAGCCCAAAGTTCTT"=>"DYS19",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385a/b",
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
"PentaE"=>"F",
"PentaD"=>"F",
"DYS391"=>"F",
"DYS456"=>"F",
"DYS390"=>"F",
"DYS389I-II"=>"R",
"DYS458"=>"F",
"DYS19"=>"R",
"DYS385a/b"=>"F",
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
"Ame"=>"F",
);
my @line;
my $header;
my $adapt=0;
my $count;
my $effect = 0;
my @hash;
my %hash     = ();
my %hash_num = ();
my @prim;
my @hash1;
die "Usage: perl $0 fasta fa2fqQC outfastq > out\n"
  unless ( @ARGV == 3 );
open( IN1, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( ADAPT, ">>$ARGV[1].adapt.rate" )
  or die "Can not open file $ARGV[2].adatp.rate\n";
open( OUT1, ">$ARGV[2]" )        or die "Can not open file $ARGV[3]\n";
open( PRIM, ">$ARGV[3].primer" ) or die "Can not open file $ARGV[5].primer\n";

foreach ( keys %len ) {
    @hash = split( /\_/, $_ );
    $hash{ $hash[0] } = $len{$_}.'_F' ;
    
    $hash{ $hash[1] } = $len{$_}.'_R' ;
}

my $i = 0;
my $seqname1;my $seqname2;my $seq1;my $seq2;my $flag1;my $flag2;my $qual1;my $qual2;
while ( defined( my $v1 = <IN1> ) ) {
    chomp($v1);
    if ($i == 0){
        $seqname1 = $v1;
        $seqname1 =~ s/^>/@/;
    }
    if ($i == 1){
        $seq1 = $v1;
    }
    $i++;
    if ($i == 2) {
        $count++;
        my @fastq1 = ($seqname1,$seq1);
        my @header = split( /(\s+)/, $fastq1[0] );
        my $seq_a = substr( $fastq1[1], 0, 18 );
        $qual = 'I' x length($seq1);
        $flag = '+';
        if ( exists $hash{$seq_a} ) {
            $hash_num{ $hash{$seq_a} }++;
            if ( $hash{ $seq_a }  =~ '_F' ) {
                $effect++;
                # $hash_num{ $len{ $seq_a . '_' . $seq_b } }++;
                # $header = $header[0] . '_' . $len{ $seq_a . '_' . $seq_b };
                if($len1{(split/_/,$hash{$seq_a})[0]} eq 'R') {
                    $fastq1[1] =  reverse($fastq1[1]);
                    $fastq1[1] =~ tr/ACGTacgt/TGCAtgca/;
                }
                print OUT1 "$fastq1[0]\n$fastq1[1]\n$flag\n$qual\n";
            }
            elsif ( $hash{ $seq_a }  =~ '_R'  ){
                $effect++;
                # $hash_num{ $len{ $seq_b . '_' . $seq_a } }++;
                # $header = $header[0] . '_' . $len{ $seq_b . '_' . $seq_a };
                if($len1{(split/_/,$hash{$seq_a})[0]} eq 'F') {
                    $fastq1[1] =  reverse($fastq1[1]);
                    $fastq1[1] =~ tr/ACGTacgt/TGCAtgca/;
                }
                print OUT1 "$fastq1[0]\n$fastq1[1]\n$flag\n$qual\n";
            }
        }      
        $i = 0;
    }
}

my ($sample) =  $ARGV[0] =~ /^(.+)\_R1/;
print ADAPT "$sample\t$count\t"
  . $effect / $count . "\n";