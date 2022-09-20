#!usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my $nodup=0;#not remove duplicates
my $se=0;#single-end

GetOptions("nodup"=>\$nodup,"se"=>\$se);

sub usage{
die"

==============================================================
Version:3.0

	perl qc_table3.pl [options] pipline_out qc_out sample

options:
	nodup       not remove duplicates
	se          for single-end

Note:
	pipline_out content mapsatats,metrics
	qc_out      content stats
	sample      list of sample
==============================================================

\n"
}

my (%reads,%map,%proper_map,%discordant,%singleton,%dup,%tmp);
my %qc_stats;

main(@ARGV);

sub main{
	usage() if @_!=3;
	my ($pip_out,$qc_out,$sample_file)=@_;
	print "nodup = $nodup,se = $se,out = $pip_out,qc = $qc_out,sample = $sample_file\n";
	$pip_out =~ s/\/$//;
	$qc_out =~ s/\/$//;
	read_map_dup($pip_out,$sample_file);
	read_qc($qc_out,$sample_file);
	print_result($sample_file);

}

sub read_map_dup{

	my ($dir,$sample_name)=@_;
	open IN,"<$sample_name" or die "cannot open $sample_name:$!";
	while(<IN>){

		chomp;
		my $sample = $_;

		my $file_map ="$dir/$sample.mapstats";
		open MAP,"<$file_map" || die "Cannot open $file_map:$!";		
		while(<MAP>){

			chomp;
			my @lines = split;

			if($se){
				$reads{$sample} = $lines[0] if $.==1;
                        	$tmp{$sample} = $lines[0] if $.==5;
                        	$proper_map{$sample} = $lines[0] if $.==9;
                        	$discordant{$sample} = $lines[0] if $.==12;
                        	$singleton{$sample} = $lines[0] if $.==11;
				next;
			}
			$reads{$sample} = $lines[0] if $.==6;
			$tmp{$sample} = $lines[0] if $.==10;
			$proper_map{$sample} = $lines[0] if $.==9;
			$discordant{$sample} = $lines[0] if $.==12;
			$singleton{$sample} = $lines[0] if $.==11;

		}

		$map{$sample} = $tmp{$sample} + $singleton{$sample};
		close MAP;

		if($nodup){
			$dup{$sample}=0;
			next;
		}

		my $file_dup = "$dir/$sample\.metrics";
		open DUP,"<$file_dup" or die "Cannot open $file_dup:$!";
		while(<DUP>){

			next if /^#/;
			chomp;
			if (/^WGC(.*)/ or /^S(.*)/){

				my @lines=split;
				foreach my $num(@lines){
					$dup{$sample} = $num if $num lt 1;
				}

			}

		
		}
		close DUP;

	}
	close IN;
}

sub read_qc_stats{
	my ($sample,$direc,$stats)=@_;	
	open SATAS,"<$stats" or die "Cannot open $stats:$!";
	while(<SATAS>){
		chomp;
		next unless $_;
		my @lines = split;
		if ($lines[0]=/rawReads/){
			$qc_stats{$sample}{$direc}{'rawReads'}=$lines[1];
		}elsif ($lines[0]=/rawBases/){
			$qc_stats{$sample}{$direc}{'rawBases'}=$lines[1];
		}elsif ($lines[0]=/effectiveReads/){
			$qc_stats{$sample}{$direc}{'effectiveReads'}=$lines[1];
		}elsif ($lines[0]=/effectiveBases/){
			$qc_stats{$sample}{$direc}{'effectiveBases'}=$lines[1];
		}elsif ($lines[0]=/q20Bases/){
			$qc_stats{$sample}{$direc}{'q20Bases'}=$lines[1];
		}elsif ($lines[0]=/q30Bases/){
			$qc_stats{$sample}{$direc}{'q30Bases'}=$lines[1];
		}elsif ($lines[0]=/gcBases/){
			$qc_stats{$sample}{$direc}{'gcBase'}=$lines[1];
		}

	}
	close SATAS;
}

