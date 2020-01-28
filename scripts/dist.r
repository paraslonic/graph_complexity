setwd("/data7a/bio/StaphylococcusPaper/phageTravelCompareDistance")


A = read.dna("coreogaligned.fasta", format = "fasta")
D = dist.dna(A, model="K80",pairwise.deletion=TRUE)
D = as.matrix(D)
colnames(D) = sub("\\|.+","",colnames(D))
rownames(D) = sub("\\|.+","",rownames(D))
.order = order(rownames(D))
D = D[.order,.order]
dist.core=D
### phage ogs

dist.list = list()
FILES = list.files("ogs_al/",pattern = ".*fasta")
FILES.count = length(FILES)
for(f in 1:FILES.count)
{
  tryCatch({
    name = sub(".fasta", "", FILES[f])
    print(name)
    A = read.dna(paste0("ogs_al/",FILES[f]), format = "fasta")
    if(nrow(A) != 62) next
    D = dist.dna(A, model="K80",pairwise.deletion=TRUE)
    D = as.matrix(D)
    print(max(D))
    if(max(D) == 0) { next }
    print(nrow(D))
    colnames(D) = sub("\\|.+","",colnames(D))
    rownames(D) = sub("\\|.+","",rownames(D))
    .order = order(rownames(D))
    D = D[.order,.order]
    dist.list[[name]] = as.matrix(D)}, error=function(e){cat("ERROR in",name, "\n")})
}

dist.list.core = dist.list
dists.3d <- abind(dist.list.core, along=3)
dists.phage <- apply(dists.3d, c(1,2), mean)

ok <- colnames(dist.core) %in% colnames(dists.mean)
dist.core <- dist.core[ok,ok]

all(rownames(dist.core) == rownames(dists.phage))

vec = function(x){unlist((as.data.frame(x[upper.tri(x)])))}

plot(vec(dist.core),vec(dists.phage), type="n",xlab="core genes distance",ylab="phage genes distance",cex.lab=1.4)
dim <- nrow(dist.core)

x.list.up=list()
y.list.up=list()
x.list.down=list()
y.list.down=list()

for(x in 1:dim){
  for(y in 1:dim)
  {
    col="darkolivegreen4"
    if(dist.core[x,y]> 0.00005 & dist.core[x,y]< 0.00015 &  dists.phage[x,y] > 2e-4){ 
      print(cap); 
      col="blue"
      x.list.up[[paste(x,y)]]=rownames(dist.core)[x]
      y.list.up[[paste(x,y)]]=colnames(dist.core)[y]
    }
    if(dist.core[x,y]> 0.0001 &  dists.phage[x,y] < 2e-4){ 
      print(cap); 
      col="orange"
      x.list.down[[paste(x,y)]]=rownames(dist.core)[x]
      y.list.down[[paste(x,y)]]=colnames(dist.core)[y]
    }
    points(dist.core[x,y], dists.phage[x,y], cex = 0.4, pch=19, col = col)
  
  }
}

    
table(unlist(x.list.up))
table(unlist(x.list.down))

table(unlist(x.list.up))[table(unlist(x.list.up)) %in% table(unlist(x.list.down))]
table(unlist(x.list.up))[names(table(unlist(x.list.up))) %in% names(table(unlist(x.list.down)))]
