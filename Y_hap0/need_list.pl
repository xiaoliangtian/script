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
    $hash{ $line[0] . '_' . $line[1] } = 1;
}
close(LIST);

open( FASTA, "$fasta" ) || die "cannot open $fasta\n";
while (<FASTA>) {
    chomp;
    my @gene = split( /\t/, $_ );
    my $name = $gene[0] . '_' . $gene[1];
    if ( $gene[0] !~ '##' ) {
        $line_count++;
        if ( $line_count == 1 ) {
            print "$_\n";
        }
        if ( $line_count > 1 and exists $hash{$name}  ) {
            if ( $_ !~ '1/1' ) {
                $gene[4] = '.';
                $out = join( "\t", @gene );
                print "$out\n";
            }
            else {
                print "$_\n";
            }
        }
    }
}
close(FASTA);

