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
unless @ARGV>=1;

########################

my $in;
my $out;
my $mom;
my $son;
my $dad;
my $min;
my $ref;
my $rate;
Getopt::Long::GetOptions (
   'i=s' => \$in,
   'o=s' => \$out,
   'm:i' => \$mom,
   's:i' => \$son,
   "f:i" => \$dad,
   "d:i" => \$min,
   "r:f"=> \$rate,
   
);


open IN, "<$in"
     or die "Cannot open file $in!\n";   
open OUT, ">$out"
     or die "Cannot open file $out!\n";

my %len = (
"D1S1646"=>"D1S1646",
"D1GATA113"=>"D1GATA113",
"D1S552"=>"D1S552",
"D1S1598"=>"D1S1598",
"D1S2134"=>"D1S2134",
"D1S3734"=>"D1S3734",
"D1S1162"=>"D1S1162",
"D1S3733"=>"D1S3733",
"D1GATA133A08"=>"GATA133A08",
"D1S1600"=>"D1S1600",
"D1S1679"=>"D1S1679",
"D1S1677"=>"D1S1677",
"D1S518"=>"D1S518",
"D1S1667"=>"D1S1667",
"D1S1656"=>"D1S1656",
"D1S1171"=>"D1S1171",
"D2TPOX"=>"TPOX",
"D2S2952"=>"D2S2952",
"D2S1360"=>"D2S1360",
"D2S405"=>"D2S405",
"D2S441"=>"D2S441",
"D2S2970"=>"D2S2970",
"D2S1379"=>"D2S1379",
"D2S1776"=>"D2S1776",
"D2S426"=>"D2S426",
"D2S1338"=>"D2S1338",
"D2S424"=>"D2S424",
"D2S1363"=>"D2S1363",
"D2S427"=>"D2S427",
"D3S2432"=>"D3S2432",
"D3S1768"=>"D3S1768",
"D3S1358"=>"D3S1358",
"D3S2452"=>"D3S2452",
"D3S2388"=>"D3S2388",
"D3S4529"=>"D3S4529",
"D3S3045"=>"D3S3045",
"D3S1744"=>"D3S1744",
"D3S3053"=>"D3S3053",
"D3S3041"=>"D3S3041",
"D4S2366"=>"D4S2366",
"D4S2408"=>"D4S2408",
"D4S2632"=>"D4S2632",
"D4S3251"=>"D4S3251",
"D4S2404"=>"D4S2404",
"D4S2364"=>"D4S2364",
"D4S1628"=>"D4S1628",
"D4S2634"=>"D4S2634",
"D4S3250"=>"D4S3250",
"D4S1644"=>"D4S1644",
"D4FGA"=>"FGA",
"D4S1629"=>"D4S1629",
"D4S2368"=>"D4S2368",
"D5S1492"=>"D5S1492",
"D5S2845"=>"D5S2845",
"D5S2856"=>"D5S2856",
"D5S1457"=>"D5S1457",
"D5S2500"=>"D5S2500",
"D5S1474"=>"D5S1474",
"D5S2499"=>"D5S2499",
"D5S818"=>"D5S818",
"D5CSF1PO"=>"CSF1PO",
"D5S820"=>"D5S820",
"D5S1471"=>"D5S1471",
"D6S477"=>"D6S477",
"D6S2439"=>"D6S2439",
"D6S1017"=>"D6S1017",
"D6S1960"=>"D6S1960",
"D6S1275"=>"D6S1275",
"D6S1052"=>"D6S1052",
"D6S1043"=>"D6S1043",
"D6S474"=>"D6S474",
"D6S2409"=>"D6S2409",
"D6S2436"=>"D6S2436",
"D6S1027"=>"D6S1027",
"D7S2201"=>"D7S2201",
"D7S3047"=>"D7S3047",
"D7S3048"=>"D7S3048",
"D7S1821"=>"D7S1821",
"D7S817"=>"D7S817",
"D7S1818"=>"D7S1818",
"D7S3069"=>"D7S3069",
"D7S820"=>"D7S820",
"D7S1820"=>"D7S1820",
"D7S1799"=>"D7S1799",
"D7S3052"=>"D7S3052",
"D7S3054"=>"D7S3054",
"D7S3070"=>"D7S3070",
"D8S1106"=>"D8S1106",
"D8S1145"=>"D8S1145",
"D8S1477"=>"D8S1477",
"D8S1104"=>"D8S1104",
"D8S2332"=>"D8S2332",
"D8S1105"=>"D8S1105",
"D8GAAT1A4"=>"GAAT1A4",
"D8S1132"=>"D8S1132",
"D8S592"=>"D8S592",
"D8S1179"=>"D8S1179",
"D9S2169"=>"D9S2169",
"D9S2156"=>"D9S2156",
"D9S921"=>"D9S921",
"D9S1121"=>"D9S1121",
"D9S2154"=>"D9S2154",
"D9S319"=>"D9S319",
"D9S1118"=>"D9S1118",
"D9S304"=>"D9S304",
"D9S2148"=>"D9S2148",
"D9S1122"=>"D9S1122",
"D9S2128"=>"D9S2128",
"D9S2145"=>"D9S2145",
"D10S1435"=>"D10S1435",
"D10S1430"=>"D10S1430",
"D10S2474"=>"D10S2474",
"D10S1426"=>"D10S1426",
"D10S1428"=>"D10S1428",
"D10S1432"=>"D10S1432",
"D10S2327"=>"D10S2327",
"D10S1246"=>"D10S1246",
"D10S1425"=>"D10S1425",
"D10S1248"=>"D10S1248",
"D10S2325"=>"D10S2325",
"D11TH01"=>"TH01",
"D11S1999"=>"D11S1999",
"D11S1981"=>"D11S1981",
"D11S2368"=>"D11S2368",
"D11S2364"=>"D11S2364",
"D11S1392"=>"D11S1392",
"D11S1393"=>"D11S1393",
"D11S2363"=>"D11S2363",
"D11S4960"=>"D11S4960",
"D11S1367"=>"D11S1367",
"D11S4951"=>"D11S4951",
"D11S1998"=>"D11S1998",
"D11S4463"=>"D11S4463",
"D12S374"=>"D12S374",
"D12vWA"=>"vWA",
"D12S391"=>"D12S391",
"D12S1057"=>"D12S1057",
"D12S2080"=>"D12S2080",
"D12S1301"=>"D12S1301",
"D12S1056"=>"D12S1056",
"D12S375"=>"D12S375",
"D12S1297"=>"D12S1297",
"D12S1064"=>"D12S1064",
"D12S1030"=>"D12S1030",
"D12S1023"=>"D12S1023",
"D12S378"=>"D12S378",
"D13S243"=>"D13S243",
"D13S1493"=>"D13S1493",
"D13S325"=>"D13S325",
"D13S1492"=>"D13S1492",
"D13S801"=>"D13S801",
"D13S1824"=>"D13S1824",
"D13S792"=>"D13S792",
"D13S317"=>"D13S317",
"D13S790"=>"D13S790",
"D13S793"=>"D13S793",
"D13S796"=>"D13S796",
"D14S742"=>"D14S742",
"D14S1280"=>"D14S1280",
"D14S608"=>"D14S608",
"D14S741"=>"D14S741",
"D14S1432"=>"D14S1432",
"D14S748"=>"D14S748",
"D14S747"=>"D14S747",
"D14S745"=>"D14S745",
"D14S125"=>"D14S125",
"D14S588"=>"D14S588",
"D14S126"=>"D14S126",
"D14S1434"=>"D14S1434",
"D14S1426"=>"D14S1426",
"D15S817"=>"D15S817",
"D15S1513"=>"D15S1513",
"D15S822"=>"D15S822",
"D15S1232"=>"D15S1232",
"D15S659"=>"D15S659",
"D15GATA153F11"=>"GATA153F11",
"D15S1507"=>"D15S1507",
"D15S1514"=>"D15S1514",
"D15PentaE"=>"PentaE",
"D15S642"=>"D15S642",
"D16S2622"=>"D16S2622",
"D16S2619"=>"D16S2619",
"D16S769"=>"D16S769",
"D16S3396"=>"D16S3396",
"D16S3253"=>"D16S3253",
"D16S3393"=>"D16S3393",
"D16S752"=>"D16S752",
"D16S2624"=>"D16S2624",
"D16S2625"=>"D16S2625",
"D16S539"=>"D16S539",
"D17GATA158H04"=>"GATA158H04",
"D17S974"=>"D17S974",
"D17AC001348A"=>"AC001348A",
"D17S2196"=>"D17S2196",
"D17S1294"=>"D17S1294",
"D17S1299"=>"D17S1299",
"D17S1290"=>"D17S1290",
"D17S2182"=>"D17S2182",
"D17S1535"=>"D17S1535",
"D17S1301"=>"D17S1301",
"D18S976"=>"D18S976",
"D18S869"=>"D18S869",
"D18S866"=>"D18S866",
"D18S536"=>"D18S536",
"D18S535"=>"D18S535",
"D18S972"=>"D18S972",
"D18S548"=>"D18S548",
"D18S51"=>"D18S51",
"D18S1367"=>"D18S1367",
"D18S1358"=>"D18S1358",
"D18S870"=>"D18S870",
"D19S591"=>"D19S591",
"D19S1165"=>"D19S1165",
"D19S253"=>"D19S253",
"D19S593"=>"D19S593",
"D19S1036"=>"D19S1036",
"D19S433"=>"D19S433",
"D19S1170"=>"D19S1170",
"D19S719"=>"D19S719",
"D19S400"=>"D19S400",
"D20S604"=>"D20S604",
"D20S161"=>"D20S161",
"D20S1145"=>"D20S1145",
"D20S607"=>"D20S607",
"D20S481"=>"D20S481",
"D20S480"=>"D20S480",
"D20S469"=>"D20S469",
"D20S430"=>"D20S430",
"D20S482"=>"D20S482",
"D21S1432"=>"D21S1432",
"D21S1437"=>"D21S1437",
"D21S1409"=>"D21S1409",
"D21S1435"=>"D21S1435",
"D21S1442"=>"D21S1442",
"D21S226"=>"D21S226",
"D21S1413"=>"D21S1413",
"D21PentaD"=>"PentaD",
"D21S1446"=>"D21S1446",
"D22GATA198B05"=>"D22-GATA198B05",
"D22S686"=>"D22S686",
"D22S533"=>"D22S533",
"D22S691"=>"D22S691",
"D22S1265"=>"D22S1265",
"D22S692"=>"D22S692",
"D22S1045"=>"D22S1045",
"D22S534"=>"D22S534",
"D22S444"=>"D22S444",
"DXS6807"=>"DXS6807",
"DXS9895"=>"DXS9895",
"DXS8378"=>"DXS8378",
"DXS9902"=>"DXS9902",
"DXS6810"=>"DXS6810",
"DXS7132"=>"DXS7132",
"DXS10075"=>"DXS10075",
"DXS6803"=>"DXS6803",
"DXS9898"=>"DXS9898",
"DXS6789"=>"DXS6789",
"DXS7133"=>"DXS7133",
"DXGATA172D05"=>"GATA172D05",
"DXS7130"=>"DXS7130",
"DXGATA165B12"=>"GATA165B12",
"DXHPRTB"=>"HPRTB",
"DXS7423"=>"DXS7423",
"DYS393"=>"DYS393",
"DYS446"=>"DYS446",
"DYS456"=>"DYS456",
"DYS570"=>"DYS570",
"DYS576"=>"DYS576",
"DYS522"=>"DYS522",
"DYS443"=>"DYS443",
"DYS458"=>"DYS458",
"DYS391"=>"DYS391",
"DYS635"=>"DYS635",
"DYS439"=>"DYS439",
"DYS438"=>"DYS438",
"DYS641"=>"DYS641",
"DYS643"=>"DYS643",
"DYS513"=>"DYS513",
"DYS533"=>"DYS533",
"DYGATAA10"=>"Y-GATA-A10",
"DYGATAH4"=>"Y-GATA-H4",
"DYS461"=>"DYS461",
"DYS460"=>"DYS460",
"DYS445"=>"DYS445",
);
my @son_ty;
my $son1;
my $mom_dad1;
my $mom_dad2;
my $mom_dad3;
my %hash1;
my $son_ty1;
my $son_ty2;
my $son_ty3;
my %hash2;
my @line3="";
my @son_var1 ="";
my @son_var3 ="";
my @mom_var1 ="";
my @mom_var3 ="";
my @dad_var1 = "";
my @dad_var3 = "";
$header = "chr\tpos\tdad_type\tpos\tmom_type\tpos\tson_type\tSTR\tdad_type\tmom_type\tson_type\tM1M1\tM1M2\tP1P1\tP1P2\tM1P1\tM1/M2\tP1/P2\n";
print "$header";
while(<IN>) {
 chomp;
 $line=$_;
 
 if(substr($line,0,2)ne"##" ) {
  $line_count++;
  my @line=split/\t/,$line;
  if($line[0]=~/^\D[0-9]+/){
  $line[0]=~/^\D[0-9]+/;
   $chr = $&;
  }
  elsif ($line[0]=~'DX'){
  $chr = 'DX';
  }
  #print "$chr\n";
  #$hash4{$chr}++;
  push @line,0;
  #print "dad\tmom\tson\tson_from_dm\tson_from_dad\tson_from_mom\tson_off_dm\n";
  my @mom=split/\//,$line[$mom];
  my @son=split/\//,$line[$son];
  my @dad=split/\//,$line[$dad];
  if($line_count>=1 ) {
  #my @mom_var=split/\,/,$mom[3];
      foreach $each_mom(@mom) {
		if( $line[$mom] eq 'NA' or $line[$mom] eq "" or $line[$mom] eq 'F'){
		$sum_mom=0;}
		else {
          my @mom_var=split/\|/,$each_mom;
          if ($mom_var[0] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$mom_var[0]);
                 shift @sum_type;
                 $mom_var3 = join("\+",@sum_type);
		 $mom_var_type = $mom_var3;
		 $mom_var_type =~ s/\([A-Z]+\)//g;
		 push @mom_var3,$mom_var_type;
                 push @mom_var1,$mom_var3;
                 push @mom_var2,$mom_var[2];
                 }
                 else {
				$mom_var_type = $mom_var[0];
				$mom_var_type =~ s/\([A-Z]+\)//g;
				push @mom_var3,$mom_var_type;
				push @mom_var1,$mom_var[0];
				push @mom_var2,$mom_var[2];
				}
		$hashmom{$line[$mom-1].'_'.$mom_var[0]}=$mom_var[1];
		$sum_mom+=$mom_var[1];}}
      foreach $each_son(@son) {
		if( $line[$son] eq 'NA' or $line[$son] eq "" or $line[$son] eq 'F'){
			$sum_son=0;}
		else {
			my @son_var=split/\|/,$each_son;
			if ($son_var[0] =~ /[0-9]\(/ ){
				@sum_type = split(/\D+/,$son_var[0]);
				shift @sum_type;
				$son_var3=join("\+",@sum_type);
				$son_var_type = $son_var3;
				$son_var_type =~ s/\([A-Z]+\)//g;
				push @son_var3,$son_var_type;
				push @son_var1,$son_var3;
				push @son_var2,$son_var[2];
			}
			else {
				$son_var_type = $son_var[0];
				$son_var_type =~ s/\([A-Z]+\)//g;
				push @son_var3,$son_var_type; 	
				push @son_var1,$son_var[0];
				push @son_var2,$son_var[2];
			}
         $hashson{$line[$son-1].'_'.$son_var[0]}=$son_var[1];
	     $hashson1{$son_var[0]}=$son_var[2];
         $sum_son+=$son_var[1];}}
		shift @son_var1;
		shift @son_var3;
		#@son_var3 = @son_var1;
		$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1]}=1;
		$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1]}=1;
		$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1]}=1;
		$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1]}=1;
		$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1]}=1;
		$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1]}=1;
		$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1]}=1;
		$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1]}=1;
		$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1]}=1;
		$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1]}=1;
		$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1]}=1;
		$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1]}=1;
		$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1]}=1;
		$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1]}=1;
		$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1]}=1;
		$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1]}=1;
		@son_var1="";
     foreach $each_dad(@dad){
		if( $line[$dad] eq 'NA' or $line[$dad] eq "" or $line[$dad] eq 'F'){
			$sum_dad=0;}
		else {
         	my @dad_var=split/\|/,$each_dad;
			if ($dad_var[0]=~ /[0-9]\(/ ){
				@sum_type = split(/\D+/,$dad_var[0]);
				shift @sum_type;
				$dad_var3 = join("\+",@sum_type);
				$dad_var_type = $dad_var3;
				$dad_var_type =~ s/\([A-Z]+\)//g;
				push @dad_var3,$dad_var_type;
				push @dad_var1,$dad_var3;
				push @dad_var2,$dad_var[2];
			}
			else {
				$dad_var_type = $dad_var[0];
				$dad_var_type =~ s/\([A-Z]+\)//g;
				push @dad_var3,$dad_var_type;
				push @dad_var1,$dad_var[0];
				push @dad_var2,$dad_var[2];
			}
            $hashdad{$line[$dad-1].'_'.$dad_var[0]}=$dad_var[1];
			#print "$line[$dad-1]".'_'."$dad_var[0]\n";
			$hashdad1{$dad_var[0]}=$each_dad;
            $sum_dad+=$dad_var[1];}}
			shift @mom_var1;
			shift @mom_var3;
			shift @dad_var1;
			shift @dad_var3;
			my @mom_dad = (M1.'_'.$mom_var1[0],M2.'_'.$mom_var1[1],P1.'_'.$dad_var1[0],P2.'_'.$dad_var1[1]);
			#print "@mom_dad\n";
			@mom_var1 ="";
			@dad_var1="";
			foreach $mom_dad1(@mom_dad) {
				foreach $mom_dad2(@mom_dad) {
					$hash1{$mom_dad1.'|'.$mom_dad2}=1;
				}
			}
			if($sum_dad>50 and $sum_mom>=50 and $sum_son> 50) {
				$hash4{$chr}++;
				foreach (keys %hash) {
					if (exists $hash1{$_}) {
					#print $_."\n";
					my @line1 = split (/\|/,$_);
						foreach $line1(@line1){
							my @line2 = split (/\_/,$line1);
							push @line3,$line2[0];
						}
						shift @line3;
						my $line3 = join ("",@line3);
						
						#print $line3."\n";
						$hash3{$line3}++;
						@line3 ="";
					}
				}
				$ran = $chr;
				$ran =~ s/D/Chr/;
				$son_var3_type = join("\/",@son_var3);
				$mom_var1_type =  join("\/",@mom_var3);
				$dad_var1_type = join("\/",@dad_var3);
				#print "$dad_var1_type\t$mom_var1_type\t$son_var3_type\n";
				print "$ran\t$line\t$len{$line[0]}\t$dad_var1_type\t$mom_var1_type\t$son_var3_type\t";
				@son_var3="";
				@mom_var3="";
				@dad_var3="";
			if (exists ($hash3{M1M1}) or exists ($hash3{M2M2} )) {
				push $result_p,"yes\t";
				$hash5{$chr.'_'.M1M1}++;
				#print $chr.'_'.M1M1;
			}
			if (!exists ($hash3{M1M1}) and !exists($hash3{M2M2})) {
				push $result_p,"NO\t";
			}
			if (exists ($hash3{M1M2}) or exists ($hash3{M2M1} )) {
				push $result_p,"yes\t";
				$hash5{$chr.'_'.M1M2}++;
			}
			if (!exists ($hash3{M1M2}) and !exists($hash3{M2M1})) {
				push $result_p,"NO\t";
			}
			if (exists ($hash3{P1P1}) or exists ($hash3{P2P2} )) {
				push $result_p,"yes\t";
				$hash5{$chr.'_'.P1P1}++;
			}
			if (!exists ($hash3{P1P1}) and !exists($hash3{P2P2})) {
				push $result_p, "NO\t";
			}
			if (exists ($hash3{P1P2}) or exists ($hash3{P2P1} )) {
				push $result_p,"yes\t";
				$hash5{$chr.'_'.P1P2}++;
			}
			if (!exists ($hash3{P1P2}) and !exists($hash3{P2P1})) {
				push $result_p,"NO\t";
			}
			if (exists ($hash3{M1P1}) or exists ($hash3{M1P2}) or exists ($hash3{M2P1}) or exists ($hash3{M2P2}) or exists ($hash3{P1M1}) or  exists ($hash3{P1M2}) or  exists ($hash3{P2M1}) or exists ($hash3{P2M2}) ) {
				push $result_p,"yes\t";
				$hash5{$chr.'_'.M1P1}++;
			}
			if (!exists ($hash3{M1P1}) and !exists ($hash3{M1P2}) and !exists ($hash3{M2P1}) and !exists ($hash3{M2P2}) and !exists ($hash3{P1M1}) and  !exists ($hash3{P1M2}) and  !exists ($hash3{P2M1}) and !exists ($hash3{P2M2})){
				push $result_p,"NO\t";
			}
			if (exists ($hash3{M1M1}) or exists ($hash3{M2M2} )) {
                                push $result_p,"yes\t";
			}
			if (!exists ($hash3{M1M1}) and !exists($hash3{M2M2})) {
                                push $result_p,"NO\t";
                        }
			if (exists ($hash3{P1P1}) or exists ($hash3{P2P2} )) {
                                push $result_p,"yes\t";
			}
			if (!exists ($hash3{P1P1}) and !exists($hash3{P2P2})) {
                                push $result_p,"NO\t";
                        }
			 push $result_p,"\n";
		}
			$sum_dad=0;
			$sum_mom=0;
			$sum_son=0;
			%hash="";
			%hash1="";
			%hash2="";
			%hash3="";
                        @son_var3="";
                        @mom_var3="";
                        @dad_var3="";
		
  }
 }
}
$header1 = "chr\tnum\tM1M1\tM1M2\tM1P1\tP1P1\tP1P2\tM1/M2\tP1/P2\n";
print "$header1";
foreach $chr1(sort {(split /D/,$a)[1] <=> (split /D/,$b)[1]} keys %hash4) {
	if($chr1 ne "" and $chr1 ne "DX") {
		$chr_2 = $chr1;
		$chr_2 =~ s/D/Chr/;
		print "$chr_2\t$hash4{$chr1}\t";
		$hash_all +=  $hash4{$chr1};
		$hash_M1M1 += $hash5{$chr1.'_'.M1M1};
		$hash_M1M2 += $hash5{$chr1.'_'.M1M2};
		$hash_M1P1 += $hash5{$chr1.'_'.M1P1};
		$hash_P1P1 += $hash5{$chr1.'_'.P1P1};
		$hash_P1P2 += $hash5{$chr1.'_'.P1P2};
		$rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1}/$hash4{$chr1})*100 .'%';
		$rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2}/$hash4{$chr1})*100 .'%';
		$rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1P1}/$hash4{$chr1})*100 .'%';
		$rate4 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1}/$hash4{$chr1})*100 .'%';
		$rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2}/$hash4{$chr1})*100 .'%';
		print "$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate1\t$rate4\n";
	}
	if($chr1 eq 'DX') {
                #$hash_all +=  $hash4{$chr1};
                #$hash_M1M1 += $hash5{$chr1.'_'.M1M1};
                #$hash_M1M2 += $hash5{$chr1.'_'.M1M2};
                #$hash_M1P1 += $hash5{$chr1.'_'.M1P1};
                #$hash_P1P1 += $hash5{$chr1.'_'.P1P1};
                #$hash_P1P2 += $hash5{$chr1.'_'.P1P2};
		$rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1}/$hash4{$chr1})*100 .'%';
                $rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2}/$hash4{$chr1})*100 .'%';
                $rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1P1}/$hash4{$chr1})*100 .'%';
                $rate4 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1}/$hash4{$chr1})*100 .'%';
                $rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2}/$hash4{$chr1})*100 .'%';
		$chrX = "ChrX\t$hash4{$chr1}\t$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate1\t$rate4\n";
	}
}
$rate_M1M1 = sprintf("%.2f",$hash_M1M1/$hash_all)*100 .'%';
$rate_M1M2 = sprintf("%.2f",$hash_M1M2/$hash_all)*100 .'%';
$rate_M1P1 = sprintf("%.2f",$hash_M1P1/$hash_all)*100 .'%';
$rate_P1P1 = sprintf("%.2f",$hash_P1P1/$hash_all)*100 .'%';
$rate_P1P2 = sprintf("%.2f",$hash_P1P2/$hash_all)*100 .'%';	
print '总计'."\t$hash_all\t".$rate_M1M1."\t".$rate_M1M2."\t".$rate_M1P1."\t".$rate_P1P1."\t".$rate_P1P2."\n$header1$chrX";
	
