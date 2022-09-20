#! /usr/bin/perl #-w
#use strict;
use Getopt::Long;
##############usage##############################
die "Usage:
    perl [script] -i [input_vcf] -o [output_file] -m [mother_hap]  -f [father_hap]

        -i  input: str txt or vcf file
        -o  output
        -hapm  mom.hap,0
        -hapf  dad.hap,0
        -f column
        -m column
        "
  unless @ARGV >= 1;

########################

my $in;
my $out;
my $mom;
my $dad;
my $f;
my $m;
Getopt::Long::GetOptions(
    'i=s'    => \$in,
    'o=s'    => \$out,
    'hapm:s' => \$mom,
    "hapf:s" => \$dad,
    'm:i'    => \$m,
    'f:i'    => \$f,

);

my @mom = split( /\,/, $mom );
my @dad = split( /\,/, $dad );

open VCF, "<$in"
  or die "Cannot open file $in!\n";
open MOM, "<$mom[0]"
  or die "Cannot open file $mom[0]!\n";
open DAD, "<$dad[0]"
  or die "Cannot open file $dad[0]!\n";
open OUT, ">>$out"
  or die "Cannot open file $out!\n";

my $line_count = 0;
my $snp_ms     = 0;
my $snp_f      = 0;
my @result;
my $line;

while (<MOM>) {
    chomp;
    @line = split( /\t/, $_ );
    if ( $mom[1] == 0 ) {
        $hashmom{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[4];
    }
    else {
        $hashmom{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[5];
    }
}

close(MOM);

while (<DAD>) {
    chomp;
    @line = split( /\t/, $_ );

    #$line = join("\t",@line);
    if ( $dad[1] == 0 ) {
        $hashdad{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[4];
    }
    else {
        $hashdad{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } = $line[5];
    }
}
close(DAD);

while (<VCF>) {
    chomp;
    $line = $_;

    if ( substr( $line, 0, 2 ) ne "##" ) {
        $line_count++;
        if ( $line_count ==1) {
            print "$line\n";
        }
        my @line = split /\t/, $line;
        my @momGeno  = split /\:/, $line[$m];
        #$hapmom = ( split '\/', $momGeno[0]  )[0];
        my @mom_var = split /\,/, $momGeno[1];

        #  my $mom_var=$mom_var[1]/$mom[2];
        my @dadGeno = split /\:/, $line[$f];
        my @dad_var = split /\,/, $dadGeno[1];

        #  my $dad_var=$dad_var[1]/$dad[2];
        $line = join( "\t", @line );
        if ( $line_count > 1 and (substr( $line[$m], 0, 3 ) eq "0/1"
            or substr( $line[$f], 0, 3 ) eq "0/1" ))
        {
            if (    exists $hashdad{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] }
                and exists $hashmom{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } )
            {
                print "$line\t$hashdad{$line[0].'_'.$line[1].'_'.$line[2].'_'.$line[3]}/$hashmom{$line[0].'_'.$line[1].'_'.$line[2].'_'.$line[3]}\n";
            }
            elsif ( exists $hashdad{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } and $momGeno[0] ne '0/1' ) {
                $hapmom = ( split '\/', $momGeno[0] )[0];
                #print "f\n";
                print "$line\t$hashdad{$line[0].'_'.$line[1].'_'.$line[2].'_'.$line[3]}/$hapmom\n";
            }
            elsif ( exists $hashmom{ $line[0] . '_' . $line[1] . '_' . $line[2] . '_' . $line[3] } and $dadGeno[0] ne '0/1' ) {
                $hapdad = ( split '\/', $dadGeno[0]  )[0];
                print "$line\t$hapdad/$hashmom{$line[0].'_'.$line[1].'_'.$line[2].'_'.$line[3]}\n";
            }
            else {
                next;
            }
        }
        elsif ( $line_count > 1 and $momGeno[0] ne '0/1' and $dadGeno[0] ne '0/1' ) {
            $hapmom = ( split '\/', $momGeno[0]  )[0];
            $hapdad = ( split '\/', $dadGeno[0]  )[0];
            print "$line\t$hapdad/$hapmom\n";
        }
    }
}
