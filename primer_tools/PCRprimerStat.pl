#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use Getopt::Long;
my %len = ();
my %len1 = ();
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
die "Usage: perl $0 fastq1 fastq2 primer.txt  adapt out1 out2 primer.stat > out\n"
  unless ( @ARGV == 7 );
open( IN1, "gzip -dc $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
open( IN2, "gzip -dc $ARGV[1]|" ) or die "Can not open file $ARGV[1]\n";
open( ADAPT, ">>$ARGV[3].adapt.rate" )
  or die "Can not open file $ARGV[3].adatp.rate\n";
open( PRIM, ">$ARGV[6].primer" ) or die "Can not open file $ARGV[6].primer\n";
open( PCR, "$ARGV[2]") or die "Can not open file $ARGV[2]\n";

while (<PCR>) {
    chomp;
    my @line = split(/\t/,$_);
    $hash{ substr($line[1],0,12)} = $line[0] . '_F';
    $hash{ substr($line[2],0,12)} = $line[0] . '_R';
    $len2{ substr($line[1],0,12).'_'.substr($line[2],0,12) } = $line[0];
}

close PCR;

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
        my $seq_a = substr( $fastq1[1], 0, 12 );
        my $seq_b = substr( $fastq2[1], 0, 12 );
        if ( $fastq1[1] =~ 'GGGGGGGGGGGGGGGGGGGGGG' ) {
            $adapt++;
        }
    
        elsif ( exists $len2{ $seq_a . '_' . $seq_b } ) {
            $hash_num{ $hash{$seq_a} }++;
            $hash_num{ $hash{$seq_b} }++;
            $effect++;
            $hash_num{ $len2{ $seq_a . '_' . $seq_b } }++;
            $header = '@' . $header[0] . '_' . $len2{ $seq_a . '_' . $seq_b };
            #print "$header\tFR\t$hash{$seq_a}\t$hash{$seq_b}\n";
            print "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
        }

        elsif ( exists  $len2{ $seq_b . '_' . $seq_a }) {
            $hash_num{ $hash{$seq_a} }++;
            $hash_num{ $hash{$seq_b} }++;
            $effect++;
            $hash_num{ $len2{ $seq_b . '_' . $seq_a } }++;
            $header = '@' . $header[0] . '_' . $len2{ $seq_b . '_' . $seq_a };
            #print "$header\tFR\t$hash{$seq_a}\t$hash{$seq_b}\n";
            print "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
        } 

        else {
            if( exists $hash{$seq_a} ) {
                $hash_num{ $hash{$seq_a} }++;
            }
            if( exists $hash{$seq_b} ) {
                $hash_num{ $hash{$seq_b} }++;
            }
            #print "$header[0]\tF\t$hash{$seq_a}\n";
        }
    $i = 0;
    }
    
}
my ($sample) =  $ARGV[0] =~ /^(.+)\_R1/;
print ADAPT "$sample\t$adapt\t$count\t"
  . $adapt / $count . "\t"
  . $effect / $count . "\n";
print PRIM "pos\t$sample" . '_'
  . "F\t$sample" . '_'
  . "R\t$sample" . '_' . "F_R\n";
foreach ( sort { $len2{$a} cmp $len2{$b} } keys %len2 ) {
    @prim = split( /\_/, $_ );
    if ( !exists $hash_num{ $len2{$_} . '_F' } ) {
        $hash_num{ $len2{$_} . '_F' } = 0;
    }
    if ( !exists $hash_num{ $len2{$_} . '_R' } ) {
        $hash_num{ $len2{$_} . '_R' } = 0;
    }
    if ( !exists $hash_num{ $len2{$_} } ) {
        $hash_num{ $len2{$_} } = 0;
    }

    print PRIM
"$len2{$_}\t$hash_num{$len2{$_}.'_F'}\t$hash_num{$len2{$_}.'_R'}\t$hash_num{$len2{$_}}\n";
}

