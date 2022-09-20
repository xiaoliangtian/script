#/usr/bin/perl
#use strict;

die "Usage: perl $0 fastq data.genotype data.ref data.match noMatch.log > genotype.stat\n" unless ( @ARGV == 5 );

my %faData  = ();
my %refData = ();
my %match   = ();
my $fastq   = $ARGV[0];

open( FA,      "$ARGV[1]" )  or die "Can not open $ARGV[1]\n";
open( REF,     "$ARGV[2]" )  or die "can not open $ARGV[2]\n";
open( MATCH,   "$ARGV[3]" )  or die "can not open $ARGV[3]\n";
open( NOMATCH, ">$ARGV[4]" ) or die "can not open $ARGV[4]\n";

while (<FA>) {
    chomp;
    my @line = split( /\t/, $_ );
    $faData{ $line[0] }{ $line[1] . '_' . $line[2] } = $line[3];
    $genoFa{ $line[0] . '_' . $line[3] } = $line[1] . '_' . $line[2];
}
close(FA);

while (<REF>) {
    chomp;
    my @line = split( /\t/, $_ );
    if ( $line[0] ne "" and $line[1] eq '+' ) {
        $refData{ $line[0] } = $line[2];
    }
    elsif ( $line[0] ne "" ) {
        $line[2] = reverse( $line[2] );
        $line[2] =~ tr/ACGTacgt/TGCAtgca/;
        $refData{ $line[0] } = $line[2];
    }
}
close(REF);

