#!/usr/bin/perl
#use strict;
#use warnings;
die "Usage: perl $0 in out qianhe \n" unless ( @ARGV == 3 );
open( IN,  "$ARGV[0]" )  or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
open( QH, ">$ARGV[2]" ) or die "Can not open file $ARGV[2]\n";

my ( $cnv, $type, $true_type, $size );
my ( %hash, %hash1 );
my $header = <IN>;
print OUT "cnv\tchromosome\tstart\tend\tsize\ttype\ttrue_type\n";
my $num = 0;
while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    $num++;
    $cnv  = 'CNVR'.$num;
    $size = $line[2] - $line[1] + 1;
    if ( $line[0] eq 'Y' ) {
        $type      = sprintf( "%.0f", 2**$line[4] * 1 );
        $true_type = sprintf( "%.2f", 2**$line[4] * 1 );
    }
    else {
        $type      = sprintf( "%.0f", 2**$line[4] * 2 );
        $true_type = sprintf( "%.2f", 2**$line[4] * 2 );
    }
    $qianhe = abs($type -$true_type);
    if ( ($type eq 2 and $line[0] ne 'X' and $line[0] ne 'Y' and $qianhe <=0.2) or ($type eq 2 and $size < 2000000 and $line[0] ne 'X' and $line[0] ne 'Y') ) {
	$hashQhChr{$line[0]} += $size;
	$hashQh1{ $line[0] } += $size*$true_type;
        print OUT "$cnv\t$line[0]\t$line[1]\t$line[2]\t$size\t$type\t$true_type\n";
    }
    else {
	print OUT "$cnv\t$line[0]\t$line[1]\t$line[2]\t$size\t$type\t$true_type\n";
        $out                                                              = "$cnv\t$line[0]\t$line[1]\t$line[2]\t$size\t$type\t$true_type";
        $hash{ $line[0] }                                                 = 1;
        $hash1{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $cnv } = $type;
        $hash2{ $line[0] . '_' . $line[1] . '_' . $line[2]. '_' . $cnv }              = $out;
        $hashQhChr{$line[0]} += $size;
        $hashQh1{ $line[0] } += $size*$true_type;
    }
}
close(IN);
close(OUT);

my $cnv_num = 0;
print "cnv\tchromosome\tstart\tend\tsize\ttype\ttrue_type\n";
foreach $h ( sort { $a <=> $b } keys %hash ) {
    foreach $i ( sort { ( split /CNVR/, $a )[1] <=> ( split /CNVR/, $b )[1] } keys %hash1 ) {
        @group  = split( /\_/, $i );
        @result = split( /\t/, $hash2{$i} );
        if ( ( split /\_/, $i )[0] eq $h ) {
            $num1++;
            if ( $num1 == 1 ) {
                $sum    = 0;
                $type   = $hash1{$i};
                $start  = $group[1];
                $end    = $group[2];
                $chrome = $group[0];
                print  'CNVR' . "$cnv_num\t$chrome\t$start\t";
                $num1++;
                $sum += $result[4];
                $read_sum += $result[4] * $result[-1];
		#print "$result[4]\n";
            }
            elsif ( ( $num1 > 1 and ( $group[1] - $end ) > 1 ) or ( $num1 > 1 and $hash1{$i} != $type ) ) {
                $cnv_num++;
                $num1++;
                $lens = $end - $start + 1;
                $true_type = $read_sum / ($lens);
		#print "$read_sum\n";
                print "$end\t$lens\t$type\t$true_type\n" . 'CNVR'
                  . $cnv_num . "\t"
                  . ( split /\_/, $i )[0] . "\t"
                  . ( split /\_/, $i )[1] . "\t";
                $type = $hash1{$i};

                $sum      = 0;
                $read_sum = 0;
                $read_sum += $result[4] * $result[-1];
                $sum += $result[4];
                $start = ( split /\_/, $i )[1];
                $end   = ( split /\_/, $i )[2];
            }
            elsif ( $num1 > 1 and ( ( split /\_/, $i )[1] - $end ) <= 1 and $hash1{$i} == $type ) {
                $end = ( split /\_/, $i )[2];
                $num1++;
                $sum += $result[4];
                $read_sum += $result[4] * $result[-1];
            }
        }
    }
    	$last = $end - $start + 1;

    	$true_type = $read_sum / ($last);
    	print  "$end\t" . $last . "\t" . ($type) . "\t$true_type\n";
    	$cnv_num++;
    	$sum      = 0;
    	$num1     = 0;
    	$read_sum = 0;
    
}

print QH "chr\tqianhe_rate\n";
foreach (sort {$a<=>$b} keys %hashQhChr) {
	$qianhe = abs($hashQh1{$_}/$hashQhChr{$_}-2);
	print QH 'chr'."$_\t$qianhe\n";
}
