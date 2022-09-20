#/usr/bin/perl
#use strict;

die "Usage: perl $0 fastq data.fa data.ref > out.fa\n" unless ( @ARGV == 3 );

my %faData  = ();
my %refData = ();
my $fastq   = $ARGV[0];

open( FA,  "$ARGV[1]" ) or die "Can not open $ARGV[1]\n";
open( REF, "$ARGV[2]" ) or die "can not open $ARGV[2]\n";

while (<FA>) {
    chomp;
    my @line = split( /\t/, $_ );
    $faData{ $line[0] }{ $line[1] . '_' . $line[2] } = $line[3];

}
close(FA);

while (<REF>) {
    chomp;
    my @line = split( /\t/, $_ );
    if ( $line[1] eq '+' ) {
        $refData{ $line[0] } = $line[2];
    }
    else {
        $line[2] = reverse( $line[2] );
        $line[2] =~ tr/ACGTacgt/TGCAtgca/;
        $refData{ $line[0] } = $line[2];
    }
}
close(REF);

my $solexatag = '';
my $seq       = '';
my $symbol    = '';
my $qual      = '';
my $i         = 0;
my @line;
my @line1;
my @line2;

my $strout;
open( fastq, "$fastq" );
while (<fastq>) {
    chomp;
    if ( $i == 0 ) {
        @line1 = split( /(\s+)/, $_ );
        $solexatag = $line1[0];
        $solexatag =~ s/^@//;
        @line2 = split( /\_/, $line1[0] );

    }
    if ( $i == 1 ) {
        $seq = $_;
    }
    if ( $i == 2 ) {
        $symbol = $_;
    }
    if ( $i == 3 ) {
        $qual = $_;
    }
    $i = $i + 1;

    if ( $i == 4 && $refData{ $line2[1] } ) {
        foreach my $h ( sort { ( split /\_/, $b )[0] <=> ( split /\_/, $a )[0] } keys %{ $faData{ $line2[1] } } ) {

            #print "$h\t$faData{$line2[1]}{$h}\t";
            @strType = split( /\_/, $h );
            $start = index( $seq, $faData{ $line2[1] }{$h}, 0 ) + 1;

            if ( $start > 0 ) {

                #print "$h\t$faData{$line2[1]}{$h}\t";
                $true = 1;

                #print "$start\n";
                $end   = $start + length( $faData{ $line2[1] }{$h} );
                $strTy = $h;
                $seq =~ s/$faData{$line2[1]}{$h}/$refData{$line2[1]}/;
                if ( length($seq) > length($qual) ) {
                    $qual = $qual . "H" x ( length($seq) - length($qual) );
                }
                else {
                    $qual = substr( $qual, 0, length($seq) );
                }

                print "@" . "$solexatag" . "_" . "$strTy" . '_' . "$start" . '_' . "$end\n$seq\n$symbol\n$qual\n";
                last;
            }

        }
        if ( !$true ) {
            $strTy = $seq;
            $start = 1;
            $end   = length($seq);
            print "@" . "$solexatag" . "_" . "$strTy" . '_' . "$start" . '_' . "$end\n$seq\n$symbol\n$qual\n";
            $true = 0;
        }
        $i = 0;
    }

    elsif ( $i == 4 && !$refData{ $line2[1] } ) {

        #print "$line2[1]\n";
        $i = 0;
    }
}
close(fastq);

