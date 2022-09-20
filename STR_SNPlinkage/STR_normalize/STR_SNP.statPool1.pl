#!/usr/bin/perl
#use strict;
#use warnings;
use List::MoreUtils qw(mesh);

my $result;
my $length = 0;
my ( $len, $read, $reads, @read, $map );
my ( %hashNameNum, %hashread );


die "Usage: perl $0 sam type\n" unless ( @ARGV == 2 );
open( SAM, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";

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
"GGAGGCTGAAACAGGAGA_TTGATACATGGAAAGAAT"=>"Penta-E",
"GAGCCTGGAAGGTCGAAG_GCCTAACCTATGGTCATA"=>"Penta-D",
"CGCGGTGTAAGGAGGTTT_CTCCGTCAAAAGAAAGAA"=>"SE33",
"GTCTCTCTTAATGTTAAC_GTAGGAACTGTAAAATTG"=>"Ame",
"CCCCACCACAGATTAGCA_CCATAGAGGGATAGGTAG"=>"DYS391",
"GCCTCCCAGCCTACATCT_AACTCAGCCCAAAACTTC"=>"DYS456",
"ATCATACATGTTTCAGAA_GCAATGTGTATACTCAGA"=>"DYS390",
"TATCCCTGAGTAGCAGAA_TGTATCCAACTCTCATCT"=>"DYS389-I/II",
"CAGCTGCCTCTAATGTGA_AGTTCTGGCATTACAAGC"=>"DYS458",
"AATTTGCTGGTCAATCTC_ACTATGACTACTGAGTTT"=>"DYS19",
"AGAGCTAGACACCATGCC_AAAATAATCTATCTATTC"=>"DYS385-a/b",
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

my ($sample) = ( $ARGV[0] =~ /^(.+)\.sam$/ );
while (<SAM>) {
    chomp;
    my @line = split( /\t/, $_ );
    @str = split(/\_/,$line[0]);
    $hashdepth{$str[1]}+=$str[2];
    if ( $line[5] ne '*') {
        my $bow = $line[3];
        while ( $line[5] =~ /([0-9]+[A-Z])/g ) {

            $map = $1;
            $len = $map;
            $len =~ s/[A-Z]+//g;
            if ( $map =~ 'S' ) {
                print "$line[0]\tfalse\n";
                next;
            }
            elsif ( $map =~ 'M' ) {
                $read = substr( $line[9], $length, $len );
                $bow += $len;
                $length += $len;
                $refread .= $read;
            }
            elsif ( $map =~ 'I' ) {
                $read = substr( $line[9], $length, $len );
                $bow = $bow - 0.5;
                $reads .= $bow . ':+' . $read . '_';
                #$hashbase1{ $bow . ':+' . $read }++;
                #$hashbase{$bow}++;
                ####change_v2###
                
                #$bow = $bow + 0.5;
                $length += $len;
            }
            elsif ( $map =~ 'D' ) {
                $bow += $len;
            }
            else {
                #print "$line[0] no match bowtie2\n";
            }
        }
        $line[17] =~ s/^MD\:Z\://;
        $bow1 = $line[3];
        while ($line[17] =~ /([0-9]+[^0-9]+)/g ) {
            $map = $1;
            #print "$1\n";
            $map =~ s/\^/-/;
            $len1 = $map;
            $len1 =~ s/[^0-9]+//g;
            if($map =~ '-') {
                $read = $map;
                #print "$map\n";
                $read =~ s/^[^A-Z]+//;
                $bow1 += $len1;
                $reads .= $bow1 . ':-' . $read . '_';
               
            }
            else{
                #print "else\t$map\n";
                $readref = $map;
                $readref =~ s/^[^A-Z]+//;
                #print "else\t$map\t$readref\n";
                $read = substr( $refread, ($length1+$len1), 1 );
                #print "$refread\n";
                $bow1 += $len1;
                $reads .= $bow1 . ':' . $readref.'>'.$read . '_';
                #print "$reads\n";
                $length1 += ($len1+1);
                $bow1 ++;
            }
            
        }
        
        $reads =~ s/\_$//;
        @reads = split(/\_/,$reads);
        foreach ( sort {(split/\:/,$a)[0] <=> (split/\:/,$b)[0]} @reads) {
            $readsout .= $_.'_';
        }
        #print "$line[0]\t$readsout\n";
        $hashstrlist{$str[1]}.= $readsout.'('.$str[3].')'.'|'.$str[2].';';
        $reads  = undef;
        $readsout = undef;
        $refread = undef;
        $length = 0;
        $length1 = 0;
        #$hashstrlist{$str[1]}.= $readsout.'('.$str[3].')'.'|'.$str[2].';';

    }
    else {
        print "$line[0]\tfalse\n";
    }
}

print OUT "str\t$sample\n";
foreach (sort values %len) {
    if(exists $hashstrlist{$_}) {
        @type = split(/\;/,$hashstrlist{$_});
        print OUT "$_\t";
        foreach(sort {(split/\|/,$b)[1] <=> (split/\|/,$a)[1]} @type) {
            print OUT "$_".';';
        }
        print OUT "\n";
    }
    else {
        print OUT "$_\tNA\n";
    }
}
