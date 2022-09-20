#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
use Cwd;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
	-i2
        -o  output
	-o2 son_type
	-o3 family type
        -m  mother_data_column
        -s  son_data_column
        -f  father_column
        -d  min_var_depth
        -noheader
        -l  Drop unsupported points
        -c  control"
  unless @ARGV >= 1;

########################

my $in;
my $in2;
my $out;
my $mom;
my $son;
my $dad;
my $min;
my $ref;
my $rate;
my $out1;
my $out3;
my $loss;
my $no_header;
my $control;
my @line_str = "";

Getopt::Long::GetOptions(
    'i=s'      => \$in,
    'i2=s'     => \$in2,
    'o=s'      => \$out,
    'm:i'      => \$mom,
    's:i'      => \$son,
    "f:i"      => \$dad,
    "d:i"      => \$min,
    "r:f"      => \$rate,
    'o2=s'     => \$out1,
    'o3=s'     => \$out3,
    'noheader' => \$no_header,
    'l'        => \$loss,
    'c'        => \$control,

);

if ($rate) {
    $rate = $rate;
}
else {
    $rate = 0.02;
}
if ($min) {
    $min = $min;
}
else {
    $min = 10;
}

if ($out) {
    if ($control) {
        $outname  = 'F' . $out . '.txt1';
        $outname3 = 'F' . $out . '.ty1';
    }
    else {
        $outname  = 'F' . $out . '.txt';
        $outname3 = 'F' . $out . '.ty';
    }
}
else {
    $dir = getcwd;
    if ($control) {
        $outname  = 'F' . ( split /\//, $dir )[-1] . '.txt1';
        $outname3 = 'F' . ( split /\//, $dir )[-1] . '.ty1';
    }
    else {
        $outname  = 'F' . ( split /\//, $dir )[-1] . '.txt';
        $outname3 = 'F' . ( split /\//, $dir )[-1] . '.ty';

        #print $outname;
    }
}
open OUT, "> $outname"
  or die "Cannot open file $outname!\n";
open OUT3, ">$outname3"
  or die "Cannot open file $outname3!\n";

open IN, "<$in"
  or die "Cannot open file $in!\n";
if ($in2) {
    $in2 = $in2;
}
else {
    $in2 = "/home/tianxl/pipeline/STR_tools/STR_ku/190220/all.erti.ty.rate";
}

$fre1 = "/home/tianxl/pipeline/STR_tools/STR_ku/190220/all.erti.ty.rate_v2";
$fre2 = "/home/tianxl/pipeline/STR_tools/STR_ku/190220/all.erti.ty.rate";

open IN2, "<$in2"
  or die "Cannot open file $in2!\n";
open OUT2, ">>$out1"
  or die "Cannot open file $out1!\n";

while (<IN2>) {
    chomp;
    my $type_ku = ( split /\t/, $_ )[0];
    $type{$type_ku} = 1;
}
my %len = ( "D2S437_(GATA)5" => 1, );

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
my $zong            = 0;
my @son_num_type    = "";
my $possible_daiyun = 0;
my $possible_normal = 0;
my @dad_type        = "";
my @mom_typen       = "";
my @out3_1;
my @out3_2;
my @out3_3;
my @out3_4;
my $dadList;
my $momList;
my $sonList;
my @momGt = "";
my @sonGt = "";

sub gettype {
    my $testtype = shift;
    @sum_from_dad1 = split( /\D+/, $testtype );
    foreach (@sum_from_dad1) {
        $son_from_dad_type1 += $_;
    }
    $STR_s1 = $testtype;
    $STR_s1 =~ s/\([A-Z]+\)//g;
    $STR_s1 =~ s/[0-9]+//g;
    if ( length($STR_s1) > 0 ) {
        $son_from_dad_type1 += int( length($STR_s1) / 4 );
        $type_last1 =$son_from_dad_type1 . '.' . length($STR_s1) % 4;
        $type_last1 =~ s/\.0//;
    }
    else {
        $type_last1 = $son_from_dad_type1;
    }
    $son_from_dad_type1 = 0;
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
        my @son = split /\;/, $line[$son];
        if ( $line_count == 1 ) {
            $momList = $line[$mom];
            $sonList = $line[$son];
            print OUT2 "$line[$mom]\t$line[$son]\n";
            push @out3_1, 'ID';
            push @out3_2, $line[$mom];
            push @out3_3, $line[$son];


            #print OUT3 "ID\t$line[$dad]\t$line[$mom]\t$line[$son]\n";
            unless ($no_header) {
                print "$line[$mom]\t$line[$son]\n";
            }

            #print OUT2 "$line[$dad]\t$line[$mom]\t$line[$son]\n";
        }
        if (    $line_count > 1
            and $line[0] !~ 'DX'
            and $line[0] !~ 'DY'
            and $line[$mom] ne 'NA'
            and $line[$mom] ne ""
            and $line[$son] ne 'NA'
            and $line[$son] ne ""
            and $line[$mom] ne 'F'
            and $line[$son] ne 'F'
             )
        {
            foreach $each_mom (@mom) {
                my @mom_var = split /\|/, $each_mom;
                $hashmom{ $mom_var[0] } = $mom_var[1];
                $sum_mom += $mom_var[1];
            }
            foreach $each_son (@son) {
                my @son_var = split /\|/, $each_son;
                $hashson{ $son_var[0] } = $son_var[1];
                $sum_son += $son_var[1];
            }

            #$hashsum_dad += $sum_dad;
            $hashsum_mom += $sum_mom;
            $hashsum_son += $sum_son;
            $line_need_count++;
            foreach $momGt(sort {$hashmom{$b}<=>$hashmom{$a}}  keys %hashmom ) {
                $momRatio = $hashmom{$momGt} / $sum_mom;
                if ( $momRatio > 0.15 and exists $type{$line[0].'_'.$momGt}) {
                    $numMom++;
                    if($numMom<=2) {
                    $sumMomRatio += $momRatio;
                    push @momGt,$momGt;
                    $hashmomGt{$momGt}=&gettype($momGt);
                    }
                }
            }
            $numMom = 0;
            foreach $sonGt(sort {$hashson{$b}<=>$hashson{$a}} keys %hashson ) {
                $sonRatio = $hashson{$sonGt}/$sum_son;

                if ( $sonRatio > 0.15 and exists $type{$line[0].'_'.$sonGt} ) {
                    $numSon++;
                    if($numSon<=2) {
                    $sumSonRatio += $sonRatio;
                    push @sonGt,$sonGt;
                    $hashsonGt{$sonGt}=&gettype($sonGt);
                    }
                }
            }
            $numSon = 0;
            shift @momGt;
            shift @sonGt;

            if ( $sum_son > 50 and $sum_mom > 50 and @sonGt and @momGt) { # and $sumMomRatio >= 0.6 and $sumSonRatio >=0.6) {
                $all++;
                foreach $each_mom (@momGt) {

                    foreach $each_son (@sonGt) {
                        #$sonType = ( split /\|/, $each_son )[0];
                        if ( $each_mom ne $each_son and $each_mom ne "" ) {
                            $hash1{$each_son} = 1;
                            $hash2{$each_son} = 1;
                            $hash1{$each_mom} = 1;
                        }
                        if ( $each_mom eq $each_son and $each_mom ne "" ) {
                            #$num++;
                            $hash{$each_mom}  = 1;
                            $hash1{$each_mom} = 1;
                            $hash2{$each_son} = 1;
                        }
                    }
                }
                $type  = keys %hash;
                $type1 = keys %hash1;
                $type2 = keys %hash2;

                if($#momGt==0) {
                    $momType = $momGt[0].'/'.$momGt[0];
                    $momTypeL = $hashmomGt{$momGt[0]}.'/'.$hashmomGt{$momGt[0]};
                }
                elsif($#momGt==1) {
                    $momType = $momGt[0].'/'.$momGt[1];
                    $momTypeL = $hashmomGt{$momGt[0]}.'/'.$hashmomGt{$momGt[1]};
                }
                if($#sonGt==0) {
                    $sonType = $sonGt[0].'/'.$sonGt[0];
                    $sonTypeL = $hashsonGt{$sonGt[0]}.'/'.$hashsonGt{$sonGt[0]};
                }
                elsif($#sonGt==1) {
                    $sonType = $sonGt[0].'/'.$sonGt[1];
                    $sonTypeL = $hashsonGt{$sonGt[0]}.'/'.$hashsonGt{$sonGt[1]};
                }
                if ( $type >= 2 or $type1 eq $type) {
                    $same++;
                    print OUT "$line[0]\t$momType\t$sonType\tsame\n";
                }
                elsif ( $type >= 1 and $type1 ne $type ) {
                    $zhichi++;
                    print OUT "$line[0]\t$momType\t$sonType\tOK\n";
                }
                else {
                    print OUT "$line[0]\t$momType\t$sonType\tReject\n";
                }


                push @out3_1, $line[0];
                push @out3_2, $momTypeL;
                push @out3_3, $sonTypeL;


            }
        }
    }
    %hashson           = ();
    %hashmom           = ();
    %hashmomGt =();
    %hashsonGt =();
    $sum_son           = 0;
    $sum_mom           = 0;
    $sum_dad           = 0;
    %hash =();
    %hash1=();
    %hash2=();
    @momGt = "";
    @sonGt = "";
    $sumMomRatio = 0;
    $sumSonRatio = 0;
}

#$ave_dad = $hashsum_dad / $line_need_count;
#$ave_mom = $hashsum_mom / $line_need_count;
#$ave_son = $hashsum_son / $line_need_count;

my $out3_1 = join( "\t", @out3_1 );
$out3_1 =~ s/\//\|/g;
my $out3_2 = join( "\t", @out3_2 );
$out3_2 =~ s/\//\|/g;
my $out3_3 = join( "\t", @out3_3 );
$out3_3 =~ s/\//\|/g;
print OUT3 "$out3_1\n$out3_2\n$out3_3\n";

print "common1\tcommon2\tall\t>=1 common\t2 common\n";
print "$zhichi\t$same\t$all\t" . ( $zhichi + $same ) / $all . "\t" . $same / $all . "\n";

if ( $all >= 5  ) {
    if ( !$control or $control ) {

`perl /home/tianxl/pipeline/STR_tools/STR_ku/190220/ptindex10.pl -i $outname3 -r $fre1 -o $momList.$sonList.out  -S 2`;
#`perl /home/tianxl/pipeline/STR_tools/STR_ku/190220/no_dad_rate_v2.pl $outname3 $fre2 > $outname3.pe`;
        open RATE, ">$outname.rate"
          or die "Cannot open file $outname.rate !\n";
        #print RATE
        #  "$zhichi\t$same\t$all\t" . ( $zhichi + $same ) / $all . "\t" . $same / $all . "\n";
        $pi_out = 'F' . ( split /\//, $dir )[-1] . '.ty.out';
        open PI, ">$pi_out"
          or die "Cannot open file $pi_out' !\n";
        open CPI, ">$outname.cpi"
          or die "Cannot open file $outname.cpi !\n";
        $/ = "ID\:";

        while (<PI>) {
            @line = split( /\n/, $_ );

            #print "@line\n";
            #foreach (@line) {
            #	@line1 = split(/\t/,$_);
            $f = ( split /\//, $dir )[-1] . 'F';
            if ( $line[0] =~ $f ) {

                #print "$line[0]\t".(split/\//,$dir)[-1].'F'."\n";
                foreach (@line) {

                    #print "$_\n";
                    @line1 = split( /\t/, $_ );
                    $s = ( split /\//, $dir )[-1] . 'S';
                    if ( $line1[0] =~ $s ) {
                        $cpi = sprintf( "%.8e", 10**$line1[1] );
                        #print CPI "CPI = $cpi\n";
                    }
                }
            }
        }
    }
    if ($control) {
        open RATE, ">$outname.rate1"
          or die "Cannot open file $outname.rate1 !\n";
        #print RATE
        #  "$zhichi\t$same\t$all\t" . ( $zhichi + $same ) / $all . "\t" . $same / $all . "\n";
    }

}
else {
    print "Too few points\n";
    exit(1);
}

$pos = 'F' . ( split /\//, $dir )[-1] . '.txt';
$neg = 'F' . ( split /\//, $dir )[-1] . '.txt1';

if ( -e $pos and -e $neg ) {
    $pe = 'F' . ( split /\//, $dir )[-1] . '.ty.pe';
 #   `cat $pos.rate  $neg.rate1 $pos.cpi $pe > $pos.last.txt`;
}

