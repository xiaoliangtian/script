
# in R command prompt
args<-commandArgs(T)
library(ggplot2)
 library(cnv)
 data <- read.delim(args[1])
 cnv.print(data)
# output ...
 cnv.summary(data)
# output ...
#plot.cnv.chr(data, colour = 5,chrom.gap = 1e+07,title = 10,ylim=c(-2,2), xlabel = "Chromosome") + theme(axis.ticks.x=element_line(colour="blue"),axis.text.x=element_text(size=15),axis.text.y=element_text(size=15),axis.title.x=element_text(size=30),axis.title.y=element_text(size=30) )
 plot.cnv.chr(data,ylim=c(0,4)) + geom_segment(aes(x=args[3], xend=args[4], y=2, yend=2), colour="blue")
 #plot.cnv(data)
 pdfname<-paste(args[2],"pdf",sep=".")
#pdf(pdfname,onefile=FALSE,width=30,height=5)
 ggsave(filename = pdfname,width=25,height=5,dpi=80)
