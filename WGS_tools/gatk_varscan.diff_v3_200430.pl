#!/usr/bin/perl

#use strict;
die "Usage: perl $0 varscan gatk > out\n" unless ( @ARGV == 2 );
open( FILE1, "$ARGV[0]" ) or die "Failed to open file $ARGV[0]\n";
open( FILE2, "$ARGV[1]" ) or die "Failed to open file $ARGV[1]\n";

#open(OUT, ">$ARGV[1]") or die "Failed to open file $ARGV[1]\n";

#my $head = <FILE>;
#print "$head";

$num = 0;
while (<FILE1>) {
    chomp;
    $line_count++;
    @line = split( /\t/, $_ );
    if ( $line_count == 1 ) {
        #$hash{ $line[0] . '_' . $line[1] } = 1;
        $sample1                           = $line[5];
        $sample2                           = $line[6];
    }
    if ( $line_count > 1 and $line[0] =~ 'chr' ) {
        $type1 = substr( $line[5], 0, 3 );
        $type2 = substr( $line[6], 0, 3 );
        $type1 =~ s/\|/\//;
        $type2 =~ s/\|/\//;
        @gt1 = split(/\//,$type1);
        @gt2 = split(/\//,$type2);
        @Gbase = split(/\,/,$line[3]);
        unshift @Gbase, $line[2];
        $hash{ $line[0] . '_' . $line[1] } = 1;
        $hashgt{$line[0] . '_' . $line[1]. '_' . $sample1 } = $Gbase[$gt1[0]].'/'.$Gbase[$gt1[1]];
        $hashgt{$line[0] . '_' . $line[1]. '_' . $sample2 } = $Gbase[$gt2[0]].'/'.$Gbase[$gt2[1]];
        $hash{ $line[0] . '_' . $line[1] . '_' . $sample1 } = $line[5];
        $hash{ $line[0] . '_' . $line[1] . '_' . $sample2 } = $line[6];
        #print "$line[0] . '_' . $line[1]\n";
    }
}

while (<FILE2>) {
    chomp;
    $line_count2++;
    @line = split( /\t/, $_ );
    if ( $line_count2 == 1 ) {
        $sample1 = $line[5];
        $sample2 = $line[6];
        $line[1] = $line[1]."\t".'ID';
        #$line[1] = $line[1]."\t".'ID';
        $line[3] = $line[3]."\t".'QUAL';
        $line[4] = $line[4]."\t".'INFO'."\t".'FORMAT';
        $line[5] = $line[5] . '_gatk' . "\t" . $line[5] . '_varscan2';
        $line[6] = $line[6] . '_gatk' . "\t" . $line[6] . '_varscan2';
        $header  = join( "\t", @line );
        print "$header\n";
    }
    if ( $line_count2 > 1 ) {
        $type1 = substr( $line[5], 0, 3 );
        $type2 = substr( $line[6], 0, 3 );
        $type1 =~ s/\|/\//;
        $type2 =~ s/\|/\//;
        @gt1 = split(/\//,$type1);
        @gt2 = split(/\//,$type2);
        @Gbase = split(/\,/,$line[3]);
        unshift @Gbase, $line[2];
        $gt1 = $Gbase[$gt1[0]].'/'.$Gbase[$gt1[1]];
        $gt2 = $Gbase[$gt2[0]].'/'.$Gbase[$gt2[1]];
        
        if ( exists $hash{ $line[0] . '_' . $line[1] } ) {
            $type1_vars = $hashgt{$line[0] . '_' . $line[1]. '_' . $sample1 };
            #print "$type1\t$type1_vars\n";
            $type2_vars = $hashgt{$line[0] . '_' . $line[1]. '_' . $sample2 };
            #print "$type1\t$type1_vars\t$type2\t$type2_vars\n";
            if ( $gt1 eq $type1_vars and $gt2 eq $type2_vars ) {
                $type1_hash = substr( $hash{$line[0].'_'.$line[1].'_'.$sample1}, 0, 3 );
                $type2_hash = substr( $hash{$line[0].'_'.$line[1].'_'.$sample2}, 0, 3 );
                $hash{$line[0].'_'.$line[1].'_'.$sample1} =~ s/$type1_hash/$type1/;
                $hash{$line[0].'_'.$line[1].'_'.$sample2} =~ s/$type2_hash/$type2/;
                print 
"$line[0]\t$line[1]\t".'.'."\t$line[2]\t$line[3]\t".'.'."\t$line[4]\t".'.'."\t".'GT:AD:DP:GQ:PL'."\t$line[5]\t$hash{$line[0].'_'.$line[1].'_'.$sample1}\t$line[6]\t$hash{$line[0].'_'.$line[1].'_'.$sample2}\n";
            }
        }
    }
}
