#!/usr/bin/perl
# Author: Thomas Thiel
# Program name: misa.pl
# Release date: 14/12/01 (version 1.0)

#Change Log###########
#Auther: Nieh Version:1.0.1  Modifed:2015/04  Commit:add option replace input ini file
#Auther: Nieh Version:1.0.2  Modifed:2015/09/16  Commit:add primer3 to predict primer
#

## _______________________________________________________________________________
##
## DESCRIPTION: Tool for the identification and localization of
##              (I)  perfect microsatellites as well as
##              (II) compound microsatellites (two individual microsatellites,
##                   disrupted by a certain number of bases)
##
## SYNTAX:   SSR.pl <FASTA file> definition interruptions
##
##    <FASTAfile>    Single file in FASTA format containing the sequence(s).
##
##    In order to specify the search criteria,
##    the microsatellite search parameters is required, which
##    like the following structure:
##    Example:
##      definition(unit_size,min_repeats):          1-10,2-6,3-5,4-5,5-5,6-5
##      interruptions(max_difference_for_2_SSRs):   100
##
## EXAMPLE: SSR.pl seqs.fasta 1-10,2-6,3-5,4-5,5-5,6-5 100
##
## _______________________________________________________________________________
##

#use strict;
use warnings;
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);

#=================================MISA=================================
if (@ARGV !=3)
  {
  open (IN,"<$0");
  while (<IN>) {if (/^\#\# (.*)/) {$message .= "$1\n"}};
  close (IN);
  die $message;
  };

open (IN,"<$ARGV[0]") || die ("\nError: FASTA file doesn't exist !\n\n");
open (OUT,">$ARGV[0].misa");
print OUT "ID\tSSR nr.\tSSR type\tSSR\tsize\tstart\tend\n";

my %typrep = $ARGV[1] =~ /(\d+)/gi;
my $amb = $ARGV[2];
my @typ = sort { $a <=> $b } keys %typrep;


$/ = ">";
my $max_repeats = 1; #count repeats
my $min_repeats = 1000; #count repeats
my (%count_motif,%count_class); #count
my ($number_sequences,$size_sequences,%ssr_containing_seqs); #stores number and size of all sequences examined
my $ssr_in_compound = 0;
my @result="";
my ($id,$seq);
while (<IN>)
  {
  next unless (($id,$seq) = /(.*?)\n(.*)/s);
  my ($nr,%start,@order,%end,%motif,%repeats); # store info of all SSRs from each sequence
  $seq =~ s/[\d\s>]//g; #remove digits, spaces, line breaks,...
#  $id =~ s/^\s*//g; $id =~ s/\s*$//g;$id =~ s/\s/_/g; #replace whitespace with "_"
  $id=(split /\s+/,$id)[0];
  $id=~ s/\|/_/g;
  $number_sequences++;
  $size_sequences += length $seq;
  for ($i=0; $i < scalar(@typ); $i++) #check each motif class
    {
    my $motiflen = $typ[$i];
    my $minreps = $typrep{$typ[$i]} - 1;
    #print "$motiflen\t$minreps\n";
    if ($min_repeats > $typrep{$typ[$i]}) {$min_repeats = $typrep{$typ[$i]}}; #count repeats
    my $motif_num = 0;
    #my $search;
    my $motif;
    #my $minreps1 = $typrep{$typ[$i]} - 3;
    my    $search = "(([acgt]{$motiflen})\\2{$minreps,})";
    #print "[acgt]{$motiflen}\n";
    #print "$id\t$seq\t$minreps\t$search\n";
    my $search2 = "(([acgt]{$motiflen})\\2{1,})";
    my $seq1 = $seq;
    my $seq2 = $seq;
    my $first;
    my $last=0;

    while ( $seq =~ /$search2/ig ) #scan whole sequence for that class
      {
        my $type = $1;
	#print "$type\ttype\n";
	$first = pos($seq) - length($type)+1;
        $list = substr($seq,$first-1,length($type)+$motiflen);
        #$motiflist = $motif.$motif;
	#print "$list\t$motiflist\t$first\t$last\tlast\n";
        if (length($type) < ($minreps+1)*$motiflen and $motif_num ==0) {
	next;
	}
        elsif(length($type) < ($minreps+1)*$motiflen and $motif_num >0 and $type !~ $motif and ($last-$first) < 0) {
	next;
	}
	elsif(length($type) < 3*$motiflen and $motif_num >0 and $type =~ $motif and substr($type,0,$motiflen) ne $motif and $list !~ "$motif$motif") {
	next;
	}
	elsif(length($type) < (($minreps+1)*$motiflen+($last-$first+1)) and $motif_num >0 and $type !~ $motif and ($last-$first) >=0) {
	next;
	}
	else{
        if($motif_num >0 and $motif ne "" and $type =~ $motif){ # $seq1 =~ /(($motif)$motif{$minreps,})/ig) {
        my $search1 = "(($motif)\\2{1,})";
            
            if ($seq2 =~ /$search1/ig){ 
            #$seq1 =~ /$search1/ig;
            #print "$seq1\t$motif\t$1\tlastn\n";
            #print "$motif\tlastn1\t$1\n";
            my $motif1=$motif;
            #$motif = uc $1;
	    $last = pos($seq2);
            $num_1 = $1;
            $motif  = $motif;
            $motif_num++;
            #print "$id\t2\t$motif_num\t$motif1\t$motif\t$1\tlast\n";
            }
        }
        else {
	    if($seq1 =~ /$search/ig) {
	
            $motif_num++;
            #$motif = uc $2;
            $seq2 =~ /$search/ig;
            #$seq1 =~ /$search/ig;
            $num_1 = $1;
            $motif = uc $2;
	    $last = pos($seq2);
            #print "$id\t1\t$motif_num\t$motif\t$seq\t$1\t$2\n";
            }
            else {
            $num_1 =0;
            next;
	    #print "false\n";
            }
	}
	}
	#print "$num_1\n";
      my $redundant; #reject false type motifs [e.g. (TT)6 or (ACAC)5]
      for ($j = $motiflen - 1; $j > 0; $j--)
        {
        my $redmotif = "([ACGT]{$j})\\1{".($motiflen/$j-1)."}";
	#print "$redmotif\tredmotif\n";
        if ( $motif =~ /$redmotif/ )
	  {
		#print "$1\t$2\tfalse\n";
		$redundant = 1;
	  }
        };
      next if $redundant;
      next unless $num_1;
      $motif{++$nr} = $motif;
      my $ssr = uc $num_1;
      #print "$num_1\tlastm\n";
      $repeats{$nr} = length($ssr) / $motiflen;
      $end{$nr} = pos($seq2);
   
      #print "$nr\t$type\t$end{$nr}\t$seq2\tlastend\n";
      $start{$nr} = $end{$nr} - length($ssr) + 1;
      #print "$id\t$seq2\t$motif_num\n";
      if($start{$nr} < 0 ) {
	next;
      }
      # count repeats
      $count_motifs{$motif{$nr}}++; #counts occurrence of individual motifs
      $motif{$nr}->{$repeats{$nr}}++; #counts occurrence of specific SSR in its appearing repeat
      $count_class{$typ[$i]}++; #counts occurrence in each motif class
      if ($max_repeats < $repeats{$nr}) {$max_repeats = $repeats{$nr}};
      };
    };
    #$motif_num = 0;
  next if (!$nr); #no SSRs
  $ssr_containing_seqs{$nr}++;
  @order = sort { $start{$a} <=> $start{$b} } keys %start; #put SSRs in right order
  #print "@order\tlast\n";
  $i = 0;
  my $count_seq; #counts
  #my @result = "";
  my $max = 0;
  my $out;

  my ($start,$end,$ssrseq,$ssrtype,$size);
  while ($i < $nr)
    {
    my $space = $amb + 1;
    if (!$order[$i+1]) #last or only SSR
      {
      $count_seq++;
      my $motiflen = length ($motif{$order[$i]});
      $ssrtype = "p".$motiflen;
      $ssrseq = "($motif{$order[$i]})$repeats{$order[$i]}";
      $start = $start{$order[$i]}; $end = $end{$order[$i++]};
      #print "$id\t$start\t$end\tlast\n";
      next
      };
    if (($start{$order[$i+1]} - $end{$order[$i]}) > $space)
      {
      $count_seq++;
      my $motiflen = length ($motif{$order[$i]});
      $ssrtype = "p".$motiflen;
      $ssrseq = "($motif{$order[$i]})$repeats{$order[$i]}";
      $start = $start{$order[$i]}; $end = $end{$order[$i++]};
      next
      };
    my ($interssr);
    if (($start{$order[$i+1]} - $end{$order[$i]}) < 1)
      {
      #print "$id\t$start{$order[$i+1]}\t$end{$order[$i]}\n";
      $count_seq++; $ssr_in_compound++;
      $ssrtype = 'c*';
      $ssrseq = "($motif{$order[$i]})$repeats{$order[$i]}($motif{$order[$i+1]})$repeats{$order[$i+1]}*";
      $start = $start{$order[$i]}; $end = $end{$order[$i+1]};
      }
    else
      {
      $count_seq++; $ssr_in_compound++;
      #print "$interssr($motif{$order[$i+1]})\tlast1\n";
      $interssr = lc substr($seq,$end{$order[$i]},($start{$order[$i+1]} - $end{$order[$i]}) - 1);
      #print "$interssr($motif{$order[$i+1]})\tlast2\n";
      $ssrtype = 'c';
      $ssrseq = "($motif{$order[$i]})$repeats{$order[$i]}$interssr($motif{$order[$i+1]})$repeats{$order[$i+1]}";
      $start = $start{$order[$i]};  $end = $end{$order[$i+1]};
      #$space -= length $interssr
      };
    while ($order[++$i + 1] and (($start{$order[$i+1]} - $end{$order[$i]}) <= $space))
      {
      if (($start{$order[$i+1]} - $end{$order[$i]}) < 1)
        {
        $ssr_in_compound++;
        $ssrseq .= "($motif{$order[$i+1]})$repeats{$order[$i+1]}*";
        $ssrtype = 'c*';
        $end = $end{$order[$i+1]}
        }
      else
        {
        $ssr_in_compound++;
	#print "$interssr($motif{$order[$i+1]})\tlast1\n";
        $interssr = lc substr($seq,$end{$order[$i]},($start{$order[$i+1]} - $end{$order[$i]}) - 1);
	#print "$interssr($motif{$order[$i+1]})\tlast2\n";
        $ssrseq .= "$interssr($motif{$order[$i+1]})$repeats{$order[$i+1]}";
        $end = $end{$order[$i+1]};
        #$space -= length $interssr
        }
      };
    $i++;
    }
  continue
    {
    my $result = "$id\t$count_seq\t$ssrtype\t$ssrseq\t".($end - $start + 1)."\t$start\t$end\n";
    #print "@result";
    push @result,$result;
    #print OUT "$id\t$count_seq\t$ssrtype\t$ssrseq\t",($end - $start + 1),"\t$start\t$end\n"
    }
    print "@result";
    shift @result;
    #print "@result";
        foreach (@result) {
	    @len = split/\t/,$_;
	    #print "$len[4]\n";
	    if ($len[4]>$max){
		 $out = $_;
		 $max = $len[4];
		# print "$id\t$max\n";
	    }
	}
	print OUT "$out";
	@result = "";
    #print OUT "$id\t$count_seq\t$ssrtype\t$ssrseq\t",($end - $start + 1),"\t$start\t$end\n"
 
  };

close (OUT);
open (OUT,">$ARGV[0].statistics");

print OUT "Specifications\n==============\n\nSequence source file: \"$ARGV[0]\"\n\nDefinement of microsatellites (unit size / minimum number of repeats):\n";
for ($i = 0; $i < scalar (@typ); $i++) {print OUT "($typ[$i]/$typrep{$typ[$i]}) "};print OUT "\n";
if ($amb > 0) {print OUT "\nMaximal number of bases interrupting 2 SSRs in a compound microsatellite:  $amb\n"};
print OUT "\n\n\n";


#small calculations
my @ssr_containing_seqs = values %ssr_containing_seqs;
my $ssr_containing_seqs = 0;
for ($i = 0; $i < scalar (@ssr_containing_seqs); $i++) {$ssr_containing_seqs += $ssr_containing_seqs[$i]};
my @count_motifs = sort {length ($a) <=> length ($b) || $a cmp $b } keys %count_motifs;
my @count_class = sort { $a <=> $b } keys %count_class;
for ($i = 0; $i < scalar (@count_class); $i++) {$total += $count_class{$count_class[$i]}};

print OUT "RESULTS OF MICROSATELLITE SEARCH\n================================\n\n";
print OUT "Total number of sequences examined:              $number_sequences\n";
print OUT "Total size of examined sequences (bp):           $size_sequences\n";
print OUT "Total number of identified SSRs:                 $total\n";
print OUT "Number of SSR containing sequences:              $ssr_containing_seqs\n";
print OUT "Number of sequences containing more than 1 SSR:  ",$ssr_containing_seqs - ($ssr_containing_seqs{1} || 0),"\n";
print OUT "Number of SSRs present in compound formation:    $ssr_in_compound\n\n\n";

print OUT "Distribution to different repeat type classes\n---------------------------------------------\n\n";
print OUT "Unit size\tNumber of SSRs\n";
my $total = undef;
for ($i = 0; $i < scalar (@count_class); $i++) {print OUT "$count_class[$i]\t$count_class{$count_class[$i]}\n"};
print OUT "\n";

print OUT "Frequency of identified SSR motifs\n----------------------------------\n\nRepeats";
for ($i = $min_repeats;$i <= $max_repeats; $i++) {print OUT "\t$i"};
print OUT "\ttotal\n";
for ($i = 0; $i < scalar (@count_motifs); $i++)
  {
  my $typ = length ($count_motifs[$i]);
  print OUT $count_motifs[$i];
  for ($j = $min_repeats; $j <= $max_repeats; $j++)
    {
    if ($j < $typrep{$typ}) {print OUT "\t-";next};
    if ($count_motifs[$i]->{$j}) {print OUT "\t$count_motifs[$i]->{$j}"} else {print OUT "\t"};
    };
  print OUT "\t$count_motifs{$count_motifs[$i]}\n";
  };
print OUT "\n";

# Eliminates %count_motifs !
print OUT "Frequency of classified repeat types (considering sequence complementary)\n-------------------------------------------------------------------------\n\nRepeats";
my (%red_rev,@red_rev); # groups
for ($i = 0; $i < scalar (@count_motifs); $i++)
  {
  next if ($count_motifs{$count_motifs[$i]} eq 'X');
  my (%group,@group,$red_rev); # store redundant/reverse motifs
  my $reverse_motif = $actual_motif = $actual_motif_a = $count_motifs[$i];
  $reverse_motif =~ tr/ACGT/TGCA/;
  $reverse_motif = reverse $reverse_motif;
  my $reverse_motif_a = $reverse_motif;
  for ($j = 0; $j < length ($count_motifs[$i]); $j++)
    {
    if ($count_motifs{$actual_motif}) {$group{$actual_motif} = "1"; $count_motifs{$actual_motif}='X'};
    if ($count_motifs{$reverse_motif}) {$group{$reverse_motif} = "1"; $count_motifs{$reverse_motif}='X'};
    $actual_motif =~ s/(.)(.*)/$2$1/;
    $reverse_motif =~ s/(.)(.*)/$2$1/;
    $actual_motif_a = $actual_motif if ($actual_motif lt $actual_motif_a);
    $reverse_motif_a = $reverse_motif if ($reverse_motif lt $reverse_motif_a)
    };
  if ($actual_motif_a lt $reverse_motif_a) {$red_rev = "$actual_motif_a/$reverse_motif_a"}
  else {$red_rev = "$reverse_motif_a/$actual_motif_a"}; # group name
  $red_rev{$red_rev}++;
  @group = keys %group;
  for ($j = 0; $j < scalar (@group); $j++)
    {
    for ($k = $min_repeats; $k <= $max_repeats; $k++)
      {
      if ($group[$j]->{$k}) {$red_rev->{"total"} += $group[$j]->{$k};$red_rev->{$k} += $group[$j]->{$k}}
      }
    }
  };
for ($i = $min_repeats; $i <= $max_repeats; $i++) {print OUT "\t$i"};
print OUT "\ttotal\n";
@red_rev = sort {length ($a) <=> length ($b) || $a cmp $b } keys %red_rev;
for ($i = 0; $i < scalar (@red_rev); $i++)
  {
  my $typ = (length ($red_rev[$i])-1)/2;
  print OUT $red_rev[$i];
  for ($j = $min_repeats; $j <= $max_repeats; $j++)
    {
    if ($j < $typrep{$typ}) {print OUT "\t-";next};
    if ($red_rev[$i]->{$j}) {print OUT "\t",$red_rev[$i]->{$j}}
    else {print OUT "\t"}
    };
  print OUT "\t",$red_rev[$i]->{"total"},"\n";
  };
close OUT;
#=================================MISA=================================

#===============================Primer3================================
#my $DIR=dirname(abs_path($0));
#`perl $DIR/p3_in.pl $ARGV[0].misa`;
#`primer3_core -default_version=1 -output=$ARGV[0].p3out $ARGV[0].p3in`;
#`perl $DIR/p3_out.pl $ARGV[0].p3out $ARGV[0].misa`;
#===============================Primer3================================
