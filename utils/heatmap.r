# Date: 2015/10/11
args<-commandArgs(T)
library(gplots)
x<-read.table(args[1],header=T)
x<-as.matrix(x)
scale<-"row"
m<-x
if (length(args)==2) {
    scale<-"none"
}else{
    if (ncol(x)==2) {
        x[x==0]<-0.0000001
        m<-log10(x)
        scale<-"none"
    }
}
if(ncol(x)==1){
    control<-rep(0,nrow(x))
    x<-cbind(x,control)
    m<-x
    scale<-"none"
}
pdf("Heatmap.pdf")
hm<-heatmap.2(m,col=greenred(75),scale=scale,density.info="none",trace="none",key.title=NA,key.xlab="",labRow=NA,cexCol=1.5,adjCol=0.5,lmat=rbind(rbind(c(0,4,0),c(0,3,3),c(2,1,1))),lwid=c(1,3,1),lhei=c(1.5,0.8,5),srtCol=0)
# srtCol=0,adjCol=0.5
y<-x[rev(hm$rowInd), hm$colInd]
write.table(y,"sorted_heatmap.data",row.names=TRUE,sep="\t",quote=FALSE,col.names=NA)
dev.off()
# carpet<-t(hm$carpet)
# z<-carpet[nrow(carpet):1,]
#z<-apply(t(hm$carpet), 2, rev)
