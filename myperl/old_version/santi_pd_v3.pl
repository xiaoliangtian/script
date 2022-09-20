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

my @son_ty;
my $son1;
my $mom_dad1;
my $mom_dad2;
my $mom_dad3;
my %hash1;
my $son_ty1;
my $son_ty2;
my $son_ty3;
my %hash;
my @line3="";
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
my %len1 = (
"D1S1646"=>7142447,
"D1GATA113"=>7442839,
"D1S552"=>19267010,
"D1S1598"=>40342165,
"D1S2134"=>48281445,
"D1S3734"=>59730337,
"D1S1162"=>69446685,
"D1S3733"=>78919633,
"GATA133A08"=>106281516,
"D1S1600"=>157786535,
"D1S1679"=>162361920,
"D1S1677"=>163559764,
"D1S518"=>187550320,
"D1S1667"=>212770725,
"D1S1656"=>230905305,
"D1S1171"=>201917408,
"TPOX"=>1493382,
"D2S2952"=>8078043,
"D2S1360"=>17491948,
"D2S405"=>29476650,
"D2S441"=>68239020,
"D2S2970"=>118948509,
"D2S1379"=>167871887,
"D2S1776"=>169645364,
"D2S426"=>190353767,
"D2S1338"=>218879557,
"D2S424"=>221348529,
"D2S1363"=>227029642,
"D2S427"=>232206290,
"D3S2432"=>32165234,
"D3S1768"=>34624371,
"D3S1358"=>45582205,
"D3S2452"=>58698719,
"D3S2388"=>83164154,
"D3S4529"=>85852595,
"D3S3045"=>106989954,
"D3S1744"=>147092515,
"D3S3053"=>171750910,
"D3S3041"=>176480240,
"D4S2366"=>6484786,
"D4S2408"=>31304387,
"D4S2632"=>35704143,
"D4S3251"=>44549291,
"D4S2404"=>93499833,
"D4S2364"=>93517332,
"D4S1628"=>98286441,
"D4S2634"=>100077923,
"D4S3250"=>123917675,
"D4S1644"=>141751514,
"FGA"=>155508848,
"D4S1629"=>158336798,
"D4S2368"=>168716312,
"D5S1492"=>3712689,
"D5S2845"=>22390658,
"D5S2856"=>41033833,
"D5S1457"=>41033842,
"D5S2500"=>58697226,
"D5S1474"=>61309943,
"D5S2499"=>91436222,
"D5S818"=>123111199,
"CSF1PO"=>149455853,
"D5S820"=>156122463,
"D5S1471"=>166876475,
"D6S477"=>6140593,
"D6S2439"=>24306691,
"D6S1017"=>41677249,
"D6S1960"=>53504592,
"D6S1275"=>67241947,
"D6S1052"=>81486035,
"D6S1043"=>92449904,
"D6S474"=>112879114,
"D6S2409"=>134647481,
"D6S2436"=>154136248,
"D6S1027"=>169209350,
"D7S2201"=>5630653,
"D7S3047"=>9474975,
"D7S3048"=>21266669,
"D7S1821"=>25124716,
"D7S817"=>32136402,
"D7S1818"=>49388903,
"D7S3069"=>52281862,
"D7S820"=>83789493,
"D7S1820"=>93353800,
"D7S1799"=>104195034,
"D7S3052"=>109381517,
"D7S3054"=>130859683,
"D7S3070"=>151567167,
"D8S1106"=>12835975,
"D8S1145"=>18352534,
"D8S1477"=>32067178,
"D8S1104"=>40643903,
"D8S2332"=>56130232,
"D8S1105"=>78848710,
"GAAT1A4"=>99189776,
"D8S1132"=>107328873,
"D8S592"=>118456153,
"D8S1179"=>125907064,
"D9S2169"=>5200458,
"D9S2156"=>7929020,
"D9S921"=>10509435,
"D9S1121"=>25403090,
"D9S2154"=>26171207,
"D9S319"=>29559723,
"D9S1118"=>31925336,
"D9S304"=>32324022,
"D9S2148"=>38295702,
"D9S1122"=>79688692,
"D9S2128"=>113526802,
"D9S2145"=>121416643,
"D10S1435"=>2243283,
"D10S1430"=>12736989,
"D10S2474"=>19437961,
"D10S1426"=>30495804,
"D10S1428"=>66817471,
"D10S1432"=>74659404,
"D10S2327"=>80712056,
"D10S1246"=>110951330,
"D10S1425"=>119340176,
"D10S1248"=>131092467,
"D10S2325"=>12793017,
"TH01"=>2192229,
"D11S1999"=>10719982,
"D11S1981"=>17086211,
"D11S2368"=>19281119,
"D11S2364"=>26486780,
"D11S1392"=>34640105,
"D11S1393"=>43994935,
"D11S2363"=>59236129,
"D11S4960"=>79965503,
"D11S1367"=>88707515,
"D11S4951"=>104624579,
"D11S1998"=>117697761,
"D11S4463"=>130872367,
"D12S374"=>5966898,
"vWA"=>6093109,
"D12S391"=>12449931,
"D12S1057"=>24677223,
"D12S2080"=>33414493,
"D12S1301"=>44062641,
"D12S1056"=>60546031,
"D12S375"=>68944798,
"D12S1297"=>81425229,
"D12S1064"=>90823335,
"D12S1030"=>102924893,
"D12S1023"=>115471368,
"D12S378"=>124662987,
"D13S243"=>28288037,
"D13S1493"=>34008973,
"D13S325"=>43173403,
"D13S1492"=>55705752,
"D13S801"=>62561629,
"D13S1824"=>67256453,
"D13S792"=>75152418,
"D13S317"=>82722110,
"D13S790"=>84435329,
"D13S793"=>97951842,
"D13S796"=>107888967,
"D14S742"=>22201155,
"D14S1280"=>26655916,
"D14S608"=>28849447,
"D14S741"=>33753919,
"D14S1432"=>38581062,
"D14S748"=>48081353,
"D14S747"=>54567670,
"D14S745"=>56551653,
"D14S125"=>66378056,
"D14S588"=>70220277,
"D14S126"=>88007632,
"D14S1434"=>95308359,
"D14S1426"=>100619565,
"D15S817"=>24604264,
"D15S1513"=>26181579,
"D15S822"=>27390703,
"D15S1232"=>34982590,
"D15S659"=>46374073,
"GATA153F11"=>57434454,
"D15S1507"=>65340046,
"D15S1514"=>95554017,
"PentaE"=>97374211,
"D15S642"=>102334827,
"D16S2622"=>3709718,
"D16S2619"=>13742515,
"D16S769"=>26158770,
"D16S3396"=>51192349,
"D16S3253"=>54786660,
"D16S3393"=>64565786,
"D16S752"=>71335188,
"D16S2624"=>71735145,
"D16S2625"=>84717747,
"D16S539"=>86386261,
"GATA158H04"=>6333086,
"D17S974"=>10518696,
"AC001348A"=>14615555,
"D17S2196"=>17264497,
"D17S1294"=>28382280,
"D17S1299"=>38994414,
"D17S1290"=>56331449,
"D17S2182"=>67139931,
"D17S1535"=>72561466,
"D17S1301"=>72680936,
"D18S976"=>5248955,
"D18S869"=>20083542,
"D18S866"=>23370589,
"D18S536"=>31588294,
"D18S535"=>38148784,
"D18S972"=>41325674,
"D18S548"=>41800668,
"D18S51"=>60948870,
"D18S1367"=>64552241,
"D18S1358"=>70220655,
"D18S870"=>71012884,
"D19S591"=>3075852,
"D19S1165"=>12294333,
"D19S253"=>15728256,
"D19S593"=>17308171,
"D19S1036"=>23652926,
"D19S433"=>30417096,
"D19S1170"=>32603384,
"D19S719"=>33913938,
"D19S400"=>41527539,
"D20S604"=>12584331,
"D20S161"=>16622082,
"D20S1145"=>21612282,
"D20S607"=>38796849,
"D20S481"=>43768319,
"D20S480"=>51857220,
"D20S469"=>53638967,
"D20S430"=>56150076,
"D20S482"=>4506307,
"D21S1432"=>17343466,
"D21S1437"=>21646836,
"D21S1409"=>24348727,
"D21S1435"=>27848866,
"D21S1442"=>28818560,
"D21S226"=>31341634,
"D21S1413"=>33848142,
"PentaD"=>45056054,
"D21S1446"=>48037620,
"D22-GATA198B05"=>17650646,
"D22S686"=>23068554,
"D22S533"=>25849157,
"D22S691"=>34875760,
"D22S1265"=>35389923,
"D22S692"=>37125688,
"D22S1045"=>37536298,
"D22S534"=>40965697,
"D22S444"=>45961533,
"DXS6807"=>4743383,
"DXS9895"=>7377142,
"DXS8378"=>9370260,
"DXS9902"=>15323662,
"DXS6810"=>42918694,
"DXS7132"=>64655485,
"DXS10075"=>66998199,
"DXS6803"=>86431175,
"DXS9898"=>87796433,
"DXS6789"=>95449414,
"DXS7133"=>109041536,
"GATA172D05"=>113174977,
"DXS7130"=>118200172,
"GATA165B12"=>120877965,
"HPRTB"=>133615487,
"DXS7423"=>149710916,
"DYS393"=>3131126,
"DYS446"=>3131433,
"DYS456"=>4270897,
"DYS570"=>6861199,
"DYS576"=>7053324,
"DYS522"=>7415578,
"DYS443"=>7508307,
"DYS458"=>7867837,
"DYS391"=>14102733,
"DYS635"=>14379518,
"DYS439"=>14515277,
"DYS438"=>14937797,
"DYS641"=>16134244,
"DYS643"=>17425988,
"DYS513"=>17441719,
"DYS533"=>18393193,
"Y-GATA-A10"=>18718856,
"Y-GATA-H4"=>18743527,
"DYS461"=>21050654,
"DYS460"=>21050799,
"DYS445"=>22092579,
);

 
my $header = <IN>;
#$header =~s/\n//;
$header = "chr\tpos\tpos\tdad_type\tpos\tmom_type\tpos\tson_type\tSTR\tdad_type\tmom_type\tson_type\t".'M1M1M1'."\t"."M1M1M2\tM1M1P1\tM1M2P1\tP1P1P1\tP1P1P2\tP1P1M1\tP1P2M1\tMMM\tMMP\tPPP\tPPM\n";
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
		$sum_mom=0;
		$sum_mom_rate=0;}
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
		$sum_mom+=$mom_var[1];
		$sum_mom_rate += $mom_var[2];
		}}
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
	$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{M2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P1.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.M2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P1.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.M2.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P1.'_'.$son_var1[2]}=1;
