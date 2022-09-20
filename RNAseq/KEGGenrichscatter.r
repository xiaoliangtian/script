# Date:2016/1/27
args<-commandArgs(T)
m<-read.table(args[1],sep="\t",header=T)
# m<-m[m[,6]<0.05,]
name<-strsplit(basename(args[1]),".DEG",fixed=TRUE)[[1]][1]
pdfname<-paste(name,".DEG_KEGGScat.pdf",sep="")
if (nrow(m)==0) {
    q(status=1)
}
if (nrow(m)>20){
    m<-m[order(m[,6]),]
    m<-head(m,20)
}
library(ggplot2)
colnames(m)<-c("pathway","id","Gene_number","backgroud","pvlaue","qvalue")
p<-ggplot(m,aes(Gene_number/backgroud,pathway))
p<-p+geom_point(aes(color=qvalue,size=Gene_number))+xlab('Rich factor')+ylab("")+labs(title="Statistics of Pathway Enrichment")
p<-p+scale_color_gradientn(colours=c("red","yellow","green","cyan","blue"),limits=c(0,0.05))
# p<-p+scale_x_continuous(limits=c(0,1))
pdf(pdfname,width=7.6,height=5+0.05*nrow(m))
p+theme_bw()
