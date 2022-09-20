#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
        -o  output
        -m  mother_data_column
        -s  son_data_column
        -d  min_var_depth"
  unless @ARGV >= 1;

########################

my $in;
my $out;
my $mom;
my $son;
my $dad;
my $min;
my $ref;
my $rate;
Getopt::Long::GetOptions(
    'i=s' => \$in,
    'o=s' => \$out,
    'm:i' => \$mom,
    's:i' => \$son,
    "f:i" => \$dad,
    "d:i" => \$min,
    "r:f" => \$rate,

);

open IN, "<$in"
  or die "Cannot open file $in!\n";
open OUT, ">$out"
  or die "Cannot open file $out!\n";

my $line_count = 0;
my $snp_ms     = 0;
my $snp_f      = 0;
my @result;
my $line;
my $num      = -1;
my @mom_type = "";
my @son_type = "";
my @dad_rate = "";
my %hashson;
my %hashdad;
my %hashmom;
my %hash_mtype;
my $zong  = 0;
my %hash  = "";
my %hash1 = "";

#my $header = <IN>;
#print "$header";
while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\//, $line[$mom];
        my @son = split /\//, $line[$son];
        my @dad = split /\//, $line[$dad];
        if ( $line_count == 1 ) {
            print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
        }
        if (    $line_count > 1
            and $line[0] !~ 'DX'
            and $line[0] !~ 'DY'
            and $line[$mom] ne 'NA'
            and $line[$mom] ne ""
            and $line[$son] ne 'NA'
            and $line[$son] ne ""
            and $line[$dad] ne 'NA'
            and $line[$dad] ne ""
            and $line[$son] ne 'F'
            and $line[$dad] ne 'F'
            and $line[$mom] ne 'F' )
        {
            $zong++;
            foreach $each_mom (@mom) {
                foreach $each_son (@son) {
                    if ( $each_mom ne $each_son and $each_mom ne "" ) {
                        $hash{$each_mom} = 1;
                    }
                    if ( $each_mom eq $each_son and $each_mom ne "" ) {
                        $hash1{$each_son} = 1;
                    }
                }
            }
            my @type = keys %hash1;
            $type = @type;

            #print "@type\n";
            if ( $type > 1 ) {
                $zhichi++;
                print OUT "$_\tOK\n";
            }
            else {
                print OUT "$_\tReject\n";
            }
        }
        %hash  = "";
        %hash1 = "";
    }
}
print "$zhichi\t$zong\t" . $zhichi / $zong . "\n";
