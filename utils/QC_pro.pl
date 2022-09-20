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
use Parallel::ForkManager;
use File::Basename qw(basename dirname);
use DB_File;


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

my $pm = Parallel::ForkManager->new(5);
tie my  %hash , "DB_File","out_file";
tie my %plot, "DB_File","out_file1";
my $file3;
my $snum=1;
my @files=<*_R1.fastq.gz>;
if (scalar(@files)==0) {
    die "thr current floder do not have *.raw_1.fq,please cheack";
}

#$pm->run_on_finish( sub {
    #my ($pid, $exit_code, $ident) = @_;
    #print "** $ident just got out of the pool ".
      #"with PID $pid and exit code: $exit_code\n";
#});

#$pm->run_on_start( sub {
    #my ($pid, $ident)=@_;
    #print "** $ident started, pid: $pid\n";
#});
    ##sleep(10);
#sub proc_file{
    #my $ident = shift;
    #my ($minlen,$querylen)=&getlen($ident);
    #my ($sample)=($ident=~/^(.+)\_R1\.fastq.gz$/);
    #my $file1=$ident;
    #unless ($keep) {
        #`perl $DIR/remove_Nbase.pl $file1 $sample.rmn_1.fq`;
        #$file1="$sample.rmn_1.fq";
    #}
    #my $file2="$sample"."_R2.fastq.gz";
    #if (-e $file2) {
        #$snum=2;
        #unless ($keep) {
            #`perl $DIR/remove_Nbase.pl $file2 $sample.rmn_2.fq`;
            #$file2="$sample.rmn_2.fq";
        #}
        #`java -jar $DIR/../third-party/trimmomatic-0.32.jar PE -threads 30 $file1 $file2 $sample.clean_1.fq $sample.rm_1.fq $sample.clean_2.fq $sample.rm_2.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:20  TOPHRED33`;
    #}else {
        #`java -jar $DIR/../third-party/trimmomatic-0.32.jar SE -threads 30 $file1 $sample.clean_1.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:13 MINLEN:50 TOPHRED33`;
    #}
    #`rm $sample.rm*_*.fq`;
    #$hash{0}{$sample}=$sample;
    #$plot{0}{$sample}=$sample;
    #$hash{1}{$sample}=`zcat $ident|wc -l `;
    #$hash{1}{$sample}=(split /\s+/,$hash{1}{$sample})[0]/4;
    #$hash{2}{$sample}=`wc -l $sample.clean_1.fq`;
    #$hash{2}{$sample}=(split /\s+/,$hash{2}{$sample})[0]/4;
    #$plot{1}{$sample}=sprintf("%.4f",$hash{2}{$sample}/$hash{1}{$sample});
    #$plot{2}{$sample}=1-$plot{1}{$sample};
    #$hash{3}{$sample}="$snum*150";
    #$hash{4}{$sample}=sprintf("%.2f",$hash{1}{$sample}*$snum*150/1000000000);
    #$hash{4}{$sample}.="G";
    #$hash{5}{$sample}=sprintf("%.2f",$hash{2}{$sample}*$snum*150/1000000000);
    #$hash{5}{$sample}.="G";
    #my $read1=`$DIR/QGC_stat $sample.clean_1.fq`;
    #if ($fastQC) {
        #`$DIR/../third-party/fastqc -t 10 -q "$sample""_R1.fastq.gz" &`
    #}
    #chomp $read1;
    #($hash{6}{$sample},$hash{7}{$sample},$hash{8}{$sample})=split/\s+/,$read1,3;
    #if ($snum==2) {
        #my $read2=`$DIR/QGC_stat $sample.clean_2.fq`;
        #chomp $read2;
        #($hash{9}{$sample},$hash{10}{$sample},$hash{11}{$sample})=split/\s+/,$read2,3;
    #}
    #return %hash,%plot;
#}

#$pm->run_on_wait( sub {
#    print "** Have to wait for one children ...\n"
#  },
#  0.5
#);

