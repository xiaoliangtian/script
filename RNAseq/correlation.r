# Date:2016/1/27
args<-commandArgs(T)
if (length(args)!=2) {
    cat("Usage:Rscript correlation.r GeneExpr A/B,C/D \n")
    q(status=1)
}
x<-read.table(args[1],header=T,stringsAsFactors=F)
arguments<-strsplit(args[2],",")[[1]]
for (i in arguments){
    vs<-strsplit(i,"/")[[1]]
    sample<-paste("RPKM",vs,sep=".")
    m<-subset(x,select=sample)
    lg<-log10(m+1)
    title<-paste(vs[2],vs[1],sep=".vs.")
    pdf(paste(title,"Correlation.pdf",sep="."),onefile=FALSE)
    plot(lg,pch=20,col="#247DE9",cex=.3,xlim=c(0,5),ylim=c(0,5),xlab=bquote(log[10]~(RPKM+1)~.(vs[1])),ylab=bquote(log[10]~(RPKM+1)~.(vs[2])),main=title,font.lab=2,yaxt="n",font.axis=2,cex.axis=.9)
    axis(2,las=2,font=2,cex.axis=.9)
    fit<-lm(lg[,2]~lg[,1])
    r2<-formatC(summary(fit)$r.squared)
    # p<-formatC(summary(fit)$coefficients[2,4])
    # pval<-ifelse(p==0,"p-value< 2.2e-16",paste("p-value= ",p))
    abline(fit,col='red',lwd=2)
    text(0,5,bquote(R^2 == .(r2)),cex=.9,adj=c(0,1))
    # text(0,4.5,pval,cex=.9,adj=c(0,0))
    dev.off()
}

