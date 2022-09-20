#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;


#add mom ratio 2019/07/08";
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
my $zong  = 0;
my %hash  = ();
my %hash1 = ();
my $same = 0;
my $zhichi=0;


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
        #my @dad = split /\//, $line[$dad];
        $sum_md = (split/\|/,$son[0])[2]+(split/\|/,$son[1])[2];
        if ( $line_count == 1 ) {
            print "$line[$mom]\t$line[$son]\n";
        }
        if (    $line_count > 1
            and $line[0] !~ 'DX'
            and $line[0] !~ 'DY'
            and $line[$mom] ne 'NA'
            and $line[$mom] ne ""
            and $line[$son] ne 'NA'
            and $line[$son] ne ""
            and $line[$son] ne 'F'
            and $line[$mom] ne 'F' 
            and (split/\|/,$son[0])[2] >=0.3 and (split/\|/,$son[0])[2] <= 0.55 and (split/\|/,$son[1])[2] >=0.3 and (split/\|/,$son[1])[2] <= 0.55 
            and ((split/\|/,$son[0])[1]+(split/\|/,$son[1])[1]) > 100)
        {
            #$zong++;
            #print "@mom\t@son\n";
            foreach $each_mom (@mom) {
	        $momType = (split/\|/,$each_mom)[0];	
                foreach $each_son (@son) {
                    #$sum_md += (split/\|/,$each_son)[2];
                    #print "$each_son\t$sum_md\n";
                    $sonType = (split/\|/,$each_son)[0];
                    if ( $momType ne $sonType and $each_mom ne "" ) {
                        $hash1{$sonType} = 1;
                        $hash2{$sonType} = 1;
			$hash1{$momType} = 1;
                    }
                    if ( $momType eq $sonType and $each_mom ne "" ) {
                        $num++;
			$hash{$momType} = (split/\|/,$each_son)[2];
			$hash1{$momType} = 1;
                        $hash2{$sonType} = 1;
                    }
                }
            }

	    $type = keys %hash;
	    $type1 = keys %hash1;
            $type2 = keys %hash2;
            if ( ($type >= 2 or $type1 eq $type) and $type2 == 2) {
                $same++;
                $zong++;
                print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tsame\n";
            }
            elsif($type >= 1 and $type1 ne $type and $type2 == 2) {
		$zhichi++;
                $zong++;
		print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tOK\n";
	    }
            elsif($type2 == 2) {
                $zong++;
                print OUT "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\tReject\n";
            }
            #print "$line[0]\t$type\t$type2\n";
            if($type ==1 and $type2 !=1) {
                #print "$type\t$type2\n";
                $num_mom++;
                @type = values %hash;
                $sum_momRatio +=$type[0];
               
                $sum_dadRatio +=($sum_md - $type[0]);
                #print "$line[0]\t$sum_md\t$sum_momRatio\t$sum_dadRatio\n";
            }
            
        }
        %hash  = ();
	%hash1  = ();
        %hash2=();
        $num=0;
        $sum_md = 0;
    }
}
if($num_mom != 0){
    $fromMom = $sum_momRatio/$num_mom;
    $fromDad = $sum_dadRatio/$num_mom;
    $polRatio = ($fromMom/($fromMom+$fromDad) -0.5)*2;
}
else {
    print "is the same sample or false sample\n";
}
print "common1\tcommon2\tall\t>=1 common\t2 common\tMaternal pollution\n";
print "$zhichi\t$same\t$zong\t" . ($zhichi+$same) / $zong."\t" .$same/$zong."\t$polRatio". "\n";
