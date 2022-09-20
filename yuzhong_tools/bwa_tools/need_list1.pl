#/usr/bin/perl

die "Usage: perl $0 fasta list > out.fa\n" unless ( @ARGV == 2 );

#  perl

my $fasta = $ARGV[0];
my $list  = $ARGV[1];

my %hash = ();

open( LIST, "$list" ) || die "cannot open $list\n";
while (<LIST>) {
    chomp;
    if (/\>(\S+)/) {
        $hash{$1} = 1;
    }
    elsif (/^(\S+)/) {
        $hash{$1} = 1;
    }
    else {
        warn "not match: $_\n";
    }
}
close(LIST);

open( FASTA, "$fasta" ) || die "cannot open $fasta\n";
$header = <FASTA>;
print $header;
while (<FASTA>) {
    chomp;
    my @gene = split( /\t/, $_ );
    my $name = $gene[1];

    #$name = (split /;/, $name)[0];
    #	next unless ($name && $seq);
    #	$seq =~ s/\n//g;
    #	$seq =~ s/^\s+//g;
    #	$seq =~ s/\s+$//g;

    if ( exists $hash{$name} ) {
        print "$_\n";
    }
}
close(FASTA);

