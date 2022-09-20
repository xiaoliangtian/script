
# in R command prompt
args = commandArgs(T)
library(showtext)
showtext_auto(enable=TRUE)

font_path = "/usr/local/share/fonts/SimHei.ttf"
font_name = tools::file_path_sans_ext(basename(font_path))
font_add(font_name, font_path)
print (args[1])
name <- strsplit(args[2], split = "_")[[1]][1]

args<-commandArgs(T)
library(ggplot2)
library(cnv)

plot.test <- function(data, chrom.gap=2e7, colour=5, title=NA, ylim=c(-2,2), xlabel='Chromosome', ylabel="copies")
{
	if(nrow(subset(data, log2>max(ylim) | log2<min(ylim)))>0) warning('missed some data points due to small ylim range')
	level <- sort(as.character(unique(data$chromosome)))
	ok.to.convert <- !is.na(suppressWarnings(as.numeric(level)))
	level <- c(sort(as.numeric(level[ok.to.convert])), level[!ok.to.convert])
	labels<-breaks<-c()
    xbreaks<-ybreaks<-c()
	last.pos <- 0
	temp <- data.frame()
	for(chr in level)
	{
		sub <- subset(data, chromosome==chr)
		if(nrow(sub)==0) next
		sub$gpos <- last.pos+sub$position
		labels <- c(labels, chr)
		breaks <- c(breaks, (min(sub$gpos)+max(sub$gpos))/2)
		last.pos <- max(sub$gpos)+chrom.gap
		temp <- rbind(temp, sub)
	}
    xbreaks <- c(xbreaks,-10000000,259350000,522550000,740550000,951650000,1152650000,1343750000,1522950000,1689350000,1850550000,2006150000,2161150000,2324500000,2459700000,2587500000,2700150000,2810450000,2911650000,3009750000,3088950000,3176600000,3248100000,3311450000,3486750000,3576000000)
    ybreaks <- c(ybreaks,0,1,2,3,4)
	data <- temp
	data$color <- as.character(data$color)
	#print (data$color)
    cbPalette <- c("blue", "red", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
	p <- ggplot()+geom_point(data=data, map=aes(x=gpos, y=log2, colour=data$color), size = 0.6) + geom_vline(xintercept=xbreaks,colour='lightgrey',size=0.8) + geom_hline(yintercept=ybreaks,colour='lightgrey',size=0.8,linetype='dotted')+labs(title=name, x='', y=ylabel)
	p <- p + scale_y_continuous(ylabel, lim=ylim, breaks=seq(0, 5, 1))
	p <- p + scale_x_continuous(breaks=breaks, labels=labels)
    p <- p + theme(panel.background = element_rect(fill ="white", colour="black"), plot.title = element_text(vjust=0.5, hjust=0.5, size=20), legend.position="none")
#	cat(breaks,"\n", sep=',')
#	cat(labels,"\n",sep=',')
	if(colour==2) p <- p + scale_colour_discrete(l=30)
	else p <- p + scale_colour_manual(values = cbPalette)
	if(!is.na(title)) p$title <- title
	p
}

data <- read.delim(args[1])
data$log2 <-as.numeric(as.character(data$log2))
cnv.print(data)
cnv.summary(data)
# output ...
plot.test(data, colour = 5,chrom.gap = 2e7,title = 10,ylim=c(-2,6), xlabel="Chromosome", ylabel="拷贝数") + theme(axis.text.x=element_text(size=15),axis.text.y=element_text(size=15),axis.title.y=element_text(size=20,vjust=0.5, hjust=0.5), text=element_text(family=font_name))

#pdfname<-paste(args[2],"pdf",sep=".")
pngname<-paste(args[2],"png",sep=".")
#ggsave(filename = pdfname,width=25,height=5,dpi=80)
ggsave(filename = pngname,width=25,height=5,dpi=80)
