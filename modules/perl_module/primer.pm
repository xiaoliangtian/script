#!/usr/bin/perl
package primer;

%hash = (
    "R"=>"ag",
    "Y"=>"CT",
    "M"=>"AC",
    "K"=>"GT",
    "S"=>"gc",
    "W"=>"AT",
    "H"=>"atc",
    "B"=>"gtc",
    "V"=>"gac",
    "D"=>"GAT",
    "N"=>"ATgc",
);

sub primer2multiple{

    $primer=$_[0];

    $prod=1;

    $primer_len=length $primer ;

    foreach $i (0..$primer_len-1){

        $char=substr($primer,$i,1);

        if ($char !~/[ATCG]/){$prod*=length $hash{$char}}

    }

    $new="";

    foreach $i (0..$primer_len-1){

        $char=substr($primer,$i,1);

        if ($char =~/[ATCG]/){$new.=$char x $prod}

        else {$tmp=length $hash{$char};$new.=$hash{$char} x ($prod/$tmp)}

    }

    die "error!" if   $primer_len*$prod != length $new ;
    @result = "";
    foreach $i (0..$prod-1){

        $tmp="";
        # @result = "";

        for(my $j=$i;$j<(length($new));$j+=$prod){$tmp.=substr($new,$j,1)}

        # print "$tmp\n";
        push @result, $tmp;

    }
    shift @result;
    return @result;

}
