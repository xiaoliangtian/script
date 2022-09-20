#! usr/bin/perl -w
use strict;
my $dir="./";
opendir DIR,"$dir" or die "Error in opening dir $dir\n"; 
my $filename;
my $sample_count=0;
my $score_file="score.sco";
open SCORE, ">$score_file" or die "Error in opening file $score_file\n";
while($filename=readdir(DIR)) {

if($filename=~/\.txt$/) {
$sample_count++;
open DEPTH, "<$filename" or die "Error in opening file $filename\n";
#open SCORE, ">>$score_file" or die "Error in opening file $score_file\n";
my @sample=split/\./,$filename;
my $count=0;
my %rs_dp_up;
my %rs_dp_lw;
my %rs_base_dp;
my $best=0;
my $good=0;
my $bad=0;
my $totrs;
while(<DEPTH>){
  chomp;
  $count++;
  if($count>=1){
    my @line=split/\t/,$_;
    my @rsinfo=split/\s+/,$line[0];
    my @rsnb=split/_/,$rsinfo[0];
    my $rs=$rsnb[2].substr($rsinfo[4],-1).substr($rsinfo[6],4,3);
    my $base=substr($line[0],-1);
    $rs_base_dp{$rs}{$base}=sprintf("%d",$line[1]);
   if($base=~/[A-Z]/) {
    $rs_dp_up{$rs}+=sprintf("%d",$line[1]);
   } elsif($base=~/[a-z]/) {
    $rs_dp_lw{$rs}+=sprintf("%d",$line[1]);
   }
   ##########

  }
}

my @rs=sort keys %rs_dp_up;
   $totrs=$#rs+1;
my @base=sort keys %{@rs_base_dp{keys %rs_base_dp}};

my @dp;
my @per;
for my $i (0 .. $#base) {
  push @dp,"dp".$base[$i];
  push @per,$base[$i]."%";
}
if($sample_count==1){
my $title=join"\t",("sample","rs#",@dp,"dp_up","dp_low",@per,"DpA1A2","A1","A1%","A2","A2%","genotype");
print "$title\n";
}
for my $m(0 ..$#rs){
   my @base_dp;
   my @base_per;
   my @algt;
   my @snp;
   my $a1=substr($rs[$m],-3,1);
   my $a2=substr($rs[$m],-1,1);
   my $dp_snp=$rs_dp_up{$rs[$m]};
   if($rs_dp_up{$rs[$m]}<$rs_dp_lw{$rs[$m]}) {
    $a1=~tr/A-Z/a-z/;
    $a2=~tr/A-z/a-z/;     
    $dp_snp=$rs_dp_lw{$rs[$m]};
   }
   my $dpa1a2=$rs_base_dp{$rs[$m]}{$a1}+$rs_base_dp{$rs[$m]}{$a2};
   for my $n (0 .. $#base) {
     my $rs_dp;
     if($base[$n]=~/[A-Z]/) {
      $rs_dp=$rs_dp_up{$rs[$m]};
     } elsif($base[$n]=~/[a-z]/) {
      $rs_dp=$rs_dp_lw{$rs[$m]};
     }
     if($rs_dp==0) {
      # push @snp,"N";
      if($rs_dp==0) {
       push @base_dp,0;
       push @base_per,0;
      
       if($base[$n]eq$a1) {
        push @algt,($a1,0);
       } elsif($base[$n]eq$a2) {
        push @algt,($a2,0);
       }
      }   
     } else {
      my $dp=$rs_base_dp{$rs[$m]}{$base[$n]};
      my $per=sprintf("%.1f",$dp/$rs_dp*100);
      
      push @base_dp,$dp;
      push @base_per,$per;
      my $fre=0;
 
       if($base[$n]eq$a1) {
         if($dpa1a2==0){
           $fre=0;
          }else {
           $fre=sprintf("%.1f",$rs_base_dp{$rs[$m]}{$a1}/($rs_base_dp{$rs[$m]}{$a1}+$rs_base_dp{$rs[$m]}{$a2})*100);
           my $absfre=abs($fre-50);
           if($absfre>=48){
             $best++;
           } elsif($absfre>=40 and $absfre<48){ 
             $good++;
           } elsif($absfre>=15 and $absfre<40) {
             $bad++;
           } elsif($absfre>=10 and $absfre<15) {
             $good++;
           } elsif($absfre>=0 and $absfre<10) {
             $best++;
           }
          }
        push @algt,($a1,$fre);
       } elsif($base[$n]eq$a2) {
         if($dpa1a2==0) {
          $fre=0;
         } else {
          $fre=sprintf("%.1f",$rs_base_dp{$rs[$m]}{$a2}/($rs_base_dp{$rs[$m]}{$a1}+$rs_base_dp{$rs[$m]}{$a2})*100);
         }
        push @algt,($a2,$fre);
       }
      

      if($dp_snp<4) {
         ;
      } else {
        if($fre>=15){
          push @snp,$base[$n];
        } 
      }

     }

    }
    if($#snp==0){
      push @snp,$snp[0];
    } elsif(!@snp) {
      @snp=qw(N N);
    }
   my $snp=join"\/",@snp;
      $snp=~tr/[a-z]/[A-Z]/;
   my $out=join"\t",($sample[0],$rs[$m],@base_dp,$rs_dp_up{$rs[$m]},$rs_dp_lw{$rs[$m]},@base_per,$dpa1a2,@algt,$snp);
   print "$out\n";
}
   my $score=100*$best/$totrs+0.7*100*$good/$totrs-8*100*$bad/$totrs;
   print SCORE "Sample:$sample[0];\tBest=$best;\tGood=$good;\tBad=$bad;\tScore=$score.\n";
}

}
