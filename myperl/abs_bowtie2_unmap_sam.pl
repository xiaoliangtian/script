#/usr/bin/perl
use strict;

### abs unmap paired reads in bowtie2 sam file
### Phred_Qual: --phred33;--phred64 (33 or 64);

die "Usage: perl $0 SAM out_prefix Phred_Qual\n" unless ( @ARGV == 3 );
open( SAM, $ARGV[0] )         or die "Can not open file $ARGV[0]\n";
open( R1,  ">$ARGV[1]_1.fq" ) or die "Can not open file $ARGV[1]_1.fq\n";
open( R2,  ">$ARGV[1]_2.fq" ) or die "Can not open file $ARGV[1]_2.fq\n";

my @info = ();
my $var  = '';
my ( $seq, $qual ) = ( '', '' );
my @qual       = ();
my $phred_type = ( $ARGV[2] - 33 );

while (<SAM>) {
    chomp;
    if (/^@/) { next; }
    @info = split /\s+/;
    if ( $info[2] eq "*" ) {
        $var = <SAM>;
        print R1 "@", $info[0], "/1\n";
        print R1 $info[9], "\n";
        print R1 "+", $info[0], "/1\n";
        @qual = split( '', $info[10] );
        for ( my $i = 0 ; $i <= $#qual ; $i++ ) {
            print R1 chr( int( ord( $qual[$i] ) + $phred_type ) );
        }
        print R1 "\n";
        @info = split( /\s+/, $var );
        print R2 "@", $info[0], "/2\n";
        print R2 $info[9], "\n";
        print R2 "+", $info[0], "/2\n";
        @qual = split( '', $info[10] );
        for ( my $i = 0 ; $i <= $#qual ; $i++ ) {
            print R2 chr( int( ord( $qual[$i] ) + $phred_type ) );
        }
        print R2 "\n";
    }
}