sub read_qc{
	my ($dir,$sample_name)=@_;
	open IN1,"<$sample_name" or die "Cannot open $sample_name:$!";	
	while(<IN1>){
		chomp;
		my $sample=$_;
		print "$sample\n";
		my $file_f;
		print "se=$se\n";
		($se != 0) ? ($file_f="$dir/fqcOut/$sample.fastq.gz/stats.txt") : ($file_f="$dir/fqcOut/$sample\_R1.fastq.gz/stats.txt");
		read_qc_stats($sample,'F',$file_f);
		if($se){
			$qc_stats{$sample}{'rawReads'} = $qc_stats{$sample}{'F'}{'rawReads'};
                	$qc_stats{$sample}{'rawBases'} = $qc_stats{$sample}{'F'}{'rawBases'};
                	$qc_stats{$sample}{'effectiveReads'} = $qc_stats{$sample}{'F'}{'effectiveReads'};
        	        $qc_stats{$sample}{'effectiveBases'} = $qc_stats{$sample}{'F'}{'effectiveBases'};
                	$qc_stats{$sample}{'q20Bases'} = $qc_stats{$sample}{'F'}{'q20Bases'};
        	        $qc_stats{$sample}{'q30Bases'} = $qc_stats{$sample}{'F'}{'q30Bases'};
	                $qc_stats{$sample}{'gcBase'} = $qc_stats{$sample}{'F'}{'gcBase'};
			next;
		}

		my $file_r="$dir/fqcOut/$sample\_R2.fastq.gz/stats.txt";
		read_qc_stats($sample,'R',$file_r);
		
		$qc_stats{$sample}{'rawReads'} = $qc_stats{$sample}{'F'}{'rawReads'} + $qc_stats{$sample}{'R'}{'rawReads'};
                $qc_stats{$sample}{'rawBases'} = $qc_stats{$sample}{'F'}{'rawBases'} + $qc_stats{$sample}{'R'}{'rawBases'};
                $qc_stats{$sample}{'effectiveReads'} = $qc_stats{$sample}{'F'}{'effectiveReads'} + $qc_stats{$sample}{'R'}{'effectiveReads'};
                $qc_stats{$sample}{'effectiveBases'} = $qc_stats{$sample}{'F'}{'effectiveBases'} + $qc_stats{$sample}{'R'}{'effectiveBases'};
                $qc_stats{$sample}{'q20Bases'} = $qc_stats{$sample}{'F'}{'q20Bases'} + $qc_stats{$sample}{'R'}{'q20Bases'};
                $qc_stats{$sample}{'q30Bases'} = $qc_stats{$sample}{'F'}{'q30Bases'} + $qc_stats{$sample}{'R'}{'q30Bases'};
                $qc_stats{$sample}{'gcBase'} = $qc_stats{$sample}{'F'}{'gcBase'} + $qc_stats{$sample}{'R'}{'gcBase'};
	}
	close IN1;
}

sub print_result{
	my $sample_name=shift;
	open SAM,"<$sample_name" or die "cannot open $sample_name:$!";
	my @sample;
	while(<SAM>){
		chomp;
		push @sample,$_;
	}
	close SAM;

	my $qc_result = "qcData.table";
	open QC,">$qc_result" or die "cannot open $qc_result:$!";	
	print QC "Sample\tRaw_Reads\tRaw_Bases\tEffective_Reads\tEfftective_Bases\tEffective_Rate\tMean_Read_Length\tQ30\tQ20\tGC_Content\n";
	foreach my $sample(@sample){
		print QC $sample."\t";
                printf QC "%.2fM", $qc_stats{$sample}{'rawReads'}/1000000;
                printf QC "\t%.2fG",$qc_stats{$sample}{'rawBases'}/1000000000;
                printf QC "\t%.2fM",$qc_stats{$sample}{'effectiveReads'}/1000000;
                printf QC "\t%.2fG",$qc_stats{$sample}{'effectiveBases'}/1000000000;
                printf QC "\t%.2f",100*$qc_stats{$sample}{'effectiveBases'}/$qc_stats{$sample}{'rawBases'};
                print QC "%";
                print QC "\t".$qc_stats{$sample}{'rawBases'}/$qc_stats{$sample}{'rawReads'};
                printf QC "\t%.2f",100*($qc_stats{$sample}{'q30Bases'}/$qc_stats{$sample}{'rawBases'});
                print QC "%";
                printf QC "\t%.2f",100*($qc_stats{$sample}{'q20Bases'}/$qc_stats{$sample}{'rawBases'});
                print QC "%";
                printf QC "\t%.2f",100*($qc_stats{$sample}{'gcBase'}/$qc_stats{$sample}{'rawBases'});
                print QC "%";
                print QC "\n";

	}
	close QC;
	
	my $map_result="mapData.table";
	open MP ,">$map_result" or die "cannot open $map_result:$!";	
	print MP "Sample\tReads\tMapped\tUnmapped\tProper_mapped\tdiscordant_mapped\tSingleton\tDuplicates\n";
	foreach my $sample(@sample){
                print MP $sample."\t";
                printf MP $reads{$sample};
                print MP "\t$map{$sample}";
                printf MP "|%.2f",100*$map{$sample}/$reads{$sample};
                print MP "%";
                print MP "\t".($reads{$sample}-$map{$sample});
                printf MP "|%.2f",100*($reads{$sample}-$map{$sample})/$reads{$sample};
                print MP "%";
                print MP "\t$proper_map{$sample}";
                printf MP "|%.2f",100*($proper_map{$sample}/$reads{$sample});
                print MP "%";
                print MP "\t$discordant{$sample}";
                printf MP "|%.2f",100*($discordant{$sample}/$reads{$sample});
                print MP "%";
                print MP "\t$singleton{$sample}";
                printf MP "|%.2f",100*($singleton{$sample}/$reads{$sample});
                print MP "%";
                printf MP "\t%.2f",100*($dup{$sample});
                print MP "%";
                print MP "\n";
        }
        close MP;
}
