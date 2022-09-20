# Date:2015/06/18 Vesion 1.1 fix the lay out auto
# Date:2015/06/19 Vesion 1.2 fix the bug that axis y not the the gene annoted in GO num

args<-commandArgs(T)
if (length(args)!=2){
    cat("pelase input GO.count and the gene annoted in GO num\n")
    q(status=1)
}
x<-read.table(args[1],header=FALSE,sep="\t",stringsAsFactors=F)
num_class<-as.data.frame(table(x[,1]))$Freq
level_class<-levels(factor(x[,1]))
# cols=c("orange3","maroon","RoyalBlue4","AntiqueWhite1","DodgerBlue1","SkyBlue3","Blue1","LightBlue1","Cyan3","gold1","DarkOrange1","DarkOrange3","PeachPuff3","MediumPurple1","PaleGreen1","MediumPurple4")
cols<-c("#0D7339","#3D90D9","#D98236","#DF514F","#8CCDA3")
col<-c(rep (cols[1:length(num_class)],num_class[1:length(num_class)]))
ymax<-as.numeric(args[2])
num<-x[,3]/ymax*100

width<-nrow(x)%/%5
pdf("GO.pdf",width=width,height=6,onefile=FALSE)
# windows(width=10, height=6)
layout(matrix(c(1,2),nrow=2),heights=c(6,6))

par(mar=c(0,3,2.5,3))
bar<-barplot(num,border=NA,col=col,ylim=c(0.01,100),yaxt="n",space=0.5,log='y',main="Gene Function Classification (GO)",ylab="Percent of genes",cex.main=0.9,font.lab=2,cex.lab=0.8,mgp=c(1.8,0.6,0))
axis(2,las=2,cex.axis=.7,mgp=c(1.8,0.6,0),font=2,at=c(0.01,0.1,1,10,100),labels=c(0.01,0.1,1,10,100))
axis(4,las=2,cex.axis=.7,mgp=c(1.8,0.6,0),font=2,at=c(0.01,0.1,1,10,100),labels=c(round(ymax/10000),round(ymax/1000),round(ymax/100),round(ymax/10),ymax))
axis(1,cex.axis=.7,mgp=c(1.8,0.6,0),at=bar,labels=FALSE,tck=-0.01)
mtext("Number of genes",side=4,font=2,line=1.8,cex=0.8)

offsetx<-0.2
offsety<-1
par(mar=c(0,3,0,3),xpd=T)
plot(c(1,max(bar)+1),c(1,max(bar)+1),xlab=NA,ylab=NA,type="n",axes=FALSE)
text(bar+0.5,max(bar)+1,labels=x[,2],srt=80,adj=1,cex=.7,font=2)
angle<-atan(tanpi(80/180)*width/3)
h<-sin(angle)
l<-cos(angle)
# maxl<-max(nchar(x[,2])-3)*width/6
maxl<-(max(bar)-3)/h
textsize<- function(i){
    tesize<-nchar(x[i,2])*width/6+1
    # tesize<-ifelse(size>40, size+27, size*2)
    return(tesize)
}
for(i in 1:length(num_class)){
    start<-sum(num_class[1:i])-num_class[i]+1
    end<-sum(num_class[1:i])
    segments(bar[start]+offsetx-textsize(start)*l,max(bar)+offsety-textsize(start)*h,bar[start]+offsetx-maxl*l,max(bar)+offsety-maxl*h,col=cols[i],lwd=2)
    segments(bar[end]+offsetx-textsize(end)*l,max(bar)+offsety-textsize(end)*h,bar[end]+offsetx-maxl*l,max(bar)+offsety-maxl*h,col=cols[i],lwd=2)
    segments(bar[start]+offsetx-maxl*l,max(bar)+offsety-maxl*h,bar[end]+offsetx-maxl*l,max(bar)+offsety-maxl*h,col=cols[i],lwd=1.5)
    text((bar[start]+bar[end])/2+offsetx-maxl*l,max(bar)+offsety-(maxl+2)*h,labels=level_class[i],font=2,adj=c(0.5,0.5),cex=.8)
}

# for (i in 1:length(col)){
#     tesize<-nchar(x[i,2])*2
#     if (nchar(x[i,2])>40){
#         tesize<-75
#     }
#     points(bar[i]+offsetx-tesize*l,max(bar)+offsety-tesize*h,col="red",cex=1,pch=16)
# }
# box()
# dev.off(),xpd=TRUE
# bar<-barplot(num,plot=FALSE)
#####################################
# par(mar=c(10,2,0,0))
# axis(1,at=y,las=2,labels=x$V2,lwd.ticks=0)
# axis(1,at=bar)
# legend("topright",legend=level_class,pch=15,col=cols[1:length(num_class)],cex=1.8)
