#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/08/27

#Change Log###########
#Auther:Nieh  Version:1.1.0  Modifed:2015/09/08 Commit: auto determine querylen ,minlen and type
#Auther:Nieh  Version:1.2.0  Modifed:2015/10/15 Commit: add FastQC Assessment option and change the r script
######################
use strict;
use warnings;
use Getopt::Long;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

my $DIR=dirname(abs_path($0));
my $adaptor="$DIR/adapter.fa";
my ($keep,$fastQC)=("","");
my $output;
GetOptions(
    "a:s" => \$adaptor,
    "keep" => \$keep,
    "fastQC"=> \$fastQC,
    "o=s" => \$output,
    "help|?" =>\&USAGE,
)or &USAGE;
&USAGE unless ($output);

my %hash;my %plot;
my $snum=1;
my @files=<*.raw_1.fq>;
if (length(@files)==0) {
    die "thr current floder do not have *.raw_1.fq,please cheack";
}
foreach my $file (@files) {
    my ($minlen,$querylen)=&getlen($file);
    my ($sample)=($file=~/^(.+)\.raw\_1\.fq$/);
    my $file1=$file;
    unless ($keep) {
        `perl $DIR/remove_Nbase.pl $file1 $sample.rmn_1.fq`;
        $file1="$sample.rmn_1.fq";
    }
    my $file2="$sample.raw_2.fq";
    if (-e $file2) {
        $snum=2;
        unless ($keep) {
            `perl $DIR/remove_Nbase.pl $file2 $sample.rmn_2.fq`;
            $file2="$sample.rmn_2.fq";
        }
        `java -jar $DIR/../third-party/trimmomatic-0.32.jar PE -threads 30 $file1 $file2 $sample.clean_1.fq $sample.rm_1.fq $sample.clean_2.fq $sample.rm_2.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:$minlen TOPHRED33`;
    }else {
        `java -jar $DIR/../third-party/trimmomatic-0.32.jar SE -threads 30 $file1 $sample.clean_1.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:$minlen TOPHRED33`;
    }
    `rm $sample.rm*_*.fq`;
    $hash{0}{$sample}=$sample;
    $plot{0}{$sample}=$sample;
    $hash{1}{$sample}=`wc -l $file`;
    $hash{1}{$sample}=(split /\s+/,$hash{1}{$sample})[0]/4;
    $hash{2}{$sample}=`wc -l $sample.clean_1.fq`;
    $hash{2}{$sample}=(split /\s+/,$hash{2}{$sample})[0]/4;
    $plot{1}{$sample}=sprintf("%.4f",$hash{2}{$sample}/$hash{1}{$sample});
    $plot{2}{$sample}=1-$plot{1}{$sample};
    $hash{3}{$sample}="$snum*$querylen";
    $hash{4}{$sample}=sprintf("%.2f",$hash{1}{$sample}*$snum*$querylen/1000000000);
    $hash{4}{$sample}.="G";
    $hash{5}{$sample}=sprintf("%.2f",$hash{2}{$sample}*$snum*$querylen/1000000000);
    $hash{5}{$sample}.="G";
    my $read1=`$DIR/QGC_stat $sample.clean_1.fq`;
    if ($fastQC) {
        `$DIR/../third-party/fastqc -t 10 -q $sample.clean_1.fq &`;
    }
    chomp $read1;
    ($hash{6}{$sample},$hash{7}{$sample},$hash{8}{$sample})=split/\s+/,$read1,3;
    if ($snum==2) {
        my $read2=`$DIR/QGC_stat $sample.clean_2.fq`;
	if ($fastQC) {
        `$DIR/../third-party/fastqc -t 10 -q $sample.clean_2.fq &`;
    }
        chomp $read2;
        ($hash{9}{$sample},$hash{10}{$sample},$hash{11}{$sample})=split/\s+/,$read2,3;
    }
}
open (OUT,">$output");
my @header=("Sample","Raw Reads","Clean reads","Average length(bp)",
"Raw data","Clean data","Read 1 Q20","Read 1 Q30","Read 1 GC content",
"Read 2 Q20","Read 2 Q30","Read 2 GC content");
foreach my $i (sort {$a<=>$b} keys %hash) {
    print OUT "$header[$i]";
    foreach  (sort keys %{$hash{$i}}) {
        print OUT "\t$hash{$i}{$_}";
    }
    print OUT "\n";
}

open (PLOT,">$output.plot");
my @plot=("","cleandata","otherdata");
foreach my $i (sort {$a<=>$b} keys %plot) {
    print PLOT "$plot[$i]";
    foreach  (sort keys %{$plot{$i}}) {
        print PLOT "\t$plot{$i}{$_}";
    }
    print PLOT "\n";
}
`Rscript $DIR/bar.r $output.plot QC`;

sub USAGE {
    my $usage=<<"USAGE";
USAGE:
    $0 [options]  -o summary.out

    [-a ADAPTER]     = ADAPTER file.Default = $DIR/adapter.fa

    -k  --keep       Keep the 'N' Base

    -f  --fastQC     FastQC Assessment

    -o <outputfile>  Output summary

    -h  --help       Help

USAGE
    print $usage;
    exit;
}

sub getlen{
    my $file=shift;
    open(IN,$file);
    <IN>;
    my $seq=<IN>;
    close (IN);
    chomp $seq;
    my $seqlen=int(length($seq)/5)*5;
    my $minlen=$seqlen>50 ? 50 : int($seqlen/2);
    return $minlen,$seqlen;
}
