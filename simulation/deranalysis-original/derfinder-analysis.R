## Run DERfinder's analysis steps

## Script is based on /amber2/scratch/jleek/orbFrontal/scripts/chr22-analysis.R /amber2/scratch/jleek/orbFrontal/scripts/chr22-finish.R
#
## Most recently, based on:
# /dcs01/stanley/work/brain_rna/deranalysis/derfinder-analysis.R

## Load libraries
library('getopt')

## Available at https://github.com/alyssafrazee/derfinder
library('derfinder')

## Specify parameters
spec <- matrix(c(
	'oridir', 'o', 1, "character", "Directory (use full path) where the files used for making the database are stored. Should be like this: datadir/sampledir/stuff",
	'samplepatt', 's', 1, "character", "Pattern used to recognize the sampledirs. The names of the sampledirs will be used with the info to then specify the covariates in the model.",
	'dbfile', 'd', 1, "character", "Data base file",
	'tablename', 't', 1, "character", "Name of the table used in makeDb(). Note that it has to follow SQL conventions for table naming. So don't use 2, use chr2",
    'group', 'c', 1, "character", "Pairs of groups to compare: AB, AC, BC",
	'verbose' , 'v', 2, "logical", "Print status updates",
	'help' , 'h', 0, "logical", "Display help"
), byrow=TRUE, ncol=5)
opt <- getopt(spec)

## Testing the script
test <- FALSE
if(test) {
	## Speficy it using an interactive R session
	test <- TRUE
    opt <- list()
}

## Test values
if(test){
	opt$oridir <- "/dcl01/lieber/ajaffe/derRuns/derSoftware/simulation/dercount"
	opt$samplepatt <- "sample"
	opt$dbfile <- "/dcl01/lieber/ajaffe/derRuns/derSoftware/simulation/dertable/chr22/chr22.db"
	opt$tablename <- "chr22"
    opt$group <- "AB"
	opt$verbose <- TRUE
}

## if help was asked for print a friendly message
## and exit with a non-zero error code
if (!is.null(opt$help)) {
	cat(getopt(spec, usage=TRUE))
	q(status=1)
}

## Default value for verbose = TRUE
if (is.null(opt$verbose)) opt$verbose <- TRUE
	


	
### Actual processing steps

if(opt$verbose) message(paste(Sys.time(), "Reading sample information"))
## Identify the sampledirs
dirs <- list.files(path=opt$oridir, pattern=opt$samplepatt)

## Sample info
info <- data.frame(dir = dirs, sample = as.integer(gsub('sample', '', dirs)))
info$group <- ifelse(info$sample <= 10, 'A', ifelse(info$sample <= 20, 'B', 'C'))
use.groups <- info$group[ - which(!info$group %in% strsplit(opt$group, '')[[1]])]
colsubset <- which(info$group %in% strsplit(opt$group, '')[[1]]) + 1
adjustvars <- NULL
nonzero <- TRUE


## Calculate the column medians
if(opt$verbose) message(paste(Sys.time(), "Calculating column medians"))
colmeds <- getColmeds(dbfile=opt$dbfile, tablename=opt$tablename, colsubset=colsubset, nonzero=nonzero)

## Save parameters used for running limma
optionsLimma <- list(dir=info$dir[colsubset -1], group=use.groups, adjustvars=adjustvars, colmeds=colmeds, colsubset = colsubset, nonzero = nonzero)
save(optionsLimma, file=paste0("optionsLimma-", opt$tablename, "-", opt$group, "R.data"))

# Run limma
if(opt$verbose) message(paste(Sys.time(), "Running limma"))
limma.input <- getLimmaInput(dbfile=opt$dbfile, tablename=opt$tablename, group=use.groups, adjustvars=adjustvars, colsubset=colsubset, nonzero=nonzero, colmeds=colmeds)
pos <- limma.input$pos
save(pos, file=paste0("pos-", opt$tablename, "-", opt$group, ".Rdata"))

# get the moderated t stats and fold changes:
if(opt$verbose) message(paste(Sys.time(), "Getting the t-stats"))
tstats <- getTstats(fit=limma.input$ebobject, trend=TRUE)
tt <- tstats$tt
logfchange <-  tstats$logfchange
save(tt,file=paste0("tt-", opt$tablename, "-", opt$group, ".Rdata"))

# fit the HMM:
if(opt$verbose) message(paste(Sys.time(), "Finding the parameters"))
find.them <- getParams(tt, verbose=opt$verbose)
if(opt$verbose) message(paste(Sys.time(), "Fitting the HMM"))
regions <- getRegions(method="HMM", chromosome=opt$tablename, pos=pos, tstats=tt, stateprobs=find.them$stateprobs, params=find.them$params, includet=TRUE, includefchange=TRUE, fchange=logfchange)

# merge the regions:
if(opt$verbose) message(paste(Sys.time(), "Merging the regions"))
regions.merged <- mergeRegions(regions$states)
save(regions.merged, file=paste0("regions-merged-", opt$tablename, "-", opt$group, ".Rdata"))

# get the p-values:
if(opt$verbose) message(paste(Sys.time(), "Calculating p-values"))
    
## Set the seed for reproducibility
seed <- 20150226 + sum(match(strsplit(opt$group, '')[[1]], toupper(letters[1:3])))
save(seed, file=paste0('seed-', opt$tablename, '-', opt$group, '.Rdata'))

set.seed(seed)
pvals = get.pvals(regions=regions.merged, dbfile=opt$dbfile, tablename=opt$tablename, num.perms=100, group=use.groups, colsubset=colsubset, adjustvars=adjustvars, est.params=find.them, chromosome=opt$tablename, colmeds=colmeds)
save(pvals, file=paste0("pvals-", opt$tablename, "-", opt$group, ".Rdata"))

# get the flags:
if(opt$verbose) message(paste(Sys.time(), "Getting the flags"))
#exons = getAnnotation("hg19","knownGene")

## Copied from /home/bst/student/afrazee/hg19-exons-GFversion.rda
load("/dcl01/lieber/ajaffe/derRuns/derSoftware/simulation/deranalysis-original/hg19-exons-GFversion.rda")

## Manually filter out unused chrs
exons <- subset(hg19.exons, chr == opt$tablename)
exons$chr <- droplevels(exons$chr)

myflags <- getFlags(regions=regions.merged, exons=exons, chromosome=opt$tablename, pctcut = 0.8)
save(myflags, file=paste0("flags-", opt$tablename, "-", opt$group, ".Rdata"))

## Done

## Reproducibility info
proc.time()
sessionInfo()