foreach my $file (@files) {
    # Forks and returns the pid for the child h
    my $pid = $pm -> start($file) and next;
    print "This is $file, Child number $pid\n";
    #my (%hash,%plot) = &proc_file($file);
    my ($minlen,$querylen)=&getlen($file);
    #print "$minlen\t$querylen\n";
    my ($sample)=($file=~/^(.+)\_R1\.fastq.gz$/);
    my $file1=$file;
    print "'0_'.$sample\n";
    unless ($keep) {
        `perl $DIR/remove_Nbase.pl $file1 $sample.rmn_1.fq`;
        $file1="$sample.rmn_1.fq";
    }
    my $file2="$sample"."_R2.fastq.gz";
    if (-e $file2) {
        $snum=2;
        unless ($keep) {
            `perl $DIR/remove_Nbase.pl $file2 $sample.rmn_2.fq`;
            $file2="$sample.rmn_2.fq";
        }
        `java -jar $DIR/../third-party/trimmomatic-0.32.jar PE -threads 30 $file1 $file2 $sample.clean_1.fq $sample.rm_1.fq $sample.clean_2.fq $sample.rm_2.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:20  TOPHRED33`;
    }else {
        `java -jar $DIR/../third-party/trimmomatic-0.32.jar SE -threads 30 $file1 $sample.clean_1.fq ILLUMINACLIP:$adaptor:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:$minlen TOPHRED33`;
    }
    `rm $sample.rm_*.fq`;
    $hash{'0_'.$sample}=$sample;
    $plot{'0_'.$sample}=$sample;
    #print "'0_'.$sample\n";
    #print "$hash{0}{$sample}\t$plot{0}{$sample}\n";
    $hash{'1_'.$sample}=`zcat $file|wc -l `;
    $hash{'1_'.$sample}=(split /\s+/,$hash{'1_'.$sample})[0]/4;
    $hash{'2_'.$sample}=`wc -l $sample.clean_1.fq`;
    #$file3= "test.clean_1.fq";
    #my $querylen1 = &getlen($file3);
    #print "$querylen1\n";
    $hash{'2_'.$sample}=(split /\s+/,$hash{'2_'.$sample})[0]/4;
    
    $plot{'1_'.$sample}=sprintf("%.4f",$hash{'2_'.$sample}/$hash{'1_'.$sample});
    
    $plot{'2_'.$sample}=1-$plot{'1_'.$sample};
    $hash{'3_'.$sample}="$snum*150";
    $hash{'4_'.$sample}=sprintf("%.2f",$hash{'1_'.$sample}*$snum*150/1000000000);
    $hash{'4_'.$sample}.="G";
    $hash{'5_'.$sample}=sprintf("%.2f",$hash{'2_'.$sample}*$snum*150/1000000000);
    $hash{'5_'.$sample}.="G";
    my $read1=`$DIR/QGC_stat $sample.clean_1.fq`;
    if ($fastQC) {
        `$DIR/../third-party/fastqc -t 10 -q "$sample""_R1.fastq.gz" &`
    }
    chomp $read1;
    ($hash{'6_'.$sample},$hash{'7_'.$sample},$hash{'8_'.$sample})=split/\s+/,$read1,3;
    if ($snum==2) {
        my $read2=`$DIR/QGC_stat $sample.clean_2.fq`;
        chomp $read2;
        ($hash{'9_'.$sample},$hash{'10_'.$sample},$hash{'11_'.$sample})=split/\s+/,$read2,3;
    }
    #my @line1= keys %hash."\n";
    #print "@line1\n";
    $pm->finish;
}
$pm->wait_all_children;

#my @line = keys %hash;
#print "@line\n";

my %hash1;my %plot1;
foreach (keys %hash) {
	my @line = split(/\_/,$_,2);
        print "$line[0]\t$line[1]\n";
       
	$hash1{$line[0]}{$line[1]} = $hash{$_};
}

foreach (keys %plot) {
	my @line = split(/\_/,$_,2);
	$plot1{$line[0]}{$line[1]} = $plot{$_};
}


open (OUT,">$output");
my @header=("Sample","Raw Reads","Clean reads","Average length(bp)",
"Raw data","Clean data","Read 1 Q20","Read 1 Q30","Read 1 GC content",
"Read 2 Q20","Read 2 Q30","Read 2 GC content");
foreach my $i (sort {$a<=>$b} keys %hash1) {
    print OUT "$header[$i]";
    foreach  (sort keys %{$hash1{$i}}) {
        print OUT "\t$hash1{$i}{$_}";
    }
    print OUT "\n";
}

open (PLOT,">$output.plot");
my @plot=("","cleandata","otherdata");
print "@plot\n";
foreach my $i (sort {$a<=>$b} keys %plot1) {
    print PLOT "$plot[$i]";
    foreach  (sort keys %{$plot1{$i}}) {
        print PLOT "\t$plot1{$i}{$_}";
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
