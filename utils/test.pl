#!/usr/bin/perl
#use strict;
#use warnings;
my $seqlen;
my $minlen;
 print &getlen();
sub getlen{
    
    my $seqlen=45;
    my $minlen=$seqlen>50 ? 50: 2;
    return $minlen,$seqlen;
}
