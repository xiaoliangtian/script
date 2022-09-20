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
my $ref;
my $rate;
my $no_header;
Getopt::Long::GetOptions(
    'i=s'      => \$in,
    'o=s'      => \$out,
    'm:i'      => \$mom,
    's:i'      => \$son,
    "f:i"      => \$dad,
    "d:i"      => \$min,
    "r:f"      => \$rate,
    'noheader' => \$no_header,
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
my $num      = -1;
my @mom_type = "";
my @son_type = "";
my @dad_rate = "";
my %hashson;
my %hashdad;
my %hashmom;
my %hash_mtype;
my $zong = 0;
my $dad_name;
my $mom_name;
my $son_name;

#my $header = <IN>;
#print "$header";
#chomp($header);
#@head = split(/\t/,$header);
#print "$head[$dad]\t$head[$mom]\t$head[$son]\n";

my %len = (
    "D9S921"  => 1,
    "D5S1484" => 1,
    "D6S474"  => 1,
    "D9S304"  => 1,
);

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        if ( $line_count == 1 ) {
            $dad_name = substr( $line[$dad], 0, 5 );
            $mom_name = substr( $line[$mom], 0, 5 );
            $son_name = substr( $line[$son], 0, 5 );
            print OUT "$line[$dad]\t$line[$mom]\t$line[$son]\n";
            unless ($no_header) {
                print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
            }
        }
        push @line, 0;
        my @mom = split /\//, $line[$mom];
        my @son = split /\//, $line[$son];
        my @dad = split /\//, $line[$dad];
        if (    $line_count > 1
            and $line[0] !~ 'DX'
            and $line[0] !~ 'DY'
            and $line[$mom] ne 'NA'
            and $line[$mom] ne ""
            and $line[$mom] ne "F"
            and $line[$son] ne "F"
            and $line[$son] ne 'NA'
            and $line[$son] ne ""
            and $line[$dad] ne 'NA'
            and $line[$dad] ne ""
            and $line[$dad] ne "F"
            and !exists $len{ $line[0] } )
        {
            #my @mom_var=split/\,/,$mom[3];
            foreach $each_mom (@mom) {
                foreach $each_dad (@dad) {
                    if ( $each_mom ne $each_dad or $each_mom eq $each_dad ) {
                        my $ty1 = $each_mom . '/' . $each_dad;
                        my $ty2 = $each_dad . '/' . $each_mom;
                        $hash{$ty1} = 1;
                        $hash{$ty2} = 1;
                    }
                }
            }
            if ( exists $hash{ $line[$son] } ) {
                if ( $dad_name eq $son_name ) {

             print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tOK\n";
                }
                $num1++;
            }
            else {
                if ( $dad_name eq $mom_name and $dad_name eq $son_name ) {
                    print OUT
"$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tReject\n";
                }
                $num2++;
            }
        }
        %hash = "";
    }
}
$num_all = $num1 + $num2;
$zhichi  = $num1 / $num_all;
print "$num_all\t$num1\t$zhichi\n";
