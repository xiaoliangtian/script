#!/usr/bin/perl

#use strict;
die "Usage: perl $0 in depth diff test.col ref.col > out\n" unless ( @ARGV == 5 );
open( FILE, "$ARGV[0]" ) or die "Failed to open file $ARGV[0]\n";

#open(OUT, ">$ARGV[1]") or die "Failed to open file $ARGV[1]\n";

#my $head = <FILE>;
#print "$head";

$num = 0;
while (<FILE>) {
    chomp;
    if ( substr( $_, 0, 2 ) ne '##' ) {
        $line_count++;
        @line = split( /\t/, $_ );
        if ( $line_count == 1 ) {
            print "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$line[6]\t$line[$ARGV[3]]\t$line[$ARGV[4]]\n";
        }
        if ( $line_count > 1 ) {
            @tumor  = split( /\:/, $line[$ARGV[3]] );
            @normal = split( /\:/, $line[$ARGV[4]] );
            @depth_T = split(/\,/,$tumor[1]);
            @depth_N = split(/\,/,$normal[1]);
            $tumor[0] =~ s/\|/\//;
            $normal[0] =~ s/\|/\//;
            if($tumor[2] >= $ARGV[1] and $normal[2] >= $ARGV[1] and $tumor[0] ne './.' and $normal[0] ne './.') {
                @tumor_gt = split(/\//,$tumor[0]);
                @normal_gt = split(/\//,$normal[0]);
                %hash_gt = ();
                foreach (@tumor_gt) {
                    $hash_gt{$_} = 1;
                }
                foreach (@normal_gt) {
                    $hash_gt{$_} = 1;
                }
                @all_gt = sort keys %hash_gt;
                #print "@all_gt\n";
                if($#all_gt <= 1) {
                    #print "test1\n";
                    $test_var = $depth_T[$all_gt[-1]]/$tumor[2];
                    $ref_var = $depth_N[$all_gt[-1]]/$normal[2];
                    $diff = abs($test_var - $ref_var);
                    #print "test1\t$diff\n"; 
                }
                elsif($#all_gt == 2 ) {
                    #print "test2\n";
                    $test_var = $depth_T[$tumor_gt[-1]]/$tumor[2];
                    $ref_var = $depth_N[$normal_gt[-1]]/$normal[2];
                    $diff = 0;
                    $diff1 = abs(($depth_T[$tumor_gt[0]]/$tumor[2])-($depth_N[$normal_gt[0]]/$normal[2]));
                    $diff2 = abs(($depth_T[$tumor_gt[1]]/$tumor[2])-($depth_N[$normal_gt[1]]/$normal[2]));
                    $diff3 = abs(($depth_T[$tumor_gt[2]]/$tumor[2])-($depth_N[$normal_gt[2]]/$normal[2]));
                    foreach ($diff1,$diff2,$diff3) {
                        if ($_ >= $ARGV[2]) {
                            $diff_num++;
                        }
                    }
                }
                else {
                    #print "test3\n";
                    $test_var = 0;
                    $ref_var = 0;
                    $diff = 0;
                }
                
            }
            else {
                #print "test4\n";
                $diff = 0 ;
                $test_var = 0;
                $ref_var = 0;
            }
            #$line[4] =~ s/\,.*//;
            
            if(($diff >= $ARGV[2] and (($test_var>0.95 or $test_var < 0.05) or ($ref_var > 0.95 or $ref_var < 0.05))) or ($diff_num >=2)) {
                print "$line[0]\t$line[1]\t$line[3]\t$line[4]\t$line[6]\t$line[$ARGV[3]]\t$line[$ARGV[4]]\n";
                $diff_num = 0;
            }
            
        }

    }
}

