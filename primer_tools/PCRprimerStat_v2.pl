#!/usr/bin/perl
# use strict;
# use warnings;
use File::Basename;
use Getopt::Long;
use primer;
use mistach;
my $mistach = 1;
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
open( OUT1, ">$ARGV[4]") or die "Can not open file $ARGV[4]\n";
open( OUT2, ">$ARGV[5]") or die "Can not open file $ARGV[5]\n";

while (<PCR>) {
    chomp;
    my @line = split(/\t/,$_);
    $hashf{ $line[0].'_F'} = $line[1];
    $hashr{ $line[0].'_R'} = $line[2];
    $len2{ $line[0] } = $line[0];
}

close PCR;

sub primer_mis{
    ($primer,$mis) = @_;
    @match = "";
    # print "primer_mis\t$primer\t$mis\n";
    @primer = primer::primer2multiple($primer);
    foreach $pri(@primer){
        $matchList = mistach::fuzzy_pattern($pri,$mis);
        push @match, $matchList;
    }
    shift @match;
    return @match;
}

sub matchOrnot{
    ($seq, @primerA) = @_;
    $result = 0;
    foreach $pri(@primerA){
        if ($seq =~ /^$pri/){
            $result = 1;
            last;
        }
    }
    return $result;
}
sub primer_stat{
    ($f, $r) = @_;
    # print "$f\n$r\n";
    $fname = "";
    $rname = "";
    $f_rname = "";
    $fpriSeq = "";
    $rpriSeq = "";
    $start = time;
    foreach $key( keys %hashf){
        $rkey = $key;
        $primerName = $key;
        $primerName =~ s/_F//;
        $rkey =~ s/_F/_R/;
        # print "primer_stat\t$primerName\t$hashr{$rkey}\n";
        # $start = time;
        @primerfA = primer_mis($hashf{$key},$mistach);
        @primerrA = primer_mis($hashr{$rkey},$mistach);
        # $mistime = time - $start;
        # print "mistime\t$mistime\t$start\n";
        # print "primer_stat\t@primerfA\n";
        if ((matchOrnot($f,@primerfA)) and (matchOrnot($r,@primerrA))){
            # $mistime1 = time - $start;
            # print "$seq\tmistime1\t$mistime1\n";
            # print "match\t$hashf{$key}\t$f\n";
            $fname = $key;
            $rname = $rkey;
            $f_rname = $primerName;
            $fpriSeq = 'F:'.$hashf{$key};
            $rpriSeq = 'R:'.$hashr{$rkey};
            last;
        }
        else{
            if (matchOrnot($f,@primerfA)){
                # print "matchr\t$hashr{$rkey}\t$r\n";
                $fname = $key;
                $fpriSeq = 'F:'.$hashf{$key};
            }
            elsif (matchOrnot($r,@primerrA)){
                # print "matchr\t$hashr{$rkey}\t$r\n";
                $rname = $rkey;
                $rpriSeq = 'R:'.$hashr{$rkey};
            }
        }
    }
    $runtime = time - $start;
    # print "$f\t$runtime\t$f_rname\n";
    return $fname,$rname,$f_rname,$fpriSeq,$rpriSeq;
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
        if ($seqname1 =~ /XF:i:1$/){
            $i = 0;
            next;
        }
        my @fastq1 = ($seqname1,$seq1,$flag1,$qual1);
        my @fastq2 = ($seqname2,$seq2,$flag2,$qual2);
        # print "$seqname1\n";
        $start = time;
        ($primerF,$primerR,$primerF_R,$primerFseq,$primerRseq) =  primer_stat($seq1,$seq2);
        $runtime = time - $start;
        print "$seqname1\t$runtime\n";
        my @header = split( /(\s+)/, $fastq1[0] );
        $seqNum = $header[-1];
        $seqNum =~ s/XF:i://;
        if ( $fastq1[1] =~ 'GGGGGGGGGGGGGGGGGGGGGG' ) {
            $adapt++;
        }
    
        elsif ( $primerF_R) {
            $hash_num{ $primerF }+= $seqNum;
            $hash_num{ $primerR }+= $seqNum;
            print "$primerR\n";
            # $hash_num{ $primerF_R }++;
            $effect++;
            $hash_num{ $primerF_R } += $seqNum;
            $header = $header[0] . '_' . $primerF_R.'_'.$seqNum."\t".$primerFseq.' '.$primerRseq;
            #print "$header\tFR\t$hash{$seq_a}\t$hash{$seq_b}\n";
            print OUT1 "$header\n$fastq1[1]\n$fastq1[2]\n$fastq1[3]\n";
            print OUT2 "$header\n$fastq2[1]\n$fastq2[2]\n$fastq2[3]\n";
        }
        else {
            if( $primerF ) {
                $hash_num{ $primerF }+= $seqNum;
            }
            if( $primerR ) {
                $hash_num{ $primerR }+= $seqNum;
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

