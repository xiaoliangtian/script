#!/usr/bin/perl

die
"usage : perl $0 in  > out\n" unless (@ARGV==1);

open(IN,$ARGV[0]);

$header = <IN>;
chomp($header);
@head = split(/\t/,$header);

print "Sample\tLocus\tSTR Length\tdepth\tSTR Sequence\n";
while(<IN>){
    chomp;
    @line = split("\t",$_);
    $colCount = 0;
    foreach $col(@line){
        # print "$col\n";
        if ($head[$colCount] =~ m/STRGA/){
            # print "$col\t$head[$colCount]\n";
            $info = $col;
            if ($col eq 'NA'){
                $len = 'NA';
                $depth = 'NA';
                $str ='NA';
                $snp = "";
                print "$head[$colCount]\t$line[0]\t$len\t$depth\t$str $snp\n";
            }
            else{
                foreach $type((split(/\//,$col))){
                    @typeInfo = split(/\|/,$type);
                    $depth = $typeInfo[1];
                    if ($typeInfo[0] =~ m/_\(/) {
                        @snp_str = split (/_\(/,$typeInfo[0]);
                        $snp = $snp_str[0];
                        @len_str = split( /\_/,$snp_str[1]);
                        $len = $len_str[0];
                        $str = $len_str[1];
                        $len =~ s/\(//;
                        $str =~ s/\)//;
                    }
                    else{
                        @len_str = split (/\_/,$typeInfo[0]);
                        $snp = "";
                        $len = $len_str[0];
                        $str = $len_str[1];
                        $len =~ s/\(//;
                        $str =~ s/\)//;
                    }
                    print "$head[$colCount]\t$line[0]\t$len\t$depth\t$str $snp\n";
                }
                # print "$head[$colCount]\t$line[0]\t$len\t$depth\t$str\n";
            }
            # print "$head[$colCount]\t$line[0]\t$len\t$depth\t$str $snp\n";
        }
        $colCount++;        
    }
}