$hash{P2.'_'.$son_var1[0].'|'.P2.'_'.$son_var1[1].'|'.P2.'_'.$son_var1[2]}=1;


@son_var1="";
     foreach $each_dad(@dad){
		if( $line[$dad] eq 'NA' or $line[$dad] eq "" or $line[$dad] eq 'F'){
			$sum_dad=0;
			$sum_dad_rate = 0;}
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
            		$sum_dad+=$dad_var[1];
			$sum_dad_rate += $dad_var[2];
			}}
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
		foreach $mom_dad3(@mom_dad) {
			$hash1{$mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3}=1;
			#print $mom_dad1.'|'.$mom_dad2.'|'.$mom_dad3."\n";
		}
	}
}
			if($sum_dad>=100 and $sum_mom>=100 and $sum_son> 100 and $sum_dad_rate > 0.6 and $sum_mom_rate > 0.6) {
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
print "$ran\t$len1{$len{$line[0]}}\t$line\t$len{$line[0]}\t$dad_var1_type\t$mom_var1_type\t$son_var3_type\t";
if (exists ($hash3{M1M1M1}) or exists ($hash3{M2M2M2} )) {
	print "yes\t";
	$hash5{$chr.'_'.M1M1M1}++;
}
if (!exists ($hash3{M1M1M1}) and !exists($hash3{M2M2M2})) {
	print "NO\t";
}
if(exists $hash3{M1M1M2} or exists $hash3{M1M2M1} or exists $hash3{M1M2M2} or exists $hash3{M2M1M1} or exists $hash3{M2M1M2} or exists $hash3{M2M2M1}) {
	print "yes\t";
	$hash5{$chr.'_'.M1M1M2}++;
}
if(!exists $hash3{M1M1M2} and !exists $hash3{M1M2M1} and !exists $hash3{M1M2M2} and !exists $hash3{M2M1M1} and !exists $hash3{M2M1M2} and !exists $hash3{M2M2M1}) {
	print "NO\t";
}
if(exists $hash3{M1M1P1} or exists $hash3{M1M1P2} or exists $hash3{M1P1M1}  or exists $hash3{M1P2M1} or exists $hash3{M2M2P1} or exists $hash3{M2M2P2} or exists $hash3{M2P1M2} or exists $hash3{M2P2M2} or exists $hash3{P1M1M1} or exists $hash3{P1M2M2} or exists $hash3{P2M1M1} or exists $hash3{P2M2M2}) {
	print "YES\t";
	$hash5{$chr.'_'.M1M1P1}++;
}
if(!exists $hash3{M1M1P1} and !exists $hash3{M1M1P2} and !exists $hash3{M1P1M1}  and !exists $hash3{M1P2M1} and !exists $hash3{M2M2P1} and !exists $hash3{M2M2P2} and !exists $hash3{M2P1M2} and !exists $hash3{M2P2M2} and !exists $hash3{P1M1M1} and !exists $hash3{P1M2M2} and !exists $hash3{P2M1M1} and !exists $hash3{P2M2M2}) {
	print "NO\t";
}
if(exists $hash3{M1M2P1}  or exists $hash3{M1M2P2} or exists $hash3{M1P1M2} or exists $hash3{M1P2M2} or exists $hash3{M2M1P1} or exists $hash3{M2M1P2} or exists $hash3{M2P1M1} or exists $hash3{M2P2M1} or exists $hash3{P1M1M2} or exists $hash3{P1M2M1} or exists $hash3{P2M1M2}  or exists  $hash3{P2M2M1} ){
	print "YES\t";
	$hash5{$chr.'_'.M1M2P1}++;
}
if(!exists $hash3{M1M2P1}  and !exists $hash3{M1M2P2} and !exists $hash3{M1P1M2} and !exists $hash3{M1P2M2} and !exists $hash3{M2M1P1} and !exists $hash3{M2M1P2} and !exists $hash3{M2P1M1} and !exists $hash3{M2P2M1} and !exists $hash3{P1M1M2} and !exists $hash3{P1M2M1} and !exists $hash3{P2M1M2}  and !exists  $hash3{P2M2M1} ){
	print "NO\t";
}
if(exists $hash3{P1P1P1}  or exists $hash3{P1P2P2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1P1}++;
}
if(!exists $hash3{P1P1P1}  and !exists $hash3{P1P2P2} ) {
	print "NO\t";
}
if(exists $hash3{P1P1P2} or exists $hash3{P1P2P1} or exists $hash3{P1P2P2} or exists $hash3{P2P1P1} or exists $hash3{P2P1P2} or exists $hash3{P2P2P1}) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1P2}++;
}
if(!exists $hash3{P1P1P2} and !exists $hash3{P1P2P1} and !exists $hash3{P1P2P2} and !exists $hash3{P2P1P1} and !exists $hash3{P2P1P2} and !exists $hash3{P2P2P1}) {
	print "NO\t";
} 
if(exists $hash3{M1P1P1} or exists $hash3{M1P2P2} or exists $hash3{M2P1P1} or exists $hash3{M2P2P2} or exists $hash3{P1M1P1} or exists $hash3{P1M2P1} or exists $hash3{P1P1M1} or exists $hash3{P1P1M2} or exists $hash3{P2M1P2} or exists $hash3{P2M2P2} or exists $hash3{P2P2M1}  or exists $hash3{P2P2M2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P1M1}++;
}
if(!exists $hash3{M1P1P1} and !exists $hash3{M1P2P2} and !exists $hash3{M2P1P1} and !exists $hash3{M2P2P2} and !exists $hash3{P1M1P1} and !exists $hash3{P1M2P1} and !exists $hash3{P1P1M1} and !exists $hash3{P1P1M2} and !exists $hash3{P2M1P2} and !exists $hash3{P2M2P2} and !exists $hash3{P2P2M1}  and !exists $hash3{P2P2M2} ) {
	print "NO\t";
}
if(exists $hash3{M1P1P2} or exists $hash3{M1P2P1} or exists $hash3{M2P1P2} or exists $hash3{M2P2P1} or exists $hash3{P1M1P2} or exists $hash3{P1M2P2} or exists $hash3{P1P2M1} or exists $hash3{P1P2M2} or exists $hash3{P2M1P1} or exists $hash3{P2M2P1} or exists $hash3{P2P1M1} or exists $hash3{P2P1M2} ) {
	print "YES\t";
	$hash5{$chr.'_'.P1P2M1}++;
}
if(!exists $hash3{M1P1P2} and !exists $hash3{M1P2P1} and !exists $hash3{M2P1P2} and !exists $hash3{M2P2P1} and !exists $hash3{P1M1P2} and !exists $hash3{P1M2P2} and !exists $hash3{P1P2M1} and !exists $hash3{P1P2M2} and !exists $hash3{P2M1P1} and !exists $hash3{P2M2P1} and !exists $hash3{P2P1M1} and !exists $hash3{P2P1M2} ) {
	print "NO\t";
}
if (exists ($hash3{M1M1M1}) or exists ($hash3{M2M2M2}) or exists $hash3{M1M1M2} or exists $hash3{M1M2M1} or exists $hash3{M1M2M2} or exists $hash3{M2M1M1} or exists $hash3{M2M1M2} or exists $hash3{M2M2M1}) {
	print "yes\t";
	$hash5{$chr.'_'.MMM}++;
}
if (!exists ($hash3{M1M1M1}) and !exists ($hash3{M2M2M2}) and !exists $hash3{M1M1M2} and !exists $hash3{M1M2M1} and !exists $hash3{M1M2M2} and !exists $hash3{M2M1M1} and !exists $hash3{M2M1M2} and !exists $hash3{M2M2M1}) {
	print "NO\t";
}
if(exists $hash3{M1M1P1} or exists $hash3{M1M1P2} or exists $hash3{M1P1M1}  or exists $hash3{M1P2M1} or exists $hash3{M2M2P1} or exists $hash3{M2M2P2} or exists $hash3{M2P1M2} or exists $hash3{M2P2M2} or exists $hash3{P1M1M1} or exists $hash3{P1M2M2} or exists $hash3{P2M1M1} or exists $hash3{P2M2M2} or exists $hash3{M1M2P1}  or exists $hash3{M1M2P2} or exists $hash3{M1P1M2} or exists $hash3{M1P2M2} or exists $hash3{M2M1P1} or exists $hash3{M2M1P2} or exists $hash3{M2P1M1} or exists $hash3{M2P2M1} or exists $hash3{P1M1M2} or exists $hash3{P1M2M1} or exists $hash3{P2M1M2}  or exists  $hash3{P2M2M1}) {
	print "YES\t";
	$hash5{$chr.'_'.MMP}++;
}
if(!exists $hash3{M1M1P1} and !exists $hash3{M1M1P2} and !exists $hash3{M1P1M1}  and !exists $hash3{M1P2M1} and !exists $hash3{M2M2P1} and !exists $hash3{M2M2P2} and !exists $hash3{M2P1M2} and !exists $hash3{M2P2M2} and !exists $hash3{P1M1M1} and !exists $hash3{P1M2M2} and !exists $hash3{P2M1M1} and !exists $hash3{P2M2M2} and !exists $hash3{M1M2P1}  and !exists $hash3{M1M2P2} and !exists $hash3{M1P1M2} and !exists $hash3{M1P2M2} and !exists $hash3{M2M1P1} and !exists $hash3{M2M1P2} and !exists $hash3{M2P1M1} and !exists $hash3{M2P2M1} and !exists $hash3{P1M1M2} and !exists $hash3{P1M2M1} and !exists $hash3{P2M1M2}  and !exists  $hash3{P2M2M1}) {
	print "NO\t";
}
if(exists $hash3{P1P1P1}  or exists $hash3{P1P2P2} or exists $hash3{P1P1P2} or exists $hash3{P1P2P1} or exists $hash3{P1P2P2} or exists $hash3{P2P1P1} or exists $hash3{P2P1P2} or exists $hash3{P2P2P1} ) {
	print "YES\t";
	$hash5{$chr.'_'.PPP}++;
}
if(!exists $hash3{P1P1P1}  and !exists $hash3{P1P2P2} and !exists $hash3{P1P1P2} and !exists $hash3{P1P2P1} and !exists $hash3{P1P2P2} and !exists $hash3{P2P1P1} and !exists $hash3{P2P1P2} and !exists $hash3{P2P2P1} ) {
	print "NO\t";
}
if(exists $hash3{M1P1P2} or exists $hash3{M1P2P1} or exists $hash3{M2P1P2} or exists $hash3{M2P2P1} or exists $hash3{P1M1P2} or exists $hash3{P1M2P2} or exists $hash3{P1P2M1} or exists $hash3{P1P2M2} or exists $hash3{P2M1P1} or exists $hash3{P2M2P1} or exists $hash3{P2P1M1} or exists $hash3{P2P1M2} or exists $hash3{M1P1P1} or exists $hash3{M1P2P2} or exists $hash3{M2P1P1} or exists $hash3{M2P2P2} or exists $hash3{P1M1P1} or exists $hash3{P1M2P1} or exists $hash3{P1P1M1} or exists $hash3{P1P1M2} or exists $hash3{P2M1P2} or exists $hash3{P2M2P2} or exists $hash3{P2P2M1}  or exists $hash3{P2P2M2}) {
	print "YES\t";
	$hash5{$chr.'_'.PPM}++;
}
if(!exists $hash3{M1P1P2} and !exists $hash3{M1P2P1} and !exists $hash3{M2P1P2} and !exists $hash3{M2P2P1} and !exists $hash3{P1M1P2} and !exists $hash3{P1M2P2} and !exists $hash3{P1P2M1} and !exists $hash3{P1P2M2} and !exists $hash3{P2M1P1} and !exists $hash3{P2M2P1} and !exists $hash3{P2P1M1} and !exists $hash3{P2P1M2} and !exists $hash3{M1P1P1} and !exists $hash3{M1P2P2} and !exists $hash3{M2P1P1} and !exists $hash3{M2P2P2} and !exists $hash3{P1M1P1} and !exists $hash3{P1M2P1} and !exists $hash3{P1P1M1} and !exists $hash3{P1P1M2} and !exists $hash3{P2M1P2} and !exists $hash3{P2M2P2} and !exists $hash3{P2P2M1}  and !exists $hash3{P2P2M2}) {
	print "NO\t";
}

