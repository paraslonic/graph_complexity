library("data.table")
setwd("/data7a/bio/StaphylococcusPaper/phageTravelCompareDistance")
t <- fread("OrthologousGroups.csv")
colnames(t) <- gsub(".fasta","",colnames(t))

g <- fread("blast_phage_to_assembly")
genes <- g$V2

t <- t[t$'36AllContigs' %in% genes,]
ogs <- t$V1

t[t!=""] <- 1
t[t==""] <- 0
t[,"V1":=NULL]

t <- apply(t,c(1,2),as.numeric)
rownames(t) <- ogs
heatmap.2(t, trace="none", col=colorRampPalette(c("gray30", "dodgerblue2")), cexRow=0.7, cexCol=0.3, margins=c(6,6))
genes %in% t$'36AllContigs'

table(rowSums(t))
colSums(t) == max(colSums(t))

# core.phage.og
core.phage.og <- rownames(t)[rowSums(t)==62|rowSums(t)==148]
write.table(core.phage.og, "core_phage_og",row.names=F, col.names=F, quote=F)
# run_align.sh