#!/usr/bin/perl
#use strict;
#use warnings;
my @line;
my $type   = 0;
my @result = "";

die "Usage: perl $0  erti.ty   > out\n" unless ( @ARGV == 1 );
open( IN, "$ARGV[0]" ) or die "Can not open file $ARGV[0]\n";

#open (DB, "$ARGV[1]") or die "Can not open file $ARGV[1]\n";

my $header = <IN>;
while (<IN>) {
    chomp;
    @line = split( /\t/, $_ );
    @type = split( /\//, $line[1] );
    if ( $line[1] ne 'F' and $line[1] ne 'NA' ) {
        foreach $str (@type) {
	    #print "$line[0]\t$str\n";
            @type1 = split( /\D+/, $str );
            foreach (@type1) {
                $type += $_;
            }

            #print "$type\n";
            $str =~ s/\([A-Z]+\)//g;

            #print $type[1]."\n";
            @type2 = split( /[0-9]+/, $str );
            $num = @type2;
            if ( $num >= 1 ) {
                foreach (@type2) {
                    if ( $_ ne "" ) {
                        $type += int( length($_) / 4 );

                        #print "$type\n";
                        $type_last = $type . '.' . length($_) % 4;
                    }
                    else {
                        #print "$type\n";
                        $type_last = $type;
                    }
                }
            }
            else {
                #print "$type\n";
                $type_last = $type;
            }
            $type_last =~ s/\.0//;
            push @result, $type_last;

            #print "$type[0]".'_'."$type_last\t$line[1]\t$line[2]\n";
            $type = 0;
        }

        shift @result;
        $result = join( '|', @result );
        print "$line[0]\t$result\n";
        @result = "";
    }
    else {
        print "$line[0]\tNA\n";
    }

}

