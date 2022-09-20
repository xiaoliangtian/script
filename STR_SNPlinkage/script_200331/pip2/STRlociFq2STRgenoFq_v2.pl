#/usr/bin/perl
#use strict;

die "Usage: perl $0 fastq data.genotype data.ref data.match noMatch.log matchDel.data > genotype.stat\n" unless ( @ARGV == 6 );

my %faData  = ();
my %refData = ();
my %match   = ();
my $fastq   = $ARGV[0];

open( FA,      "$ARGV[1]" )  or die "Can not open $ARGV[1]\n";
open( REF,     "$ARGV[2]" )  or die "can not open $ARGV[2]\n";
open( MATCH,   "$ARGV[3]" )  or die "can not open $ARGV[3]\n";
open( NOMATCH, ">$ARGV[4]" ) or die "can not open $ARGV[4]\n";
open( MATDEL,  "$ARGV[5]" ) or die "can not open $ARGV[5]\n";

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

while (<MATDEL>) {
    my @line = split( /\t/, $_ );
    $del{ $line[0] }    = $line[1];
    $dellen{ $line[0] } = $line[2];
}
close(MATDEL);

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
        @line1 = split( /\t/, $_ );
        $solexatag = $line1[0];
        $solexatag =~ s/^@//;
        $line1[1] =~ s/XF\:i\://;

        #print "@line1\t$line1[1]\n";
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

    if ( $i == 4 ) {
        #print "$line2[-1]\n";
        $hashStrNum{ $line2[-1] } += $line1[1];

        #print "$line1[1]\n";
        $i = 0;
    }
}
close(fastq);

