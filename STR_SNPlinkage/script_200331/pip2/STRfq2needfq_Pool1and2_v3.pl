#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = (
"AAAAAAAATTAGCCGGAC_GGGGGCATCTCTTATACT"=>"D3S1358_pool1",
"GATCCTATAAGGTAGAGT_TAGGACAGATGATAAATA"=>"vWA_pool1",
"CAAGTGCCAGATGCTCGT_TGTGTGTGCATCTGTAAG"=>"D16S539_pool1",
"GTGTTCCAACCTGAGTCT_CATTTCCTGTGTCAGACC"=>"CSF1PO_pool1",
"GCTCTCACAACCCCCACC_CTTCTGTCCTTGTCAGCG"=>"TPOX_pool1",
"GATCCTTGGGGTGTCGCT_GTATCCCATTGCGTGAAT"=>"D8S1179_pool1",
"GATTCTTCAGCTTGTAGA_AGAGACAGACTAATAGGA"=>"D21S11_pool1",
"TAGTCTCAGCTACTTGCA_GTGGAGATGTCTTACAAT"=>"D18S51_pool1",
"TAAGACCCACGGCCAGAA_TTAAATTGGAGCTAAGTG"=>"D2S441_pool1",
"ATAGGTTTTTAAGGAACA_AGGTTGAGGCTGCAAAAA"=>"D19S433_pool1",
"ACTGCTACAACTCACACC_ATTCCCATTGGCCTGTTC"=>"TH01_pool1",
"CCCATAGGTTTTGAACTC_TGCTGAGTGATTTGTCTG"=>"FGA_pool1",
"GGGGTCCAGGATGCTGAT_TGAGTGATCACGCGAATG"=>"D22S1045_pool1",
"TTAAAGCTTCTAATTAAA_ATTCCAATCATAGCCACA"=>"D5S818_pool1",
"ACAAATGGTAATTCTGCC_CAGCCCAAAAAGACAGAC"=>"D13S317_pool1",
"CAGGCATGTGCTACTGCA_CCTCATTGACAGAATTGC"=>"D7S820_pool1",
"TCAGGAATAAGTGCAGTG_AAAGCAAACCTGAGCATT"=>"D10S1248_pool1",
"TGGGTCATTGTAAAGGTC_CTGTGTTAGTCAGGATTC"=>"D1S1656_pool1",
"AACTCAAATTGTGATAGT_CCTCCATATCACTTGAGC"=>"D12S391_pool1",
"GGAGCTCTCACCAGGGGG_TGGCCCATAATCATGAGT"=>"D2S1338_pool1",
"AGGCACTTCATATTCATA_CCATAATTGTATGAGCCA"=>"D6S1043_pool1",
"GGAGGCTGAAACAGGAGA_TTGATACATGGAAAGAAT"=>"PentaE_pool1",
"GAGCCTGGAAGGTCGAAG_GCCTAACCTATGGTCATA"=>"PentaD_pool1",
#"CGCGGTGTAAGGAGGTTT_CTCCGTCAAAAGAAAGAA"=>"SE33_pool1",
"GTCTCTCTTAATGTTAAC_GTAGGAACTGTAAAATTG"=>"Ame_pool1",
"CCCCACCACAGATTAGCA_CCATAGAGGGATAGGTAG"=>"DYS391_pool1",
"GCCTCCCAGCCTACATCT_AACTCAGCCCAAAACTTC"=>"DYS456_pool1",
"ATCATACATGTTTCAGAA_GCAATGTGTATACTCAGA"=>"DYS390_pool1",
"TATCCCTGAGTAGCAGAA_TGTATCCAACTCTCATCT"=>"DYS389I-II_pool1",
"CAGCTGCCTCTAATGTGA_AGTTCTGGCATTACAAGC"=>"DYS458_pool1",
"AATTTGCTGGTCAATCTC_ACTATGACTACTGAGTTT"=>"DYS19_pool1",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385a/b_pool1",
"GTATGTCTTTACTAGCAG_GGCCTATAATCTAACTAA"=>"DYS393_pool1",
"CTATGTCCTGAATGGTAC_CTGGCTTGGAATTCTTTT"=>"DYS439_pool1",
"ACCAAGGCTCCATCTCAA_AATGGAATGCTCTCTTGG"=>"DYS635_pool1",
"CTCCATCCATGTTGCTCC_ACAGAGGGATCATTAAAC"=>"DYS392_pool1",
"AGCTAAACAGAGACCTAA_TAGCCCACTTGTTAAACA"=>"GATA-H4_pool1",
"CTGTTCCTCAGGCTGCAT_GTCATTCACAGATGATAT"=>"DYS437_pool1",
"AATGAAGGAAATAGAGTA_TCGAGATCACACCATTGC"=>"DYS438_pool1",
"AGTGTCAAAGAGCTTCAA_GCCGGTCTGGAAATTTAT"=>"DYS448_pool1",
"GCCTACATAGTGGAACCT_CCACACCTGGCTCCTTTC"=>"DYS481_pool1",
"TCTCTCTCTCTTTCTTTA_GGCTGTAAGTAGAGATCA"=>"DYS533_pool1",
"CAAAAAAAACAAAAACTG_GGAGGAGATGGGAGTAAT"=>"DYS576_pool1",
"CACTCTTTACAATTTTTT_ATAGGCAGAGGATAGATG"=>"DYS460_pool1",
"GTAAGCCAAACCCAAATA_GTGGCATAAGTGGTAATG"=>"DYS549_pool1",
"TGTTTAAAAAGTTCCCCC_CACCATTGCACTCTAGGT"=>"DYS449_pool1",
"GAGATTAGGAGCACAGTG_AACCTAAGCTGAAATGCA"=>"DYS570_pool1",
"TTGCTGAGGTTGAGGACA_GCGTTATCTCTGCCTTTC"=>"DYS447_pool1",
"ACATCAACATAGAATGAA_TTCAAACTCACGTTGTTC"=>"DYS444_pool1",
"GGTGACAGAGCAAGACCC_AAAAGCTATTCCCAGGTG"=>"D3S1358_pool2",
"AAGCCCTAGTGGATGATA_AGATGATAGATACATAGG"=>"vWA_pool2",
"GCTCTTCCTCTTCCCTAG_TGCCATAGACTTAAAAAC"=>"D16S539_pool2",
"CCTGTGTCTCAGTTTTCC_CTCTTCCACACACCACTG"=>"CSF1PO_pool2",
"GACTGGCACAGAACAGGC_CTCAAACGTGAGGTTGAC"=>"TPOX_pool2",
"CACACGGCCTGGCAACTT_AGCTGTCAAAAACCGTAT"=>"D8S1179_pool2",
"CCATAAATATGTGAGTCA_AGATGTTGTATTAGTCAA"=>"D21S11_pool2",
"CACTGCACTTCACTCTGA_GGACATGTTGGCTTCTCT"=>"D18S51_pool2",
"ACAAAAGGCTGTAACAAG_CACACCCAGCCATAAATA"=>"D2S441_pool2",
"TGCACCCATTACCCGAAT_TTTTTTAAAATTAGCCAG"=>"D19S433_pool2",
"GAGTGCAGGTCACAGGGA_CTAGTCAGCACCCCAACC"=>"TH01_pool2",
"TCCAAAAGTCAAATGCCC_CACTCGGTTGTAGGTATT"=>"FGA_pool2",
"CCCTGTCCTAGCCTTCTT_AAGTCCCTAAGGCTCTCT"=>"D22S1045_pool2",
"ATAGCAAGTATGTGACAA_TAGGCTGTTGAGGTAGTT"=>"D5S818_pool2",
"CTCTCTGGACTCTGACCC_GATAACAGTCTGAAAGTA"=>"D13S317_pool2",
"AGGCTGACTATGGAGTTA_GAGGTCTTAAAATCTGAG"=>"D7S820_pool2",
"TTGTCTTGTTATTAAAGG_CAAGCTTAGTACTTAACT"=>"D10S1248_pool2",
"AGTTCAAGCCTGTGTTGC_TTCCACCGCAGCACAAAA"=>"D1S1656_pool2",
"CTCCAGAGAGAAAGAATC_CATCAGTTTCCCTGGTTT"=>"D12S391_pool2",
"GTGGATTTGGAAACAGAA_CTGGCTTCTTCCCTGTCT"=>"D2S1338_pool2",
"AATAGTGTGCAAGGATGG_TTGGACTGAGATTTACAC"=>"D6S1043_pool2",
"CTGGGCGACTGAGCAAGA_TGAGGAAAATAATACTCA"=>"PentaE_pool2",
"GCCTAGGTGACAGAGCAA_ATATCTAAGAAATATTTG"=>"PentaD_pool2",
"TGGGCTCTGTAAAGAATA_ACATTTTACCGGATGGGA"=>"Ame_pool2",
"ACCTATCATCCATCCTTA_AGCATCTCTGGGCTCCAC"=>"DYS391_pool2",
"GCTCATCTTGCTCCTCAG_TGTGTTCAGTCACTGGTT"=>"DYS456_pool2",
"CCCTGCATTTTGGTACCC_AGAAAAGTCCTGAGACAG"=>"DYS390_pool2",
"TGCTAGATAAATAGATAG_TCATTATACCTACTTCTG"=>"DYS389I-II_pool2",
"TGCAGACTGAGCAACAGG_CGCCCGGCTAATTTTTGT"=>"DYS458_pool2",
"CAAGGAGTCCATCTGGGT_GACAAGCCCAAAGTTCTT"=>"DYS19_pool2",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385a/b_pool2",
"ATTCCTAATGTGGTCTTC_GCCAGATAACGTGTGTGG"=>"DYS393_pool2",
"GGTGATAGATATACAGAT_TTTTAGTGGAGACGGGGT"=>"DYS439_pool2",
"CCAGCCCAAATATCCATC_TGTCTCACTTCAAGCACC"=>"DYS635_pool2",
"CAAGTGTTTGTTATTTAA_TGAAAATTATGGAAGCTA"=>"DYS392_pool2",
"ATGTTATGCTGAGGAGAA_CATTTCCTCTGATGGTGA"=>"GATA-H4_pool2",
"CTGGGACTATGGGCGTGA_GCCTGAGGAACAGAGGAA"=>"DYS437_pool2",
"CTGATGCAAGAAAGATTC_GGTGGCAGACGCCTATAA"=>"DYS438_pool2",
"AGACAGAAAGGGAGATAG_TGTTGGAGACCTTTTCTT"=>"DYS448_pool2",
"AGGGGGAGAAGAAGGGGG_AGTCTCACTTTTTTGCCC"=>"DYS481_pool2",
"ATCTATCAATCTTCTACC_GCTAATATAATTAACTTG"=>"DYS533_pool2",
"TACTTTGAGAGACTGAGG_GGGAGCTAGAATTCAAGA"=>"DYS576_pool2",
"GTAAATCTGTCCAGTAGT_CAAGAATACCAGAGGAAT"=>"DYS460_pool2",
"GTAGACATAGCAATTAGG_ATCTTTCTTGCTTAATAT"=>"DYS549_pool2",
"TGTTTAAAAAGTTCCCCC_CACCATTGCACTCTAGGT"=>"DYS449_pool2",
"TGACTAGGTAGAAATCCT_TGTCCTGCACATCTTGGG"=>"DYS570_pool2",
"GGTCACAGCATGGCTTGG_TGCAAGCTCCCAATGGTG"=>"DYS447_pool2",
"CTCCACTTTAACCAGTAT_GCTTTGGTCTGGCTGTCT"=>"DYS444_pool2",
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
my %len2=();
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
    $hash{ substr($hash[0],0,12)} = $len{$_} . '_F';
    $hash{ substr($hash[1],0,12) } = $len{$_} . '_R';
    $len2{substr($hash[0],0,12).'_'.substr($hash[1],0,12) } = $len{$_};
}

