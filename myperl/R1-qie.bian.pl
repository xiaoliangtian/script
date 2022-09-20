#! /usr/bin/perl -w 

die "Usage : fastq > out.fq\n" unless ( @ARGV == 1 );
open( FQ, "gzip -dc $ARGV[0]|" ) or die "can not open fq\n";

my $idx;
while (<FQ>) {
    my $name = $_;
    my $seq  = <FQ>;
    my $s    = <FQ>;
    my $qua  = <FQ>;
    if ( $seq =~ /GCATTGACAGGAG/ ) {
        ( my $idx = $seq ) =~ /[\w]+(?=GCATTGACAGGAG)/;
        $idx =~ s/(?=GCATTGACAGGAG)[\w]+//;
        $seq1 = substr( $seq, -( length($seq) - length($idx) + 1 ) );
        $seq =~ s/[\w]+(?=GCATTGACAGGAG)//;

        #print "$idx";
        @line1 = split( /(\s+)/, $name );

        #print "$line1[0]\n";
        @line2 = split( /\|/, $line1[0] );
        push @line2, $idx;
        $name1 = join( '|', @line2 );
        print "$name1";
        $qua = substr( $qua, -length($seq1) );

        #$l1 = leng;
        #$l2= length ($qua);
        print "$seq1$s$qua";
    }
}
close(FQ);

