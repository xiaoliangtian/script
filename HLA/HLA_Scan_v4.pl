#!/usr/bin/perl
#use strict;
#use warnings;
use List::MoreUtils qw(mesh);

my $result;
my $length = 0;
my ( $len, $read, $reads, @read, $map );
my ( %hashNameNum, %hashread );


die "Usage: perl $0 bam gene.name\n" unless ( @ARGV == 2 );
open( SAM, "samtools view $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";

######change v3 ######
my $refPath = '/home/tianxl/pipeline/myperl/HLA_type/alignments/ref/';
my $ref = $ARGV[1].".ref.fa";
my $refreads;
open(REF, "$refPath\/$ref") or die "Can not open file $refPath\/$ref\n";
while (<REF>) {
    chomp;
    $line_count++; 
    if($line_count ==2) {
        $refreads = $_;
        my @line = split(//,$_);
        foreach (@line) {
            $baseNum++;
            $hashrefbase{$baseNum.':'.$_}=1;
            $hashrefbase{($baseNum+0.5).':D'}=1;
            #print "$baseNum\t$_\n";
        }
    }
}


while (<SAM>) {
    chomp;
    my @line = split( /\t/, $_ );

    #$hashNameNum{ $line[0] }++;
    if ( $line[5] ne '*' and abs($line[8])>0  ) {
        my $bow = $line[3];
        while ( $line[5] =~ /([0-9]+[A-Z])/g ) {

            $map = $1;
            $len = $map;
            $len =~ s/[A-Z]+//g;

            #print "$map\n";
            if ( $map =~ 'S' ) {
                $length += $len;
            }
            elsif ( $map =~ 'M' ) {
                $read = substr( $line[9], $length, $len );
                @read = split( //, $read );
                foreach (@read) {
                    $num++;
                    if ( $num > 1 ) {
                        $reads .= ( $bow - 0.5 ) . ':D' . '_' . $bow . ':' . $_ . '_';
                        $hashbase{$bow}++;
                        $hashbase{ $bow - 0.5 }++;
                        $hashbase1{ $bow . ':' . $_ }++;
                        $hashbase1{ ( $bow - 0.5 ) . ':D' }++;
                        $bow++;
                    }
                    else {
                        $reads .= $bow . ':' . $_ . '_';
                        $hashbase{$bow}++;
                        $hashbase1{ $bow . ':' . $_ }++;
                        $bow++;
                    }
                }
                $num = 0;
                $length += $len;
            }
            elsif ( $map =~ 'I' ) {
                $read = substr( $line[9], $length, $len );
                $bow = $bow - 0.5;
                $reads .= $bow . ':+' . $read . '_';
                $hashbase1{ $bow . ':+' . $read }++;
                $hashbase{$bow}++;
                ####change_v2###
                
                $bow = $bow + 0.5;
                $length += $len;
            }
            elsif ( $map =~ 'D' ) {
                $read = substr( $refreads, ($bow-1), $len );
                $reads .= $bow . ':-' . $read . '_';
                $hashbase{$bow}++;
                $hashbase1{ $bow . ':-'. $read }++;
                ####change_v2###
                $hashbase{$bow-0.5}++;
                $hashbase1{($bow-0.5).':D'}++;
                $hashbase{$bow+$len-0.5}++;
                $hashbase1{($bow+$len-0.5).':D'}++;
                ################
                $bow += $len;
            }
            else {
                print "$line[0] no match bowtie2\n";
            }

            #print "$1\n";
        }
        $reads =~ s/\_$//;
        #print "$line[0]\t$reads\n";
        $hashNameNum{ $line[0] }++;

        #$hashreadname{ $line[0] }++;
        #$hashread{ $line[0] . '_' . $hashNameNum{ $line[0] } } = $reads;

        #$hashread{ $line[0]} .= $reads.'_';
        $reads  = undef;
        $length = 0;

    }
}

foreach (keys %hashbase) {
    $numbase++;
    $allbase += $hashbase{$_};
}
$mean = $allbase/$numbase;

foreach ( keys %hashbase1 ) {
    if ( $hashbase1{$_} > 2 ) {
        $pos = ( split /\:/, $_ )[0];
        #print "$_\t$hashbase1{$_}\t$hashbase{$pos}\n";
        $ratio = $hashbase1{$_} / $hashbase{$pos};
        $ratioTF = $hashbase1{$_}/$mean;
        print "$_\t$hashbase1{$_}\t$hashbase{$pos}\t$ratio\t$mean\n"; 
        if ( $ratio > 0.35 and $ratioTF > 0.35) {
            $hashpos{$pos}++;
            $hashpos1{$pos}.=( split /\:/, $_ )[1].'_';
        }
    }
}

foreach $posalle ( keys %hashbase1 ) {
    $pos = ( split /\:/, $posalle )[0];
    $ratio = $hashbase1{$posalle} / $hashbase{$pos};
    if ( $hashpos{$pos} >= 2 and $ratio > 0.35) {
        $hashresultBase1{$posalle} = 1;
        
        print "2\t$posalle\n";
    }
    elsif($hashpos{$pos} == 1 and $ratio > 0.35 and $hashbase1{$posalle} >2 and !exists $hashrefbase{$posalle} ) {
        $hashresultBase2{$posalle} = 1;
        #$hashpos1{$pos} = ( split /\:/, $posalle )[1];
        print "1\t$posalle\n";
    }
    #elsif($hashpos{$pos} == 1 and $ratio > 0.2 and $hashbase1{$posalle} >2 and exists $hashrefbase{$posalle} ) {
    #    $hashpos1{$pos} = ( split /\:/, $posalle )[1];
    #}
    
}

foreach ( sort{(split/\:/,$a)[0] <=> (split/\:/,$b)[0]} keys %hashrefbase) {
    @line = split(/:/,$_);
    $hashpos1{$line[0]} =~ s/\_$//;
    
    if($hashpos{$line[0]}==0 and $hashpos1{$line[0]} ne 'D') {
        $contig .= 'N';
    }
    elsif($hashpos{$line[0]} == 1 and $hashpos1{$line[0]} ne 'D' ) {
        if($hashpos1{$line[0]} =~ '-') {
            $contig = $contig;
        }
        else{
            $contig .= $hashpos1{$line[0]};
        }
        print "$line[0]\t$hashpos1{$line[0]}\t$contig\n";
    }
    elsif($hashpos{$line[0]} == 2) {
        @contig = split(/\_/,$hashpos1{$line[0]});
        if($contig[0]  =~ '-') {
            $hashcontigs{$line[0].':'.$contig[0]}=$contig;
        }
        else {
            $hashcontigs{$line[0].':'.$contig[0]}=$contig.$contig[0];
        }
        if($contig[1]  =~ '-') {
            $hashcontigs{$line[0].':'.$contig[1]}=$contig;
        }
        else {
            $hashcontigs{$line[0].':'.$contig[1]}=$contig.$contig[1];
        }
        #$hashcontigs{$line[0].':'.$contig[0]}=$contig.$contig[0];
        #$hashcontigs{$line[0].':'.$contig[1]}=$contig.$contig[1];
        print "$line[0]_$contig[0]\t$contig$contig[0]\n$line[0]_$contig[1]\t$contig$contig[1]\n";
        $contig = undef;
    }
    
}
print "$contig\n";
    


open( SAM, "samtools view $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
while (<SAM>) {
    chomp;
    my @line = split( /\t/, $_ );

    #$hashNameNum{ $line[0] }++;
    if ( $line[5] ne '*' and abs($line[8])>0) {
        my $bow = $line[3];
        while ( $line[5] =~ /([0-9]+[A-Z])/g ) {

            $map = $1;
            $len = $map;
            $len =~ s/[A-Z]+//g;

            #print "$map\n";
            if ( $map =~ 'S' ) {
                $length += $len;
            }
            elsif ( $map =~ 'M' ) {
                $read = substr( $line[9], $length, $len );
                @read = split( //, $read );
                foreach (@read) {
                    $num++;
                    #print "0\t".$bow . ':' . $_ . '_'."\n";
                    
                    if ( $num > 1 and exists $hashresultBase1{ $bow . ':' . $_ } and exists $hashresultBase1{ ( $bow - 0.5 ) . ':D' } ) {
                        $reads .= ( $bow - 0.5 ) . ':D' . '_' . $bow . ':' . $_ . '_';
                        #print "1\t".( $bow - 0.5 ) . ':D' . '_' . $bow . ':' . $_ . '_'."\n";
                        #$hashbase{$bow}++;
                        #$hashbase{ $bow - 0.5 }++;
                        #$hashbase1{ $bow . ':' . $_ }++;
                        #$hashbase1{ ( $bow - 0.5 ) . ':D' }++;
                        #$bow++;
                    }
                    elsif ( $num > 1 and exists $hashresultBase1{ $bow . ':' . $_ } ) {
                        $reads .= $bow . ':' . $_ . '_';
                        #print "2\t".$bow . ':' . $_ . '_'."\n";
                        #$bow++;
                    }
                    elsif ( $num > 1 and exists $hashresultBase1{ ( $bow - 0.5 ) . ':D' } ) {
                        $reads .= ( $bow - 0.5 ) . ':D' . '_';
                        #print "3\t".( $bow - 0.5 ) . ':D' . '_'."\n";
                        #$bow++;
                    }
                    elsif ( $num == 1 and exists $hashresultBase1{ $bow . ':' . $_ } ) {
                        $reads .= $bow . ':' . $_ . '_';
                        #print "4\t".$bow . ':' . $_ . '_'."\n";
                        #$hashbase{$bow}++;
                        #$hashbase1{ $bow . ':' . $_ }++;
                        #$bow++;
                    }
                    #####change v3#####
                    elsif(exists $hashresultBase2{ $bow . ':' . $_ }) {
                        $reads .= $bow . ':' . $_ . '_';
                    }
                    #########
                    else {
                        #print "5\t".$bow . ':' . $_."\n";
                    }
                    $bow++;
                }
                $num = 0;
                $length += $len;
            }
            elsif ( $map =~ 'I' ) {
                $read = substr( $line[9], $length, $len );
                $bow = $bow - 0.5;
                $reads .= $bow . ':+' . $read . '_';

                #$hashbase1{ $bow . ':+' . $read }++;
                #$hashbase{$bow}++;
                $bow = $bow + 0.5;
                $length += $len;
            }
            elsif ( $map =~ 'D' ) {
                $read = substr( $refreads, ($bow-1), $len );
                $reads .= $bow . ':-'.$read . '_';

                #$hashbase{$bow}++;
                #$hashbase1{ $bow . ':-' }++;
                $bow += $len;
            }
            else {
                print "$line[0] no match bowtie2\n";
            }

            #print "$1\n";
        }
        $reads =~ s/\_$//;
        #print "$line[0]\t$reads\n";
        $hashNameNum1{ $line[0] }++;

        #$hashreadname{ $line[0] }++;
        $hashread1{ $line[0] } .= $reads . '_';

        #$hashread{ $line[0]} .= $reads.'_';
        $reads  = undef;
        $length = 0;

    }
}
foreach $name ( keys %hashread1 ) {
    #print "$name\n";
    $hashread1{$name} =~ s/_$//;
    print "$name\t$hashread1{$name}\n";
    #for ( $i = 1 ; $i <= $hashNameNum{$name} ; $i++ ) {
    @bases = split( /\_/, $hashread1{$name} );
    foreach $posBase (@bases) {
        if($posBase != '') {
            @pb = split(/\:/,$posBase);
            $hashpb{$pb[0]}++;
            $hashpb1{$pb[0]} .= $pb[1].'_'; 
        }
    }
    
    foreach ( keys %hashpb) {
        if($hashpb{$_}==2) {
            $hashpb1{$_} =~ s/\_$//;
            @pb = split(/\_/,$hashpb1{$_});
            if($pb[0] ne $pb[1]) {
                $numfalse++;
            }
        }
        elsif($hashpb{$_}==1){
            
        }
        else{
            print "$_\t$hashpb{$_}\thashfalse\t";
        }
    }
    if($numfalse >=1) {
        print "false\n";
        
    }
    else{
        
    #print "@bases\n";
    #@bases = mesh @bases, @base;
    #}
    #foreach $name ( keys %hashread ) {
    #print "$name\n";
    #$hashread{$name}=~s/_$//;
    #@bases = split( /\_/, $hashread{ $name } );
    foreach $posBase1 (@bases) {
        
        foreach $posBase2 (@bases) {
            
            $hashresult{ $posBase1 . '_' . $posBase2 }++;
        }
    }}
    $numfalse = 0;
    %hashpb1 =();
    %hashpb=();
    #@bases = "";
}

#foreach $posBase1 ( @bases ) {
#if($posBase1 ne "") {
#print "$posBase1\n";
#$pos1 = ( split /\:/, $posBase1 )[0];
#$ratio1 = $hashbase1{$posBase1} / $hashbase{$pos1};
#}
#else{
#$ratio1 = 0;
#}
#foreach $posBase2 ( @bases ) {
#if($posBase2 ne "") {
#$pos2 = ( split /\:/, $posBase2 )[0];
#$ratio2 = $hashbase1{$posBase2} / $hashbase{$pos2};
#}
#else {
#$ratio2 = 0;
#}
#if ( $ratio1 > 0.01 and $ratio2 > 0.01 and $hashbase1{$posBase1} >1 and $hashbase1{$posBase2} >1 ) {
#$hashresult{ $posBase1 . '_' . $posBase2 }++;

#}
#}
#}
#@bases = "";
#}

$out = join( "\t", sort { ( split /\:/, $a )[0] <=> ( split /\:/, $b )[0] } keys %hashresultBase1 );
print "\t$out\n";
foreach my $i ( sort { ( split /\:/, $a )[0] <=> ( split /\:/, $b )[0] } keys %hashresultBase1 ) {
    print "$i";
    foreach my $h ( sort { ( split /\:/, $a )[0] <=> ( split /\:/, $b )[0] } keys %hashresultBase1 ) {
        if ( exists $hashresult{ $i . '_' . $h } ) {
            print "\t$hashresult{$i.'_'.$h}";
        }
        else {
            print "\t0";
        }
    }
    print "\n";
}

foreach ( sort{(split/\:/,$a)[0] <=> (split/\:/,$b)[0]} keys %hashrefbase) {
    @line = split(/:/,$_);
    $hashpos1{$line[0]} =~ s/\_$//;
    
    if($hashpos{$line[0]} == 2) {
        $numcount++;
        if($numcount == 1) {
            @contig = split(/\_/,$hashpos1{$line[0]});
            $start1 = $line[0].':'.$contig[0];
            $start2 = $line[0].':'.$contig[1];
            $combContig1 = $hashcontigs{$start1};
            $combContig2 = $hashcontigs{$start2};
        }
        if($numcount >1 ) {
            @contig = split(/\_/,$hashpos1{$line[0]});
            $next1 = $line[0].':'.$contig[0];
            $next2 = $line[0].':'.$contig[1];
            if($hashresult{$start1.'_'.$next1} >10 or $hashresult{$start1.'_'.$next2} > 10 ) {
                if($hashresult{$start1.'_'.$next1} >10 and $hashresult{$start1.'_'.$next1} > $hashresult{$start1.'_'.$next2}) {
                    $combContig1 .= $hashcontigs{$next1};
                    $combContig2 .= $hashcontigs{$next2};
                    $start1 = $next1;
                    $start2 = $next2;
                }
                elsif($hashresult{$start1.'_'.$next2} > 10 and $hashresult{$start1.'_'.$next1} < $hashresult{$start1.'_'.$next2}) {
                    $combContig1 .= $hashcontigs{$next2};
                    $combContig2 .= $hashcontigs{$next1};
                    $start1 = $next2;
                    $start2 = $next1;
                }
                else {
                    print "combine false\n";
                }
                
            }
            else {
                $combContig1 =~ s/N//g;
                $combContig1 =~ s/\+//g;
                $combContig1 =~ s/D//g;
                $combContig2 =~ s/N//g;
                $combContig2 =~ s/\+//g;
                $combContig2 =~ s/D//g;
                print ">$next1\n$combContig1\n>$next2\n$combContig2\n";
                $start1 = $next1;
                $start2 = $next2;
                $combContig1 = $hashcontigs{$start1};
                $combContig2 = $hashcontigs{$start2};
            }
        }
    }
}
$lastread1 = $combContig1.$contig;
$lastread1 =~ s/N//g;
$lastread1 =~ s/\+//g;
$lastread1 =~ s/D//g;
$lastread2 = $combContig2.$contig;
$lastread2 =~ s/N//g;
$lastread2 =~ s/\+//g;
$lastread2 =~ s/D//g;
print ">last1\n$lastread1\n>last2\n$lastread2\n";