open( fastq, "$fastq" );
while (<fastq>) {
    chomp;
    if ( $i == 0 ) {
        @line1 = split( /\t/, $_ );
        $solexatag = $line1[0];
        $solexatag =~ s/^@//;
        $readsNum = $line1[1];
        $readsNum =~ s/XF\:i\://;
        @line2 = split( /\_/, $solexatag );
        #print "@line2\n";
        if ( $hashStrNum{ $line2[-1] } ) {
            $readsRatio = $readsNum / $hashStrNum{ $line2[-1] };
            #print "$line2[-1]\n";
        }
        else {
            $readsRatio = 0;
        }

        #print "$readsNum\t$readsRatio\n";

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
    $strName = (split /\_/, $line2[-1])[0];
    if ( $i == 4 && $match{ $strName } and $readsNum > 1 and $readsRatio > 0.005 ) {

        #print "$match{$line2[-1]}\n";
        if ( $seq =~ m/$match{$strName}/i ) {
            $hashLoci{ $line2[-1] } += $readsNum;
            #print "$line2[-1]\t$readsNum\n";
            for ( my $h = 1 ; $h < 100 ; $h += 2 ) {
                if ( ${$h} ) {

                    #print "${$h}\t";
                    $motif_old = $motif;
                    $motif     = ${ $h + 1 };
                    if ( $motif ne $motif_old ) {
                        $repeats = length( ${$h} ) / length($motif);
                        if ( length($motif) < 10 ) {
                            $repeat1 = int( length( ${$h} ) / $motifLen{ $strName } );
                            $repeat2 = length( ${$h} ) % $motifLen{ $strName };
                            $repeatSum += $repeat1 . '.' . $repeat2;
                        }

                        #print "ne\t$motif\t$repeats\t$repeat1\t$repeat2\n";
                        if ( $repeats == 1 and length($motif) < 10 ) {
                            $strout .= '[' . $motif . ']';

                            #$strseq .= ${$h};
                        }
                        elsif ( $repeats > 1 and length($motif) < 10 ) {
                            $strout .= '[' . $motif . ']' . $repeats;

                            #$strseq .= ${$h};
                        }
                        elsif ( length($motif) >= 10 ) {
                            $strout .= 'N' . length($motif);
                        }
                    }
                    elsif ( $motif eq $motif_old ) {
                        $repeats = length( ${$h} ) / length($motif);
                        $repeat1 = int( length( ${$h} ) / $motifLen{ $strName } );
                        $repeat2 = length( ${$h} ) % $motifLen{ $strName };
                        $repeatSum += $repeat1 . '.' . $repeat2;
                        $strout =~ /\]([0-9]+|)$/;
                        if ($1) {
                            $repeats_new = $1 + $repeats;
                        }
                        else {
                            $repeats_new = 1 + $repeats;
                        }
                        $strout =~ s/$1$/$repeats_new/;
                    }
                    $strseq .= ${$h};
                }
            }
            #print "$strName\t$strseq\n";
            if ( exists $del{ $strName } ) {
                #print "$strName\n";
                $delLength = int( $dellen{ $strName } / $motifLen{ $strName } ) . '.' . $dellen{ $strName } % $motifLen{ $strName };
                $repeatSum = $repeatSum - $delLength;
                if ( $del{ $strName } eq 'F' ) {
                    $strseq = substr( $strseq, $dellen{ $strName } , length($strseq) );
                }
                else {
                    $strseq = substr( $strseq, 0, length($strseq) - $dellen{ $strName } );
                }
            }
            $strPosLeft = index($seq,$strseq);
            $strPosRight = $strPosLeft + length($strseq);
            # print "length($seq)\n";
            if (exists $hashStrminLeft{$strName}){
                #print "you $hashStrminLeft{$strName}\n";
                if ($hashStrminLeft{$strName} > $strPosLeft){
                    $hashStrminLeft{$strName} = $strPosLeft;
                }
                if ($hashStrminRight{$strName} > $strPosRight){
                    $hashStrminRight{$strName} = $strPosRight;
                }
            }
            else{
                #print "wu $hashStrminLeft{$strName}\n";
                $hashStrminLeft{$strName} = $strPosLeft;
                $hashStrminRight{$strName} = $strPosRight;
            }
            $seq =~ s/$strseq/$refData{$strName}/;

            #print "$strName\t$strseq\n";
            if ( length($seq) > length($qual) ) {
                $qual = $qual . "H" x ( length($seq) - length($qual) );
            }
            else {
                $qual = substr( $qual, 0, length($seq) );
            }
            if ( exists $genoFa{ $strName . '_' . $strseq } ) {
                print "@" . "$solexatag" . "_" . "$readsNum" . "_" . "$genoFa{$strName.'_'.$strseq}\n$seq\n$symbol\n$qual\n";
            }
            else {
                $hashNewGenoLoci{ $line2[-1] } += $readsNum;
                $hashNewGeno{ $line2[-1] }{$strout} = $strseq;
                $hashNewGenoNum{ $line2[-1] }{$strout} += $readsNum;
                print "@" . "$solexatag" . "_" . "$readsNum" . "_" . "$repeatSum" . '_' . "$strout\n$seq\n$symbol\n$qual\n";

                #print "@"."$listhash{$solexatag}_$strout\n$seq\n$symbol\n$qual\n";
            }
        }
        else {
            $hashLoci{ $line2[-1] }           += $readsNum;
            $hashError{ $line2[-1] }          += $readsNum;
            $hashErrorSeq{ $line2[-1] }{$seq} += $readsNum;
            print NOMATCH "@" . "$solexatag\t$seq\n";
        }
        $strout    = undef;
        $strseq    = undef;
        $i         = 0;
        $motif     = "";
        $repeatSum = 0;
    }
    elsif ( $i == 4 ) {

        #print "$line2[1]\n";
        $i = 0;
    }
}
close(fastq);

