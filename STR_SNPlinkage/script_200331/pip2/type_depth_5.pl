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
my @mom_type1 = "";
my $header    = <IN>;
#$header =~ s/str/\tdepth/;
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
            if ( $sum_mom > 10 ) {
                foreach $mom_type ( keys %hashmom ) {
                    $mom_type_rate =
                      sprintf( "%.2f", $hashmom{$mom_type} / $sum_mom );
                    @sum_type = split( /\D+/, $mom_type );
                    if ( $mom_type_rate > 0.15 ) {
                        $all++;
                        my $mom_type1 =
                            $mom_type . '|'
                          . $hashmom{$mom_type} . '|'
                          . $mom_type_rate;
                        push @mom_type, $mom_type1;
                    }
                    if ( $mom_type_rate > 0.1 and $mom_type_rate <= 0.2 ) {
                        $ten++;
                    }
                    if ( $mom_type_rate > 0.15 and $mom_type_rate <= 0.2 ) {
                        $fifteen++;
                    }
                    if ( $mom_type_rate > 0.2 and $mom_type_rate <= 0.3 ) {
                        $twenty++;
                    }
                    if ( $mom_type_rate > 0.25 and $mom_type_rate <= 0.3 ) {
                        $twentyFive++;
                    }
                    if ( $mom_type_rate > 0.3 and $mom_type_rate <= 0.4 ) {
                        $thirty++;
                    }
                    if ( $mom_type_rate > 0.35 and $mom_type_rate <= 0.4 ) {
                        $thirtyFive++;
                    }
                    if ( $mom_type_rate > 0.4 and $mom_type_rate <= 0.5 ) {
                        $fourty++;
                    }
                    if ( $mom_type_rate > 0.45 and $mom_type_rate <= 0.5 ) {
                        $fourtyFive++;
                    }
                    if ( $mom_type_rate > 0.5 and $mom_type_rate <= 0.6 ) {
                        $fifty++;
                    }
                    if ( $mom_type_rate > 0.55 and $mom_type_rate <= 0.6 ) {
                        $fiftyFive++;
                    }
                    if ( $mom_type_rate > 0.6 and $mom_type_rate <= 0.7 ) {
                        $sixty++;
                    }
                    if ( $mom_type_rate > 0.65 and $mom_type_rate <= 0.7 ) {
                        $sixtyFive++;
                    }
                    if ( $mom_type_rate > 0.7 and $mom_type_rate <= 0.8 ) {
                        $seventy++;
                    }
                    if ( $mom_type_rate > 0.75 and $mom_type_rate <= 0.8 ) {
                        $seventyFive++;
                    }
                    if ( $mom_type_rate > 0.8 and $mom_type_rate <= 0.9 ) {
                        $eighty++;
                    }
                    if ( $mom_type_rate > 0.85 and $mom_type_rate <= 0.9 ) {
                        $eightyFive++;
                    }
                    if ( $mom_type_rate > 0.9 and $mom_type_rate <= 1 ) {
                        $ninety++;
                    }
                    if ( $mom_type_rate > 0.95 and $mom_type_rate <= 1 ) {
                        $ninetyFive++;
                    }
                }
                shift @mom_type;
                foreach $rate (
                    sort { ( split /\|/, $b )[2] <=> ( split /\|/, $a )[2] }
                    @mom_type )
                {
                    push @mom_type1, $rate;
                }
                shift @mom_type1;
                my $momtype = join( "\/", @mom_type1 );
		if (scalar(@mom_type1) > 0){
                    print "$line[0]\t$sum_mom\t$momtype\n";
		}
		else {
		    print "$line[0]\t$sum_mom\tF\n";
		}
            }
            else {
                print "$line[0]\t$sum_mom\tNA\n";
            }
            %hashmom   = "";
            $sum_mom   = 0;
            @mom_type  = "";
            @mom_type1 = "";
        }
    }
}
my ($sample) = ( $in =~ /^(.+)\.type$/ );
#print OUT
#"num\t$sample\n10\t".($ten/$all)."\n15\t".($fifteen/$all)."\n20\t".($twenty/$all)."\n25\t".($twentyFive/$all)."\n30\t".($thirty/$all)."\n35\t".($thirtyFive/$all)."\n40\t".($fourty/$all)."\n45\t".($fourtyFive/$all)."\n50\t".($fifty/$all)."\n55\t".($fiftyFive/$all)."\n60\t".($sixty/$all)."\n65\t".($sixtyFive/$all)."\n70\t".($seventy/$all)."\n75\t".($seventyFive/$all)."\n80\t".($eighty/$all)."\n85\t".($eightyFive/$all)."\n90\t".($ninety/$all)."\n95\t".($ninetyFive/$all)."\n";
print OUT
"num\t$sample\n10\t$ten\n20\t$twenty\n30\t$thirty\n40\t$fourty\n50\t$fifty\n60\t$sixty\n70\t$seventy\n80\t$eighty\n90\t$ninety\n";
