#/usr/bin/perl
use strict;
die "Usage: perl $0 fq_in fq_out \n" unless (@ARGV == 2);

my $in = $ARGV[0];
my $out1  = $ARGV[1];
#my $adaptor="GATCGGAAGAGC";  ### normal tag 
my $adaptor="TGGAATTCTCGGGTGCCAAGG";  ### NEB miRNA tag
#my $adaptor="TGGAATTCTCGGGTGCCAAGG";  ### Illumina miRNA tag
             
my $MIN_LEN =17;
my $MAX_LEN =35;

open (IN, "gzip -dc $in|") or die "Can not open file $in\n";
open (OUT1, ">$out1") or die "Can not open file $out1\n";
open (OUT2, ">$out1.notag") or die "Can not open file $out1.notag\n";
open (OUT3, ">$out1.len_filter") or die "Can not open file $out1.len_filter\n";
open (OUT4, ">$out1.nosrna") or die "Can not open file $out1.nosrna\n";
my $a_len = length($adaptor);
my @adp_tag = ();
for(my $i=$a_len;$i>=10;$i--){
	my $a = substr($adaptor, 0, $i);
	#print $a,"\n";
	unshift @adp_tag, $a;
	&mismatch_primer($a, \@adp_tag)
	
}

while (<IN>) {
  chomp;
  my $title=$_;
  my $seq = <IN>;
  chomp $seq;
  my $str = <IN>;
  chomp $str;
  my $quality = <IN>; 
  chomp $title;
  chomp $quality;

  next unless ($title&&$seq&&$str&&$quality);
  $quality=~s/\n//g;
  my ($seq2,$qt2)="";
  if($seq=~/^$adaptor/){
     print OUT4 "$title\n$seq\n$str\n$quality\n";
     next;
  }
  foreach my $k_tag(@adp_tag){
	  if($seq=~/(\S+)$k_tag/){
	  	#print "OK","\n";
	  	$seq2=$1;	  	
	  	my $len2=length($seq2);
	  	my $qt2=substr($quality,0,$len2);
	  	if($qt2 eq ""){next;}
	  	if($len2>=$MIN_LEN&& $len2<=$MAX_LEN){
	  		print OUT1 "$title\n$seq2\n$str\n$qt2\n";
	  	}
	  	else{
	  		print OUT3 "$title\n$seq2\n$str\n$qt2\n";
	  	}
	  	last;
	  }
	  else{
	  	print OUT2 "$title\n$seq\n$str\n$quality\n";
	  	last;
	  }
	}
}
close IN;
close OUT;




sub mismatch_primer{
	my ($primer, $mis_primer) = @_;
	my $p_len = length($primer);
	my @init_p = split('',$primer);
	
	## FOR mismatch
	for(my $i=0;$i<$p_len;$i++){
		my $var = "";
		if($init_p[$i] eq "A"){
			$init_p[$i] = "G";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "T";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "C";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "A";
			next;
		}
		elsif($init_p[$i] eq "G"){
			$init_p[$i] = "A";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "T";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "C";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "G";
			next;
		}
		elsif($init_p[$i] eq "T"){
			$init_p[$i] = "A";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "G";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "C";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "T";
			next;
		}		
		elsif($init_p[$i] eq "C"){
			$init_p[$i] = "A";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "G";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "T";$var = join('',@init_p);push @$mis_primer, $var;
			$init_p[$i] = "C";
			next;
		}
	}
	
	## FOR deleltion
	for(my $i=0;$i<$p_len;$i++){
		if($i==0){
			my $var= join('',@init_p[1..$#init_p]);
			push @$mis_primer, $var;
		}
		elsif($i==1){
			my $var=$init_p[0].join('',@init_p[2..$#init_p]);
			push @$mis_primer, $var;
		}
		elsif($i==$#init_p-1){
			my $var=join('',@init_p[0..$i-1]).$init_p[$#init_p];
			push @$mis_primer, $var;
		}
		elsif($i==$#init_p){
			my $var=join('',@init_p[0..$i-1]);
			push @$mis_primer, $var;
		}
		else{
			my $var=join('',@init_p[0..$i]).join('',@init_p[$i+2..$#init_p]);
			push @$mis_primer, $var;
		}
	}
	#pop @$mis_primer;
}
