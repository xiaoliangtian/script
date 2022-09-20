#/usr/bin/perl

die "Usage: perl $0 tell.hap > need.hap\n" unless (@ARGV==1);

open(IN, $ARGV[0]);

$/ ="\nBLOCK";
while(<IN>) {
    chomp;
    my @line = split(/\n/,$_);
    if ($#line > 5) {
        shift @line;
        pop @line;
        foreach (@line){
            @lineSplit = split(/\t/,$_);
            $lineOut = join("\t",@lineSplit[3..6],@lineSplit[1..2]);
            if ($lineOut ne "") {
                print "$lineOut\n";
            }
        }
    }
}
