#/usr/bin/perl

die "Usage: perl $0  list >pathway\n" unless (@ARGV == 1);
#  perl 

my $fasta = $ARGV[0];
my $list  = $ARGV[1];


my %hash = ();



open (LIST, "$fasta") || die "cannot open $list\n";
while(<LIST>) {
	chomp;
        @line1= split (/\t/,$_);
        @line2 = split (/\; /,$line1[5]);
        $kegg = $line1[6].','.$line1[7].','.$line1[8];
        $path = (split/ /,$line1[0])[0];
        $hash{$line2[0]} .= $kegg.'|'.$path.';';      
       
}
close(LIST);


foreach (keys %hash) {
    $hash{$_} =~ s/;$//;
    print "$_\t($hash{$_})\n";
}
