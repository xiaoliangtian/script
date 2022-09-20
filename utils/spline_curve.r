#Date:2015/10/15
args<-commandArgs(T)
cutoff<-50
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
cols<-c("#4A7EBB","#BE4B48","#0D7339","#D98236","#CC6699","#3F5D7D","#279B61","#008AB8","#993333","#3D90D9","#A3E496","#95CAE4","#CC3333","#FFCC33","#FFFF7A","#CC6699")
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
}else{
    plot(x[,1],seq(ymin,ymax,length=nrow(x)),type="n",xlab=labstr[1],ylab=labstr[2],font.lab=2,yaxt="n",font.axis=2,cex.axis=.7)
}
axis(2,las=2,font=2,cex.axis=.7)
if (ncol(x)>2) {
    for (i in (2:ncol(x))) {
        if( x[4,i]<200) {
        print(colnames(x)[i])
        lines(spline(x[,1],x[,i], n = 1000, method = "fmm"),lty=1,col=cols[i-1],lwd=2)
        a<-which.max(x[,i])
        #print(a)
        
            text(x[a,1],max(x[a,i]),colnames(x)[i],col=cols[i-1],pos=3,cex = 0.5)
        }
        else {
           lines(spline(x[,1],x[,i], n = 1000, method = "fmm"),lty=1,col=cols[i-1],lwd=2)
           legend("topright",lty=1,cex=.6,legend=colnames(x)[2:ncol(x)],col=cols,bty="n",text.font=2,lwd=2,ncol=2)
        }
        
           
    }
    #if( x[4,ncol(x)]>200) {
    #   legend("topright",lty=1,cex=.6,legend=colnames(x)[2:ncol(x)],col=cols,bty="n",text.font=2,lwd=2,ncol=2)
    #}
}else{
    lines(spline(x[,1],x[,2],n = 1000, method = "fmm"),lty=1,col="red",lwd=2)
    legend("topright",lty=1,cex=.6,legend=colnames(x)[2:ncol(x)],col="red",bty="n",text.font=2,lwd=2,ncol=2)
}
dev.off()
