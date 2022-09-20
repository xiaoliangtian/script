#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_column] -s [son_column] -f [father_column] -d [min_var_depth]

        -i  input: str txt or vcf file
	-i2 
        -o  output
	-o2 son_type
        -m  mother_data_column
        -s  son_data_column
        -f  father_column
        -d  min_var_depth"  
unless @ARGV>=1;

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
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'i2=s' => \$in2,
   'o=s' => \$out,
   'm:i' => \$mom,
   's:i' => \$son,
   "f:i" => \$dad,
   "d:i" => \$min,
   "r:f"=> \$rate,
   'o2=s'=> \$out1,
   
);


open IN, "<$in"
     or die "Cannot open file $in!\n";
open IN2, "<$in2"
     or die "Cannot open file $in2!\n";   
open OUT, ">$out"
     or die "Cannot open file $out!\n";
open OUT2, ">$out1"
     or die "Cannot open file $out1!\n";

while (<IN2>) {
	chomp;
	my $type_ku = (split/\t/,$_)[0];
	$type{$type_ku} = 1;
}
my $line_count=0;
my $snp_ms=0;
my $snp_f=0;
my @result;
my $line;
my $num=-1;
my @mom_type="";
my @son_type="";
my @dad_rate="";
my %hashson;
my %hashdad;
my %hashmom;
my %hash_mtype;
my $zong=0;
while(<IN>) {
	chomp;
	$line=$_;
	if(substr($line,0,2)ne"##" ) {
	$line_count++;
  	my @line=split/\t/,$line;
  	push @line,0;
  	my @mom=split/\;/,$line[$mom];
  	my @son=split/\;/,$line[$son];
  	my @dad=split/\;/,$line[$dad];
  	if($line_count==1 ) {
		print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
  	}
  	if($line_count>1 and $line[0]!~ 'DX'and $line[0]!~ 'DY' and $line[$mom] ne 'NA' and $line[$mom] ne "" and $line[$son] ne 'NA' and $line[$son] ne "" and $line[$dad] ne 'NA' and $line[$dad] ne "") {
  	#my @mom_var=split/\,/,$mom[3];
      		foreach $each_mom(@mom) {
        		my @mom_var=split/\|/,$each_mom;
          		$hashmom{$mom_var[0]}=$mom_var[1];
          		#print $mom_var[1]."\n";
          		$sum_mom+=$mom_var[1];
		}
          		#$mom_var=$each_mom/$mom[2];
         		# print $mom_var."\n";
          		#push @mom_rate,$mom_var;} 
			#  my @son=split/\:/,$line[$son];
			  #my @son_var=split/\,/,$son[3];
      		foreach $each_son(@son) {
          		my @son_var=split/\|/,$each_son;
             		$hashson{$son_var[0]}=$son_var[1];
             		$sum_son+=$son_var[1];
		}
          		#push @son_rate,$son_var;}
			#  my @dad=split/\:/,$line[$dad];
  			#my @dad_var=split/\,/,$dad[3];
     		foreach $each_dad(@dad){
         		my @dad_var=split/\|/,$each_dad;
            		$hashdad{$dad_var[0]}=$dad_var[1];
            		$sum_dad+=$dad_var[1];
		}
         	#$dad_var=$each_dad/$dad[2];
         	#push @dad_rate,$dad_var;}
		#  print $line."\n";
         	#shift @mom_rate;
         	#shift @son_rate;
         	#shift @dad_rate;
         	$hashsum_dad += $sum_dad;
	 	$hashsum_mom += $sum_mom;
	 	$hashsum_son += $sum_son;
         	#print $sum_dad/284 ."\t".$sum_mom/284 ."\t".$sum_son/284 ."\n";
		if($sum_son > 100 and $sum_mom >100 and $sum_dad > 50) {
			$all++;
     			foreach $mom_type(keys %hashmom) {
	    			if($sum_mom>0) {
             				$mom_type_rate= $hashmom{$mom_type}/$sum_mom;
             				@sum_type=split(/\D+/,$mom_type);
             				#print "@sum_type"."\n";
             				#foreach $sum_type1(@sum_type){
             				#$sum_type+=$sum_type1;
	     				#}
             				if ($mom_type_rate>0.7) {
						$all_1++;
		 				foreach $sum_type1(@sum_type){
                     					$sum_type+=$sum_type1;
                 				}
                 			#$son_from_mom= $line[$ref]+($mom_type/4);
                 			$son_from_mom=$mom_type.'_'.$sum_type;
                 			$sum_type=0;
                 			#print $son_from_mom;
                 			}
             				elsif ($mom_type_rate>0.15) {
                 				push @mom_type, $mom_type_rate;
                 				push @son_type,$hashson{$mom_type}/$sum_son;
                      				$hash_mtype{$mom_type_rate} = $mom_type;
                 			}
            			}
			}
            		shift @mom_type;
            		shift @son_type;
            		$num = @son_type;
            		if($num >2) {
				$all_1++;
              			$bad++;
             		}
	    		if($num ==1) {		
				#print "@son_type\n";
	   		}
	
            		if($num==2) {
				$all_1++;
				#print "$son_type[1]\t$son_type[0]\n";
             			if($son_type[1] != 0 and $son_type[0]!= 0 and ($son_type[1]/$son_type[0])>($mom_type[1]/$mom_type[0])){
 	       				@sum_type=split(/\D+/,$hash_mtype{$mom_type[1]});
               				foreach (@sum_type) {
						$sum_type+=$_;
					}
					$STR_s2 = $hash_mtype{$mom_type[0]};
					$STR_s2 =~ s/\([A-Z]+\)//g;
					@STR_s1 = split(/[0-9]+/,$STR_s2);
					$num = @STR_s1;
					if ($num  >= 1) {
						foreach (@STR_s) {
                					if ($_ ne "") {
                        					$sum_type += int(length($_)/4);
                        					$type_from_mom_last = $sum_type.'.'.length($_)%4;
                					}
                					else {
                        					$type_from_mom_last = $sum_type;
                					}
						}
					}
					else {
                				#print "$type\n";
                				$type_from_mom_last = $sum_type;
					}
					$sum_type =0;
					$son_from_mom = $hash_mtype{$mom_type[1]}.'_'.$sum_type;
					$sum_type=0;
               				#$son_from_mom = $line[$ref] + ($hash_mtype{$mom_type[1]}/4);
					#print "true1\n";
               			}
             			elsif( $son_type[1] != 0 and $son_type[0] != 0 and ($son_type[1]/$son_type[0])< ($mom_type[1]/$mom_type[0])){
					@sum_type=split(/\D+/,$hash_mtype{$mom_type[0]});
					foreach (@sum_type) {
                        			$sum_type+=$_;
                			}
					$STR_s2 = $hash_mtype{$mom_type[0]};
					$STR_s2 =~ s/\([A-Z]+\)//g;
					@STR_s1 = split(/[0-9]+/,$STR_s2);
					$num = @STR_s1;
					if ($num  >= 1) {
						foreach (@STR_s) {
                					if ($_ ne "") {
                        					$sum_type += int(length($_)/4);
                        					$type_from_mom_last = $sum_type.'.'.length($_)%4;
                					}
                					else {
                        					$type_from_mom_last = $sum_type;
                					}
						}
					}		
					else {
                				#print "$type\n";
                				$type_from_mom_last = $sum_type;
					}
					$son_from_mom = $hash_mtype{$mom_type[0]}.'_'.$sum_type;
                			$sum_type=0;
					#print "true2\n";
               				#$son_from_mom = $line[$ref] + ($hash_mtype{$mom_type[0]}/4); 
               			}
				elsif ( $son_type[1] <0.05  or  $son_type[0] <0.05) {
					print "false\n";
				}
				else {
					print "false1\n";
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
         				if (($mom_rate < 0.01 and ($son_rate-$mom_rate)>$rate and ($son_rate-$mom_rate) < 0.2 and $hashson{$STR_s}>$min ) ) {
	     					# print $son_rate-$mom_rate."\t$line[0]\n";
	      					$zong += ($son_rate-$mom_rate);
             					# print $mom_rate."\n";#or ($STR_m > 0.01 and $STR_m < 0.1 and ($son_rate[$num]-$STR_m)>0.04 and $son_var[$num]>$min)) {
              					$snp_ms++;
              					@sum_from_dad = split(/\D+/,$STR_s);
	      					foreach (@sum_from_dad) {
		      					$son_from_dad_type+=$_;
	      					}
						$STR_s1 = $STR_s;
						$STR_s1 =~ s/\([A-Z]+\)//g;
						@STR_s = split(/[0-9]+/,$STR_s1);
						$num = @STR_s;
						if ($num  >= 1) {
							foreach (@STR_s) {
                						if ($_ ne "") {
                        						$son_from_dad_type += int(length($_)/4);
                        						$type_last = $son_from_dad_type.'.'.length($_)%4;
                						}
                						else {
                        						$type_last = $son_from_dad_type;
                						}
							}
						}
						else {
                					#print "$type\n";
                					$type_last = $son_from_dad_type;
						}
						$son_from_dad_type =0;
              					$son_from_dad=$STR_s.'_'.$son_from_dad_type;
              					$son_from_dad_type=0;
              					#$son_from_dad = $line[$ref]+($STR_s/4);
          					if($dad_rate>0.1){
              						$snp_f++;
              						$line[$#line]=1;
              						#$re=$line[$ref]+($STR_s/4);
              						$line1 =$son_from_dad."\t".$son_from_mom."\t".'-'.$line."\t".$son_from_dad."\t".$son_from_mom."\t".'-';
							print OUT2 "$line[0]\t".$type_last.'/'."$type_from_mom_last\n";   
          					}
          					elsif($dad_rate< 0.1) {
              						#$re=$line[$ref]+($STR_s/4);
              						$line1 =$son_from_dad."\t".$son_from_mom."\t".'错配'.$line ."\t".$son_from_dad."\t".$son_from_mom."\t".'错配';
							print OUT2 "$line[0]\t$type_last".'/'."$type_from_mom_last\n";
        					}
          					push @result,$line1; 
         					#  print "$line\n";
       					}
       				}
      			}
		}
	}
}
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
my $ratio = $zong/$snp_ms;
my $youli=$ratio*2;
#print $zong."\n";
$ave_dad = $hashsum_dad/432;
$ave_mom = $hashsum_mom/432;
$ave_son = $hashsum_son/432;
print $snp_ms."\t"."$snp_f"."\t$match_fre\t$ratio\t$youli\t$ave_dad\t$ave_mom\t$ave_son\t$all\t$all_1\n";
