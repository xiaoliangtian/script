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
    if ( $line[5] ne '*'){# and abs($line[8])>0) {
        my $bow = $line[3];
        while ( $line[5] =~ /([0-9]+[A-Z])/g ) {

            $map = $1;
            $len = $map;
            $len =~ s/[A-Z]+//g;
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
                @readbases = split(//,$read);
                $basepos = $bow;
                foreach (@readbases) {
                    
                    $reads .= $basepos.':-'.$_.'_';
                    $hashbase{$basepos}++;
                    $hashbase1{ $basepos . ':-'. $_ }++;
                    $hashbase{$basepos-0.5}++;
                    $hashbase1{($basepos-0.5).':D'}++;
                    $basepos++;
                }
                $bow += $len;
            }
            else {
                #print "$line[0] no match bowtie2\n";
            }
        }
        $reads =~ s/\_$//;
        $hashNameNum{ $line[0] }++;
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
        $ratio = $hashbase1{$_} / $hashbase{$pos};
        $ratioTF = $hashbase1{$_}/$mean;
        $hashratio{$_} = $ratio;
        #if($_ =~ /\:\+/) {
        #    $ratio = $ratio+0.2;
        #    $ratioTF = $ratioTF+0.2;
        #}
        #elsif($_ =~ /\.5\:D/) {
        #    $ratio = $ratio-0.2;
            #$ratioTF = $ratioTF-0.2;
        #}
######        print "$_\t$hashbase1{$_}\t$hashbase{$pos}\t$ratio\t$mean\n"; 
        if ( $ratio > 0.1 ) {
            $hashpos{$pos}++;
            $hashpos1{$pos}.=( split /\:/, $_ )[1].'_';
            
        }
    }
}

foreach $posalle ( keys %hashbase1 ) {
    $pos = ( split /\:/, $posalle )[0];
    $ratio = $hashbase1{$posalle} / $hashbase{$pos};
    #if($posalle =~ /\:\+/) {
    #    $ratio = $ratio+0.2;
        #$ratioTF = $ratioTF+0.2;
    #}
    #elsif($posalle =~ /\.5\:D/) {
    #    $ratio = $ratio-0.2;
        #$ratioTF = $ratioTF-0.2;
    #}
    if ( $hashpos{$pos} >= 2 and $ratio > 0.1) {
        $hashresultBase1{$posalle} = 1;
        
######        print "2\t$posalle\n";
    }
    elsif($hashpos{$pos} == 1 and $ratio > 0.1 and $hashbase1{$posalle} >2 and !exists $hashrefbase{$posalle} ) {
        $hashresultBase2{$posalle} = 1;
        #$hashpos1{$pos} = ( split /\:/, $posalle )[1];
######        print "1\t$posalle\n";
    }
    #elsif($hashpos{$pos} == 1 and $ratio > 0.2 and $hashbase1{$posalle} >2 and exists $hashrefbase{$posalle} ) {
    #    $hashpos1{$pos} = ( split /\:/, $posalle )[1];
    #}
    
}

foreach ( sort{(split/\:/,$a)[0] <=> (split/\:/,$b)[0]} keys %hashrefbase) {
    @line = split(/:/,$_);
    $hashpos1{$line[0]} =~ s/\_$//;
    
    if($hashpos{$line[0]}==0 and $hashpos1{$line[0]} ne 'D' and $line[0] !~ /\.5/) {
        $contig .= 'N';
######        print "$line[0]\t$hashpos1{$line[0]}\t$contig\n";
    }
    elsif($hashpos{$line[0]} == 1 and $hashpos1{$line[0]} ne 'D' and $hashpos1{$line[0]} ne "") {
        if($hashpos1{$line[0]} =~ '-') {
            #$lenDel = length($hashpos1{$line[0]})-2;
            $contig = $contig;
            #print "1\tdel\t$lenDel\t$contig\n";
        }
        else{
            $contig .= $hashpos1{$line[0]};
        }
######        print "$line[0]\t$hashpos1{$line[0]}\t$contig\n";
    }
    elsif($hashpos{$line[0]} >= 2) {
        @contig = split(/\_/,$hashpos1{$line[0]});
        foreach (@contig) {
            if($_ =~ '-') {
                $hashcontigs{$line[0].':'.$_}=$contig;
            }
            else {
                $hashcontigs{$line[0].':'.$_}=$contig.$_;
            }
######            print "$line[0]_$_\t$contig$_\n";
        }
        $contig = undef;
    
        #if($contig[0]  =~ '-') {
        #    $hashcontigs{$line[0].':'.$contig[0]}=$contig;
        #}
        #else {
        #    $hashcontigs{$line[0].':'.$contig[0]}=$contig.$contig[0];
        #}
        #if($contig[1]  =~ '-') {
        #    $hashcontigs{$line[0].':'.$contig[1]}=$contig;
        #}
        #else {
        #    $hashcontigs{$line[0].':'.$contig[1]}=$contig.$contig[1];
        #}
        #$hashcontigs{$line[0].':'.$contig[0]}=$contig.$contig[0];
        #$hashcontigs{$line[0].':'.$contig[1]}=$contig.$contig[1];
        #print "$line[0]_$contig[0]\t$contig$contig[0]\n$line[0]_$contig[1]\t$contig$contig[1]\n";
        #$contig = undef;
    }
    elsif($hashpos1{$line[0]} ne 'D') {
######        print "$line[0]\t$hashpos{$line[0]}\t$hashpos1{$line[0]}\tfalse\n";
    }
    
}
#print "$contig\n";
    


