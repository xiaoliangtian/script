#Date:2015/10/11
library(VennDiagram)
args<-commandArgs(T)
cols<-c("#FF0000", "#008B00", "#0000FF", "#FF00FF", "#CD8500")
vennplot<-function(m,tag=FALSE){
    vennlist <- sapply(colnames(m), function(x) rownames(m[m[,x]!=0,]))
    len <- ifelse(ncol(m)>=5,5,ncol(m))
    venn.plot <- venn.diagram(vennlist[1:len],col=cols[1:len],filename =NULL,margin=0.1,cat.cex=1.5,cat.fontface="bold")#,cat.col=cols[1:len])
    pdfname<-ifelse(tag==FALSE,"Venn.pdf",paste(tag,"Venn.pdf",sep="."))
    pdf(pdfname)
    grid.draw(venn.plot)
    dev.off()
}
otu<-read.table(args[1],header=T)
if (length(args)==2){
    arguments<-args[2]
    argu<-strsplit(arguments,',')[[1]]
    for (i in argu){
        sample<-strsplit(i,'_')[[1]]
        m<-subset(otu,select=sample)
        vennplot(m,i)
    }
}else{
    vennplot(otu)
}
