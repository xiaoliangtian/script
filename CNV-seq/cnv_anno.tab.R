# this scirpt takes an input file in the format of cnv_anno from Xiaoliang Tian
require(ExomeDepth)
require(GenomicRanges)

# read input arguments
args <- commandArgs(trailingOnly=T)
input_file <- args[1]
if (is.na(args[1])) {message("Usage: Rscript cnv_anno.R <XXX.txt>")}

cnv_dat <- read.table(input_file, sep="\t", header=T, stringsAsFactors=F)

# read CNV annotation information
data(Conrad.hg19)
dgv.gold.standard.cnv <- read.table("/workshop/ywu/cnvdb/DGV/DGV_gold_standard.cnv.txt", sep="\t", header=T, stringsAsFactors=F)
thousandGenomes.cnv <- read.table("/workshop/ywu/cnvdb/1000Genomes/1kG.wgs.mergedSV.txt", sep="\t", header=T, stringsAsFactors=F)
decipher.cnv <- read.table("/workshop/ywu/cnvdb/DECIPHER/decipher_population_cnv.txt", sep="\t", header=T, stringsAsFactors=F)
decipher.HI <- read.table("/workshop/ywu/cnvdb/DECIPHER/decipher_HI.txt", sep="\t", header=T, stringsAsFactors=F)
#dbVar <- read.table("/workshop/ywu/cnvdb/dbVar/dbVar.hg19.txt", sep="\t", header=T, stringsAsFactors=F)

dgv.goldStandard.GRanges <- GRanges(seqnames = dgv.gold.standard.cnv$chromosome, IRanges(start=dgv.gold.standard.cnv$start, end=dgv.gold.standard.cnv$end), names=dgv.gold.standard.cnv$annotation)
thousandGenomes.GRanges <- GRanges(seqnames = thousandGenomes.cnv$chromosome, IRanges(start=thousandGenomes.cnv$start, end=thousandGenomes.cnv$end), names=thousandGenomes.cnv$annotation)
decipher.cnv.GRanges <- GRanges(seqnames = decipher.cnv$chromosome, IRanges(start=decipher.cnv$start, end=decipher.cnv$end), names=decipher.cnv$annotation)
decipher.HI.GRanges <- GRanges(seqnames = decipher.HI$chromosome, IRanges(start=decipher.HI$start, end=decipher.HI$end), names=decipher.HI$annotation)
#dbVar.GRanges <- GRanges(seqnames = dbVar$chromosome, IRanges(start=dbVar$start, end=dbVar$end), names=dbVar$annotation)


# generate output filename
out_file <- paste(gsub(input_file, pattern='.xls$', replacement=''), '.cnv_anno.xls', sep='')

# generate mock ExomeDepth object
mock.dat <- new('ExomeDepth', test=111, reference=222)
colnames(cnv_dat)[2] <- "chromosome"
mock.dat@CNV.calls <- cnv_dat

mock.dat <- AnnotateExtra(x=mock.dat, reference.annotation = Conrad.hg19.common.CNVs, min.overlap=0.5, column.name='Conrad.hg19')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = dgv.goldStandard.GRanges,
            min.overlap = 0.5, column.name = 'DGV.GoldStandard.hg19')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = thousandGenomes.GRanges,
            min.overlap = 0.5, column.name = '1000Genomes.hg19')
#mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = dbVar.GRanges,
#            min.overlap = 0.5, column.name = 'dbVar.hg19')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = decipher.cnv.GRanges,
            min.overlap = 0.5, column.name = 'DECIPHER.hg19')
mock.dat <- AnnotateExtra(x = mock.dat, reference.annotation = decipher.HI.GRanges,
            min.overlap = 0.5, column.name = 'Haploinsufficiency.hg19')

out.dat1 <- mock.dat@CNV.calls[,1:11]
out.dat2 <- mock.dat@CNV.calls[,12:14]
out.dat3 <- mock.dat@CNV.calls[,15:ncol(mock.dat@CNV.calls)]
out.dat <- cbind(out.dat1,out.dat3,out.dat2)
write.table(file = out_file, x = out.dat, row.names = FALSE, quote=FALSE, sep="\t")
