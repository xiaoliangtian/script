#!/usr/bin/perl
# use strict;
# use warnings;
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