$/ = "\n\@M";
while ( defined( my $v1 = <IN1> ) and defined( my $v2 = <IN2> ) ) {

    #print $v1;
    $count++;
    my @fastq1 = split( /\n/,    $v1 );
    my @header = split( /(\s+)/, $fastq1[0] );
    my @fastq2 = split( /\n/,    $v2 );
    my $seq_a = substr( $fastq1[1], 0, 12 );
    my $seq_b = substr( $fastq2[1], 0, 12 );
    #print "$fastq1[0]\n";
    #print "$seq_a\t$seq_b\t$count\n";
    if ( $fastq1[1] =~ 'GGGGGGGGGGGGGGGGGGGGGG' ) {
        $adapt++;
    }
    
    elsif ( exists $len2{ $seq_a . '_' . $seq_b } ) {
        $hash_num{ $hash{$seq_a} }++;
        $hash_num{ $hash{$seq_b} }++;
        $effect++;
        $hash_num{ $len2{ $seq_a . '_' . $seq_b } }++;
        $header = '@M' . $header[0] . '_' . $len2{ $seq_a . '_' . $seq_b };
        if($len1{(split/_/,$len2{ $seq_a . '_' . $seq_b })[0]} eq 'R') {
            $fastq1[1] =  reverse($fastq1[1]);
            $fastq1[1] =~ tr/ACGTacgt/TGCAtgca/;
            $fastq1[2] = reverse($fastq1[2]);
        }
        print "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
    }
    elsif ( exists $hash{$seq_a} ) {
        $hash_num{ $hash{$seq_a} }++;

        #print "$hash{$seq_a}\t$hash_num{ $hash{$seq_a} }\n";
    }
    elsif ( exists $hash{$seq_b} ) {
        $hash_num{ $hash{$seq_b} }++;
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

