#date:2015/10/14
args<-commandArgs(T)
x<-read.table(args[1],header=T)
x<-as.matrix(x)
x<-apply(x,2,function(x) x/sum(x)*100)
cols<-c("#4A7EBB","#BE4B48","#0D7339","#CC6699","#D98236","#DF514F","#8CCDA3","#3F5D7D","#279B61","#FFFF7A","#993333","#A3E496","#95CAE4","#CC3333","#FFCC33","#3D90D9","#008AB8")
if (nrow(x)>length(cols)) {
    library(RColorBrewer)
    cols<-c(cols,colorRampPalette(brewer.pal(8,"Dark2"))(nrow(x)-length(cols)))
}
pdfname<-paste(args[2],"pdf",sep=".")
pdf(pdfname,onefile=FALSE)
if (ncol(x)==1) {
    ratio<-sprintf("%.2f",x[,1])
    ratio<-paste(ratio,"%",sep="")
    par(mar=c(0,2,0,7),xpd=T)
    pie(x,col=cols,labels=ratio)
    legend("right",legend=rownames(x),bty="n",inset=-0.25,fill=cols)
}else{
    chr<-max(nchar(rownames(x)))
    side<-chr*0.3+4.5
    inset<-chr*0.023+0.05
    par(mar=c(4,3,2,side),xpd=T,mgp=c(2,0,0))
    barplot(x,col=cols,yaxt="n",border=NA,cex.name=0.7,space=1,font=2,las=2)
    axis(2,axTicks(2),labels=paste(axTicks(2),"%",sep=""),las=2,mgp=c(3,0.5,0),cex.axis=1,font=2)
    legend("right",col=cols,legend=rownames(x),pch=15,bty="n",inset=-inset,text.font=2,cex=0.9)
}
dev.off()
