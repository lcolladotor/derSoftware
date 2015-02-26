## This function creates the database needed to use derfinder

## Based on 
# /amber2/scratch/jleek/orbFrontal/scripts/makeTHtable-all.R
# http://stackoverflow.com/questions/2151212/how-can-i-read-command-line-parameters-from-an-r-script
# derfinder's vignette
#
## Most recently, based on:
# /dcs01/stanley/work/brain_rna/dertable/makeTableDB.R

## Load libraries
library('getopt')
library('derfinder')
library('IRanges')

## Specify parameters
spec <- matrix(c(
	'datadir', 'd', 1, "character", "Directory (use full path) where the data files are stored. Should be constructed like this: datadir/sampledir/filetoread",
	'samplepatt', 's', 1, "character", "Pattern used to recognize the sampledirs. The names of the sampledirs will be used to specify the columns of the merged table used to construct the database.",
	'file', 'f', 1, "character", "File name to read in. For example, 1-bybp",
	'merged', 'm', 1, "character", "Name of the merged table which will be used to construct the database",
	'output', 'o', 1, "character", "Name of the output database. Used in makeDb()",
	'tablename', 't', 1, "character", "Name of the table used in makeDb(). Note that it has to follow SQL conventions for table naming. So don't use 2, use chr2",
	'verbose' , 'v', 2, "logical", "Print status updates",
	'help' , 'h', 0, "logical", "Display help"
), byrow=TRUE, ncol=5)
opt <- getopt(spec)

## if help was asked for print a friendly message
## and exit with a non-zero error code
if (!is.null(opt$help)) {
	cat(getopt(spec, usage=TRUE))
	q(status=1)
}

## Default value for verbose = TRUE
if (is.null(opt$verbose)) opt$verbose <- TRUE

## Identify the sampledirs
dirs <- list.files(path=opt$datadir, pattern=opt$samplepatt, full.names=TRUE)
names(dirs) <- list.files(path=opt$datadir, pattern=opt$samplepatt)

## Function that reads in the tables
readDir <- function(dir, file=opt$file, test=FALSE, verbose=opt$verbose) {
	
	## Construct the name of the actual input
	input <- paste(dir, file, sep="/")
	if(length(input) == 0) {
		warning(paste0("Dir ", dir, " with patern ", file, " did not return a proper input in readDir."))
		break
	}
	if(verbose) message(paste(Sys.time(), "Reading file", input))
	
	lines <- -1
	## Testing the function
	if(test){
		lines <- 1000
	}
	
	## Read in the table
	data <- read.table(input, sep="\t", nrows=lines, header=FALSE, colClasses=c("integer", "integer"), col.names=c("pos", "count"))
	
	## Compressing the information using Rle's
	res <- list(pos=data$pos, count=Rle(data$count))
	
	## Free space
	rm(data)
	if(verbose) gc()
	
	## done
	return(res)
}

## Load tables
if(opt$verbose) message(paste(Sys.time(), "Reading input tables"))
all <- lapply(dirs, function(x) { readDir(x, file=opt$file, test=test)})

## Find sample with the longest position
lengths <- unlist(lapply(all, function(x) { length(x$pos) }))
long <- which.max(lengths)
thelen <- lengths[long]

## For the samples without the max length, fill in with 0's
if(opt$verbose) message(paste(Sys.time(), "Filling in with 0's to the max length"))
count <- lapply(1:length(all), function(i) { 
	
	ldiff <- thelen - lengths[i]
	if(length(ldiff) > 0) {
		toAdd <- Rle(0, ldiff)
		res <- c(all[[i]]$count, toAdd)
	} else {
		res <- all[[i]]$count
	}
	return(res)
})
names(count) <- names(all)

## position to use
pos <- all[[long]]$pos

## Create merged data
if(opt$verbose) message(paste(Sys.time(), "Creating merged data"))
merged <- DataFrame(pos, count)

## Save data
if(opt$verbose) message(paste(Sys.time(), "Writing merged table"))
	
## Options and flags for writing the data in chunks
start <- 1
append <- FALSE
col.names <- TRUE
chunksize <- 100000

## Write the data in chunks
while(start <= thelen) {
	
	## Define end point (either by chunksize or if it's the end of the file just the part that's missing)
	end <- min(thelen, start + chunksize - 1)
	
	if(opt$verbose) message(paste(Sys.time(), "Writing from row", start, "to row", end))
	
	## Subset the data to write
	data <- as.data.frame(merged[start:end, ])
	
	## Actually write it
	write.table(data, file=opt$merged, row.names=FALSE, quote=FALSE, sep="\t", append=append, col.names=col.names)
	
	## Once the first time it's written, now append on it
	if(!append) {
		append <- TRUE
		col.names <- FALSE
	}
	
	## Set up for next round
	start <- end + 1
}

## Create the database
if(opt$verbose) message(paste(Sys.time(), "Creating the database"))
makeDb(dbfile=opt$output, textfile=opt$merged, tablename=opt$tablename)

## Compress the merged table
if(opt$verbose) message(paste(Sys.time(), "Compressing the merged table. If the database is ok, you can discard this file. Or at least discard the input files."))
system(paste("gzip -f", opt$merged))

## Processing time
if(opt$verbose) print(proc.time())
