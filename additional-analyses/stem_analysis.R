###
library(GenomicRanges)
library(derfinder)
library(RColorBrewer)
library(bumphunter)

ss = function(x, pattern, slot=1,...) sapply(strsplit(x,pattern,...), function(y) y[slot])
getPcaVars = function(pca)  signif(((pca$sdev)^2)/(sum((pca$sdev)^2)),3)*100
getF = function(fit, fit0, theData) {
	rss1 = rowSums((fitted(fit)-theData)^2)
	df1 = ncol(fit$coef)
	rss0 = rowSums((fitted(fit0)-theData)^2)
	df0 = ncol(fit0$coef)
	fstat = ((rss0-rss1)/(df1-df0))/(rss1/(ncol(theData)-df1))
	f_pval = pf(fstat, df1-1, ncol(theData)-df1,lower.tail=FALSE)
	fout = cbind(fstat,df1-1,ncol(theData)-df1,f_pval)
	colnames(fout)[2:3] = c("df1","df0")
	fout = data.frame(fout)
	return(fout)
}

# single base
load("/dcs01/ajaffe/Brain/derRuns/derStem/derCoverageInfo/fullCov.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/fullRegions.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/models.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/groupInfo.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/fullAnnotatedRegions.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/regionCoverage.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/regionCoverage.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/sampleDepths.Rdata")
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/derAnalysis/run4-v1.0.10/fullNullSummary.Rdata")
totalMapped = 2^sampleDepths-1

sigStem = fullRegions[fullRegions$significantFWER==TRUE]
sigStem$annotation = ss(sigStem$annotation, " ")

countTable = fullAnnotatedRegions$countTable[fullRegions$significantFWER==TRUE,]
g = matchGenes(sigStem)

# relabel groups to match paper
group2 = factor(as.character(groupInfo),
	levels = c("h1", "h1-mesendoderm", "h1-npc","h1-bmp4","h1-msc"),
	labels = c("H1","ME","NPC","TBL","MSC"))


# get mean coverage
names(fullCov) = paste0("chr", names(fullCov))
covMat = getRegionCoverage(fullCov = fullCov, regions = sigStem,
	totalMapped = totalMapped, targetSize = 1e8)
meanCoverage = t(sapply(covMat, colMeans))

# published list
x = read.csv("codingGenes_xie2013.csv",as.is=TRUE)
pub = x[!duplicated(x$GeneID), 2:7]
rownames(pub) = pub$GeneID
pub$GeneID=NULL

library(biomaRt)
ensembl = useMart("ENSEMBL_MART_ENSEMBL", # VERSION 75, hg19
	dataset="hsapiens_gene_ensembl",
	host="feb2014.archive.ensembl.org")
sym = getBM(attributes = c("ensembl_gene_id","hgnc_symbol","entrezgene",
	"chromosome_name", "start_position","end_position"),mart=ensembl)
sym = sym[sym$chromosome_name %in% c(1:22,"X","Y","MT"),]
mm = match(rownames(pub), sym$hgnc_symbol)
geneInfo = sym[mm[!is.na(mm)],]
pub = pub[!is.na(mm),]

# from the literature
geneGR = GRanges(paste0("chr", geneInfo$chromosome_name),
	IRanges(geneInfo$start_position, geneInfo$end_position,
	names=geneInfo$hgnc_symbol))
mcols(geneGR)= pub

######################
## expressed-region
load("/dcs01/ajaffe/Brain/derRuns/derSoftware/stem/regionMatrix/regionMat-cut5.Rdata")
library(limma)

regList = lapply(regionMat, function(x) x$regions)
fullRegionGR = unlist(GRangesList(regList))
oo = findOverlaps(geneGR, fullRegionGR)

## annotate regions based on transcriptome databases
load("/home/epi/ajaffe/GenomicStates/GenomicState.Hsapiens.ensembl.GRCh37.p12.rda")
gs = GenomicState.Hsapiens.ensembl.GRCh37.p12$fullGenome
ensemblAnno = annotateRegions(fullRegionGR,gs)
countTable = ensemblAnno$countTable

