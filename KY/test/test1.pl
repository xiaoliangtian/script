#!/usr/bin/perl
die "Usage: perl $0 in  out\n" unless ( @ARGV == 2);

$input = $ARGV[0];

open (IN,$input);
while (<IN>) {
    chomp;
    unless (/^Sample/) {
        #print "$_\n";
        @line = split(/\t/,$_);
        $hash{$line[1].'_'.$line[2].'_'.$line[3].'_'.$line[4].'_'.substr($line[-1],0,3)} .= ",".$line[0];
        $hashSample{$line[0]}++;
        #print "$line[1].'_'.$line[2].'_'.$line[3].'_'.$line[4].'_'.".substr($line[-1],0,3)."\n";
        
    }
}

close IN;

open (OUT, ">$ARGV[1]");
#print keys %hashSample;
$sampleHeader = join("\t", sort keys %hashSample);
print OUT "\t$sampleHeader\n";

foreach $key1(sort keys %hash){
    #@group1 = split(/_/,$key1);
    #print "$key1\t";
    
    @sample = split(/\,/,$hash{$key1});
    shift @sample;
    #print "@sample\n";
    foreach $i(@sample){
        foreach $j(@sample){
            #print "$i\t$j\n";
            $hashsame{$i.'_'.$j}++;
        }
    }
}



foreach (sort keys %hashSample){
    $samp1 = $_;
    #print "$samp1\n";
    print OUT "$samp1\t";
    foreach (sort keys %hashSample){
        $samp2 = $_;
        #print "$samp1\t$samp2\t$hashsame{$samp1.'_'.$samp2}\t$hashSample{$samp1}\n";
        $same = $hashsame{$samp1.'_'.$samp2};
        $ratio  = sprintf("%.2f",$same/$hashSample{$samp1});
        print OUT "$ratio".'/'."$hashSample{$samp1}\t";
        if ($ratio >= 1 and $samp1 ne $samp2){
            print "$samp1\t$samp2\t$same\t$hashSample{$samp1}\t$hashsame{$samp2.'_'.$samp1}\t$hashSample{$samp2}\n";
        }
    }
    print OUT "\n";
}
