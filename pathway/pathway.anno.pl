#/usr/bin/perl

die "Usage: perl $0 fasta list > out.fa\n" unless (@ARGV == 2);
#  perl 

my $fasta = $ARGV[0];
my $list  = $ARGV[1];


my %hash = ();



open (LIST, "$list") || die "cannot open $list\n";
while(<LIST>) {
	chomp;
	@line = split (/\t/,$_);
        $hash{$line[0]} = $line[1];
}
close(LIST);


open (FASTA, "$fasta") || die "cannot open $fasta\n";
$header = <FASTA>;
chomp($header);
print "$header\tKEGG_pathway\n";
while (<FASTA>) {
	chomp;
	my @gene = split (/\t/,$_);
        #print "$gene[6]\n";
        if($gene[6] =~ ';') {
            @gene_name = split(/\;/,$gene[6]);
            foreach (@gene_name) {
                if(exists $hash{$gene[6]}) {
                    $pathway .= $_.$hash{$_}.';';
                }
                else {
                    $pathway .= '-'.';';
                }
            }
            $pathway =~ s/;$//;
        }
        else {
            if (exists $hash{$gene[6]}) {
                $pathway = $gene[6].$hash{$gene[6]};
            }
            else {
                $pathway = '-';
            }
        }
        print "$_\t$pathway\n";
        $pathway = "";
}
close(FASTA);



