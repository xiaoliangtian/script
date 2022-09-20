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
"GGAGGCTGAAACAGGAGA_TTGATACATGGAAAGAAT"=>"PentaE",
"GAGCCTGGAAGGTCGAAG_GCCTAACCTATGGTCATA"=>"PentaD",
"CGCGGTGTAAGGAGGTTT_CTCCGTCAAAAGAAAGAA"=>"SE33",
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

my %reverse = (
    "D1S1656"=>"1",
    "D2S1338"=>"1",
    "FGA"=>"1",
    "D5S818"=>"1",
    "CSF1PO"=>"1",
    "D6S1043"=>"1",
    "D7S820"=>"1",
    "vWA"=>"1",
    "PentaE"=>"1",
    "D19S433"=>"1",
    "DYS19"=>"1",
    "DYS635"=>"1",
    "DYS389I-II"=>"1",
    "DYS390"=>"1",
    "GATA-H4"=>"1",
    "DYS385a/b"=>"1",
    "DYS460"=>"1",
    "DYS392"=>"1",
);

my ($sample) = ( $ARGV[0] =~ /^(.+)\.sam$/ );
while (<SAM>) {
    chomp;
    my @line = split( /\t/, $_ );
    @str = split(/\_/,$line[0]);
    $hashdepth{$str[1]}+=1;
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
            print "reads\t$_\t$line[3]\n";
            # if(length($line[9]) > 290 ){
            if (((split/\:/,$_)[0] - $line[3]) > 10 and ((split/\:/,$_)[0] - $line[3]) < 290 and ($line[3] + length($line[9]))>((split/\:/,$_)[0]+1)) {
                $diff = (split/\:/,$_)[0] - $line[3];
                print "$_\n";
                $readsout .= $_.'_';
            }
            # }
            # else{
            #     $readsout .= $_.'_';
            # }
        }
        print "$line[0]\t$readsout\n";
        $snpStrList = $readsout.'('.$str[-2].'_'.$str[-1].')';
        #$hashstrlistNum{$str[1]}{$readsout.'('.$line[3].'_'.$line$str[4].')'}++;
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
    if($snpStrList ne ""){
    	$hashstrlistNum{$str[-4]}{$snpStrList} += $str[-3];
	$hashstrlist{$str[-4]} += $str[-3];
    }
    $snpStrList = undef;
}

sub reAtr{
    $string = $_;
    undef $strre;
    #print "str\t$string\n";
    ($numStr) = $string =~ m/([0-9]+)/;
    @string = split(/\][0-9]{0,}/,$string);
    @string = reverse @string;
    foreach (@string){
        if ($_ =~ /[A-Z]+/i and $_ !~ m/[0-9]/ ){
            $seq = reverse $_;
            $seq =~ tr/ACGTacgt/TGCAtgca/;
            $strre .= '['.$seq.']';
        }
        else{
            $strre .= $_; 
        }
    }
    $strre .= $numStr;
    #print "str $strre\n";
    return $strre;
}
print OUT "str\tdepth\t$sample\n";
foreach $str(sort values %len) {
    if (exists $hashstrlist{$str}) {
        #@type = split(/\;/,$hashstrlist{$_});
        print OUT "$str\t$hashstrlist{$str}\t";
        foreach(sort {$hashstrlistNum{$str}{$b} <=> $hashstrlistNum{$str}{$a}} keys %{$hashstrlistNum{$str}}) {
            $typeDe = $_;
            if (exists $reverse{$str}){
                if ($typeDe =~ m/(.*)\((.*)\)/){
                    $snp = $1;
                    $strTy = $2;
                    #print "$snp\t$strTy\n";
                }
                else{
                    #print "$str\t$type\n";
                }
                if ($snp){
                    $type = $snp.'(';
                }
                else {
                    $type .= "("; 
                }
                @strTy = split(/\_/,$strTy);
                @strTyRe = split(/\[/,$strTy[1]);
                @strTyRe = reverse (@strTyRe);
                #print "@strTyRe\n";
                $type .= $strTy[0].'_';
                #print "$type\n";
                foreach (@strTyRe){
                    if ($_ ne ""){
                        $split = $_;
                        #print "split1 $split\n";
                        $split = reAtr($split);
                        #$split =~ tr/ACGTacgt/TGCAtgca/;
                        #print "split2 $split\n";
                        $type .= $split;
                    }
                } 
                $type .= ')';       
            }
            else {
                $type = $typeDe;
            }
            #print "type\t$type\n";
            print OUT "$type".'|'.$hashstrlistNum{$str}{$typeDe}.';';
            $type ="";
        }
        print OUT "\n";
    }
    else {
        print OUT "$str\t0\tNA\n";
    }
}
