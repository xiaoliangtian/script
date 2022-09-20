#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;

#add mom ratio 2019/07/08";
#添加计算染色体嵌合比例，2022/09/15(注:只能计算一条染色体相对于另一条染色体的插入或者缺失的比例)
##实际嵌合比例计算值为来自母本的染色体占比减去来自父本的染色体占比
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column]

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
my $zong   = 0;
my %hash   = ();
my %hash1  = ();
my $same   = 0;
my $zhichi = 0;

my %len = (
    "D10S1208"=> 1,
    "D10S1221"=> 1,
    "D10S1230"=>1,
    "D10S2322"=>1,
    "D11S2362"=>1,
    "D12S1072"=>1,
    "D14S592"=>1,
    "D15S652"=>1,
    "D17S2193"=>1,
    "D18S1370"=>1,
    "D18S843"=>1,
    "D1S1588"=>1,
    "D1S1589"=>1,
    "D1S1631"=>1,
    "D20S473"=>1,
    "D22S1045"=>1,
    "D22S1265"=>1,
    "D2S1353"=>1,
    "D3S2418"=>1,
    "D4S2390"=>1,
    "D4S2397"=>1,
    "D5S1480"=>1,
    "D5S1484"=>1,
    "D6S1021"=>1,
    "D6S1031"=>1,
    "D6S1035"=>1,
    "D6S1266"=>1,
    "D7S1813"=>1,
    "D8S1100"=>1,
    "D8S1116"=>1,
    "D8S1119"=>1,
    "D8S1458"=>1,
    "D20S1082"=>1,
);
my $header = <IN>;
#print "$header";
chomp($header);
@head = split(/\t/,$header);
print "$head[$mom]\t$head[$son]\n";

open POL, ">$head[$son].pollution"
  or die "Cannot open file $head[$son].pollution!\n";
print POL "num\tchr\tmom_genotype\tfrom_mom\toff_mom\tdiff\n";