($sample) = $ARGV[0] =~ /(.*).uniq.R1.fastq/;
open( LOG, ">$sample.log" ) or die "can not open $sample.log\n";
print LOG "Loci\tsum reads\tmistach reads(%)\tmax mistach reads(%)\tmax seq\n";
open( POS, ">$sample.pos" ) or die "can not open $sample.pos\n";
print POS "Loci\tminleft\tmaxright\n";
foreach $strName( keys %refData ) {
    # foreach (("pool1","pool2")){
    #     $strName = $strName.'_'.$_;
    #     print "pool $strName\n";
    if ( exists $hashLoci{$strName} ) {
        if ( exists $hashError{$strName} ) {
            $errorRatio = sprintf( "%.2f", $hashError{$strName} / $hashLoci{$strName} );
            @sortSeq     = sort { $hashErrorSeq{$strName}{$b} <=> $hashErrorSeq{$strName}{$a} } keys %{ $hashErrorSeq{$strName} };
            $maxSeq      = $sortSeq[0];
            # print "maxseq\t$maxSeq\n";
            $maxSeqSTR = `perl /home/tianxl/pipeline/STR_SNPlinkage/script_200331/pip2/SSR_nomatch.pl $maxSeq 3-4,4-4,5-4,6-4,7-3 100`;
            # $maxSeq = $maxSeqSTR.$maxSeq;
            $maxSeqNum   = $hashErrorSeq{$strName}{$maxSeq};
            $maxSeqRatio = sprintf( "%.2f", $maxSeqNum / $hashLoci{$strName} );
            $maxSeq = $maxSeqSTR.$maxSeq;
        }
        else {
            $hashError{$strName} = 0;
            $errorRatio    = 0;
            $maxSeq        = 'none';
            $maxSeqNum     = 0;
            $maxSeqRatio   = 0;
        }
        print LOG "$strName\t$hashLoci{$strName}\t$hashError{$strName}($errorRatio)\t$maxSeqNum($maxSeqRatio)\t$maxSeq\n";
    }
    else {
        $hashError{$strName} = 0;
        $errorRatio    = 0;
        $hashLoci{$strName}  = 0;
        print LOG "$strName\t$hashLoci{$strName}\t$hashError{$strName}($errorRatio)\t0(0)\t\n";
    }
    if (exists  $hashStrminLeft{$strName} ){
        print POS "$strName\t$hashStrminLeft{$strName}\t$hashStrminRight{$strName}\t";
        if ($hashStrminLeft{$strName} < 10 or $hashStrminRight{$strName} > 270){
            print POS "bad STR\n";
        }
        else {
            print POS "\n";
        }
    }
    else {
        print POS "$strName\tNone\tNone\n";
    }
}
close(LOG);
close(POS);

open( NEWGENO, ">$sample.newgeno" ) or die "can not open $sample.newgeno\n";
print NEWGENO "Loci\tsum reads\tall newgeno reads(%)\tnum 1 newgeno reads(%)\tnum 2 newgeno  reads(%)\tnum 3 newgeno  reads(%)\tmax seq\n";
foreach $strName( keys %refData ) {
    # foreach (("pool1","pool2")){
    #     $strName = $strName.'_'.$_;
    if ( exists $hashLoci{$strName} and $hashLoci{$strName} != 0 ) {
        if ( exists $hashNewGenoLoci{$strName} ) {
            $newGenoRatio = sprintf( "%.2f", $hashNewGenoLoci{$strName} / $hashLoci{$strName} );
            @sortGeno = sort { $hashNewGenoNum{$strName}{$b} <=> $hashNewGenoNum{$strName}{$a} } keys %{ $hashNewGeno{$strName} };
            $num1     = $hashNewGenoNum{$strName}{ $sortGeno[0] };
            $num2     = $hashNewGenoNum{$strName}{ $sortGeno[1] };
            $num3     = $hashNewGenoNum{$strName}{ $sortGeno[2] };
            $Ratio1   = sprintf( "%.2f", $num1 / $hashLoci{$strName} );
            $Ratio2   = sprintf( "%.2f", $num2 / $hashLoci{$strName} );
            $Ratio3   = sprintf( "%.2f", $num3 / $hashLoci{$strName} );
        }
        else {
            $newGenoRatio        = 0;
            $hashNewGenoLoci{$strName} = 0;
            $num1                = 0;
            $num2                = 0;
            $num3                = 0;
            $Ratio1              = 0;
            $Ratio2              = 0;
            $Ratio3              = 0;
            @sortGeno            = "";
        }
        print NEWGENO
        "$strName\t$hashLoci{$strName}\t$hashNewGenoLoci{$strName}\t$num1($Ratio1)\t$num2($Ratio2)\t$num3($Ratio3)\t$sortGeno[0]($hashNewGeno{$strName}{$sortGeno[0]})\n";
    }
    else {
        $hashNewGenoLoci{$strName} = 0;
        $hashLoci{$strName}        = 0;
        $newGenoRatio        = 0;
        print NEWGENO "$strName\t$hashLoci{$strName}\t$hashNewGenoLoci{$strName}($newGenoRatio)\t0(0)\t0(0)\t0(0)\tnone\n";
    }
}
close(NEWGENO);
