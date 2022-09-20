#!/usr/bin/perl

@file = <*.log>;

foreach $file(@file) {
    ($sample) = $file =~ /(.*)\.log/;
    open(IN,"$file");
    $header = <IN>;
    while(<IN>){
        chomp;
        @lineInfo = split(/\t/,$_);
        ($ratio) = $lineInfo[3] =~ /.*\((.*)\)/;
        ($depth) = $lineInfo[3] =~ /([0-9]+)\(/;
        @seq = split(/ /,$lineInfo[4]);
        # print "$depth\n";
        # print "$sample\t$ratio\t$seq[0]\n";
        if ($ratio > 0.1 and $seq[0] ne "" and $seq[0] !~ m/n/ and $depth >=10 ){
            $hash{$lineInfo[0].'_'.$seq[0]} ++;
            $hashS{$lineInfo[0].'_'.$seq[0]} .= $sample.',';
        }
    }
}

foreach $key(sort keys %hash){
    print "$key\t$hash{$key}\t$hashS{$key}\n";
}