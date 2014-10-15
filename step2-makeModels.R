## Load the data without a filter, save it, then filter it for derfinder processing steps

## Load libraries
library('getopt')

## Available at https://github.com/lcolladotor/derfinder
library('derfinder')
library('devtools')

## Specify parameters
spec <- matrix(c(
	'experiment', 'e', 1, 'character', 'Experiment. Either stem or brainspan',
	'help' , 'h', 0, 'logical', 'Display help'
), byrow=TRUE, ncol=5)
opt <- getopt(spec)


## if help was asked for print a friendly message
## and exit with a non-zero error code
if (!is.null(opt$help)) {
	cat(getopt(spec, usage=TRUE))
	q(status=1)
}

## Check experiment input
stopifnot(opt$experiment %in% c('stem', 'brainspan'))


if(opt$experiment == 'stem') {
    ## Load the coverage information
    load(file.path('..', '..', 'CoverageInfo', 'fullCov.Rdata'))
    load(file.path('..', '..', 'CoverageInfo', 'chrYCovInfo.Rdata'))

    ## Identify the samplefiles
    files <- colnames(chrYCovInfo$coverage)

    ##### Note that this whole section is for defining the models using makeModels()
    ##### You can alternatively define them manually and/or use packages such as splines if needed.
    
    ## Load the information table
     load("/home/epi/ajaffe/Lieber/Projects/RNAseq/UCSD_samples/UCSD_stemcell_pheno.rda")
    info <- pd
    ## Match files with actual rows in the info table
    match <- sapply(files, function(x) { which(info$sample == x)})
    info <- info[match, ]

    ## Define the groups
    groupInfo <- factor(info$Condition)

    ## Set h1 to be the reference group
    groupInfo <- relevel(groupInfo, "h1")
    
    ## Calculate the library adjustments and build the models

    ## Determine sample size adjustments
    if(file.exists("sampleDepths.Rdata")) {
    	load("sampleDepths.Rdata")
    } else {
    	if(file.exists("collapsedFull.Rdata")) {
    		load("collapsedFull.Rdata")
    	} else {
    		## Collapse
    		collapsedFull <- collapseFullCoverage(fullCov, save=TRUE)
    	}

    	## Get the adjustments
    	sampleDepths <- sampleDepth(collapsedFull = collapsedFull, probs = 1,
            nonzero = TRUE, scalefac = 32, center = FALSE)
    	save(sampleDepths, file="sampleDepths.Rdata")
    }
    
    
    ## Build the models
    models <- makeModels(sampleDepths = sampleDepths, testvars = groupInfo,
        adjustvars = NULL, testIntercept = FALSE)
} else if(opt$experiment == 'brainspan') {
    ## Define the groups
    load("/home/epi/ajaffe/Lieber/Projects/Grants/Coverage_R01/brainspan/brainspan_phenotype.rda")

    ## Build the models
    fetal <- ifelse(pdSpan$Age < 0, "fetal", "adult")
    mod <- model.matrix(~ fetal * pdSpan$structure_acronym)
    mod0 <- model.matrix(~1, data=pdSpan)
    models <- list(mod=mod, mod0=mod0)

    ## Save information used for analyzeChr(groupInfo)
    # https://www.dropbox.com/s/nzv8r9rw7xi27vt/boxplots_brainspan.jpg
    # First 11 are neocortical, next four are not, last is cerebellum
    groupInfo <- factor(paste(ifelse(pdSpan$structure_acronym %in% c("DFC", "VFC", "MFC", "OFC", "M1C", "S1C", "IPC", "A1C", "STC", "ITC", "V1C"), "Neo", ifelse(pdSpan$structure_acronym %in% c("HIP", "AMY", "STR", "MD"), "notNeo", "CBC")), toupper(substr(fetal, 1, 1)), sep="."), levels=paste(rep(c("Neo", "notNeo", "CBC"), each=2), toupper(substr(unique(fetal), 1, 1)), sep="."))
    
}

## Save models
save(models, file="models.Rdata")

## Save information used for analyzeChr(groupInfo)
save(groupInfo, file="groupInfo.Rdata")

## Done :-)
proc.time()
options(width = 90)
session_info()
