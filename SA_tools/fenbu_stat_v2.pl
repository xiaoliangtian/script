#!/usr/bin/perl
#Author:Tian
#Version:1.0.0
#Date:20180911

#Change Log###########

######################

#use strict;
#use warnings;

use Getopt::Long;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
my $output;
GetOptions(
    "o=s"    => \$output,
    "help|?" => \&USAGE,
) or &USAGE;
&USAGE unless ($output);

my %hash;
my %plot;
my $file3;
my @file;
my $snum  = 1;
my @files = <*.distrub>;
if ( scalar(@files) == 0 ) {
    die "the current floder do not have *.fenbu,please cheack";
}
foreach my $file (@files) {
    my ($sample) = ( $file =~ /^(.+)\.distrub$/ );
    open( FILE, "$file" ) or die "Can not open file $file\n";
    @file = <FILE>;
    $hash{0}{$sample} = $sample;

    #@file = split(/\n/,<FILE>);
    #print "@file\n";
    chomp(@file);
    $hash{1}{$sample} = ( split( /\t/, $file[1] ) )[1];
    $fam = $sample;
    $fam =~ s/\D+//g;
    $fam = substr( $fam, 0, 4 );
    #print "$fam\n";
    push @fam, $fam;
    my $out = ( split( /\t/, $file[1] ) )[1];

    #print "$out\n";
    $hash{2}{$sample} = ( split( /\t/, $file[2] ) )[1];
    $hash{3}{$sample} = ( split( /\t/, $file[3] ) )[1];
    $hash{4}{$sample} = ( split( /\t/, $file[4] ) )[1];
    $hash{5}{$sample} = ( split( /\t/, $file[5] ) )[1];
    $hash{6}{$sample} = ( split( /\t/, $file[6] ) )[1];
    $hash{7}{$sample} = ( split( /\t/, $file[7] ) )[1];
    $hash{8}{$sample} = ( split( /\t/, $file[8] ) )[1];
    $hash{9}{$sample} = ( split( /\t/, $file[9] ) )[1];
}
open( OUT, ">$output" );
$num = 0;
my @header = ( "Sample", "10", "20", "30", "40", "50", "60", "70", "80", "90" );
foreach $family (@fam) {
    open( OUT1, ">$family.stat" );

    #print "$family\n";
    $num++;
    foreach my $i ( sort { $a <=> $b } keys %hash ) {

        #$test = 'OUT'."$num";
        #open (OUT1,">$family.stat");
        print OUT1 "$header[$i]";
        if ( $num == 1 ) {
            print OUT "$header[$i]";
        }
        foreach ( sort keys %{ $hash{$i} } ) {
            if ( $_ =~ $family ) {
                if ( $hash{$i}{$_} ne "" ) {
                    print OUT1 "\t$hash{$i}{$_}";
                }
                if ( $hash{$i}{$_} eq "" ) {
                    print OUT1 "\t0";
                }

            }

            #print OUT1 "\n";
            if ( $num == 1 ) {
                if ( $hash{$i}{$_} ne "" ) {
                    print OUT "\t$hash{$i}{$_}";
                }
                if ( $hash{$i}{$_} eq "" ) {
                    print OUT "\t0";
                }
            }
        }
        if($num == 1 ) {
            print OUT "\n";
        }
        print OUT1 "\n";
    }
}

sub USAGE {
    my $usage = <<"USAGE";
USAGE:
    $0 [options]  -o summary.out

    -o <outputfile>  Output summary

    -h  --help       Help

USAGE
    print $usage;
    exit;
}
