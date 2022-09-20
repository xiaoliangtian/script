#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/10/24

#Change Log###########
#Auther:  Version:  Modifed: Commit:
######################
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

my $DIR=dirname(abs_path($0));
die "Usage: perl $0 pep.fa NRdb\n" unless (@ARGV == 1 or @ARGV == 2);

my $db= (@ARGV == 2)? $ARGV[1] : "/home/assembly/Blast/nr-new/nr";
`blastp -query $ARGV[0] -db $db -max_target_seqs 1 -evalue 1e-5 -num_threads 30 -outfmt 5 -out $ARGV[0].nr.xml`;
`python $DIR/blastxmlparser.py $ARGV[0].nr.xml $ARGV[0].nr 0 1`;
`perl $DIR/NRformat.pl $ARGV[0].nr $ARGV[0].nr.anno`;
`Rscript $DIR/spciescount.r $ARGV[0].nr.anno.stat`;