# region matrix
fullRegionMat = do.call("rbind",
	lapply(regionMat, function(x) x$coverageMatrix))
y = log2(fullRegionMat + 1)
rownames(y) = NULL

## pseudo RPKM
bg = matrix(rep(totalMapped), nc = length(groupInfo), 
	nr = nrow(fullRegionMat),	byrow=TRUE)
widG = matrix(rep(width(fullRegionGR)), 
	nr = nrow(fullRegionMat), nc = length(groupInfo),byrow=FALSE)
rpkm = fullRegionMat/(widG/1000)/(bg/1e6)

meanRpkm = sapply(split(seq(along=group2),group2), function(ii) {
	rowMeans(rpkm[,ii])})

# entropy
ri = meanRpkm / rowSums(meanRpkm)	
H = rowSums(-1*ri*log2(ri+0.0001))

plot(density(H[subjectHits(oo)], bw=0.1),
	col="red",lwd=3,ylim=c(0,1.5))
lines(density(H[-subjectHits(oo)], bw=0.1),col="black",lwd=3)

lineageList = split(as.data.frame(meanRpkm[subjectHits(oo),]),
	queryHits(oo))
meanLineage	= t(sapply(lineageList, colMeans))
ind = as.numeric(names(lineageList))
plot(log2(meanLineage[,1]+1), 
	log2(geneGR$H1_FPKM[ind] + 1))
plot(log2(meanLineage[,2]+1), 
	log2(geneGR$ME_FPKM[ind] + 1))

pca = prcomp(t(y))
pcaVars = getPcaVars(pca)
# palette(brewer.pal(5,"Set1"))
# plot(pca$x,pch=21,bg=as.numeric(groupInfo))

# DE analysis
mod = model.matrix(~group2 + sampleDepths)
colnames(mod)[2:5] = levels(group2)[-1]
fit = lmFit(y, mod)
eb = ebayes(fit)

# null
fit0 = lmFit(y, models$mod0)
ff = getF(fit,fit0, y)
ff$qval = p.adjust(ff$f_pval, "fdr")
ff$pbonf = p.adjust(ff$f_pval, "bon")

### genes
sigF = order(ff$f_pval)[1:sum(ff$pbonf < 0.05)]
genesF = matchGenes(fullRegionGR[sigF],	mc.cores=6)

countTableF = countTable[sigF,]

mean(countTableF$exon == 1 & countTableF$intergenic == 0 & 
	countTableF$intron== 0)
mean(countTableF$exon == 0 & (countTableF$intergenic > 0 | 
	countTableF$intron > 0))
sum(countTableF$exon == 0 & countTableF$intergenic > 0 & 
	countTableF$intron ==  0)
sum(countTableF$exon == 0 & countTableF$intergenic == 0 & 
	countTableF$intron > 0)

intronic = which(countTableF$exon == 0 & 
	countTableF$intergenic == 0 & 
	countTableF$intron > 0)
genesIntronic = genesF[intronic,]
genesIntronic$annotation = ss(genesIntronic$annotation, " ")


#### t-tests to H1
logFC = fit$coef[,2:5]
tstats = eb$t[,2:5]
pvals = eb$p[,2:5]

qvals = apply(pvals, 2, p.adjust, 'fdr')
colSums(qvals < 0.01)

pbonf = apply(pvals, 2, p.adjust, 'bonferroni')
colSums(pbonf < 0.05)
table(rowSums(pbonf < 0.05))

sigListT = apply(pbonf < 0.05, 2, which)
for(i in seq(along=sigListT)) {
	ii = sigListT[[i]]
	sigListT[[i]] = ii[order(pvals[ii,i])]
}

tstatsSig = sigListT
for(i in seq(along=sigListT)) {
	tstatsSig[[i]] = tstats[sigListT[[i]],i]
}
sapply(tstatsSig, function(x) table(sign(x)))


