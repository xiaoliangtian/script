#!/usr/bin/env Rscript

###########################################################################
#                                                                         #
# Author: Yiming Wu                                                       #
# Version: 0.1                                                            #
# Date: Jun 12, 2019                                                      #
#                                                                         #
###########################################################################

## read input arguments
args <- commandArgs(trailingOnly=T)
if (length(args) != 1) {
	message("Please at least give a tab-format input file.")
	q()
}
infile = args[1]
cnv_dat <- read.table(args[1], sep="\t", header=F, stringsAsFactors=F)
colnames(cnv_dat) <- c("chromosome", "start", "end")

# in case there's "chr" prefix in file
cnv_dat$chromosome <- gsub(cnv_dat$chromosome, pattern='^chr', replacement='')

decipher_urls <- paste("https://decipher.sanger.ac.uk/search?q=", cnv_dat$chromosome, ":", cnv_dat$start, "-", cnv_dat$end, "#consented-patients/results", sep="")

## load necessary libraries
suppressPackageStartupMessages(require(ExomeDepth))
suppressPackageStartupMessages(require(GenomicRanges))
message("Loading annotation data.")

## read CNV annotation information
# 1) common CNV
data(Conrad.hg19)

dgv.gold.standard.cnv <- read.table("/workshop/ywu/db/DGV/DGV_gold_standard.cnv.txt", header=T, stringsAsFactors=F)
dgv.goldStandard.GRanges <- GRanges(seqnames = dgv.gold.standard.cnv$chromosome, 
	IRanges(start=dgv.gold.standard.cnv$start, end=dgv.gold.standard.cnv$end), names=dgv.gold.standard.cnv$annotation)

thousandGenomes.cnv <- read.table("/workshop/ywu/db/1000Genomes/1kG.wgs.mergedSV.txt", header=T, stringsAsFactors=F)
thousandGenomes.GRanges <- GRanges(seqnames = thousandGenomes.cnv$chromosome, 
	IRanges(start=thousandGenomes.cnv$start, end=thousandGenomes.cnv$end), names=thousandGenomes.cnv$annotation)

decipher.cnv <- read.table("/workshop/ywu/db/DECIPHER/decipher_population_cnv.txt", header=T, stringsAsFactors=F)
decipher.cnv.GRanges <- GRanges(seqnames = decipher.cnv$chromosome, 
	IRanges(start=decipher.cnv$start, end=decipher.cnv$end), names=decipher.cnv$annotation)

ExAC.cnv <- read.table("/workshop/ywu/db/ExAC/ExAC_CNV.bed", header=T, stringsAsFactors=F)
ExAC.cnv.GRanges <- GRanges(seqnames = ExAC.cnv$chromosome,
        IRanges(start=ExAC.cnv$start, end=ExAC.cnv$end), names=ExAC.cnv$annotation)

# 2) "disease" CNV
#clinvar.cnv <- read.table("/workshop/ywu/db/dbVar/dbVar_clinvar.hg19.bed", sep="\t", header=T, stringsAsFactors=F)
#clinvar.cnv.GRanges <- GRanges(seqnames = clinvar.cnv$chromosome, 
#	IRanges(start=clinvar.cnv$start, end=clinvar.cnv$end), names=clinvar.cnv$annotation)

#sfari.cnv <- read.table("/workshop/ywu/db/Others/SFARI_Autism_CNV.bed", header=T, stringsAsFactors=F)
#sfari.cnv.GRanges <- GRanges(seqnames = sfari.cnv$chromosome,
#        IRanges(start=sfari.cnv$start, end=sfari.cnv$end), names=sfari.cnv$annotation)

# 3) gene information
ExAC.genes <- read.table("/workshop/ywu/db/ExAC/ExAC_CNV_genescores.bed", header=T, stringsAsFactors=F)
ExAC.genes.GRanges <- GRanges(seqnames = ExAC.genes$chromosome,
        IRanges(start=ExAC.genes$start, end=ExAC.genes$end), names=ExAC.genes$annotation)

