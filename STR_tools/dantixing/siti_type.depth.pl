#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
        -o  output
        -m  mother_data_column"
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

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\;/, $line[$mom];
        if ( $line_count >= 1 ) {

            #my @mom_var=split/\,/,$mom[3];
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

            #$mom_var=$each_mom/$mom[2];
            # print $mom_var."\n";
            #push @mom_rate,$mom
            if ( $sum_mom > 50 ) {

                #print $line[0]."\n";
                foreach $mom_type ( keys %hashmom ) {
                    $mom_type_rate = sprintf( "%.2f", $hashmom{$mom_type} / $sum_mom );
                    @sum_type = split( /\D+/, $mom_type );

                    #print "@sum_type"."\n";
                    #foreach $sum_type1(@sum_type){
                    #        $sum_type+=$sum_type1;
                    #}
                    if ( $mom_type_rate > 0.1 ) {

                        #print $line[0]."\n";
                        my $mom_type1 = $mom_type . '|' . $hashmom{$mom_type} . '|' . $mom_type_rate;

                        #print "$mom_type1\n";
                        push @mom_type, $mom_type1;

                        #print "@mom_type\n";
                    }
                }
                shift @mom_type;
                $mom_num = @mom_type;
                my $momtype = join( "\/", @mom_type );
                if ( $mom_num == 1 ) {
                    print "$line[0]\t" . $momtype . '/' . $momtype . '/' . $momtype . '/' . $momtype . "\n";
                }
                if ( $mom_num == 2 ) {
                    $momtype = join( "\/", @mom_type );
                    $num1 = ( split /\|/, $mom_type[0] )[2];
                    $num2 = ( split /\|/, $mom_type[1] )[2];
                    if ( sprintf( "%.0f", $num1 / $num2 ) > 1 ) {
                        print "$line[0]\t$mom_type[0]" . '/' . $mom_type[0] . '/' . $mom_type[0] . '/' . $mom_type[1] . "\n";
                    }
                    if ( sprintf( "%.0f", $num1 / $num2 ) < 1 ) {
                        print "$line[0]\t$mom_type[1]" . '/' . $mom_type[1] . '/' . $mom_type[1] . '/' . $mom_type[0] . "\n";
                    }
                    if ( sprintf( "%.0f", $num1 / $num2 ) == 1 ) {
                        print "$line[0]\t$mom_type[0]" . '/' . $mom_type[0] . '/' . $mom_type[1] . '/' . $mom_type[1] . "\n";
                    }

                }
                if ( $mom_num == 3 ) {
                    foreach ( sort { ( split /\|/, $b )[2] <=> ( split /\|/, $a )[2] } @mom_type ) {
                        $num1++;
                        if ( $num1 == 1 ) {
                            print "$line[0]\t$_" . '/' . $_;
                        }
                        elsif ( $num1 > 1 ) {
                            print '/' . "$_";
                        }
                    }
                    print "\n";

                    #$num1 =0;
                }

                #print "\n";
                $num1 = 0;
                if ( $mom_num == 4 ) {
                    $momtype = join( "\/", @mom_type );
                    print "$line[0]\t$momtype\n";
                }
                if ( $mom_num > 4 ) {
                    print "$line[0]\tF\n";
                }
                elsif ( $mom_num == 0 ) {
                    print "$line[0]\tF\n";
                }

            }
            else {
                print "$line[0]\tNA\n";
            }
            %hashmom  = "";
            $sum_mom  = 0;
            @mom_type = "";
        }
    }
}