open( SAM, "samtools view $ARGV[0]|" ) or die "Can not open file $ARGV[0]\n";
while (<SAM>) {
    chomp;
    my @line = split( /\t/, $_ );

    #$hashNameNum{ $line[0] }++;
    if ( $line[5] ne '*'){# and abs($line[8])>0) {
        my $bow = $line[3];
        while ( $line[5] =~ /([0-9]+[A-Z])/g ) {

            $map = $1;
            $len = $map;
            $len =~ s/[A-Z]+//g;
            if ( $map =~ 'S' ) {
                $length += $len;
            }
            elsif ( $map =~ 'M' ) {
                $read = substr( $line[9], $length, $len );
                @read = split( //, $read );
                foreach (@read) {
                    $num++;
                    
                    if ( $num > 1 and exists $hashresultBase1{ $bow . ':' . $_ } and exists $hashresultBase1{ ( $bow - 0.5 ) . ':D' } ) {
                        $reads .= ( $bow - 0.5 ) . ':D' . '_' . $bow . ':' . $_ . '_';
                    }
                    elsif ( $num > 1 and exists $hashresultBase1{ $bow . ':' . $_ } ) {
                        $reads .= $bow . ':' . $_ . '_';
                    }
                    elsif ( $num > 1 and exists $hashresultBase1{ ( $bow - 0.5 ) . ':D' } ) {
                        $reads .= ( $bow - 0.5 ) . ':D' . '_';
                    }
                    elsif ( $num == 1 and exists $hashresultBase1{ $bow . ':' . $_ } ) {
                        $reads .= $bow . ':' . $_ . '_';
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
                @readbases = split(//,$read);
                $basepos = $bow;
                foreach (@readbases) {
                    
                    $reads .= $basepos.':-'.$_.'_';
                    $basepos++;
                }
                $bow += $len;
            }
            else {
                #print "$line[0] no match bowtie2\n";
            }
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
######    print "$name\t$hashread1{$name}\n";
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
            $numfalse++;
#######            print "$_\t$hashpb{$_}\thashfalse\t";
        }
    }
    if($numfalse >=1) {
######        print "false\t$name\n";
        
    }
    else{
    foreach $posBase1 (@bases) {
        @posBase1 = split(/\:/,$posBase1);
        foreach $posBase2 (@bases) {
            @posBase2 = split(/\:/,$posBase2);
            $hashresultall{$posBase1.'_'.$posBase2[0]}++;
            $hashresultall{$posBase1[0].'_'.$posBase2[0]}++;
            $hashresult{ $posBase1 . '_' . $posBase2 }++;
        }
    }}
    $numfalse = 0;
    %hashpb1 =();
    %hashpb=();
    #@bases = "";
}


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

my @start = "";
my @next = "";

foreach ( sort{(split/\:/,$a)[0] <=> (split/\:/,$b)[0]} keys %hashrefbase) {
    @line = split(/:/,$_);
    $hashpos1{$line[0]} =~ s/\_$//;
    
    if($hashpos{$line[0]} >= 2) {
        $numcount++;
        if($numcount == 1) {
            @contig = split(/\_/,$hashpos1{$line[0]});
            foreach (@contig) {
                $start = $line[0].':'.$_;
                push @start,$start;
                $hashComb{$start} = $hashcontigs{$start};
                $hashnumList{$start} = $start;
            }
            shift @start;
        }
        
        
        if($numcount >1 ) {
            $combineNum++;
            @contig = split(/\_/,$hashpos1{$line[0]});
            foreach (@contig) {
                $next = $line[0].':'.$_;
                push @next,$next;
            }
            shift @next;
            foreach $start(@start) {
                @startList = split(/\:/,$start);
                foreach $next(@next) {
                    @nextList =  split(/\:/,$next);
                    if(exists $hashresultall{$start.'_'.$nextList[0]}) {
                        $chose = $hashresult{$start.'_'.$next}/$hashresultall{$start.'_'.$nextList[0]};
                        $chose1 = $hashresult{$start.'_'.$next}/$hashresultall{$startList[0].'_'.$nextList[0]};
                        $chose2 = $hashresult{$start.'_'.$next}/$mean;
                    if($hashresult{$start.'_'.$next} > 0 and $chose > 0.5 and $chose1 > 0.1 and $chose2 >0.1 ) {
                        #$CombSeq = $hashcontigs{$next};
                        $hashnumList{$start} =~ s/^\;//;
                        @num_list = split/\;/,$hashnumList{$start};
                        if($#num_list>0) {
######                            print "$start\t@num_list\n";
                            foreach $allele(@num_list){
                                if($allele ne "") {
                                    if (exists $hashnumList{$next}) {
                                        $false_num++;
                                        $hashnumList{$next} .= ';'.$allele.'|'.$next;
                                    }
                                    else {
                                        $hashnumList{$next} = $allele.'|'.$next;
                                    }
                                }
                            }
                        }
                        else {
                            if (exists $hashnumList{$next}) {
                                $false_num++;
                                $hashnumList{$next} .= ';'.$hashnumList{$start}.'|'.$next;
                            }
                            else {
                                $hashnumList{$next} = $hashnumList{$start}.'|'.$next;  
                            }
                            
                        }
                        $hashStart{$start}=1;
                        $hashNext{$next}=1;
######                        print "$start\t$next\tcombine true\t$hashnumList{$next}\n";
                    }
                    else {
                        
######                        print "$start\t$next\t$hashresult{$start.'_'.$next}\t$chose\t$chose1\t$chose2\tcombine false\n";
                    }
                }}
            }

            if($false_num > 10) {
                die "Too many assembly errors or Have multiple haplotypes\n";
            }

            foreach( @start) {
                if (!exists $hashStart{$_}) {
                    @num_list = split/\;/,$hashnumList{$_};
######                    print "$_\t@num_list\n";
                    foreach $allele(@num_list){
                        if (!exists $hashprint{$allele}) {
                            $hashprint{$allele} =1;
                            @allele = split(/\|/,$allele);
                            print ">$allele\n";
                            foreach(@allele) {
                                $hashcontigs{$_} =~ s/\+//g;
                                $hashcontigs{$_} =~ s/D//g;
                                print "$hashcontigs{$_}";
                            }
                            print "\n";
                        }
                    }
                }
            }
            $true_contig = $#next+1;
            foreach( @next) {
                #$true_contig = $#next+1;
                if (!exists $hashNext{$_} ) { 
######                    print "$_\n";
                    $true_contig--;
                    $hashnumList{$_} = $_;
                }
                
            }
            if ($true_contig > 0 ) {
                foreach( @next) {
                    if (!exists $hashNext{$_} and $hashratio{$_} > 0.4 ) { ####0.4防止bug造成突变缺失
                        $true_contig++;
                        $hashnumList{$_} = $_;
                    }
                }
            }
            if($true_contig >=2 or $true_contig == 0){
                @start = @next;
######                print "@start\t$true_contig\n";
                @next = "";
                if($true_contig == 0) {
                    foreach( @start ) {
                        $hashnumList{$_} = $_;
                    }
                }
            }
            #elsif($true_contig ==0) {
            #    @start = @next;
            #    foreach (@start) {
            #        $hashnumList{$_}
            #    print "@start\t$true_contig\n";
            #    @next = "";
            #}
            else {
                @start = @start;
                foreach $i(@start) {
                    foreach $h(@next) {
                        if(exists $hashNext{$h} and exists $hashStart{$i}) {
                            $hashnumList{$i} =~ s/^\;//;
                            #@startList = split(/\;/,$hashnumList{$i});
                            @num_list = split/\;/,$hashnumList{$i};
######                            print "1\t$h\t@num_list\n";
                            #if($#num_list>0) {
                            foreach $allele(@num_list){
                                $num_assem++;
                                if($num_assem ==1) {
                                    $hashnumList{$i} = $allele.'|'.$h;
                                }
                                else {
                                    $hashnumList{$i} .= ';'.$allele.'|'.$h;
                                }
######                                print "2\t$i\t$allele\t$h\t$hashnumList{$i}\n";
                                
                            }
                            $num_assem = 0;
                        }
                    }
                }
######                print "@start\t$true_contig\n";
                @next = "";
            }
            %hashNext =();
            %hashStart=();
        }
    }
}   

foreach $start(@start) {
    #print "$start\n";
    @startList = split(/\;/,$hashnumList{$start});
    foreach $allele(@startList){
        #print "$allele\n";
        if(!exists $hashprint{$allele}) {
            $hashprint{$allele} =1;
            @allele = split(/\|/,$allele);
            print ">$allele\n";
            foreach(@allele) {
                $hashcontigs{$_} =~ s/\+//g;
                $hashcontigs{$_} =~ s/D//g;
                print "$hashcontigs{$_}";
            }
        
            $contig =~ s/\+//g;
            $contig =~ s/D//g;
            print "$contig\n";
        }
    }
}


