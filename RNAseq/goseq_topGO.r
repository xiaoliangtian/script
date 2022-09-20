# Date:2016/1/27
args<-commandArgs(T)
library(topGO)
geneTable<-read.table(file=args[1],sep="\t",row.names=1,quote="",stringsAsFactors=F)
filename<-basename(args[1])
DG<-strsplit(filename,".DEA",fixed=TRUE)[[1]][1]
myInterestedGenes<-row.names(geneTable)[c(which(geneTable[, 10]=="up"),which(geneTable[, 10]=="down"))]
geneID2GO<-readMappings(file=args[2])
# GO2geneID<-inverseList(geneID2GO)
# GO_info<-read.table(args[2], header=F, row.names=1,stringsAsFactors=F)
# geneID2GO<-apply(GO_info, 1, function(geneTable) unlist(strsplit(geneTable,',')))
# names(geneID2GO)<-rownames(GO_info)
geneNames<-names(geneID2GO)
geneList<-factor(as.integer(geneNames %in% myInterestedGenes))
names(geneList)<-geneNames

# goseq analysis
library(goseq)
gene_lengths<-geneTable[,1,drop=F][geneNames,]
pwf<-nullp(geneList,bias.data=gene_lengths)
res<-goseq(pwf,gene2cat=geneID2GO)    #test.cats=c("GO:MF") "KEGG"

## over-represented categories:
pvals<-res$over_represented_pvalue
pvals[pvals> 1-1e-10]<-1-1e-10
qvals<-p.adjust(pvals,method="fdr")   #"BH" or its alias "fdr"
res$over_represented_FDR<-qvals
go_enrich_filename<-paste(DG,"GOseq.enriched",sep=".")
result_table<-res[res$over_represented_FDR<=0.05,]
write.table(result_table[order(result_table$over_represented_pvalue),],file=go_enrich_filename,sep="\t",quote=F,row.names=F)
## under-represented categories:
# pvals<-res$under_represented_pvalue
# pvals[pvals>1-1e-10]<-1-1e-10
# qvals<-p.adjust(pvals,method="fdr")
# res$under_represented_FDR<-qvals
# go_depleted_filename<-paste(DG,".GOseq.depleted",sep="")
# result_table<-res[res$under_represented_pvalue<=0.05,]
# write.table(result_table[order(result_table$under_represented_pvalue),],file=go_depleted_filename,sep="\t",quote=F,row.names=F)

# topGO
# useInfo = c("none", "pval", "counts", "def", "np", "all")
# Fisher's Exact Test is Based on Hypergeometric Distribution
BPdata<-new("topGOdata",ontology="BP",allGenes=geneList,annot=annFUN.gene2GO,gene2GO=geneID2GO)
resultFisher<-runTest(BPdata,algorithm="classic",statistic="fisher")
# gtFisher<-GenTable(BPdata,classicFisher=resultFisher,orderBy="classic",ranksOf="classicFisher",topNodes=40)
# write.table(gtFisher,paste(DG,".BP.xls",sep=""),sep="\t",quote=F,row.names=F)
printGraph(BPdata,resultFisher,firstSigNodes=10, fn.prefix=paste(DG,".BP",sep=""),useInfo="all",pdfSW=TRUE)

CCdata<-new("topGOdata",ontology="CC",allGenes=geneList,annot=annFUN.gene2GO,gene2GO=geneID2GO)
resultFisher<-runTest(CCdata,algorithm="classic",statistic="fisher")
# gtFisher<-GenTable(CCdata,classicFisher=resultFisher,orderBy="classic",ranksOf="classicFisher",topNodes=40)
# write.table(gtFisher,paste(DG,".CC.xls",sep=""),sep="\t",quote=F,row.names=F)
printGraph(CCdata,resultFisher,firstSigNodes=10, fn.prefix=paste(DG,".CC",sep=""),useInfo="all",pdfSW=TRUE)

MFdata<-new("topGOdata",ontology="MF",allGenes=geneList,annot=annFUN.gene2GO,gene2GO=geneID2GO)
resultFisher<-runTest(MFdata,algorithm="classic",statistic="fisher")
# gtFisher<-GenTable(MFdata,classicFisher=resultFisher,orderBy="classic",ranksOf="classicFisher",topNodes=40)
# write.table(gtFisher,paste(DG,".MF.xls",sep=""),sep="\t",quote=F,row.names=F)
printGraph(MFdata,resultFisher,firstSigNodes=10, fn.prefix=paste(DG,".MF",sep=""),useInfo="all",pdfSW=TRUE)

dev.off()
# reorganize file
file.remove("Rplots.pdf")
file.rename(paste(DG,".BP_classic_10_all.pdf",sep=""),paste(DG,".BP_DAG.pdf",sep=""))
file.rename(paste(DG,".CC_classic_10_all.pdf",sep=""),paste(DG,".CC_DAG.pdf",sep=""))
file.rename(paste(DG,".MF_classic_10_all.pdf",sep=""),paste(DG,".MF_DAG.pdf",sep=""))
