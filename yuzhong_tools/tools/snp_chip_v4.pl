#! usr/bin/perl -w
use strict;
die "Usage:
        perl [script] [f_fq] [r_fq] [snp_seqs.fasta] [f_rest_fq] [r_rest_fq] [snp_results]\n"
unless @ARGV==6;

my $f_fq=shift;
my $r_fq=shift;
my $fasta=shift;
my $f_rest=shift;
my $r_rest=shift;
my $snp_results=shift;

open FASTA, "<$fasta" 
     or die "Error in opening file $fasta\n";
open F_FQ, "gzip -dc $f_fq|"
     or die "Error in opening file $f_fq\n";
open R_FQ, "gzip -dc $r_fq|"
     or die "Error in opening file $r_fq\n";
open F_REST, ">>$f_rest"
     or die "Error in opening file $f_rest\n";
open R_REST, ">>$r_rest"
     or die "Error in opening file $r_rest\n";
open SNP_RE, ">>$snp_results"
     or die "Error in opening file $snp_results\n";


my $k_len=25;
##################################build hash snp chip##################       
my $snp_id;
my %seq_snp;##key=seqs, value=snp_allele;
my %snp_counts; ##key=snp_allele, value=allele counts;
my %snp_pos;
while (<FASTA>) {
  chomp;
  $_=~s/\s+$//;
  my $line=$_;
  my $snp_seq;
  if(substr($line,0,1)eq">") {
   $snp_id=$line;
   $snp_counts{$snp_id."_A"}=0;
   $snp_counts{$snp_id."_a"}=0;
   $snp_counts{$snp_id."_T"}=0;
   $snp_counts{$snp_id."_t"}=0;
   $snp_counts{$snp_id."_G"}=0;
   $snp_counts{$snp_id."_g"}=0;
   $snp_counts{$snp_id."_C"}=0;
   $snp_counts{$snp_id."_c"}=0;
  } else {
   $snp_seq=$line;   
   my @seq=split/\|/,$snp_seq;
  # print "\@seq=@seq\n";#test
  # my $k_len=20;###edit
   my $probe_a=join"",substr($seq[0],-$k_len+1),"A",substr($seq[2],0,$k_len-1);
   my $probe_t=join"",substr($seq[0],-$k_len+1),"T",substr($seq[2],0,$k_len-1);
   my $probe_g=join"",substr($seq[0],-$k_len+1),"G",substr($seq[2],0,$k_len-1);
   my $probe_c=join"",substr($seq[0],-$k_len+1),"C",substr($seq[2],0,$k_len-1);
#   print "probe_a=$probe_a\n";#test
    for(my $i=0;$i<$k_len;$i++){
      my $a_seq=substr($probe_a,$i,$k_len);
         $snp_pos{$a_seq}=$k_len-1-$i;
      my $a_src=&rev_com($a_seq);
         $snp_pos{$a_src}=$i;
      my $t_seq=substr($probe_t,$i,$k_len);
         $snp_pos{$t_seq}=$k_len-1-$i;
      my $t_src=&rev_com($t_seq);
         $snp_pos{$t_src}=$i;
      my $g_seq=substr($probe_g,$i,$k_len);
         $snp_pos{$g_seq}=$k_len-1-$i;
      my $g_src=&rev_com($g_seq);
         $snp_pos{$g_src}=$i;
      my $c_seq=substr($probe_c,$i,$k_len);
         $snp_pos{$c_seq}=$k_len-1-$i;
      my $c_src=&rev_com($c_seq);
         $snp_pos{$c_src}=$i;

     if(!$seq_snp{$a_seq}) {
      $seq_snp{$a_seq}=$snp_id."_A";
     # $seq_snp{$a_src}=$snp_id."_a";
     } else {
      $seq_snp{$a_seq}.="|".$snp_id."_A";
      
       #print "a_seq=$a_seq\n";
       #print "rev_com_a_seq=".$a_src."\n";
       #print $seq_snp{$a_seq}."\n";
       #print $snp_id."\n";
     }

     if(!$seq_snp{$a_src}) {
       $seq_snp{$a_src}=$snp_id."_a";
     } else {
       $seq_snp{$a_src}.="|".$snp_id."_a";
     }

     if(!$seq_snp{$t_src}) {
      $seq_snp{$t_seq}=$snp_id."_T";
      #$seq_snp{$t_src}=$snp_id."_t";
     } else {
      $seq_snp{$t_seq}.="|".$snp_id."_T";
      # print "t_seq=$t_seq\n";
      # print "rev_com_t_seq=".$t_src."\n";
      # print $seq_snp{$t_seq}."\n";
      # print $snp_id."\n";
     }

     if(!$seq_snp{$t_src}) {
      $seq_snp{$t_src}=$snp_id."_t"; 
     } else {
      $seq_snp{$t_src}.="|".$snp_id."_t";
     }


    
     if(!$seq_snp{$g_seq}) {
      $seq_snp{$g_seq}=$snp_id."_G";
     # $seq_snp{$g_src}=$snp_id."_g";
     } else {
      $seq_snp{$g_seq}.="|".$snp_id."_G";
      # print "g_seq=$g_seq\n";
      # print "rev_com_g_seq=".$g_src."\n";
      # print $seq_snp{$g_seq}."\n";
      # print $snp_id."\n";
     }

     if(!$seq_snp{$g_src}) {
      $seq_snp{$g_src}=$snp_id."_g";
     } else {
      $seq_snp{$g_src}.="|".$snp_id."_g";
     }



 
     if(!$seq_snp{$c_seq}) {
      $seq_snp{$c_seq}=$snp_id."_C";
     # $seq_snp{$c_src}=$snp_id."_c";
     } else {
      $seq_snp{$c_seq}.="|".$snp_id."_C";
      #print "c_seq=$c_seq\n";
      #print "rev_com_c_seq=".$c_src."\n";
      #print $seq_snp{$c_seq}."\n";
      #print $snp_id."\n";
     }

     if(!$seq_snp{$c_src}) {
      $seq_snp{$c_src}=$snp_id."_c";
     } else {
      $seq_snp{$c_src}.="|".$snp_id."_c";
     }
   
    }
  }

}

