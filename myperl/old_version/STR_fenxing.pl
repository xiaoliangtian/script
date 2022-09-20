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
my @son_off_dm="";
my @son_from_dad="";
my %hashson1;
my @son_from_dm="";
my @son_from_mom="";
my @son_from_dm1="";
my @son_from_dad1="";
my @son_from_mom1="";
my @son_off_dm1="";
my @mom_var1="";
my @mom_var2="";
my @son_var1="";
my @son_var2="";
my @dad_var1="";
my @dad_var2="";
my @sum_type;
my $dad_type2;
my $mom_var3;
my $son_var3;
my $dad_var3; 

print "pos\tdad_genotype\tdad_frequency\tmom_genotype\tmom_frequency\tson_genotype\tson_frequency\tson_from_dm\tson_from_dm%\tson_from_dad\tson_from_dad%\tson_from_mom\tson_from_mom%\tson_off_dm\tson_off_dm\n";
while(<IN>) {
 chomp;
 $line=$_;
 
 if(substr($line,0,2)ne"##" ) {
  $line_count++;
  my @line=split/\t/,$line;
  push @line,0;
  #print "dad\tmom\tson\tson_from_dm\tson_from_dad\tson_from_mom\tson_off_dm\n";
  my @mom=split/\//,$line[$mom];
  my @son=split/\//,$line[$son];
  my @dad=split/\//,$line[$dad];
  if($line_count>=1 ) {
  #my @mom_var=split/\,/,$mom[3];
      foreach $each_mom(@mom) {
		if( $line[$mom] eq 'NA' or $line[$mom] eq ""){
		$sum_mom=0;}
		else {
          my @mom_var=split/\|/,$each_mom;
          if ($mom_var[0] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$mom_var[0]);
                 shift @sum_type;
                 $mom_var3 = join("\+",@sum_type);
                 push @mom_var1,$mom_var3;
                 push @mom_var2,$mom_var[2];
                 }
                 else {
	  push @mom_var1,$mom_var[0];
	  push @mom_var2,$mom_var[2];
          }
          $hashmom{$line[$mom-1].'_'.$mom_var[0]}=$mom_var[1];
          $sum_mom+=$mom_var[1];}}
      foreach $each_son(@son) {
		if( $line[$son] eq 'NA' or $line[$son] eq ""){
		$sum_son=0;}
		else {
          my @son_var=split/\|/,$each_son;
	  if ($son_var[0] =~ /[0-9]\(/ ){
		@sum_type = split(/\D+/,$son_var[0]);
		shift @sum_type;
		$son_var3=join("\+",@sum_type);
		push @son_var1,$son_var3;
		push @son_var2,$son_var[2];
		}
		else {
	  push @son_var1,$son_var[0];
	  push @son_var2,$son_var[2];
		}
             $hashson{$line[$son-1].'_'.$son_var[0]}=$son_var[1];
	     $hashson1{$son_var[0]}=$son_var[2];
             $sum_son+=$son_var[1];}}
     foreach $each_dad(@dad){
		if( $line[$dad] eq 'NA' or $line[$dad] eq ""){
		$sum_dad=0;}
		else {
         my @dad_var=split/\|/,$each_dad;
		if ($dad_var[0]=~ /[0-9]\(/ ){
		@sum_type = split(/\D+/,$dad_var[0]);
		shift @sum_type;
		$dad_var3 = join("\+",@sum_type);
		push @dad_var1,$dad_var3;
		push @dad_var2,$dad_var[2];
		}
		else {
	 push @dad_var1,$dad_var[0];
	 push @dad_var2,$dad_var[2];
		}
            $hashdad{$line[$dad-1].'_'.$dad_var[0]}=$dad_var[1];
	    $hashdad1{$dad_var[0]}=$each_dad;
            $sum_dad+=$dad_var[1];}}
         #print "$line[0]\t$sum_dad\t$sum_mom\t$sum_son\n";
if($sum_son > 50 and $sum_mom >= 50 and $sum_dad > 50) {
     foreach $dad_type(keys %hashson) {
             #$dad_type_rate= $hashdad{$dad_type}/$sum_dad;
             #@sum_type=split(/\D+/,$mom_type);
	     my @dad_type = split(/\_/,$dad_type);
             if (exists $hashdad{$dad_type} and exists $hashmom{$dad_type} and $dad_type ne "") {
		 #print "@son_from_dad"."1\n";
		 if ($dad_type[1] =~ /[0-9]\(/ ){
		 @sum_type = split(/\D+/,$dad_type[1]);
		 shift @sum_type;
		 $dad_type2 = join("\+",@sum_type);
		 push @son_from_dm,$dad_type2;
		 push @son_from_dm1,$hashson1{$dad_type[1]};
		 }
		 else {
		 push  @son_from_dm,$dad_type[1];
                 push  @son_from_dm1,$hashson1{$dad_type[1]};
                 }}
	     if (exists $hashdad{$dad_type} and (!exists $hashmom{$dad_type}) and $dad_type ne "") {
		if ($dad_type[1] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$dad_type[1]);
		 shift @sum_type;
                 $dad_type2 = join("\+",@sum_type);
                 push @son_from_dm,$dad_type2;
                 push @son_from_dm1,$hashson1{$dad_type[1]};
                 }
                 else {
		push  @son_from_dad,$dad_type[1];
		push  @son_from_dad1,$hashson1{$dad_type[1]};
		}}
	     if ((!exists $hashdad{$dad_type}) and exists $hashmom{$dad_type} and $dad_type ne "") {
		if ($dad_type[1] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$dad_type[1]);
		 shift @sum_type;
                 $dad_type2 = join("\+",@sum_type);
                 push @son_from_dm,$dad_type2;
                 push @son_from_dm1,$hashson1{$dad_type[1]};
                 }
                 else {
		push  @son_from_mom,$dad_type[1];
		push  @son_from_mom1,$hashson1{$dad_type[1]};
		}}
             elsif ((!exists $hashdad{$dad_type}) and (!exists $hashmom{$dad_type})and $dad_type ne "") {
		 if ($dad_type[1] =~ /[0-9]\(/ ){
                 @sum_type = split(/\D+/,$dad_type[1]);
		 shift @sum_type;
                 $dad_type2 = join("\+",@sum_type);
                 push @son_from_dm,$dad_type2;
                 push @son_from_dm1,$hashson1{$dad_type[1]};
                 }
                 else {
		 push @son_off_dm,$dad_type[1];
		 push @son_off_dm1,$hashson1{$dad_type[1]};
		 #print "$dad_type[1]\n";
                 }
            }}
	    #print "@son_from_dad\n";
            shift @son_from_dad;
	    shift @son_from_dm;
	    shift @son_from_mom;
		shift @son_from_dm1;
		shift @son_from_dad1;
		shift @son_from_mom1;
		shift @son_off_dm1;
		shift @mom_var1;shift @mom_var2;shift @son_var1;shift @son_var2;shift @dad_var1;shift @dad_var2;
	    #shift @son_from_dad;
	    #print "@son_from_dad\n";
            shift @son_off_dm;
	    #print "@son_off_dad\n";
	    $son_from_dm = join("\/",@son_from_dm);
	    $son_from_dad = join("\/",@son_from_dad);
	    $son_from_mom = join("\/",@son_from_mom);
	    $son_off_dm = join("\/",@son_off_dm);
		$mom_var1 = join("\/",@mom_var1);
		$mom_var2 = join("\|",@mom_var2);
		$son_var1 = join("\/",@son_var1);
		$son_var2 = join("\|",@son_var2);
		$dad_var1 = join("\/",@dad_var1);
		$dad_var2 = join("\|",@dad_var2);
		$son_from_dm1 = join("\|",@son_from_dm1);
		$son_from_dad1 = join("\|",@son_from_dad1);
		$son_from_mom1 = join("\|",@son_from_mom1);
		$son_off_dm1 = join("\|",@son_off_dm1);
		#$son_from_dm =~s/[0-9]\(/\[0-9]\+(/g;
		if ($son_from_dm ne "") {
		$son_from_dm =~s/\([A-Z]+\)//g;
		}
		else {
			$son_from_dm = '-';
			$son_from_dm1 = '-';
		}
		if ($son_from_dad ne "") {
		$son_from_dad =~s/\([A-Z]+\)//g;
		}
		else {
			$son_from_dad = '-';
			$son_from_dad1 = '-';
		}
		if ($son_from_mom ne "") {
		$son_from_mom =~s/\([A-Z]+\)//g;
		}
		else {
			$son_from_mom ='-';
			$son_from_mom1 = '-';
		}
		if ($son_off_dm ne "") {
		$son_off_dm =~s/\([A-Z]+\)//g;
		}
		else {
			$son_off_dm ='-';
			$son_off_dm1 = '-';
		}
		$mom_var1 =~s/\([A-Z]+\)//g;
		$son_var1 =~s/\([A-Z]+\)//g;
		$dad_var1 =~s/\([A-Z]+\)//g;
		print "$len{$line[0]}\t$dad_var1\t$dad_var2\t$mom_var1\t$mom_var2\t$son_var1\t$son_var2\t$son_from_dm\t$son_from_dm1\t$son_from_dad\t$son_from_dad1\t$son_from_mom\t$son_from_mom1\t$son_off_dm\t$son_off_dm1\t\n";
	   # print "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\t$son_from_dm\t$son_from_dad\t$son_from_mom\t$son_off_dm\n";
}
else {
	#print "$line[0]\t$line[$dad]\t$line[$mom]\t$line[$son]\t0\t0\t0\t0\n";
}
      %hashson="";
      %hashmom="";
      %hashdad="";
      %hashson1="";
      $sum_son=0;
      $sum_mom=0;
      $sum_dad=0;
      @son_off_dm="";
      @son_from_dad="";
	@son_from_dm="";
	@son_from_mom="";
	@son_from_dm1="";
	@son_from_dad1="";
	@son_from_mom1="";
	@son_off_dm1="";
	@mom_var1="";
	@mom_var2="";
	@son_var1="";
	@son_var2="";
	@dad_var1="";
	@dad_var2="";
}}}
 
