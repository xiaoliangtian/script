#!/usr/bin/perl
die "Usage: perl $0 in  out\n" unless ( @ARGV == 2);

$input = $ARGV[0];

open (IN,$input);
while (<IN>) {
    chomp;
    unless (/^Sample/) {
        #print "$_\n";
        @line = split(/\t/,$_);
        $hash{$line[0].'_'.$line[1].'_'.$line[2].'_'.$line[3].'_'.$line[4]} = substr($line[-1],0,3);
        $hashSample{$line[0]}++;
        
    }
}

close IN;
#print keys %hashSample;
$sampleHeader = join("\t", keys %hashSample);
print "\t$sampleHeader\n";

foreach $key1(sort keys %hash){
    @group1 = split(/_/,$key1);
    #print "$key1\n";
    $snp1 = join("_",@group1[1..$#group1]);
    #print "$snp\n";
    foreach $key2(sort keys %hash){
        @group2 = split(/_/,$key2);
        #print "key2\t$key2\n";
        $snp2 = join("_",@group2[1..$#group2]);
        if ($snp1 eq $snp2 and $hash{$key1} == $hash{$key2}){
            $hashsame{$group1[0].'_'.$group2[0]}++; 
            print "$key1\t$key2\n";
        }
    }

}

open(OUT, $ARGV[1]);
foreach (sort %hashSample){
    $samp1 = $_;
    print OUT "$samp1\t";
    foreach (sort %hashSample){
        $samp2 = $_;
        $same = $hashsame{$samp1.'_'.$samp2};
        $ratio  = sprintf("%.2f",$same/$hashSample{$samp1});
        print OUT "$ratio".'/'."$hashSample{$samp1}\t";
    }
    print OUT "\n";
}
