#!/usr/bin/perl
#use strict;
#use warnings;
use File::Basename;
use Getopt::Long;
my %len = ();
my @line;
my $header;
my %hash1 = ();
my %hash2 = ();
my %hash3;
my $str_name;
my $type_name;
my $num;
my @num = "";
my $str_type;
my $name;
my @type_name;
my @num1 = "";
my $num2;
die "Usage: perl $0 misa primer.txt > out\n" unless ( @ARGV == 2 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";
open( STR, "$ARGV[1]" ) or die "Can not open file $ARGV[1]\n";
my ($sample) = ( $ARGV[0] =~ /^(.+)\.need.fasta.misa$/ );
print "pos\t$sample\n";
while(<STR>) {
    chomp;
    my @line = split(/\t/,$_);
    $len{$line[0]} = $line[0];
}
close STR;

while (<IN>) {
    chomp;
    my @line = split( /\t/, $_ );
    my @name = split( /\_/, $line[0] );
    if($name[2]>1) {
    
        $hash1{ $name[1] }+=$name[2];
        $hash2{ $name[1] . '_' . $line[3] }+=$name[2];
    }
}
foreach $str_name ( sort { $a cmp $b } values %len ) {
    if ( exists $hash1{$str_name} ) {
        foreach $type_name ( keys %hash2 ) {
            if ( $type_name =~ $str_name ) {
                @type_name = split( /\_/, $type_name );
                $num = $type_name[1] . '|' . $hash2{$type_name};
                $hash3{ $type_name[1] } = $hash2{$type_name};
                push @num, $num;
            }

            #elsif($type_name=~$str_name and $hash1{$str_name}<=10) {
            #        push @num,"NA";
            #}
        }
        shift @num;
        foreach ( sort { $hash3{$b} <=> $hash3{$a} } keys %hash3 ) {
            $num2 = $_ . '|' . $hash3{$_};
            push @num1, $num2;
        }
        shift @num1;
        $str_type = join( ";", @num1 );
        print "$str_name\t$str_type\n";
        @num   = "";
        @num1  = "";
        %hash3 = ();
    }
    elsif ( !exists $hash1{$str_name} ) {
        print "$str_name\tNA\n";
    }
}

