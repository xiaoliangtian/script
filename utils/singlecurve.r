#Date:2015/09/16
args<-commandArgs(T)
x<-read.table(args[1],header=FALSE,sep="\t")
pdfname<-ifelse(length(args)>1,paste(args[2],"Curve.pdf",sep=""),"Curve.pdf")
lab<-paste(args[-c(1,2)],collapse=" ")
labstr<-strsplit(lab,",")[[1]]
pdf(pdfname,width=7,height=5,onefile=FALSE)
options(scipen=9999999)
par(mar=c(5,4,2,2),xpd=T,mgp=c(2.6,0.7,0))
plot(x[,1],x[,2],type="n",xlab=labstr[1],ylab=labstr[2],font.lab=2,yaxt="n",font.axis=2,cex.axis=.7)
axis(2,las=2,font=2,cex.axis=.7)
lines(x[,1],x[,2],lty=1,col="red",lwd=2)
dev.off()
