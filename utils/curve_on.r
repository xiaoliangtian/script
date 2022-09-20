#Date:2015/10/15
library(ggplot2)
args<-commandArgs(T)
cutoff<-10
cmd<-paste("head -1",args[1],sep=" ")
header<-read.table(pipe(cmd),header=F,stringsAsFactors=F)
flag<-length(grep("[A-Z|a-z]",header[1,1]))==1
x<-read.delim(args[1],header=flag)
if(colnames(x)[ncol(x)]=="X") { x<-x[,-ncol(x)] }
if(ncol(x)-1>cutoff) {x<-x[,1:(cutoff+1)]}
vector<-as.vector(x[,-1])
ymin<-min(vector[!is.na(vector)])
ymax<-max(vector[!is.na(vector)])
xmin<-min(x[,1])
xmax<-max(x[,1])
cols<-c("#4A7EBB","#BE4B48","#0D7339","#3D90D9","#D98236","#DF514F","#8CCDA3","#3F5D7D","#279B61","#008AB8","#993333","#A3E496","#95CAE4","#CC3333","#FFCC33","#FFFF7A","#CC6699")
if (ncol(x)-1>length(cols)) {
    library(RColorBrewer)
    cols<-c(cols,colorRampPalette(brewer.pal(8,"Dark2"))(ncol(x)-1-length(cols)))
}

pdfname<-ifelse(length(args)>1,paste(args[2],"Curve.pdf",sep=""),"Curve.pdf")
lab<-paste(args[-c(1,2)],collapse=" ")
labstr<-strsplit(lab,",")[[1]]
pdf(pdfname,width=7,height=5,onefile=FALSE)
par(mar=c(5,4,2,2),mgp=c(2.6,0.7,0))
options(scipen=9999999)
if (abs(xmin)<5 & abs(ymin)<5){
    plot(c(0,1.1*max(x[,1])),c(0,1.1*ymax),type="n",xlab=labstr[1],ylab=labstr[2],font.lab=2,yaxt="n",font.axis=2,cex.axis=.7,xaxs="i", yaxs="i")
    #text(10000,labstr[2],"colnames(x)[2:ncol(x)]",pos=4,cex=0.5)
}else{
    plot(x[,1],seq(ymin,ymax,length=nrow(x)),type="n",xlab=labstr[1],ylab=labstr[2],font.lab=2,yaxt="n",font.axis=2,cex.axis=.7)
    #mtext(colnames(x)[2:ncol(x)],side=4,cex=0.5)
}
axis(2,las=2,font=2,cex.axis=.7)
if (ncol(x)>2) {
    for (i in (2:ncol(x))) {
        heng<-as.vector(x[,1])
        zong<-as.vector(x[,i-1])
        df<-data.frame(heng,zong)
        ggplot(df,aes(x=df$heng,y=df$zong))+ geom_line(size = 0, colour = cols[i-1],group=1)#+geom_text(aes(label=colnames(x)[i-1]),vjust=1)
        xmax1<-max(x[,i-1])
        #ymax1<-as.vector(x[,i-1])
        #vector1<-as.vector(x[,(i-1)])
        #max(as.vector(x[,(i-1)]))
       #text(xmax,ymax,colnames(x)[i-1],pos=4,cex=0.5)
    }
    #text(x[,1],seq(ymin,ymax,length=nrow(x)),label=colnames(x)[2:ncol(x)],cex=0.5)
    legend("bottomright",lty=1,cex=.7,legend=colnames(x)[2:ncol(x)],col=cols,bty="n",text.font=2,lwd=2,ncol=2)
    #mtext(colnames(x)[2:ncol(x)],side=4,cex=0.5)
}else{
    lines(x[,1],x[,2],lty=1,col="red",lwd=2)
}
dev.off()
