#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = (
"AAAAAAAATTAGCCGGAC_GGGGGCATCTCTTATACT"=>"D3S1358",
"GATCCTATAAGGTAGAGT_TAGGACAGATGATAAATA"=>"vWA",
"CAAGTGCCAGATGCTCGT_TGTGTGTGCATCTGTAAG"=>"D16S539",
"GTGTTCCAACCTGAGTCT_CATTTCCTGTGTCAGACC"=>"CSF1PO",
"GCTCTCACAACCCCCACC_CTTCTGTCCTTGTCAGCG"=>"TPOX",
"GATCCTTGGGGTGTCGCT_GTATCCCATTGCGTGAAT"=>"D8S1179",
"GATTCTTCAGCTTGTAGA_AGAGACAGACTAATAGGA"=>"D21S11",
"TAGTCTCAGCTACTTGCA_GTGGAGATGTCTTACAAT"=>"D18S51",
"TAAGACCCACGGCCAGAA_TTAAATTGGAGCTAAGTG"=>"D2S441",
"ATAGGTTTTTAAGGAACA_AGGTTGAGGCTGCAAAAA"=>"D19S433",
"ACTGCTACAACTCACACC_ATTCCCATTGGCCTGTTC"=>"TH01",
"CCCATAGGTTTTGAACTC_TGCTGAGTGATTTGTCTG"=>"FGA",
"GGGGTCCAGGATGCTGAT_TGAGTGATCACGCGAATG"=>"D22S1045",
"TTAAAGCTTCTAATTAAA_ATTCCAATCATAGCCACA"=>"D5S818",
"ACAAATGGTAATTCTGCC_CAGCCCAAAAAGACAGAC"=>"D13S317",
"CAGGCATGTGCTACTGCA_CCTCATTGACAGAATTGC"=>"D7S820",
"TCAGGAATAAGTGCAGTG_AAAGCAAACCTGAGCATT"=>"D10S1248",
"TGGGTCATTGTAAAGGTC_CTGTGTTAGTCAGGATTC"=>"D1S1656",
"AACTCAAATTGTGATAGT_CCTCCATATCACTTGAGC"=>"D12S391",
"GGAGCTCTCACCAGGGGG_TGGCCCATAATCATGAGT"=>"D2S1338",
"AGGCACTTCATATTCATA_CCATAATTGTATGAGCCA"=>"D6S1043",
"GGAGGCTGAAACAGGAGA_TTGATACATGGAAAGAAT"=>"PentaE",
"GAGCCTGGAAGGTCGAAG_GCCTAACCTATGGTCATA"=>"PentaD",
#"CGCGGTGTAAGGAGGTTT_CTCCGTCAAAAGAAAGAA"=>"SE33",
"GTCTCTCTTAATGTTAAC_GTAGGAACTGTAAAATTG"=>"Ame",
"CCCCACCACAGATTAGCA_CCATAGAGGGATAGGTAG"=>"DYS391",
"GCCTCCCAGCCTACATCT_AACTCAGCCCAAAACTTC"=>"DYS456",
"ATCATACATGTTTCAGAA_GCAATGTGTATACTCAGA"=>"DYS390",
"TATCCCTGAGTAGCAGAA_TGTATCCAACTCTCATCT"=>"DYS389I-II",
"CAGCTGCCTCTAATGTGA_AGTTCTGGCATTACAAGC"=>"DYS458",
"AATTTGCTGGTCAATCTC_ACTATGACTACTGAGTTT"=>"DYS19",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385a/b",
"GTATGTCTTTACTAGCAG_GGCCTATAATCTAACTAA"=>"DYS393",
"CTATGTCCTGAATGGTAC_CTGGCTTGGAATTCTTTT"=>"DYS439",
"ACCAAGGCTCCATCTCAA_AATGGAATGCTCTCTTGG"=>"DYS635",
"CTCCATCCATGTTGCTCC_ACAGAGGGATCATTAAAC"=>"DYS392",
"AGCTAAACAGAGACCTAA_TAGCCCACTTGTTAAACA"=>"GATA-H4",
"CTGTTCCTCAGGCTGCAT_GTCATTCACAGATGATAT"=>"DYS437",
"AATGAAGGAAATAGAGTA_TCGAGATCACACCATTGC"=>"DYS438",
"AGTGTCAAAGAGCTTCAA_GCCGGTCTGGAAATTTAT"=>"DYS448",
"GCCTACATAGTGGAACCT_CCACACCTGGCTCCTTTC"=>"DYS481",
"TCTCTCTCTCTTTCTTTA_GGCTGTAAGTAGAGATCA"=>"DYS533",
"CAAAAAAAACAAAAACTG_GGAGGAGATGGGAGTAAT"=>"DYS576",
"CACTCTTTACAATTTTTT_ATAGGCAGAGGATAGATG"=>"DYS460",
"GTAAGCCAAACCCAAATA_GTGGCATAAGTGGTAATG"=>"DYS549",
"TGTTTAAAAAGTTCCCCC_CACCATTGCACTCTAGGT"=>"DYS449",
"GAGATTAGGAGCACAGTG_AACCTAAGCTGAAATGCA"=>"DYS570",
"TTGCTGAGGTTGAGGACA_GCGTTATCTCTGCCTTTC"=>"DYS447",
"ACATCAACATAGAATGAA_TTCAAACTCACGTTGTTC"=>"DYS444",
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

$/ = "\n\@M";
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
my ($sample) =  $ARGV[0] =~ /^(.+)\_R1/;
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

