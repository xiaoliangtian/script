# Date:2015/09/17
# Author: Nieh
args<-commandArgs(T)
if (length(args)!=2) {
    cat("Usage:Rscript DEGseq.r GeneExpr A/B,C/D,A_B/C_D \n")
    q(status=1)
}
library(DEGseq)
cmd<-paste("head -3",args[1],sep=" ")
x<-read.table(pipe(cmd),header=T,stringsAsFactors=F)
comparisons<-strsplit(args[2],",")[[1]]
for (i in comparisons){
    vs<-strsplit(i,"/")[[1]]
    valCol1<-c()
    samps1<-strsplit(vs[1],"_")[[1]]
    name1<-paste("Reads",samps1,sep=".")
    for (j in name1) {
        # j<-paste(j,"\\d",sep="")
        valColj<-grep(j,colnames(x))
        valCol1<-c(valCol1,valColj)
    }
    expCol1<-1+(1:length(valCol1))

    valCol2<-c()
    samps2<-strsplit(vs[2],"_")[[1]]
    name2<-paste("Reads",samps2,sep=".")
    for (j in name2) {
        valColj<-grep(j,colnames(x))
        valCol2<-c(valCol2,valColj)
    }
    expCol2<-1+(1:length(valCol2))

    outputDir<-paste(paste(samps1,collapse="-"),"vs",paste(samps2,collapse="-"),"DEGseq",sep=".")
    geneExpMatrix1<-readGeneExp(file=args[1], geneCol=1,valCol=valCol1)
    geneExpMatrix2<-readGeneExp(file=args[1], geneCol=1,valCol=valCol2)
    DEGexp(geneExpMatrix1=geneExpMatrix1,geneCol1=1,expCol1=expCol1,groupLabel1=vs[1],geneExpMatrix2=geneExpMatrix2,geneCol2=1,expCol2=expCol2,outputDir=outputDir,groupLabel2=vs[2],method="MARS",thresholdKind=1)
}