close FASTA;
#######################################build hash snp chip end###########################
my $f_seq=<F_FQ>;
my $r_seq=<R_FQ>;
my @f_seq;
my @r_seq;
my %snpid_seqid_count;
my %seqid_used;
my %var_pos_count;
my $reads_total=0;
my $reads_offtarget=0;
while ($f_seq && $r_seq) {
  chomp($f_seq);
  chomp($r_seq);
  push @f_seq,$f_seq;
  push @r_seq,$r_seq;
  
  if($#f_seq==3 && $#r_seq==3) {
    my $len_f=length($f_seq[1]);
    my $len_r=length($r_seq[1]);

    $reads_total++;   

    my @seq_id_f=split/\s/,$f_seq[0];#add
    my $seq_id=$seq_id_f[0];
    for (my $i=0;$i<=$len_f-$k_len;$i++) {
       my $subseq=substr($f_seq[1],$i,$k_len);
 ##      print "subseq=$subseq\n";##test
       if($seq_snp{$subseq}) {
          my $snp_allele=$seq_snp{$subseq};
          $seqid_used{$f_seq[0]}++;
         # my @seq_id_f=split/\s/,$f_seq[0];#add
          $seqid_used{$seq_id}++;#add
       ##edit20170713#################################
          my @snp_allele=split/\|/,$snp_allele;
          for(my $a=0;$a<=$#snp_allele;$a++){
          if(!$snpid_seqid_count{$f_seq[0]}{$snp_allele[$a]}) {
            $snpid_seqid_count{$f_seq[0]}{$snp_allele[$a]}++;
            $snp_counts{$snp_allele[$a]}++;
            my $var_pos=$snp_pos{$subseq}+$i;#add
            $var_pos_count{$snp_allele[$a]}{$var_pos}++;#add
          }          
         } 
        ##edit20170713############################
       } 

    }

  #  my @seq_id_r=split/\s/,$r_seq[0];#add

    for (my $j=0;$j<=$len_r-$k_len;$j++) {
       my $subseq=substr($r_seq[1],$j,$k_len);
       if($seq_snp{$subseq}) {
          my $snp_allele=$seq_snp{$subseq};
          $seqid_used{$r_seq[0]}++;
        #  my @seq_id_r=split/\s/,$r_seq[0];#add
          $seqid_used{$seq_id}++;#add

##edit20170713################################

          my @snp_allele=split/\|/,$snp_allele;
          for(my $b=0;$b<=$#snp_allele;$b++){

          if(!$snpid_seqid_count{$r_seq[0]}{$snp_allele[$b]}) {
            $snpid_seqid_count{$r_seq[0]}{$snp_allele[$b]}++;
            $snp_counts{$snp_allele[$b]}++;
            my $var_pos=$snp_pos{$subseq}+$j;#add
            $var_pos_count{$snp_allele[$b]}{$var_pos}++;#add
          }
         }
##edit20170713#################################
       }

    }

   
   if(!$seqid_used{$seq_id}) {
     $reads_offtarget++;
     my $f_rest=join"\n",@f_seq;
     my $r_rest=join"\n",@r_seq;
     print F_REST "$f_rest\n";
     print R_REST "$r_rest\n";
   }
   
   @f_seq=();
   @r_seq=();
  }

  $f_seq=<F_FQ>;
  $r_seq=<R_FQ>;

}
close F_FQ;
close R_FQ;
close F_REST;
close R_REST;
my $ontarget=1-$reads_offtarget/$reads_total;
print "reads% on target region of sample $snp_results=$ontarget\n";
foreach my $key1 (sort keys %snp_counts) {
   
  my $hash2=$var_pos_count{$key1};
  my @pos_reads;
  foreach my $key2 (sort{$hash2->{$b}<=>$hash2->{$a}} keys %$hash2){
   push @pos_reads,$key2,$var_pos_count{$key1}{$key2};
  }

   print SNP_RE "$key1\t$snp_counts{$key1}\t@pos_reads\n";
}

close SNP_RE;
###sub reverse_com;###############################################
 sub rev_com {                                                  ##
  my ($seq)=@_;                                                 ##
  my @seq=split//,$seq;                                         ##
  my %bs_pair=("A"=>"T","T"=>"A","G"=>"C","C"=>"G");            ##
  my $seq_new;                                                  ##
  for(my $i=$#seq;$i>=0;$i--) {                                 ##
    $seq_new.=$bs_pair{$seq[$i]};                               ## 
  }                                                             ##  
# print "seq=$seq\nseq_new=$seq_new\n";                         ##  
 return $seq_new;                                               ##
                                                                ##
}                                                               ##
                                                                ##
################################################################## 



