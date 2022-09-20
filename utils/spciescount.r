#Date:2015/05/12
args<-commandArgs(T)
library(ggplot2)
x<-read.table(args[1],sep="\t")
m<-x
if (nrow(x)>12){
    m<-head(x,12)
}
p<-ggplot(m,aes(x=reorder(V1,-V2),y=V2))
p<-p+geom_bar(stat='identity',width=.5,fill="#4A7EBB") +coord_flip()
p<-p+xlab("")+ylab("")+theme_bw()+geom_text(aes(label=V2),size=3,hjust=1,vjust=0.3)
pdf("SpciesCount.pdf",width=10,height=5)
p+scale_y_log10()
dev.off()
