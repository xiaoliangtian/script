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
        my @son = split /\;/, $line[$son];
        my @dad = split /\;/, $line[$dad];
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
            #push @mom_rate,$mom_var;}
            #  my @son=split/\:/,$line[$son];
            #my @son_var=split/\,/,$son[3];
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

            #push @son_rate,$son_var;}
            #  my @dad=split/\:/,$line[$dad];
            #my @dad_var=split/\,/,$dad[3];
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

            #$dad_var=$each_dad/$dad[2];
            #push @dad_rate,$dad_var;}
            #  print $line."\n";
            #shift @mom_rate;
            #shift @son_rate;
            #shift @dad_rate;
            print "$line[0]\t$sum_dad\n";
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

=pod
 
if($sum_son > 100 and $sum_mom >100 and $sum_dad > 100) {
     foreach $mom_type(keys %hashmom) {
	     if($sum_mom>0) {
             $mom_type_rate= $hashmom{$mom_type}/$sum_mom;
             @sum_type=split(/\D+/,$mom_type);
             #print "@sum_type"."\n";
             #foreach $sum_type1(@sum_type){
             #        $sum_type+=$sum_type1;
	     #}
             if ($mom_type_rate>0.75) {
		 foreach $sum_type1(@sum_type){
                     $sum_type+=$sum_type1;
                 }
                 #$son_from_mom= $line[$ref]+($mom_type/4);
                 $son_from_mom=$mom_type.'_'.$sum_type;
                 $sum_type=0;
                 #print $son_from_mom;
                 }
             elsif ($mom_type_rate>0.2) {
                 push @mom_type, $mom_type_rate;
                 push @son_type,$hashson{$mom_type}/$sum_son;
                      $hash_mtype{$mom_type_rate} = $mom_type;
                 }
            }}
            shift @mom_type;
            shift @son_type;
            $num = @son_type;
            if($num >2) {
              $bad++;
             }
            if($num==2) {
             if(($son_type[1]/$son_type[0])>($mom_type[1]/$mom_type[0])){
 	       @sum_type=split(/\D+/,$hash_mtype{$mom_type[1]});
               foreach (@sum_type) {
			$sum_type+=$_;
		}
		$son_from_mom = $hash_mtype{$mom_type[1]}.'_'.$sum_type;
		$sum_type=0;
               #$son_from_mom = $line[$ref] + ($hash_mtype{$mom_type[1]}/4);
               }
             if(($son_type[1]/$son_type[0])< ($mom_type[1]/$mom_type[0])){
		@sum_type=split(/\D+/,$hash_mtype{$mom_type[0]});
		foreach (@sum_type) {
                        $sum_type+=$_;
                }
		$son_from_mom = $hash_mtype{$mom_type[0]}.'_'.$sum_type;
                $sum_type=0;
                #$son_from_mom = $line[$ref] + ($hash_mtype{$mom_type[0]}/4); 
               }              
             }        
  if( $line[0]!~'DX' and $line[0]!~'DY' and $line[$mom] ne 'NA' and $line[$dad] ne 'NA' and $line[$son] ne 'NA' and $line[$son] ne "") {  
         foreach $STR_s(keys %hashson){
                 $son_rate=$hashson{$STR_s}/$sum_son;
                # print $son_rate."\n";
               if(exists $hashmom{$STR_s}) {
                 $mom_rate=$hashmom{$STR_s}/$sum_mom;
                 }
                 else{
                 $mom_rate=0;
                 }
               if(exists $hashdad{$STR_s}) {
                 $dad_rate = $hashdad{$STR_s}/$sum_dad;
                 }
                 else{
                 $dad_rate = 0;
                 }
                 #$num++;
         if (($mom_rate < 0.008 and ($son_rate-$mom_rate)>$rate and ($son_rate-$mom_rate) < 0.2 and $hashson{$STR_s}>$min) ) {
             # print $mom_rate."\n";#or ($STR_m > 0.01 and $STR_m < 0.1 and ($son_rate[$num]-$STR_m)>0.04 and $son_var[$num]>$min)) {
              $snp_ms++;
              @sum_from_dad = split(/\D+/,$STR_s);
	      foreach (@sum_from_dad) {
		      $son_from_dad_type+=$_;
	      }
              $son_from_dad=$STR_s.'_'.$son_from_dad_type;
              $son_from_dad_type=0;
              #$son_from_dad = $line[$ref]+($STR_s/4);
          if($dad_rate>0.1){
              $snp_f++;
              $line[$#line]=1;
              #$re=$line[$ref]+($STR_s/4);
              $line1 =$son_from_dad."\t".$son_from_mom."\t".'-'.$line."\t".$son_from_dad."\t".$son_from_mom."\t".'-';
              
          }
          elsif($dad_rate< 0.1) {
              #$re=$line[$ref]+($STR_s/4);
              $line1 =$son_from_dad."\t".$son_from_mom."\t".'错配'.$line ."\t".$son_from_dad."\t".$son_from_mom."\t".'错配';
        }
          push @result,$line1; 
         #  print "$line\n";
       }
       }
      }}}}
      %hashson="";
      %hashmom="";
      %hashdad="";
      $sum_son=0;
      $sum_mom=0;
      $sum_dad=0;
      @mom_type="";
      @son_type="";
      %hash_mtype="";
      #@mom_rate="";
      #@son_rate="";
      #@dad_rate="";
 # elsif($line_count==1) {
  #push  @result,$line1;
 #}
}
my $result=join"\n",@result;
#print "$result\n";
print OUT "$result";
my $match_fre=$snp_f/$snp_ms;
print $snp_ms."\t"."$snp_f"."\t$match_fre\n";
=cut 
