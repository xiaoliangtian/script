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
        -d  min_var_depth
	-noheader" 
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
my $no_header;
my @line_str = "";
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
   'noheader' => \$no_header,

);

open IN, "<$in"
     or die "Cannot open file $in!\n";
open IN2, "<$in2"
     or die "Cannot open file $in2!\n";   
open OUT, ">$out"
     or die "Cannot open file $out!\n";
open OUT2, ">>$out1"
     or die "Cannot open file $out1!\n";

while (<IN2>) {
	chomp;
	my $type_ku = (split/\t/,$_)[0];
	$type{$type_ku} = 1;
}
my %len = (
"D2S437_(GATA)5"=>1,
);

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
my @son_num_type="";
my $possible_daiyun=0;
my $possible_normal=0;
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
		unless($no_header) {
		print "$line[$dad]\t$line[$mom]\t$line[$son]\n";
		print OUT2 "$line[$dad]\t$line[$mom]\t$line[$son]\n";}
  	}
  	if($line_count>1 and $line[0]!~ 'DX'and $line[0]!~ 'DY' and $line[$mom] ne 'NA' and $line[$mom] ne "" and $line[$son] ne 'NA' and $line[$son] ne "" and $line[$dad] ne 'NA' and $line[$dad] ne "") {
      		foreach $each_mom(@mom) {
        		my @mom_var=split/\|/,$each_mom;
          		$hashmom{$mom_var[0]}=$mom_var[1];
          		$sum_mom+=$mom_var[1];
		}
      		foreach $each_son(@son) {
          		my @son_var=split/\|/,$each_son;
             		$hashson{$son_var[0]}=$son_var[1];
             		$sum_son+=$son_var[1];
		}
     		foreach $each_dad(@dad){
         		my @dad_var=split/\|/,$each_dad;
            		$hashdad{$dad_var[0]}=$dad_var[1];
            		$sum_dad+=$dad_var[1];
		}
         	$hashsum_dad += $sum_dad;
	 	$hashsum_mom += $sum_mom;
	 	$hashsum_son += $sum_son;
		$line_need_count++;
		foreach (keys %hashdad){
			if ($hashdad{$_}/$sum_dad >0.15) {
				$sum_dad_type_rate += $hashdad{$_}/$sum_dad;
			}
		}
		if($sum_son > 100 and $sum_mom >100 and $sum_dad > 50) {
			$all++;
     			foreach $mom_type(keys %hashmom) {
	    			if($sum_mom>0) {
             				$mom_type_rate= $hashmom{$mom_type}/$sum_mom;
             				@sum_type=split(/\D+/,$mom_type);
					#$STR_s5 =~ s/\([A-Z]+\)//g;
					#$STR_s5 =~ s/[0-9]+//g;
             				if ($mom_type_rate>0.7) {
						$all_1++;
						$num_type = 1;
						@son_type = 1;
						#print "$line[0]\n";
		 				foreach $sum_type1(@sum_type){
                     					$sum_type+=$sum_type1;
                 				}
						$STR_s5 = $mom_type;
						$STR_s5 =~ s/\([A-Z]+\)//g;
						$STR_s5 =~ s/[0-9]+//g;
						$sum_type += int(length($STR_s5)/4);
						$sum_type=$sum_type.'.'.length($STR_s5)%4;
                 				$son_from_mom=$mom_type.'_'.$sum_type;
						$type_from_mom_last = $sum_type;
						$type_off_mom_last = $sum_type;
						#push @son_num_type,$type_from_mom_last;
                 				$sum_type=0;
						$sum_mom_type_rate += $mom_type_rate;
                 			}
             				elsif ($mom_type_rate>0.15) {
                 				push @mom_type, $mom_type_rate;
                 				push @son_type,$hashson{$mom_type}/$sum_son;
                      				$hash_mtype{$mom_type_rate} = $mom_type;
						$sum_mom_type_rate += $mom_type_rate;
                 			}
				}
			}
			if ( @son_type != 1) {
            			shift @mom_type;
            			shift @son_type;
           			$num_type = @son_type;
            			if($num_type >2) {
					$all_1++;
              				$bad++;
					#print "@son_type\n";
             			}
	    			if($num_type ==1) {
					$num_type =0;		
					#print "$line[0]\t@son_type\tfasle2\n";
	   			}
				#print "$line[0]\t@son_type\t$num_type\n";
	
            			if($num_type ==2) {
					$all_1++;
             				if($son_type[1] != 0 and $son_type[0]!= 0 and ($son_type[1]/$son_type[0])>($mom_type[1]/$mom_type[0])){
 	       					@sum_type=split(/\D+/,$hash_mtype{$mom_type[1]});
						@sum_type1=split(/\D+/,$hash_mtype{$mom_type[0]});
               					foreach (@sum_type) {
							$sum_type+=$_;
						}
						foreach (@sum_type1) {
							$sum_type1+=$_;
						}
						$STR_s3 = $hash_mtype{$mom_type[0]};
						$STR_s3 =~ s/\([A-Z]+\)//g;
						$STR_s3 =~ s/[0-9]+//g;
						$STR_s2 = $hash_mtype{$mom_type[1]};
						$STR_s2 =~ s/\([A-Z]+\)//g;
						$STR_s2 =~ s/[0-9]+//g;
						#print "$STR_s2\n";
						if(length($STR_s2) >0) {
							$sum_type += int(length($STR_s2)/4);
							$type_from_mom_last = $sum_type.'.'.length($STR_s2)%4;
							#push @son_num_type,$type_from_mom_last;
						}
						else {
							$type_from_mom_last = $sum_type;
							#push @son_num_type,$type_from_mom_last;
						}
						if(length($STR_s3) >0) {
							$sum_type1 += int(length($STR_s3)/4);
							$type_off_mom_last = $sum_type1.'.'.length($STR_s3)%4;
							#push @son_num_type,$type_off_mom_last;
						}
						#@STR_s1 = split(/[0-9]+/,$STR_s2);
						#$num = @STR_s1;
						#if ($num  >= 1) {
						#	foreach (@STR_s1) {
                				#		if ($_ ne "") {
                        			#			$sum_type += int(length($_)/4);
                        			#			$type_from_mom_last = $sum_type.'.'.length($_)%4;
						#			#push @son_num_type,$type_from_mom_last;
                				#		}
                				#		else {
                        			#			$type_from_mom_last = $sum_type;
						#			#push @son_num_type,$type_from_mom_last;
                				#		}
						#	}
						#}
						else {
                					$type_off_mom_last = $sum_type1;
							#push @son_num_type,$type_off_mom_last;
						}
						$son_from_mom = $hash_mtype{$mom_type[1]}.'_'.$sum_type;
						$sum_type=0;
						$sum_type1=0;
               				}
             				elsif( $son_type[1] != 0 and $son_type[0] != 0 and ($son_type[1]/$son_type[0])< ($mom_type[1]/$mom_type[0])){
						@sum_type=split(/\D+/,$hash_mtype{$mom_type[0]});
						@sum_type1=split(/\D+/,$hash_mtype{$mom_type[1]});
						foreach (@sum_type) {
                        				$sum_type+=$_;
                				}
						foreach (@sum_type1) {
							$sum_type1+=$_;
						}
						$STR_s3 = $hash_mtype{$mom_type[1]};
						$STR_s3 =~ s/\([A-Z]+\)//g;
						$STR_s3 =~ s/[0-9]+//g;
						$STR_s2 = $hash_mtype{$mom_type[0]};
						$STR_s2 =~ s/\([A-Z]+\)//g;
						$STR_s2 =~ s/[0-9]+//g;
						#print "$STR_s2\n";
						if(length($STR_s2) >0) {
							$sum_type += int(length($STR_s2)/4);
							$type_from_mom_last = $sum_type.'.'.length($STR_s2)%4;
							#push @son_num_type,$type_from_mom_last;
						}
						else {
							$type_from_mom_last = $sum_type;
							#push @son_num_type,$type_from_mom_last;
						}
						if(length($STR_s3) >0) {
							$sum_type1 += int(length($STR_s3)/4);
							$type_off_mom_last = $sum_type1.'.'.length($STR_s3)%4;
							#push @son_num_type,$type_off_mom_last;
						}
						#@STR_s1 = split(/[0-9]+/,$STR_s2);
						#$num = @STR_s1;
						#if ($num  >= 1) {
						#	foreach (@STR_s1) {
                				#		if ($_ ne "") {
                        			#			$sum_type += int(length($_)/4);
                        			#			$type_from_mom_last = $sum_type.'.'.length($_)%4;
						#			push @son_num_type,$type_from_mom_last;
                				#		}
                				#		else {
                        			#			$type_from_mom_last = $sum_type;
						#			push @son_num_type,$type_from_mom_last;
                				#		}
						#	}
						#}		
						else {
                					$type_off_mom_last = $sum_type1;
							#push @son_num_type,$type_off_mom_last;
						}
						$son_from_mom = $hash_mtype{$mom_type[0]}.'_'.$sum_type;
                				$sum_type=0;
						$sum_type1=0;
               				}
					elsif ( $son_type[1] <0.1  or  $son_type[0] <0.1) {
						print OUT2 "false\n";
					}
					else{
						print OUT2 "false1\t$son_type[1]\t$son_type[0]\n";
					}           
             			}
			}
			if( $line[0]!~'DX' and $line[0]!~'DY' and $line[$mom] ne 'NA' and $line[$dad] ne 'NA' and $line[$son] ne 'NA' and $line[$son] ne "") {  
         			foreach $STR_s(keys %hashson){
                 			$son_rate=$hashson{$STR_s}/$sum_son;
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
         				if ($mom_rate < 0.01 and ($son_rate-$mom_rate)>$rate and ($son_rate-$mom_rate) < 0.2 and $hashson{$STR_s}>$min and $sum_mom_type_rate >0.7 and $sum_dad_type_rate > 0.7 and $num_type <=2 and $num_type > 0 ) {
	      					$hash_zong{$line[0].'_'.$STR_s}=$son_rate-$mom_rate;
						#print "$STR_s\n";
						#$zong += ($son_rate-$mom_rate);
              					#$snp_ms++;
              					@sum_from_dad = split(/\D+/,$STR_s);
	      					foreach (@sum_from_dad) {
		      					$son_from_dad_type+=$_;
	      					}
						$STR_s1 = $STR_s;
						$STR_s1 =~ s/\([A-Z]+\)//g;
						$STR_s1 =~ s/[0-9]+//g;
						#@STR_s = split(/[0-9]+/,$STR_s1);
						if(length($STR_s1)>0) {
							$son_from_dad_type += int(length($STR_s1)/4);
							$type_last = $son_from_dad_type.'.'.length($STR_s1)%4;
						}
						#$num = @STR_s;
						#if ($num  >= 1) {
						#	foreach (@STR_s) {
                				#		if ($_ ne "") {
                        			#			$son_from_dad_type += int(length($_)/4);
                        			#			$type_last = $son_from_dad_type.'.'.length($_)%4;
                				#		}
                				#		else {
                        			#			$type_last = $son_from_dad_type;
                				#		}
						#	}
						#}
						else {
                					$type_last = $son_from_dad_type;
						}
              					$son_from_dad=$STR_s.'_'.$son_from_dad_type;
              					$son_from_dad_type=0;
          					if($dad_rate>0.1){
							#print "$line[0]\n";
              						#$snp_f++;
              						$line[$#line]=1;
              						$line1 =$son_from_dad."\t".$son_from_mom."\t".'-'.$line."\t".$son_from_dad."\t".$son_from_mom."\t".'-';
							push @line_str,$line1;
							print OUT2 "$line[0]\t".$type_last.'/'."$type_from_mom_last\n";   
          					}
          					elsif($dad_rate< 0.1 and  !exists $len{$line[0].'_'.$STR_s}) {
							#print "$line[0]\t$type_last\t$type_from_mom_last\t$type_off_mom_last\n";
              						$line1 =$son_from_dad."\t".$son_from_mom."\t".'错配'.$line ."\t".$son_from_dad."\t".$son_from_mom."\t".'错配';
							push @line_str,$line1;
							print OUT2 "$line[0]\t$type_last".'/'."$type_from_mom_last\n";
        					}
						else{
							#$snp_ms--;
							$line1="";
						}
						#if ($line1 ne "") {
          					#	push @result,$line1; 
						#}
       					}}
					shift @line_str;
					$line_str = @line_str;
					if ($line_str >2 ) {
						$possible_daiyun2++;
					}
					if ($line_str >=2 ) {
						$snp_ms++;
						$possible_daiyun++;
						foreach(@line_str) {
							if($_ =~'错配'){
								$cuopei_num++;
								if($cuopei_num==1) {
									$line_str_cuopei = $_;
								}
								$cuopei++;
							}
							else{
								$zhichi_num++;
								if($zhichi_num==1){
									$line_str_zhichi = $_;
								}
								$zhichi++;
							}
						}
							
						if($zhichi>0) {
							$snp_f++;
							$zong+=$hash_zong{$line[0].'_'.((split/\_/,$line_str_zhichi))[0]};
							#$out=$line[0].'_'.((split/\_/,$line_str_zhichi))[0];
							#print "$out\n";
							push @result,$line_str_zhichi;
						}
						else {
							$zong+=$hash_zong{$line[0].'_'.(split/\_/,$line_str_cuopei)[0]};
							push @result,$line_str_cuopei;
							
						}
					}
					#elsif($line_str==1 ) {
					#	$snp_ms++;
					#	$possible_normal++;
					#	$zong+=$hash_zong{$line[0].'_'.(split/\_/,$line_str[0])[0]};
					#	if($line_str[0] !~ '错配'){
					#		$snp_f++;
					#		push @result,@line_str;
					#	}
					#	else {
					#		push @result,@line_str;
					#	}
					#}
       				@line_str = "";
				$cuopei_num =0;
				$cuopei =0;
				$zhichi_num =0;
				$zhichi = 0;
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
      	%hash_mtype=();
	$sum_mom_type_rate = 0;
	$sum_dad_type_rate = 0;
}
my $result=join"\n",@result;
print OUT "$result";
my $match_fre=$snp_f/$snp_ms;
my $ratio = $zong/$snp_ms;
my $youli=$ratio*2;
$ave_dad = $hashsum_dad/$line_need_count;
$ave_mom = $hashsum_mom/$line_need_count;
$ave_son = $hashsum_son/$line_need_count;
print $snp_ms."\t"."$snp_f"."\t$match_fre\t$ratio\t$youli\t$ave_dad\t$ave_mom\t$ave_son\t$all\t$all_1\t$possible_daiyun\t$possible_daiyun2\t$possible_normal\n";
