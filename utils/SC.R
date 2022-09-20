
# in R command prompt
args<-commandArgs(T)
library(ggplot2)
 library(cnv)
 data <- read.delim(args[1])
 cnv.print(data)
# output ...
 cnv.summary(data)
# output ...
name <- strsplit(args[2], split = "_")[[1]][1]
plot.cnv.all(data, colour = 2, chrom.gap = 1e+07,title = 10,ylim=c(0,8),xlabel = "") + theme(axis.ticks.x=element_line(colour="black"),axis.text.x=element_text(size=15),axis.text.y=element_text(size=15),axis.title.x=element_text(size=30),axis.title.y=element_text(size=15) )+labs(title=name,lineheight=20) + theme(plot.title = element_text(hjust = 0.5,size=20))
 #plot.cnv.chr(data)
 #plot.cnv(data)
 #pdfname<-paste(args[2],"pdf",sep=".")
 pngname<-paste(args[2],"png",sep=".")
#pdf(pdfname,onefile=FALSE,width=30,height=5)
 #ggsave(filename = pdfname,width=15,height=3,dpi=80)
 ggsave(filename = pngname,width=15,height=3,dpi=80)
