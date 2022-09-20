args<-commandArgs(T)
b<-read.table(args[1],nrows=2,header=FALSE,sep="\t")
c<-b[1:2,1:2]
chisq.test(c)
