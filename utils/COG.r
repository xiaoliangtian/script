#date:2015/10/14
args<-commandArgs(T)
x<-read.table(args[1],sep="\t",header=F)
cols<-x[,4]
pdfname<-ifelse(length(args)==2,paste(args[2],"pdf",sep="."),"COG.pdf")
pdf(pdfname,width=9,height=6,onefile=FALSE)
par(mgp=c(2,0,0),mar=c(4,3,2,18),xpd=T)
barplot(x[,2],col=as.character(cols),names.arg=x[,1],ylim=c(0,1.2*max(x[,2])),cex.name=0.6,width=0.6,space=0.6,yaxt="n",font=2,xlab="Function Class",ylab="Frequency",font.lab=2)
axis(2,las=2,mgp=c(3,0.7,0),font=2,cex.axis=.7)
box()
legend("right",legend=paste(x[,1],x[,3],sep=":"),cex=.7,bty="n",inset =-0.75,text.font=2)
