# Date:2016/1/27
args<-commandArgs(T)
x<-read.table(args[1],sep="\t",quote="",row.name=1,stringsAsFactors=F)
up<-length(which(x[, 10]=="up"))
up<-paste(up,"up-expressed genes")
down<-length(which(x[, 10]=="down"))
down<-paste(down,"down-expressed genes")
filename<-basename(args[1])
DG<-strsplit(filename,".DEA",fixed=TRUE)[[1]][1]
pdfname<-paste(DG,".DEGsScat.pdf",sep="")
pdf(pdfname)
sample<-strsplit(DG,".vs.",fixed=TRUE)[[1]]

x[x==0]<-0.0000001
logx<-log2(x[,6])
logy<-log2(x[,4])
RPKM_cutoff<-log2(20)
# FC_cutoff<-log2(2)
# color<-ifelse((logx>RPKM_cutoff)|(logy>RPKM_cutoff),
#         ifelse((logy-logx>(-FC_cutoff)),
#             ifelse((logy-logx<FC_cutoff),
#                 "black",
#             "red"),
#         "blue"),
#     "black")
color<-ifelse(x[,10]=="up","red",ifelse(x[,10]=="down","blue","black"))
plot(logx,logy,col=color,pch=20,cex=.3,xlim=c(-10,15),ylim=c(-10,15),xlab=bquote(log[2]~RPKM~.(sample[2])),ylab=bquote(log[2]~RPKM~.(sample[1])),main=DG,font.lab=2,yaxt="n",font.axis=2,cex.axis=.9)
axis(2,las=2,font=2,cex.axis=.9)

legend("topleft",col=c("red","blue","black"),legend=c(up,down,"equally-expressed genes"),pch=15,bty="n",inset=c(0.05,0),cex=.8)

fit<-lm(logy~logx)
r2<-formatC(summary(fit)$r.squared)
text(10,15,bquote(R^2 == .(r2)),cex=.9)
c<-lm(logy~logx+0)
abline(c,col='green',lwd=2)
# p<-formatC(summary(fit)$coefficients[2,4])  #coef(summary(fit))["logx","Pr(>|t|)"]
# pval<-ifelse(p==0,"p-value< 2.2e-16",paste("p-value= ",p))
# text(10,14,pval,cex=.9)

segments(-10,-8,-10,RPKM_cutoff,lwd=2)
segments(-10,RPKM_cutoff,-10,13,col="red",lwd=2)
segments(-8,-10,RPKM_cutoff,-10,lwd=2)
segments(RPKM_cutoff,-10,13,-10,col="blue",lwd=2)

dev.off()
