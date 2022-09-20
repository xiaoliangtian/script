#Date:2015/09/15
#Motified:2015/10/14 add colors
args<-commandArgs(T)
x<-read.table(args[1],header=FALSE,sep="\t")
pdfname<-ifelse(length(args)==2,paste(args[2],"Pie.pdf",sep=""),"Pie.pdf")
pdf(pdfname,width=7,height=4,onefile=FALSE)
ratio<-sprintf("%.2f",100*x[,2]/sum(x[,2]))
ratio<-paste(ratio,"%",sep="")
par(mar=c(0,2,0,12),xpd=T)
cols<-c("#4A7EBB","#BE4B48","#0D7339","#3D90D9","#D98236","#DF514F","#8CCDA3","#3F5D7D","#279B61","#008AB8","#993333","#A3E496","#95CAE4","#CC3333","#FFCC33","#FFFF7A","#CC6699")
if (length(x[,2])>length(cols)) {
    library(RColorBrewer)
    cols<-c(cols,colorRampPalette(brewer.pal(8,"Dark2"))(length(x[,2])-length(cols)))
}
pie(x[,2],col=cols,labels=ratio,cex=.5)
legend("right",legend=x[,1],bty="n",inset=-0.5,fill=cols,cex=1.1)
dev.off()
