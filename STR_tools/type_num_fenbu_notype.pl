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
my $header = <IN>;
print "$header";

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\;/, $line[$mom];
        if ( $line_count >= 1 ) {
            foreach $each_mom (@mom) {
                if ( $line[$mom] eq 'NA' or $line[$mom] eq "" ) {
                    $sum_mom = 0;
                }
                else {
                    my @mom_var = split /\|/, $each_mom;
                    $hashmom{ $mom_var[0] } = $mom_var[1];
                    $sum_mom += $mom_var[1];
                }
            }
            if ( $sum_mom > 300 ) {
                foreach $mom_type ( keys %hashmom ) {
                    $mom_type_rate =
                      sprintf( "%.2f", $hashmom{$mom_type} / $sum_mom );
                    @sum_type = split( /\D+/, $mom_type );
                    if ( $mom_type_rate > 0.01 ) {
                        my $mom_type1 =
                            $mom_type . '|'
                          . $hashmom{$mom_type} . '|'
                          . $mom_type_rate;
                        push @mom_type, $mom_type1;
                    }
                }
                shift @mom_type;
                $type_num_first = @mom_type;
                if ( $type_num_first >= 1 ) {
                    $all++;
                    foreach $type2 (
                        sort { ( split /\|/, $b )[2] <=> ( split /\|/, $a )[2] }
                        @mom_type
                      )
                    {
                        #print "$line[0]\t";
                        @type_all = split( /\|/,  $type2 );
                        @sum_type = split( /\D+/, $type_all[0] );
                        foreach (@sum_type) {
                            if ( $_ ne "" ) {
                                $type_num += $_;
                            }
                        }

                        #print "$type_num\t";
                        $type_only = $type_all[0];
                        $type_only =~ s/\d+//g;
                        if ( $type_all[2] > 0.15 ) {
                            $hash_zhu{$type_only}    = 1;
                            $hash_zhu_num{$type_num} = 1;

                            #$all_type_num++;
                            #print "$type_only\t$type_num\t";
                            $type_num = 0;

                            #print "$type_only\t$type_num\t";
                        }
                        elsif (
                            !exists $hash_zhu{$type_only}
                            or (    !exists( $hash_zhu_num{ $type_num + 1 } )
                                and !exists( $hash_zhu_num{ $type_num - 1 } ) )
                          )
                        {
                            $all_type_num++;

                            #print "$type_only\t$type_num";
                            $type_num = 0;
                        }
                        else {
                            $type_num = 0;
                        }
                    }
                    $hash_type_num{$all_type_num}++;
                    $hash_type_num1{$all_type_num} .= $line[0] . '_';
                    $all_type_num = 0;
                    %hash_zhu     = ();
                    %hash_zhu_num = ();

                    #print "\n";
                }
            }
            %hashmom  = ();
            $sum_mom  = 0;
            @mom_type = "";
        }
    }
}

if ( exists $hash_type_num{1} ) {
    print "1\t$hash_type_num{1}\t$hash_type_num1{1}\n";
}
else {
    print "1\t0\n";
}
if ( exists $hash_type_num{2} ) {
    print "2\t$hash_type_num{2}\t$hash_type_num1{2}\n";
}
else {
    print "2\t0\n";
}
if ( exists $hash_type_num{3} ) {
    print "3\t$hash_type_num{3}\t$hash_type_num1{3}\n";
}
else {
    print "3\t0\n";
}
if ( exists $hash_type_num{4} ) {
    print "4\t$hash_type_num{4}\t$hash_type_num1{4}\n";
}
else {
    print "4\t0\n";
}
if ( exists $hash_type_num{5} ) {
    print "5\t$hash_type_num{5}\t$hash_type_num1{5}\n";
}
print "all\t$all\n";