countTableList = lapply(sigListT, function(ii) countTable[ii,])
sapply(countTableList, function(x) { # strictly exonic
	mean(x$exon == 1 & x$intergenic == 0 & 	x$intron== 0)
})
sapply(countTableList, function(x) { # strictly intergenic
	mean(x$exon == 0 & x$intergenic == 1 & 	x$intron== 0)
})
sapply(countTableList, function(x) { # strictly intronic
	mean(x$exon == 0 & x$intergenic == 0 & 	x$intron== 1)
})

intronicIndex=lapply(countTableList, function(x) { intronic
	which(x$exon == 0 & x$intergenic == 0 & x$intron== 1)
})

# which genes?
geneListT = mclapply(sigListT, function(ii) {
	matchGenes(fullRegionGR[ii])
},mc.cores=4)
head(geneListT[[1]]$name[intronicIndex[[1]]],20)
head(geneListT[[2]]$name[intronicIndex[[2]]],20)
head(geneListT[[3]]$name[intronicIndex[[3]]],20)
head(geneListT[[4]]$name[intronicIndex[[4]]],20)

intronicGenes =mapply(function(x, ii, tt) {
	ii = ii[which(sign(tt) > 0)]
	x[ii,]
}, geneListT, intronicIndex, tstatsSig,SIMPLIFY=FALSE)

tabOut = sapply(intronicGenes, function(x) {
	x = x[!is.na(x$region),]
	unique(x$name)[1:25]
})
write.csv(tabOut, "top25_stemByCondition.csv",
	row.names=FALSE,quote=FALSE)

	# load permutations
load("signif_via_perm_stem_regionMat.rda")

## permutations
set.seed(257)
Indexes = replicate(500, sample(seq(along=groupInfo), replace=FALSE),
	simplify=FALSE)

nullStats = mclapply(Indexes, function(ii) {
	cat(".")
	fitNull = lmFit(y[,ii],  models$mod)
	fit0Null = lmFit(y[,ii],  models$mod0)
	tNull = ebayes(fitNull)$t[,2:5]
	fNull = getF(fitNull,fit0Null,y[,ii])
	list(tNull = tNull, fNull = fNull$fstat)
},mc.cores=12)

## fwer
tNullMax = sapply(nullStats, function(x) max(abs(x$tNull)))
fNullMax = sapply(nullStats, function(x) max(x$fNull))

fwerT = apply(abs(tstats), 2, function(x) {
	cat(".")
	sapply(x, function(y) mean(tNullMax > y))
})
colSums(fwerT < 0.05)

fwerF = sapply(ff$fstat, function(x) mean(fNullMax > x))
sum(fwerF < 0.05)

tNull = do.call("cbind", lapply(nullStats, function(x) x$tNull))
fNull = do.call("cbind", lapply(nullStats, function(x) x$fNull))

# pvalue calculator
edge.pvalue <- function(stat, stat0, pool=TRUE) {
  err.func <- "edge.pvalue"
  m <- length(stat)
  if(pool==TRUE) {
    if(is.matrix(stat0)) {stat0 <- as.vector(stat0)}
    m0 <- length(stat0) 
    v <- c(rep(T, m), rep(F, m0))
    v <- v[order(c(stat,stat0), decreasing = TRUE)]
    u <- 1:length(v)
    w <- 1:m
    p <- (u[v==TRUE]-w)/m0
    p <- p[rank(-stat)]
    p <- pmax(p,1/m0)
  } else {
    if(is.vector(stat0)) {
      err.msg(err.func,"stat0 must be a matrix.")
      return(invisible(1))
    }
    if(ncol(stat0)==m) {stat0 <- t(stat0)}
    if(nrow(stat0)!=m){
      err.msg(err.func,"Number of rows of stat0 must equal length of stat.")
      return(invisible(1))
    }
    stat0 <- (stat0 - matrix(rep(stat,ncol(stat0)),byrow=FALSE,nrow=m)) >= 0
    p <- apply(stat0,1,mean)
    p <- pmax(p,1/ncol(stat0))
  }
  return(p)
}

pvalF = edge.pvalue(ff$fstat, fNull)
pvalT = apply(abs(tstats), 2, edge.pvalue, stat0 = abs(tNull))

save(pvalF, pvalT, fwerF, fwerT, file="signif_via_perm_stem_regionMat.rda")

