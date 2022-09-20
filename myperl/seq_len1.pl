#/usr/bin/perl
use strict;

die "Usage: perl $0 FAA OUT\n" unless ( @ARGV == 2 );
open( FAA, $ARGV[0] )        or die "Can not open file $ARGV[0]\n";
open( OUT, ">$ARGV[1]" )     or die "Can not open file $ARGV[1]\n";
open( DIS, ">$ARGV[1].dis" ) or die "Can not open file $ARGV[1].dis\n";

my ( $name,    $seq )      = ( '', '' );
my ( $min,     $max )      = ( 0,  0 );
my ( $all_len, $citg_num ) = ( 0,  0 );
my (
    $two_three,       $three_four,        $four_five,         $five_six,          $six_seven,         $seven_eight,
    $eight_nine,      $nine_ten,          $ten_twelve,        $twelve_fourteen,   $fourteen_sixteen,  $sixteen_eighteen,
    $eighteen_twenty, $twenty_twentyfive, $twentyfive_thirty, $thirty_thirtyfive, $thirtyfive_fourty, $above_fourty
) = ( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

local $/ = "\n>";
while (<FAA>) {
    chomp;
    s/>//;
    my ( $name, $seq ) = split /\n/, $_, 2;
    $seq =~ s/\s+//g;
    my $seqlen = length($seq), "\n";

    #if($seqlen == 0){next;}
    $all_len = $all_len + $seqlen;
    $citg_num++;
    if ( $seqlen >= 200  && $seqlen < 300 )  { $two_three++ }
    if ( $seqlen >= 300  && $seqlen < 400 )  { $three_four++ }
    if ( $seqlen >= 400  && $seqlen < 500 )  { $four_five++ }
    if ( $seqlen >= 500  && $seqlen < 600 )  { $five_six++ }
    if ( $seqlen >= 600  && $seqlen < 700 )  { $six_seven++ }
    if ( $seqlen >= 700  && $seqlen < 800 )  { $seven_eight++ }
    if ( $seqlen >= 800  && $seqlen < 900 )  { $eight_nine++ }
    if ( $seqlen >= 900  && $seqlen < 1000 ) { $nine_ten++ }
    if ( $seqlen >= 1000 && $seqlen < 1200 ) { $ten_twelve++ }
    if ( $seqlen >= 1200 && $seqlen < 1400 ) { $twelve_fourteen++ }
    if ( $seqlen >= 1400 && $seqlen < 1600 ) { $fourteen_sixteen++ }
    if ( $seqlen >= 1600 && $seqlen < 1800 ) { $sixteen_eighteen++ }
    if ( $seqlen >= 1800 && $seqlen < 2000 ) { $eighteen_twenty++ }
    if ( $seqlen >= 2000 && $seqlen < 2500 ) { $twenty_twentyfive++ }
    if ( $seqlen >= 2500 && $seqlen < 3000 ) { $twentyfive_thirty++ }
    if ( $seqlen >= 3000 && $seqlen < 3500 ) { $thirty_thirtyfive++ }
    if ( $seqlen >= 3500 && $seqlen < 4000 ) { $thirtyfive_fourty++ }
    if ( $seqlen >= 4000 ) { $above_fourty++ }
    print OUT ">$name\t", $seqlen, "\n";

    if ( $min == 0 ) {
        $min = $seqlen;
    }
    else {
        if ( $min >= $seqlen ) {
            $min = $seqlen;
        }
    }
    if ( $max == 0 ) {
        $max = $seqlen;
    }
    else {
        if ( $max <= $seqlen ) {
            $max = $seqlen;
        }
    }
}
close(FAA);
local $/ = "\n";
close OUT;

my $avg_len = $all_len / $citg_num;
print DIS "200-300",   "\t", $two_three,         "\n";
print DIS "300-400",   "\t", $three_four,        "\n";
print DIS "400-500",   "\t", $four_five,         "\n";
print DIS "500-600",   "\t", $five_six,          "\n";
print DIS "600-700",   "\t", $six_seven,         "\n";
print DIS "700-800",   "\t", $seven_eight,       "\n";
print DIS "800-900",   "\t", $eight_nine,        "\n";
print DIS "900-1000",  "\t", $nine_ten,          "\n";
print DIS "1000-1200", "\t", $ten_twelve,        "\n";
print DIS "1200-1400", "\t", $twelve_fourteen,   "\n";
print DIS "1400-1600", "\t", $fourteen_sixteen,  "\n";
print DIS "1600-1800", "\t", $sixteen_eighteen,  "\n";
print DIS "1800-2000", "\t", $eighteen_twenty,   "\n";
print DIS "2000-2500", "\t", $twenty_twentyfive, "\n";
print DIS "2500-3000", "\t", $twentyfive_thirty, "\n";
print DIS "3000-3500", "\t", $thirty_thirtyfive, "\n";
print DIS "3500-4000", "\t", $thirtyfive_fourty, "\n";
print DIS ">4000",     "\t", $above_fourty,      "\n";
print "Total number\t$citg_num\n";
print "Average length\t$avg_len\n";
print "Minuimun length\t$min\n";
print "Maximun length\t$max\n";
