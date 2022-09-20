#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

##########
#add  comand -p 09/29/2019'''
##############

die "Usage:
    perl [script] -i [input] -o [out] -t  [type change] -Y

        -i  input: str txt or vcf file
        -o  output
        -t 2to3 or 3to2
        -Y default false if not
        -p yk or other"
  unless @ARGV >= 1;
my $in;
my $out;
my $chrY;
my $type;
my $project;

Getopt::Long::GetOptions(
    'i=s'=>\$in,
    'o=s'=>\$out,
    't=s'=>\$type,
    'Y'=>\$chrY,
    'p=s'=>\$project,
);
open IN, "<$in"
  or die "Cannot open file $in!\n";
open OUT, ">$out"
  or die "Cannot open file $out!\n";

my $header = <IN>;
print OUT $header;
while (<IN>) {

    chomp;
    my @line = split(/\t/,$_);
    if ( $type eq '2to3' )  {
        unless ($chrY) {
        if($line[0] ne 'Y') {
	    $line[6] = $line[6]*1.5;
	    my $result = join("\t",@line);
	    print  OUT "$result\n";
        }
        else {
	    print OUT "$_\n";
        }}
    }
    if (! $chrY and $type eq '3to2' )  {
        $line[6] = $line[6]/(3/2);
        my $result = join("\t",@line);
        print  OUT "$result\n";
    }
    if ( $chrY and $type eq '2to3' )  {
        $line[6] = $line[6]*1.5;
        my $result = join("\t",@line);
        print  OUT "$result\n";
    }
    if ( $chrY and $type eq '3to2' )  {
        $line[6] = $line[6]/(3/2);
        my $result = join("\t",@line);
        print  OUT "$result\n";
    }
    
}

my ($sample)=($in=~/^(.+)\.point$/);

if($project eq 'yk') {
    `Rscript /home/tianxl/pipeline/utils/SC.R $out $out `;
    `sed '/^X/d' $out > $out.noXY`;
    `sed -i '/^Y/d' $out.noXY`;
    `Rscript /home/tianxl/pipeline/utils/SC.R $out.noXY $out.noXY`;
}
if($project eq 'other') {
    `Rscript /home/tianxl/pipeline/utils/CNV.R $out $out `;
}
