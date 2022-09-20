# Date:2016/1/27
args<-commandArgs(T)
x<-read.table(args[1],sep="\t",quote="",row.name=1,stringsAsFactors=F)
filename<-basename(args[1])
DG<-strsplit(filename,".DEA",fixed=TRUE)[[1]][1]
pdfname<-paste(DG,".DEGsVolc.pdf",sep="")
pdf(pdfname)

color<-ifelse(x[,10]=="up","red",ifelse(x[,10]=="down","blue","black"))
meanexp<-(x[,4]+x[,6])/2
plot(log2(meanexp),x[,7],col=color,pch=20,cex=.3,xlab="log2(Mean expression)",ylab="log2(Fold change)",font.lab=2,yaxt="n",font.axis=2,cex.axis=.9)
axis(2,las=2,font=2,cex.axis=.9)
abline(h=1,col="red",lty="dashed")
abline(h=-1,col="blue",lty="dashed")
