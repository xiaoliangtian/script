#!/usr/bin/perl
#Auther:Nieh Hsiaoting
#Version:1.0.0
#Date:2015/10/07
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

my $DIR=dirname(abs_path($0));
die "Usage: perl $0 pep.fa\n" unless (@ARGV == 1);
`/home/niext/bin/iprscan -cli -appl hmmpfam -i $ARGV[0] -o $ARGV[0].ipr -nocrc -iprlookup -goterms -format raw 2>ipr.log`;
`python $DIR/iprscan2go.py $ARGV[0].ipr ipr2go.txt`;
`python $DIR/GOformat.py ipr2go.txt -g geneid2go -o GO.xls -s GO.count`;
