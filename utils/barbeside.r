#Date:2015/10/15
args<-commandArgs(T)
x<-read.table(args[1],header=T)
x<-as.matrix(x)
cutoff<-5
if(ncol(x)>cutoff) { x<-x[,1:cutoff] }
x<-apply(x,2,function(x) x/sum(x)*100)
cols<-c("#4A7EBB","#BE4B48","#0D7339","#3D90D9","#D98236","#DF514F","#8CCDA3","#3F5D7D","#279B61","#008AB8","#993333","#A3E496","#95CAE4","#CC3333","#FFCC33","#FFFF7A","#CC6699")
if (ncol(x)>length(cols)) {
    library(RColorBrewer)
    cols<-c(cols,colorRampPalette(brewer.pal(8,"Dark2"))(ncol(x)-length(cols)))
}
pdfname<-paste(args[2],"pdf",sep=".")
pdf(pdfname,width=8,onefile=FALSE)
par(mgp=c(2,0,0),mar=c(2,3.5,1,6),xpd=T)
# flag<-ncol(x)>1
barplot(t(x),col=cols[1:ncol(x)],border=NA,ylab="Percent",font.lab=2,yaxt="n",font.axis=2,cex.names=.9,beside=T)
axis(2,las=2,font=2,cex.axis=.9,mgp=c(3.5,0.7,0))
legend("right",legend=colnames(x),bty ="n",fill=cols,inset=-0.18,cex=1,text.font=2)
dev.off()
