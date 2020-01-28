library("stringr")
library("data.table")

tab = fread("tmp/Orthogroups.csv", head = TRUE, showProgress = TRUE)
colnames(tab) = gsub(".fasta","",colnames(tab))
strains = setdiff(colnames(tab), "V1")

ogtab = fread("tmp/ortho_table.txt", head = TRUE, showProgress = TRUE)
setkey(ogtab,id)
ogtab.strains = ogtab$strains
ogtab.og = ogtab$id
ogtab[,`:=`(strains = NULL, id = NULL, product = NULL)]

core.og = subset(ogtab.og, rowSums(ogtab)==ogtab.strains & ogtab.strains == max(ogtab.strains))
core.og = gsub(":","",core.og)
save(core.og, file = "core.og.rdata")

system("mkdir -p orientation")

get_orient = function(strain)
{
  nout = fread(paste0("tmp/nucmer/",strain,".coords"), showProgress = TRUE)
  nout[, orient := V6*V7*V9]
  orient = nout[,sum(orient),by=V11]
  colnames(orient) = c("contig","orient")
  setkey(orient, "contig")
  write.table(orient, paste0("orientation/",strain), quote=FALSE, row.names=FALSE)
  return(orient)
}

make_path = function(strain)
{
  strain.col = which(colnames(tab) == strain)
  og_id = data.frame(og = as.character(tab$V1), 
                     id = tab[,strain.col, with=FALSE], stringsAsFactors = FALSE)
  colnames(og_id) = c("og","id")
  ### split by commas
  .og_id = subset(og_id, !grepl(", ", og_id$id) & og_id$id != "") ## N.B. no paralogs yet!
  # for (i in grep(", ", og_id$id)){
  #   for(x in str_split(og_id$id[i],", ")[[1]]){
  #     .og_id <<- rbind(.og_id, c(og_id$og[i], x))
  #   }
  # }
  
  ### make a table
  og_id = .og_id
  ID = str_split_fixed(og_id$id, "\\|",6)
  og_place = data.frame(og_id$og, ID[,c(4:6,1)], stringsAsFactors = F)
  og_place$coord = (as.numeric(og_place$X2)+as.numeric(og_place$X3))/2
  og_place = data.frame(og = og_place$og_id.og, contig = og_place$X1, strain = og_place$X4, coord = og_place$coord, stringsAsFactors = FALSE)
  
  
  og_place = og_place[order(og_place$contig, as.numeric(og_place$coord)),] # no need
  
  ### split contigs
  
  og_place = split(og_place, og_place$contig)

  contigs = names(og_place)
  path = list()
  orient = get_orient(strain)
  for(contig in contigs){
    lcontig=og_place[[contig]]
    .decreasing = FALSE
    if( contig %in% orient$contig){ if(orient[contig,]$orient < 0) {.decreasing = TRUE} }  
    lcontig = lcontig[order(lcontig$coord, decreasing = .decreasing), ]
    .path=list()
    if(nrow(lcontig)<2) next
    for(l in 1:(nrow(lcontig)-1)){
      .path[[l]] = c(lcontig$og[l],lcontig$og[l+1],lcontig$strain[l])
    }
    path[[contig]]=do.call(rbind,.path)
  }
  path = do.call(rbind, path)
 
  return(path)  
}

path.list = sapply(strains, make_path)
path.df = do.call(rbind, path.list)
write.table(path.df, "paths.sif", row.names=FALSE, quote=FALSE,col.names=FALSE)