while (<IN>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        my @line = split /\t/, $line;
        push @line, 0;
        my @mom = split /\//, $line[$mom];
        my @son = split /\//, $line[$son];

        #my @dad = split /\//, $line[$dad];
        $sum_md = ( split /\|/, $son[0] )[2] + ( split /\|/, $son[1] )[2];
        #if ( $line_count == 1 ) {
        #    print "$line[$mom]\t$line[$son]\n";
        #}
        if (    $line_count >= 1
            and $line[0] !~ 'DX'
            and $line[0] !~ 'DY'
            and $line[$mom] ne 'NA'
            and $line[$mom] ne ""
            and $line[$son] ne 'NA'
            and $line[$son] ne ""
            and $line[$son] ne 'F'
            and $line[$mom] ne 'F' )
        {
            ##
            ($chr) = $line[0] =~ /(D[0-9]+)/;
            $chr =~ s/\D/chr/;
            # $hashchr{$chr}
            $zong++;
            foreach $each_mom (@mom) {
                $momType = ( split /\|/, $each_mom )[0];
                foreach $each_son (@son) {

                    #$sum_md += (split/\|/,$each_son)[2];
                    #print "$each_son\t$sum_md\n";
                    $sonType = ( split /\|/, $each_son )[0];
                    if ( $momType ne $sonType and $each_mom ne "" ) {
                        $hash1{$sonType} = 1;
                        $hash2{$sonType} = 1;
                        $hash1{$momType} = 1;
                    }
                    if ( $momType eq $sonType and $each_mom ne "" ) {
                        $num++;
                        $hash{$momType}  = ( split /\|/, $each_son )[2];
                        $hash1{$momType} = 1;
                        $hash2{$sonType} = 1;
                    }
                }
            }

            $type  = keys %hash;
            $type1 = keys %hash1;
            $type2 = keys %hash2;
            # print "$line[0]\t$type\t$type1\n";
            if ( $type >= 2 or $type1 eq $type ) {
                $same++;
                print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tsame\n";
            }
            elsif ( $type >= 1 and $type1 ne $type ) {
                $zhichi++;
                print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tOK\n";
            }
            else {
                print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tReject\n";
            }

            #print "$line[0]\t$type\t$type2\n";
            if ( !exists $len{$line[0]} and $type == 1  and (split /\|/, $mom[0] )[0] eq (split /\|/, $mom[1] )[0] and $type2 != 1 ) {

                #print "$type\t$type2\n";
                $num_mom++;
                @type = values %hash;
                $sum_momRatio += $type[0];
                $line[0] =~ /D([0-9]+)/;
                $sum_dadRatio += ( $sum_md - $type[0] );
                $diff = (($type[0]-($sum_md - $type[0]))/$sum_md);
                #print "$line[0]\t$diff\n";
                $sum_diff += (($type[0] - ( $sum_md - $type[0] ))/$sum_md);
                #print "$line[0]\t@mom\t$type[0]\t$sum_md\n";
                ##计算染色体嵌合比例
                $hashchrmomRatio{$chr} += $type[0];
                $hashchroffmomRatio{$chr} += ($sum_md - $type[0]);
                $hashchr{$chr}++;       
                print POL "$num_mom\t$1\tHomo\t$type[0]\t".($sum_md - $type[0])."\t$diff\n";
            }
            elsif(!exists $len{$line[0]} and $type == 1  and (split /\|/, $mom[0] )[0] ne (split /\|/, $mom[1] )[0] and $type2 != 1 ) {
                $num_mom++;
                @type = values %hash;
                $line[0] =~ /D([0-9]+)/;
                $sum_momRatio += $type[0];
                $sum_dadRatio += ( $sum_md - $type[0] );
                $diff = 2*(($type[0]-($sum_md - $type[0]))/$sum_md);
                #print "$line[0]\t@mom\t$type[0]\t$sum_md\n";
                $sum_diff += 2*(($type[0] - ( $sum_md - $type[0] ))/$sum_md);
                ##计算染色体嵌合比例
                $hashchrmomRatio{$chr} += $type[0];
                $hashchroffmomRatio{$chr} += ($sum_md - $type[0]);
                $hashchr{$chr}++;
                print POL "$num_mom\t$1\tHete\t$type[0]\t".($sum_md - $type[0])."\t$diff\n";
            }

        }
        %hash   = ();
        %hash1  = ();
        %hash2  = ();
        $num    = 0;
        $sum_md = 0;
    }
}
if ( $num_mom != 0 ) {
    #$fromMom  = ($sum_momRatio-$sum_dadRatio) / $num_mom;
    #$fromDad  = $sum_dadRatio / $num_mom;
    #$polRatio1 = ( $fromMom / ( $fromMom + $fromDad ) - 0.5 ) * 2;
    #print "$polRatio1\n";
    $polRatio2 = ($sum_diff/$num_mom);
    print POL "合计\t$polRatio2\n";
    foreach (sort {(split/chr/,$a)[1] <=> (split/chr/,$b)[1]} keys %hashchr){
      if ($hashchrmomRatio{$_} >= $hashchroffmomRatio{$_}){
        # $chimPlus = (($hashchrmomRatio{$_}/$hashchr{$_} - $polRatio2) / (($hashchroffmomRatio{$_})/$hashchr{$_}) ) -1;
        # $chimDell = ($hashchroffmomRatio{$_}/$hashchr{$_}) / ($hashchrmomRatio{$_}/$hashchr{$_} - $polRatio2) -1 ;
        $chimPlus = (($hashchrmomRatio{$_}/$hashchr{$_} ) / (($hashchroffmomRatio{$_})/$hashchr{$_}) ) -1;
        $chimDell = ($hashchroffmomRatio{$_}/$hashchr{$_}) / ($hashchrmomRatio{$_}/$hashchr{$_} ) -1 ;
        # print POL "$chr\t$chimPlus\t$chimDell\n";
      }
      else {
        # $chimPlus = ($hashchroffmomRatio{$_}/$hashchr{$_}) / ($hashchrmomRatio{$_}/$hashchr{$_} - $polRatio2) -1  ;
        # $chimDell = (($hashchrmomRatio{$_}/$hashchr{$_} - $polRatio2) / (($hashchroffmomRatio{$_})/$hashchr{$_}) ) -1;
        $chimPlus = ($hashchroffmomRatio{$_}/$hashchr{$_}) / ($hashchrmomRatio{$_}/$hashchr{$_} ) -1  ;
        $chimDell = (($hashchrmomRatio{$_}/$hashchr{$_} ) / (($hashchroffmomRatio{$_})/$hashchr{$_}) ) -1;
      }
      print POL "$_\t$chimPlus\t$chimDell\t$hashchr{$_}\n";
    }
}
else {
    print "is the same sample or false sample\n";
}
print "common1\tcommon2\tall\t>=1 common\t2 common\tMaternal pollution\n";
print "$zhichi\t$same\t$zong\t" . ( $zhichi + $same ) / $zong . "\t" . $same / $zong . "\t$polRatio2\|$num_mom" . "\n";
