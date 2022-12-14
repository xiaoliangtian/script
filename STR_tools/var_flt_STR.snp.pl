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
open OUT, ">$out"
  or die "Cannot open file $out!\n";

my $line_count = 0;
my $snp_ms     = 0;
my $snp_f      = 0;
my @result;
my $line;
while (<IN>) {
    chomp;
    $line = $_;

    #if($line_count==1 ) {
    # print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
    #}
    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        if ( $line_count == 1 ) {
            print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
        }
        push @line, 0;
        my @mom = split /\:/, $line[$mom];
        my @son = split /\:/, $line[$son];
        my @dad = split /\:/, $line[$dad];

        if (    $line_count > 1
            and substr( $line[$mom], 0, 3 ) ne "./."
            and substr( $line[$son], 0, 3 ) ne "./."
            and substr( $line[$dad], 0, 3 ) ne "./."
            and $mom[2] ne "."
            and $son[2] ne "."
            and $dad[2] ne "."
            and $mom[-2] >= 50
            and $son[-2] >= 50
            and $dad[-2] >= 50 )
        {

            my @mom_var = split /\,/, $mom[-1];
            my $mom_var = $mom_var[1] / $mom[-2];
            my @son_var = split /\,/, $son[-1];
            my $son_var = $son_var[1] / $son[-2];
            my @dad_var = split /\,/, $dad[-1];
            my $dad_var = $dad_var[1] / $dad[-2];

            if (
                    ( $line[3] ne "-" and $line[4] ne "-" and length( $line[3] ) <= 1 and length( $line[4] ) <= 1 )
                and ( $mom[0] eq "0/0" or $mom[0] eq "1/1" )
                and ( $son[0] eq "0/0" or $son[0] eq "1/1" )
                and ( $son[0] eq $mom[0] )
                and ( $mom[-2] >= 3 and $son[-2] >= 2 )
                and ( $son[-2] >= $min )
                and (  ( ( $son_var - $mom_var ) >= 0.02 and ( $son_var - $mom_var ) <= 0.15 )
                    or ( ( $mom_var - $son_var ) >= 0.85 and ( $mom_var - $son_var ) <= 0.98 ) )
                and $son_var[0] >= 3
                and $son_var[1] >= 3
                and $dad[0] !~ '2'
                and ( $mom_var <= 0.01 or $mom_var >= 0.99 )
              )
            {
                print "$son_var\n";
                $snp_ms++;
                if ( ( $dad[0] ne $mom[0] or ( $dad_var >= 0.2 and $dad_var <= 0.8 ) ) ) {
                    $snp_f++;
                    $line[$#line] = 1;

                    $line = $line . "\t" . '-';
                }
                else {
                    $line = $line . "\t" . '??????';
                }
                push @result, $line;
            }
        }
        elsif ( $line_count == 1 ) {
            push @result, $line;
        }
    }
}
my $result = join "\n", @result;
print OUT "$result";
my $match_fre = $snp_f / $snp_ms;
print $snp_ms. "\t" . "$snp_f" . "\t$match_fre\n";