print "\n";
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
			$sum_mom_rate =0;
			$sum_dad_rate =0;
  }
 }
}
$header1 = "chr\tnum\tM1M1M1\tM1M1M2\tM1M1P1\tM1M2P1\tP1P1P1\tP1P1P2\tP1P1M1\tP1P2M1\tMMM\tMMP\tPPP\tPPM\n";
print "$header1";
foreach $chr1(sort {(split /D/,$a)[1] <=> (split /D/,$b)[1]} keys %hash4) {
	if($chr1 ne "" and $chr1 ne "DX") {
        $chr_2 = $chr1;
        $chr_2 =~ s/D/Chr/;
        print "$chr_2\t$hash4{$chr1}\t";
	#print "$chr1\t$hash4{$chr1}\t";
	$hash_all += $hash4{$chr1};
	$hash_M1M1M1 += $hash5{$chr1.'_'.M1M1M1};
	$hash_M1M1M2 += $hash5{$chr1.'_'.M1M1M2};
	$hash_M1M1P1 += $hash5{$chr1.'_'.M1M1P1};
	$hash_M1M2P1 += $hash5{$chr1.'_'.M1M2P1};
	$hash_P1P1P1 += $hash5{$chr1.'_'.P1P1P1};
	$hash_P1P1P2 += $hash5{$chr1.'_'.P1P1P2};
	$hash_P1P1M1 += $hash5{$chr1.'_'.P1P1M1};
	$hash_P1P2M1 += $hash5{$chr1.'_'.P1P2M1};
	$hash_MMM += $hash5{$chr1.'_'.MMM};
	$hash_MMP += $hash5{$chr1.'_'.MMP};
	$hash_PPP += $hash5{$chr1.'_'.PPP};
	$hash_PPM += $hash5{$chr1.'_'.PPM};
	$rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M1}/$hash4{$chr1})*100 .'%';
	$rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M2}/$hash4{$chr1})*100 .'%';
	$rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1P1}/$hash4{$chr1})*100 .'%';
	$rate4 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2P1}/$hash4{$chr1})*100 .'%';
	$rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P1}/$hash4{$chr1})*100 .'%';
	$rate6 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P2}/$hash4{$chr1})*100 .'%';
	$rate7 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1M1}/$hash4{$chr1})*100 .'%';
	$rate8 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2M1}/$hash4{$chr1})*100 .'%';
	$rate9 = sprintf("%.2f",$hash5{$chr1.'_'.MMM}/$hash4{$chr1})*100 .'%';
	$rate10 = sprintf("%.2f",$hash5{$chr1.'_'.MMP}/$hash4{$chr1})*100 .'%';
	$rate11 = sprintf("%.2f",$hash5{$chr1.'_'.PPP}/$hash4{$chr1})*100 .'%';
	$rate12 = sprintf("%.2f",$hash5{$chr1.'_'.PPM}/$hash4{$chr1})*100 .'%';
	print "$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate6\t$rate7\t$rate8\t$rate9\t$rate10\t$rate11\t$rate12\n";
	}
	if($chr1 eq 'DX') {
        #$hash_all += $hash4{$chr1};
        #$hash_M1M1M1 += $hash5{$chr1.'_'.M1M1M1};
        #$hash_M1M1M2 += $hash5{$chr1.'_'.M1M1M2};
        #$hash_M1M1P1 += $hash5{$chr1.'_'.M1M1P1};
        #$hash_M1M2P1 += $hash5{$chr1.'_'.M1M2P1};
        #$hash_P1P1P1 += $hash5{$chr1.'_'.P1P1P1};
        #$hash_P1P1P2 += $hash5{$chr1.'_'.P1P1P2};
        #$hash_P1P1M1 += $hash5{$chr1.'_'.P1P1M1};
        #$hash_P1P2M1 += $hash5{$chr1.'_'.P1P2M1};
        #$hash_MMM += $hash5{$chr1.'_'.MMM};
        #$hash_MMP += $hash5{$chr1.'_'.MMP};
        #$hash_PPP += $hash5{$chr1.'_'.PPP};
        #$hash_PPM += $hash5{$chr1.'_'.PPM};
        $rate1 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M1}/$hash4{$chr1})*100 .'%';
        $rate2 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1M2}/$hash4{$chr1})*100 .'%';
        $rate3 = sprintf("%.2f",$hash5{$chr1.'_'.M1M1P1}/$hash4{$chr1})*100 .'%';
        $rate4 = sprintf("%.2f",$hash5{$chr1.'_'.M1M2P1}/$hash4{$chr1})*100 .'%';
        $rate5 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P1}/$hash4{$chr1})*100 .'%';
        $rate6 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1P2}/$hash4{$chr1})*100 .'%';
        $rate7 = sprintf("%.2f",$hash5{$chr1.'_'.P1P1M1}/$hash4{$chr1})*100 .'%';
        $rate8 = sprintf("%.2f",$hash5{$chr1.'_'.P1P2M1}/$hash4{$chr1})*100 .'%';
        $rate9 = sprintf("%.2f",$hash5{$chr1.'_'.MMM}/$hash4{$chr1})*100 .'%';
        $rate10 = sprintf("%.2f",$hash5{$chr1.'_'.MMP}/$hash4{$chr1})*100 .'%';
        $rate11 = sprintf("%.2f",$hash5{$chr1.'_'.PPP}/$hash4{$chr1})*100 .'%';
        $rate12 = sprintf("%.2f",$hash5{$chr1.'_'.PPM}/$hash4{$chr1})*100 .'%';
	$chrX = "ChrX\t$hash4{$chr1}\t$rate1\t$rate2\t$rate3\t$rate4\t$rate5\t$rate6\t$rate7\t$rate8\t$rate9\t$rate10\t$rate11\t$rate12\n";
	}
}
$rate_M1M1M1 = sprintf("%.2f",$hash_M1M1M1/$hash_all)*100 .'%';
$rate_M1M1M2 = sprintf("%.2f",$hash_M1M1M2/$hash_all)*100 .'%';
$rate_M1M1P1 = sprintf("%.2f",$hash_M1M1P1/$hash_all)*100 .'%';
$rate_M1M2P1 = sprintf("%.2f",$hash_M1M2P1/$hash_all)*100 .'%';
$rate_P1P1P1 = sprintf("%.2f",$hash_P1P1P1/$hash_all)*100 .'%';
$rate_P1P1P2 = sprintf("%.2f",$hash_P1P1P2/$hash_all)*100 .'%';
$rate_P1P1M1 = sprintf("%.2f",$hash_P1P1M1/$hash_all)*100 .'%';
$rate_P1P2M1 = sprintf("%.2f",$hash_P1P1M1/$hash_all)*100 .'%';
$rate_MMM = sprintf("%.2f",$hash_MMM/$hash_all)*100 .'%';
$rate_MMP = sprintf("%.2f",$hash_MMP/$hash_all)*100 .'%';
$rate_PPP = sprintf("%.2f",$hash_PPP/$hash_all)*100 .'%';
$rate_PPM = sprintf("%.2f",$hash_PPM/$hash_all)*100 .'%';
print '总计'."\t$hash_all\t$rate_M1M1M1\t$rate_M1M1M2\t$rate_M1M1P1\t$rate_M1M2P1\t$rate_P1P1P1\t$rate_P1P1P2\t$rate_P1P1M1\t$rate_P1P2M1\t$rate_MMM\t$rate_MMP\t$rate_PPP\t$rate_PPM\n$header1$chrX";
