#/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/09/29

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;

die "Usage: perl $0 mismatch.stat project.list\n" unless (@ARGV == 2);
open (OUT, ">$ARGV[0]") or die "Can not open file $ARGV[0]\n";
open (IN, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";

my %hashlist;
while(<IN>) {
    chomp;
    my @line = split(/\t/,$_);
    $hashlist{$line[0]} = $line[1];
}

my @sam = <*.sam>;
my @files = <*dedup.sorted.bam>;
if (@sam == 0 && @files == 0) {
    die "the current floder do not have SAM or BAM file,please check";
}
if (@sam != 0) {
    @files = @sam;
}
my %hash;
foreach my $file (@files) {
    my ($sample) = ($file =~/(^\S+)\.dedup.sorted.bam/);
    $hash{0}{$sample}=$sample;
    if ($file =~/sam$/) {
        open (SAM,$file);
    }else{
        open (SAM, "samtools view -@ 20 $file |");
    }
    print "OK";
    while(<SAM>){
        next if (/^@/);
        chomp;
        $hash{1}{$sample}++;
        my @line = split/\t/;
        next if ($line[5] eq "*");
        $hash{2}{$sample}++;
        unless (/\s+(XS:\S+)\s+/){
            $hash{4}{$sample}++;
        }else{
            $hash{5}{$sample}++;
        }
        my ($xm) = ($_ =~/\s+NM:i:(\d+)\s+/);
        if ($xm == 0) {
            $hash{6}{$sample}++;
        }elsif ($xm <= 5) {
            $hash{7}{$sample}++;
        }
    }
    $hash{3}{$sample}=$hash{1}{$sample}-$hash{2}{$sample};
    close SAM;
}
my $normal;
my %hashtest;
my @header = ("Sample","Total reads","Total mapped","Total unmapped","Unique match","Mutliple match","Perfect match","<=5bp mismatch");
foreach my $i (sort {$a<=>$b} keys %hash) {
    print OUT "$header[$i]";
    foreach  (sort keys %{$hash{$i}}) {
        if ($i>1) {
            my $per = sprintf("%.2f",$hash{$i}{$_}/$hash{1}{$_}*100);
            if($hashlist{$_} eq 'project1' or $hashlist{$_} eq 'others') {
                $normal = 2000000;
            }else{
                $normal = 6000000;
            }
            if($i eq 2 ) {
                $hashtest{$_} = $_;
                my $effect = sprintf("%.2f",$hash{$i}{$_}/$normal);
                #print "$effect\n";
                if($per<0.95 and $effect < 0.66) {
                    $hashtest{$_} .="\t($effect)mapping比例偏低&数据量低";
                }
                elsif($effect < 0.66) {
                    $hashtest{$_} .= "\t($effect)数据量偏低";
                }
                else {
                    $hashtest{$_} .= "\t($effect)正常";
                }
            }
            if($i eq 5 ) {
                if($per>39.5) {
                    $hashtest{$_} .= "\t($per)疑似降解";
                }
                else {
                    $hashtest{$_} .= "\t($per)正常";
                }
            }
            $hash{$i}{$_}.="($per\%)";
        }
        print OUT "\t$hash{$i}{$_}";
    }
    
    print OUT "\n";
}
print "sample\t数据量\t样本质量\n";
foreach  (sort keys %hashtest) {
    print "$hashtest{$_}\n";
}
