#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
use Math::Round;
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

            # $mom_var=$each_mom/$mom[2];
            # print $mom_var."\n";
            # push @mom_rate,$mom
            if ( $sum_mom > 50 ) {

                #print $line[0]."\n";
                foreach $mom_type ( keys %hashmom ) {
                    $mom_type_rate = sprintf( "%.2f", $hashmom{$mom_type} / $sum_mom );
                    @sum_type = split( /\D+/, $mom_type );

                    if ( $mom_type_rate > 0.15 ) {

                        my $mom_type1 = $mom_type . '|' . $hashmom{$mom_type} . '|' . $mom_type_rate;

                        #print "$mom_type1\n";
                        push @mom_type, $mom_type1;
                        $rate += $mom_type_rate;
                        #print "@mom_type\n";
                    }
                }
                shift @mom_type;
                $mom_num = @mom_type;
                my $momtype = join( "\/", @mom_type );
                if ( $mom_num == 1 and $rate >= 0.8 ) {#修改判断纯合单个基因型占比rate由0.6》0.8
                    print "$line[0]\t" . $momtype . '/' . $momtype . '/' . $momtype . "\n";
                }
                elsif ( $mom_num == 2 and $rate >= 0.6 ) {
                    $momtype = join( "\/", @mom_type );
                    ##计算两个基因型的比值，与2相比，用于判断该条染色体是否为三体（三体如果出现两种基因型，那么必然是2：1的关系）
                    $num1 = ( split /\|/, $mom_type[0] )[2];
                    $num2 = ( split /\|/, $mom_type[1] )[2];
                    ($chr) = $line[0] =~ /^(\D[0-9]+)/;
                    # print "$line[0]\t$chr\n";
                    if ($line[0] !~ /DY/ and $chr ne ""){
                      $hash{$chr} ++;
                    }
                    elsif ($line[0] !~ /DY/){
                      $chr = "DX";
                      $hash{$chr} ++;
                      # print "$chr\t$line[0]\n";
                    }
                    if ( $num1 >= $num2 ) {
                      ##同上
                      # $chr =~ /^\D[0-9]+/;
                      $hashCHRdoublegenoDepth{$chr.'_'.2} += (split /\|/,$mom_type[0])[1];
                      $hashCHRsinglegenoDepth{$chr.'_'.1} += (split /\|/,$mom_type[1])[1];
                      # $doublegenoDepth += (split /\|/,$mom_type[0])[1];
                      # $singlegenoDepth += (split /\|/,$mom_type[1])[1]; 
                        print "$line[0]\t$mom_type[0]" . '/' . $mom_type[0] . '/' . $mom_type[1] . "\n";
                    }
                    elsif ( $num1 < $num2 ) {
                      # $hash{$chr} = 1;
                      $hashCHRdoublegenoDepth{$chr.'_'.2} += (split /\|/,$mom_type[1])[1];
                      $hashCHRsinglegenoDepth{$chr.'_'.1} += (split /\|/,$mom_type[0])[1];
                        print "$line[0]\t$mom_type[1]" . '/' . $mom_type[1] . '/' . $mom_type[0] . "\n";
                    }

                }
                elsif ( $mom_num == 3 and $rate >= 0.6  ) {
                    $momtype = join( "\/", @mom_type );
                    print "$line[0]\t$momtype\n";
                }
                elsif ( $mom_num > 3 ) {
                    print "$line[0]\tF\n";
                }
                elsif ( $mom_num == 0 ) {
                    print "$line[0]\tF\n";
                }
                else {
                   print "$line[0]\tF\n";
                }
                $rate = 0;

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

foreach (keys %hash){

  $double = $hashCHRdoublegenoDepth{$_.'_'.2};
  $single = $hashCHRsinglegenoDepth{$_.'_'.1};
  $rate = round($double/$single);
  print "$_\t$rate".'('.$hash{$_}.')'."\n";
}