while (<MATCH>) {
    my @line = split( /\t/, $_ );
    $line[1] =~ s/\[/\(/g;
    $line[1] =~ s/\]/\)/g;
    $line[1] =~ s/\(A\-Z\)\{/\[A\-Z\]\{/g;
    $line[1] =~ s/\(a\-z\)\{/\[a\-z\]\{/g;
    while ( $line[1] =~ m/(\(A\-Z\)([0-9]+))/ig ) {
        $num = $2;
        $line[1] =~ s/\(A\-Z\)[0-9]+/\[A\-Z\]\{$num\}/i;
    }
    $match{ $line[0] }    = $line[1];
    $motifLen{ $line[0] } = $line[2];
}
close(MATCH);

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
        @line2 = split( /\_/, $solexatag );

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

    if ( $i == 4 && $match{ $line2[-1] } ) {

        #print "$match{$line2[-1]}\n";
        if ( $seq =~ m/$match{$line2[-1]}/i ) {
            $hashLoci{ $line2[-1] }++;
            for ( my $h = 1 ; $h < 100 ; $h += 2 ) {
                if ( ${$h} ) {

                    #print "${$h}\t";
                    $motif_old = $motif;
                    $motif     = ${ $h + 1 };
                    if ( $motif ne $motif_old ) {
                        $repeats = length( ${$h} ) / length($motif);

                        $repeat1 = int( length( ${$h} ) / $motifLen{ $line2[-1] } );
                        $repeat2 = length( ${$h} ) % $motifLen{ $line2[-1] };
                        $repeatSum += $repeat1 . '.' . $repeat2;

                        #print "ne\t$motif\t$repeats\t$repeat1\t$repeat2\n";
                        if ( $repeats == 1 ) {
                            $strout .= '[' . $motif . ']';

                            #$strseq .= ${$h};
                        }
                        elsif ( $repeats > 1 ) {
                            $strout .= '[' . $motif . ']' . $repeats;

                            #$strseq .= ${$h};
                        }
                    }
                    elsif ( $motif eq $motif_old ) {
                        $repeats = length( ${$h} ) / length($motif);
                        $repeat1 = int( length( ${$h} ) / $motifLen{ $line2[-1] } );
                        $repeat2 = length( ${$h} ) % $motifLen{ $line2[-1] };
                        $repeatSum += $repeat1 . '.' . $repeat2;
                        $strout =~ /\]([0-9]+|)$/;

                        #print "eq\t$motif\t$repeats\t$repeat1\t$repeat2\t$1\n";
                        if ($1) {
                            $repeats_new = $1 + $repeats;
                        }
                        else {
                            $repeats_new = 1 + $repeats;
                        }
                        $strout =~ s/$1$/$repeats_new/;

                        #$strseq .= ${$h};
                    }
                    $strseq .= ${$h};

                    #print "$strseq\n";
                }
            }
            $seq =~ s/$strseq/$refData{$line2[-1]}/;

            #print "$strseq\n";
            if ( length($seq) > length($qual) ) {
                $qual = $qual . "H" x ( length($seq) - length($qual) );
            }
            else {
                $qual = substr( $qual, 0, length($seq) );
            }
            if ( exists $genoFa{ $line2[-1] . '_' . $strseq } ) {
                print "@" . "$solexatag" . "_" . "$line2[-1]" . "_" . "$genoFa{$line2[-1].'_'.$strseq}\n$seq\n$symbol\n$qual\n";
            }
            else {
                $hashNewGenoLoci{ $line2[-1] }++;
                $hashNewGeno{ $line2[-1] }{$strout} = $strseq;
                $hashNewGenoNum{ $line2[-1]}{$strout }++;
                print "@" . "$solexatag" . "_" . "$line2[-1]" . "_" . "$repeatSum" . '_' . "$strout\n$seq\n$symbol\n$qual\n";

                #print "@"."$listhash{$solexatag}_$strout\n$seq\n$symbol\n$qual\n";
            }
        }
        else {
            $hashLoci{ $line2[-1] }++;
            $hashError{ $line2[-1] }++;
            $hashErrorSeq{ $line2[-1] }{$seq}++;
            print NOMATCH "@" . "$solexatag\t$seq\n";
        }
        $strout    = undef;
        $strseq    = undef;
        $i         = 0;
        $motif     = "";
        $repeatSum = 0;
    }
    elsif ( $i == 4 && !$refData{ $line2[-1] } ) {

        #print "$line2[1]\n";
        $i = 0;
    }
}
close(fastq);

($sample) = $ARGV[0] =~ /(.*).R1.fastq/;
open( LOG, ">$sample.log" ) or die "can not open $sample.log\n";
print LOG "Loci\tsum reads\tmistach reads(%)\tmax mistach reads(%)\tmax seq\n";
foreach ( keys %refData ) {
    if ( exists $hashLoci{$_} ) {
        if ( exists $hashError{$_} ) {
            $errorRatio = sprintf( "%.2f", $hashError{$_} / $hashLoci{$_} );
            @sortSeq     = sort { $hashErrorSeq{$_}{$b} <=> $hashErrorSeq{$_}{$a} } keys %{ $hashErrorSeq{$_} };
            $maxSeq      = $sortSeq[0];
            $maxSeqNum   = $hashErrorSeq{$_}{$maxSeq};
            $maxSeqRatio = sprintf( "%.2f", $maxSeqNum / $hashLoci{$_} );
        }
        else {
            $hashError{$_} = 0;
            $errorRatio = 0;
            $maxSeq = 'none';
            $maxSeqNum = 0;
            $maxSeqRatio = 0;
        }
        print LOG "$_\t$hashLoci{$_}\t$hashError{$_}($errorRatio)\t$maxSeqNum($maxSeqRatio)\t$maxSeq\n";
    }
    else {
        $hashError{$_} = 0;
        $errorRatio    = 0;
        $hashLoci{$_}  = 0;
        print LOG "$_\t$hashLoci{$_}\t$hashError{$_}($errorRatio)\t0(0)\t\n";
    }
}
close(LOG);

open( NEWGENO, ">$sample.newgeno" ) or die "can not open $sample.newgeno\n";
print NEWGENO "Loci\tsum reads\tall newgeno reads(%)\tnum 1 newgeno reads(%)\tnum 2 newgeno  reads(%)\tnum 3 newgeno  reads(%)\tmax seq\n";
foreach ( keys %refData ) {
    if ( exists $hashLoci{$_} and $hashLoci{$_} != 0) {
        if ( exists $hashNewGenoLoci{$_} ) {
            $newGenoRatio = sprintf( "%.2f", $hashNewGenoLoci{$_} / $hashLoci{$_} );
	    @sortGeno = sort { $hashNewGenoNum{$_}{$b} <=> $hashNewGenoNum{$_}{$a} } keys %{ $hashNewGeno{$_} };
            $num1     = $hashNewGenoNum{ $_ }{ $sortGeno[0] };
            $num2     = $hashNewGenoNum{ $_ }{ $sortGeno[1] };
            $num3     = $hashNewGenoNum{ $_ }{ $sortGeno[2] };
            $Ratio1   = sprintf( "%.2f", $num1 / $hashLoci{$_} );
            $Ratio2   = sprintf( "%.2f", $num2 / $hashLoci{$_} );
            $Ratio3   = sprintf( "%.2f", $num3 / $hashLoci{$_} );
        }
        else {
            $newGenoRatio = 0;
            $hashNewGenoLoci{$_} = 0;
            $num1 = 0;
            $num2 = 0;
            $num3 = 0;
            $Ratio1 = 0;
            $Ratio2 = 0;
            $Ratio3 = 0;
            @sortGeno = "";
        }
        print NEWGENO "$_\t$hashLoci{$_}\t$hashNewGenoLoci{$_}\t$num1($Ratio1)\t$num2($Ratio2)\t$num3($Ratio3)\t$sortGeno[0]($hashNewGeno{$_}{$sortGeno[0]})\n";
    }
    else {
        $hashNewGenoLoci{$_} = 0;
        $hashLoci{$_}        = 0;
        $newGenoRatio        = 0;
        print NEWGENO "$_\t$hashLoci{$_}\t$hashNewGenoLoci{$_}($newGenoRatio)\t0(0)\t0(0)\t0(0)\tnone\n";
    }
}
close(NEWGENO);
