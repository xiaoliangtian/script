#/usr/bin/perl

die "Usage: perl $0 fasta list > out.fa\n" unless ( @ARGV == 2 );

#  perl

my $fasta = $ARGV[0];
my $list  = $ARGV[1];

my %hash = ();

open( LIST, "$list" ) || die "cannot open $list\n";
while (<LIST>) {
    chomp;
    @line = split( /\t/, $_ );
    if ( $line[0] !~ '##' ) {
        $line_count++;
        #if ( $line_count == 1 ) {
        #    print "$_\n";
        #}
        if ( $line_count >= 1 ) {
            $hash{ $line[0] . '_' . $line[1] } = $_;
        }
    }
}
close(LIST);

open( FASTA, "$fasta" ) || die "cannot open $fasta\n";
while (<FASTA>) {
    chomp;
    my @gene = split( /\t/, $_ );
    my $name = "chr".$gene[0] . '_' . $gene[1];

    if ( exists $hash{$name} ) {
        print "$_\n";
    }
    else {
        #print "$gene[0]\t$gene[1]\n";
    }
}
close(FASTA);