ExAC.pLI <- read.table("/workshop/ywu/db/ExAC/ExAC_genes_pLI.bed", header=T, stringsAsFactors=F)
ExAC.pLI.GRanges <- GRanges(seqnames = ExAC.pLI$chromosome,
        IRanges(start=ExAC.pLI$start, end=ExAC.pLI$end), names=ExAC.pLI$annotation)

decipher.HI <- read.table("/workshop/ywu/db/DECIPHER/decipher_HI.txt", header=T, stringsAsFactors=F)
decipher.HI.GRanges <- GRanges(seqnames = decipher.HI$chromosome,
        IRanges(start=decipher.HI$start, end=decipher.HI$end), names=decipher.HI$annotation)

#dbvar.nr_del <- read.table("/workshop/ywu/db/dbVar/GRCh37.nr_deletions.acmg_genes.bed", header=T, stringsAsFactors=F)
#dbvar.nr_del.GRanges <- GRanges(seqnames = dbvar.nr_del$chromosome,
#	IRanges(start=dbvar.nr_del$start, end=dbvar.nr_del$end), names=dbvar.nr_del$annotation)

#dbvar.nr_dup <- read.table("/workshop/ywu/db/dbVar/GRCh37.nr_duplications.acmg_genes.bed", header=T, stringsAsFactors=F)
#dbvar.nr_dup.GRanges <- GRanges(seqnames = dbvar.nr_dup$chromosome,
#        IRanges(start=dbvar.nr_dup$start, end=dbvar.nr_dup$end), names=dbvar.nr_dup$annotation)


## generate output filename
outfile <-  paste(gsub(infile, pattern='.\\w+$', replacement=''), '.cnv_anno.txt', sep='')

## generate mock ExomeDepth object
mock.dat <- new('ExomeDepth', test=111, reference=222)
mock.dat@CNV.calls <- cnv_dat

## annotate common CNV
mock.dat <- AnnotateExtra(x=mock.dat, reference.annotation = Conrad.hg19.common.CNVs, 
	min.overlap=0.5, column.name='Conrad.Common.CNV')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = dgv.goldStandard.GRanges,
            min.overlap = 0.5, column.name = 'DGV.GoldStandard.Common.CNV')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = thousandGenomes.GRanges,
            min.overlap = 0.5, column.name = '1000Genomes.Common.CNV')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = decipher.cnv.GRanges,
            min.overlap = 0.5, column.name = 'DECIPHER.Common.CNV')
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = ExAC.cnv.GRanges,
#            min.overlap = 0.5, column.name = 'ExAC.Common.CNV')

message("Finish annotating common CNV information.")

## annotate disease CNV
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = clinvar.cnv.GRanges,
#            min.overlap = 0.5, column.name = 'Clinvar.CNV')
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = sfari.cnv.GRanges,
#            min.overlap = 0.5, column.name = 'SFARI.ASD.CNV')
#message("Finish annotating \"disease\" CNV information.")

## annotate gene information
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = decipher.HI.GRanges,
            min.overlap = 0.5, column.name = 'Haploinsufficiency(LOD)')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = ExAC.genes.GRanges,
            min.overlap = 0.5, column.name = 'ExAC.genes.constraints')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = ExAC.pLI.GRanges,
            min.overlap = 0.5, column.name = 'ExAC.pLI')
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = dbvar.nr_del.GRanges,
#            min.overlap = 0.5, column.name = 'dbVar.Deletions.ACMG.genes')
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = dbvar.nr_dup.GRanges,
#            min.overlap = 0.5, column.name = 'dbVar.Duplications.ACMG.genes')

message("Finish annotating gene information.")

# write output
out_dat <- cbind(mock.dat@CNV.calls, decipher_urls)
write.table(file=outfile, x=out_dat, row.names=FALSE, quote=FALSE, sep="\t")
message("Finish writing output.")
