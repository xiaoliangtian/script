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

sub gettype {
    my $testtype = shift;
    if($testtype =~ /[0-9]\(/) {
        @sum_from_dad1 = split( /\([A-Z]+\)/, $testtype );
        shift @sum_from_dad1;
        $son_from_dad_type1 = join("\+",@sum_from_dad1);
    }
    else {
        $son_from_dad_type1 = $testtype;
        $son_from_dad_type1 =~ s/\([A-Z]+\)//g;
    }
    $type_last1 = $son_from_dad_type1;
    
    return($type_last1);
    #$son_from_dad_type1 = 0;
}

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\;/, $line[$mom];
        if ( $line_count >= 1 and $line[0] ne 'DYS393') {
            foreach $each_mom (@mom) {
                if ( $line[$mom] eq 'NA' or $line[$mom] eq "" ) {
                    $sum_mom = 0;
                }
                else {
                    my @mom_var = split /\|/, $each_mom;
                    $ertiType = &gettype($mom_var[0]);
                    $hashmom{ $mom_var[0] } = $mom_var[1];
                    $hashtype{$mom_var[0] } = $ertiType;
                    $sum_mom += $mom_var[1];
                    #print "$ertiType\t";
                }
            }
            if($line[0]=~ /D([0-9]+)/) {
                $chr = 'chr'.$1;
            }
            elsif($line[0]=~ /DX/){
                $chr = chrX;
            }
            elsif($line[0]=~ /DY/){
                $chr = chrY;
            }
            if ( $sum_mom > 50 ) {
                foreach $mom_type ( keys %hashmom ) {
                    $mom_type_rate = sprintf( "%.2f", $hashmom{$mom_type} / $sum_mom );
                    if ( $mom_type_rate > 0.15 ) {
                        
                        my $mom_type1 = $hashtype{$mom_type} . '|' . $hashmom{$mom_type} . '|' . $mom_type_rate;
                        push @mom_type, $mom_type1;
                        $rate += $mom_type_rate;
                    }
                }
                shift @mom_type;
                $mom_num = @mom_type;
                my $momtype = join( "\/", @mom_type );
                if ( $mom_num == 1 and $rate >= 0.7  ) {
                    print "$chr\t" . $momtype . "\n";
                }
                elsif ( $mom_num == 2 and $rate >= 0.7 ) {
                    $momtype = join( "\/", @mom_type );
                    print "$chr\t$momtype\n";
                }
                elsif ( $mom_num >= 3 ) {
                    print "$chr\tF\n";
                }
                elsif ( $mom_num == 0 ) {
                    print "$chr\tF\n";
                }
		else {
                    print "$chr\tF\n";
                }
                $rate = 0;

            }
            else {
                
                print "$chr\tNA\n";
            }
            %hashmom  = ();
            $sum_mom  = 0;
            %hashtype = ();
            @mom_type = "";
        }
    }
}
