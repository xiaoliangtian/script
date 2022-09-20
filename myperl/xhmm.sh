xhmm --genotype -p params.txt  -r DATA.PCA_normalized.filtered.sample_zscores.RD.txt  -R DATA.same_filtered.RD.txt -g DATA.xcnv -F human_g1k_v37.fasta  -v DATA.vcf
java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \
-T DepthOfCoverage -I group1.READS.bam.list -L EXOME.interval_list \
-R /opt/seqtools/gatk/ucsc.hg19.fasta \
-dt BY_SAMPLE -dcov 5000 -l INFO --omitDepthOutputAtEachBase –omitLocusTable \
--minBaseQuality 0 --minMappingQuality 20 \
--start 1 --stop 5000 --nBins 200 \
--includeRefNSites \
--countType COUNT_FRAGMENTS \
-o group1.DATA
 java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar -T DepthOfCoverage -I QW-302_combined.bam -L /opt/seqtools/bed/SeqCap_EZ_Exome_v3_capture.intervals -R  /opt/seqtools/gatk/ucsc.hg19.fasta -dt BY_SAMPLE -dcov 5000 -l INFO --omitDepthOutputAtEachBase --omitLocusTable --minBaseQuality 0 --minMappingQuality 20 --start 1 --stop 5000 --nBins 200 --includeRefNSites --countType COUNT_FRAGMENTS -o group1.DATA


java -XX:ParallelGCThreads=1 -jar /opt/seqtools/gatk/GenomeAnalysisTK.jar \
-T GCContentByInterval -L EXOME.interval_list \
-R /opt/seqtools/gatk/ucsc.hg19.fasta \
-o DATA.locus_GC.txt

cat  DATA.locus_GC.txt | awk '{if ($2 < 0.1 || $2 > 0.9) print $1}' > extreme_gc_targets.txt

interval_list_to_pseq_reg  EXOME.interval_list > EXOME.targets.reg

pseq . loc-load --locdb EXOME.targets.LOCDB --file EXOME.targets.reg --group targets  --out ./EXOME.targets.LOCDB.loc-load


pseq . loc-stats --locdb /home/xiaoliang.tian/software/plinkseq/hg19/refdb.dbsnp --group targets --seqdb /home/xiaoliang.tian/software/plinkseq/hg19/seqdb.hg19 | awk '{if(NR > 1) print $_}' | sort -k1 -g | awk '{print $10}' | paste EXOME.interval_list - | awk ‘{print $1"\t"$2}' > DATA.locus_complexity.txt

cat  DATA.locus_complexity.txt | awk '{if ($2 > 0.25) print $1}' > low_complexity_targets.txt

xhmm --mergeGATKdepths -o DATA.RD.txt --GATKdepths group1.DATA.sample_interval_summary --GATKdepths group2.DATA.sample_interval_summary

xhmm --matrix -r DATA.RD.txt --centerData --centerType target -o DATA.filtered_centered.RD.txt --outputExcludedTargets DATA.filtered_centered.RD.txt.filtered_targets.txt --outputExcludedSamples DATA.filtered_centered.RD.txt.filtered_samples.txt --excludeTargets extreme_gc_targets.txt --excludeTargets low_complexity_targets.txt --minTargetSize 10 --maxTargetSize 10000 --minMeanTargetRD 10 --maxMeanTargetRD 500 --minMeanSampleRD 25 --maxMeanSampleRD 200 --maxSdSampleRD 150

xhmm --PCA -r DATA.filtered_centered.RD.txt --PCAfiles DATA.RD_PCA

xhmm --normalize -r DATA.filtered_centered.RD.txt --PCAfiles DATA.RD_PCA --normalizeOutput DATA.PCA_normalized.txt --PCnormalizeMethod PVE_mean --PVE_mean_factor 0.7


xhmm --matrix -r DATA.PCA_normalized.txt --centerData --centerType sample --zScoreData -o DATA.PCA_normalized.filtered.sample_zscores.RD.txt --outputExcludedTargets DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt --outputExcludedSamples DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt --maxSdTargetRD 30

xhmm --matrix -r DATA.RD.txt --excludeTargets DATA.filtered_centered.RD.txt.filtered_targets.txt --excludeTargets DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_targets.txt --excludeSamples DATA.filtered_centered.RD.txt.filtered_samples.txt --excludeSamples DATA.PCA_normalized.filtered.sample_zscores.RD.txt.filtered_samples.txt -o DATA.same_filtered.RD.txt

xhmm --discover -p params.txt -r DATA.PCA_normalized.filtered.sample_zscores.RD.txt -R DATA.same_filtered.RD.txt -c DATA.xcnv -a DATA.aux_xcnv -s DATA


pseq . loc-intersect --group refseq --locdb /home/xiaoliang.tian/software/plinkseq/hg19/locdb --file EXOME.interval_list --out annotated_targets.refseq

xhmm --genotype -p params.txt -r DATA.PCA_normalized.filtered.sample_zscores.RD.txt -R DATA.same_filtered.RD.txt -g DATA.xcnv -F /opt/seqtools/gatk/ucsc.hg19.fasta -v DATA.vcf