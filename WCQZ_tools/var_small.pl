#! /usr/bin/perl -w
use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
        -o  output
        -m  mother_data_column
        -s  son_data_column
        -f  father_column
        -d  min_var_depth"
  unless @ARGV >= 1;

########################

my $in;
my $out;
my $mom;
my $son;
my $dad;
my $min;
my $son_small;
my $dad_small;
my $sim;
my $sim1;
my $sim2;
my $sim3;
my $sim4;

Getopt::Long::GetOptions(
    'i=s' => \$in,
    'o=s' => \$out,
    'm:i' => \$mom,
    's:i' => \$son,
    "f:i" => \$dad,
    "d:i" => \$min,

);

open IN, "<$in"
  or die "Cannot open file $in!\n";
open OUT, ">>$out"
  or die "Cannot open file $out!\n";

my $line_count = 0;
my $snp_ms     = 0;
my $snp_f      = 0;
my @result;
my $line;
while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\:/, $line[$mom];

        #  my @mom_var=split/\,/,$mom[1];
        #  my $mom_var=$mom_var[1]/$mom[2];
        my @son = split /\:/, $line[$son];

        #  my @son_var=split/\,/,$son[1];
        #  my $son_var=$son_var[1]/$son[2];
        my @dad = split /\:/, $line[$dad];

        #  my @dad_var=split/\,/,$dad[1];
        #  my $dad_var=$dad_var[1]/$dad[2];

#if($line_count>1 and substr($line[$mom],0,3)ne"./." and substr($line[$son],0,3)ne"./." and substr($line[$dad],0,3)ne"./." and $mom[2]ne"." and $son[2]ne"." and $dad[2]ne"." and $mom[2]>5 and $son[2]>5 and $dad[2]>5) {
#my @line=split/\t/,$line;
# print $line."\n";
#  my @mom=split/\:/,$line[$mom];
#my @mom_var=split/\,/,$mom[1];
#my $mom_var=$mom_var[1]/$mom[2];
#  my @son=split/\:/,$line[$son];
        if ( $line_count > 1 && $line[-2] eq 1 ) {
            my @son_var = split /\,/, $son[1];
            if ( $son_var[0] < $son_var[1] ) {
                my $son_small = $son_var[0] / $son[2];

                #  my @dad=split/\:/,$line[$dad];
                my @dad_var = split /\,/, $dad[1];
                my $dad_small = $dad_var[0] / $dad[2];
                $sim = $dad_small - $son_small;
                print OUT $son_small . "\t" . $line . "\n";
            }
            if ( $son_var[0] > $son_var[1] ) {
                my $son_small = $son_var[1] / $son[2];
                if ( $dad[1] =~ ',' ) {
                    my @dad_var = split /\,/, $dad[1];
                    my $dad_small = $dad_var[1] / $dad[2];
                    $sim1 = $dad_small - $son_small;
                    print OUT $son_small . "\t" . $line . "\n";
                }
                else {
                    $sim2 = 1 - $son_small;
                    print OUT $son_small . "\t" . $line . "\n";
                }
            }
        }
        elsif ( $line_count > 1 && $line[-1] != ~1 ) {
            my @son_var = split /\,/, $son[1];
            if ( $son_var[0] < $son_var[1] ) {
                my $son_small = $son_var[0] / $son[2];
                $sim3 = 0 - $son_small;
                print OUT $son_small . "\t" . $line . "\n";
            }
            if ( $son_var[0] > $son_var[1] ) {
                my $son_small = $son_var[1] / $son[2];
                $sim4 = 0 - $son_small;
                print OUT $son_small . "\t" . $line . "\n";
            }
        }
    }
}

