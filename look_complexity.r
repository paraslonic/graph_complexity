library("data.table")
setwd("/data4/bio/operonTravel_d4/Neisseria_meningitidis/graph/out_w20")

### complexity
c <- read.delim("stat_window_complexity_table_contig0.txt", head = F)
og <- fread("../../tmp/Orthogroups.csv", head = T)
og <- data.frame(og$V1, og$`GCF_000008805.1_ASM880v1_genomic`, stringsAsFactors = F)
tab <- merge(c, og, by.x="V1",by.y="og.V1")
colnames(tab) <- c("og","complex","gene")
q <- lapply(tab$gene, function(x) { strsplit(x, "\\|")[[1]]} )
q <- do.call(rbind, q)
tab$chr <- q[,4]
tab$pos <- (as.integer(q[,5])+as.integer(q[,6]))/2
tab$end <- q[,6]
tab <- tab[order(tab$pos),]

plot(tab$pos, (tab$complex), ylim=c(0,max( (tab$complex)+3)), type="l", pch=3, cex = 0.3, col="gray50", lwd = 0.3, xlab="chromosome position, bp", ylab="complexity", cex.lab=2)
xx <- c(tab$pos, rev(tab$pos))
yy <- c(rep(0, nrow(tab)), rev(tab$complex))
polygon(xx, yy, col='darkorange',lwd = 0.1)

### add bridges
bridges <- read.delim("all_bridges_table_contig0.txt", head = F)
colnames(bridges) <- c("start_og","end_og","count")
og.pos <- data.table(og = tab$og, pos = tab$pos)
setkey(og.pos,"og")

all(bridges$V1 %in% og.pos$og)
bridges$start <- sapply(as.character(bridges$start_og), function(x) {return(og.pos[x]$pos)})
bridges$end <- sapply(as.character(bridges$end_og), function(x) {return(og.pos[x]$pos)})
head(bridges)

for(i in 1:nrow(bridges)){
  draw.circle((bridges$start[i]+bridges$end[i])/2,0,abs(bridges$end[i]-bridges$start[i])/2, lwd = 0.1, border=rgb(0.2,0.2,0.2))
}
