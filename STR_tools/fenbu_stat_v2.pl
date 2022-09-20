#!/usr/bin/perl
#Author:Tian
#Version:1.0.0
#Date:20180911

#Change Log###########

######################

use strict;
use warnings;

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
    $hash{10}{$sample} = ( split( /\t/, $file[10] ) )[1];
    $hash{11}{$sample} = ( split( /\t/, $file[11] ) )[1];
    $hash{12}{$sample} = ( split( /\t/, $file[12] ) )[1];
    $hash{13}{$sample} = ( split( /\t/, $file[13] ) )[1];
    $hash{14}{$sample} = ( split( /\t/, $file[14] ) )[1];
    $hash{15}{$sample} = ( split( /\t/, $file[15] ) )[1];
    $hash{16}{$sample} = ( split( /\t/, $file[16] ) )[1];
    $hash{17}{$sample} = ( split( /\t/, $file[17] ) )[1];
    $hash{18}{$sample} = ( split( /\t/, $file[18] ) )[1];
}
open( OUT, ">$output" );
my @header = ( "Sample", "10", "15", "20","25", "30","35", "40","45", "50","55", "60","65", "70","75", "80","85", "90","95" );
foreach my $i ( sort { $a <=> $b } keys %hash ) {
    print OUT "$header[$i]";
    foreach ( sort keys %{ $hash{$i} } ) {
        if ( $hash{$i}{$_} ne "" ) {
            print OUT "\t$hash{$i}{$_}";
        }
        if ( $hash{$i}{$_} eq "" ) {
            print OUT "\t0";
        }
    }
    print OUT "\n";
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
