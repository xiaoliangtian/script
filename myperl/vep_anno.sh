for i in test.srt.bam.raw.vcf;do perl /home/xiaoliang.tian/software/ensembl-tools-release-89/scripts/variant_effect_predictor/variant_effect_predictor.pl -i $i -o $i.vep.anno --species homo_sapiens --assembly GRCh37 --plugin CSN --tab --cache --dir /home/xiaoliang.tian/.vep --fasta /home/xiaoliang.tian/.vep/homo_sapiens/89_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa   --offline --db_version 89  --appris --biotype --check_existing --hgvs --numbers  --plugin ExAC,/home/xiaoliang.tian/.vep/ExAC.r0.3.1.sites.vep.vcf.gz --polyphen b --protein --pubmed  --regulatory --sift b --symbol --tsl --uniprot --force_overwrite --refseq ;done
