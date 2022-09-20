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
        #$hashstrlist{$str[1]}.= $readsout.'('.$str[3].')'.'|'.$str[2].';';
        $hashstrlist{$str[1]}.= $str[3].'|'.$str[2].';';
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
