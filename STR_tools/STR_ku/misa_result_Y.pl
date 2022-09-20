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

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        if ( $line_count == 1 ) {

            #print OUT2 "$line[$dad]\t$line[$mom]\t$line[$son]\n";
            unless ($no_header) {
                print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
            }
        }
        push @line, 0;
        my @mom = split /\;/, $line[$mom];
        my @son = split /\;/, $line[$son];
        my @dad = split /\;/, $line[$dad];
        if ( $line_count >= 1 and $line[0] =~ 'DY' ) {
            foreach $each_mom (@mom) {
                if ( $line[$mom] eq 'NA' or $line[$mom] eq "" ) {
                    $sum_mom = 0;
                }
                else {
                    my @mom_var = split /\|/, $each_mom;
                    $hashmom{ $mom_var[0] } = $mom_var[1];

                    #print $mom_var[1]."\n";
                    $sum_mom += $mom_var[1];
                }
            }
            foreach $each_son (@son) {
                if ( $line[$son] eq 'NA' or $line[$son] eq "" ) {
                    $sum_son = 0;
                }
                else {
                    my @son_var = split /\|/, $each_son;
                    $hashson{ $son_var[0] } = $son_var[1];
                    $sum_son += $son_var[1];
                }
            }
            foreach $each_dad (@dad) {
                if ( $line[$dad] eq 'NA' or $line[$dad] eq "" ) {
                    $sum_dad = 0;
                }
                else {
                    my @dad_var = split /\|/, $each_dad;
                    $hashdad{ $dad_var[0] } = $dad_var[1];
                    $sum_dad += $dad_var[1];
                }
            }
            if ( $sum_son > 50 and $sum_mom < 50 ) {
                foreach $son_type ( keys %hashson ) {
                    $son_type_rate = $hashson{$son_type} / $sum_son;
                    @sum_type = split( /\D+/, $mom_type );
                    if ( $son_type_rate > 0.2 ) {
                        push @son_type, $hashson{$son_type} / $sum_son;
                        $hash_mtype{$son_type_rate} = $son_type;
                    }
                }
            }
            shift @son_type;
            $num = @son_type;
            if ( $num > 1 ) {
                $bad++;
            }
            if ( $num == 1 ) {
                $snp_ms++;
                foreach $STR_s (@son_type) {
                    $son_rate = $hashson{ $hash_mtype{$STR_s} } / $sum_son;
                    if ( exists $hashdad{ $hash_mtype{$STR_s} } ) {
                        $dad_rate = $hashdad{ $hash_mtype{$STR_s} } / $sum_dad;
                    }
                    elsif ( !exists $hashdad{ $hash_mtype{$STR_s} } ) {
                        $dad_rate = 0;
                    }
                    if ( $dad_rate > 0.5 and $son_rate > 0.1 ) {
                        $snp_f++;
                        $line1 = $dad_rate . "\t$son_rate\t" . '-' . $line;
                    }
                    elsif ( $dad_rate < 0.5 and $son_rate > 0.1 ) {
                        $line1 = $dad_rate . "\t$son_rate\t" . '错配' . $line;
                    }
                    push @result, $line1;
                }
            }
            %hashson    = "";
            %hashmom    = "";
            %hashdad    = "";
            $sum_son    = 0;
            $sum_mom    = 0;
            $sum_dad    = 0;
            @mom_type   = "";
            @son_type   = "";
            %hash_mtype = "";
        }
    }
}
my $result = join "\n", @result;

#print "$result\n";
print OUT "$result";
my $match_fre = $snp_f / $snp_ms;
print $snp_ms. "\t" . "$snp_f" . "\t$match_fre\n";

