#!/usr/bin/perl 
use primer;
use mistach;

@primer = primer::primer2multiple("GTTTCTTYCATCATTTTGTGTATTAAGGT");
# print "@primer\n";
foreach (@primer){
    print "$_\n";
    $test = mistach::fuzzy_pattern($_,1);
    # print "$test\n";
}