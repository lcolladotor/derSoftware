## Create paired.txt file for running hisat 

files <- dir('/dcl01/lieber/ajaffe/PublicData/SRA_GTEX/FASTQ')
fastq <- gsub('\\.fastq\\.gz', '', files)
srr <- gsub('_1|_2', '', fastq)

stopifnot(length(unique(srr)) == 36)

sink('paired.txt')
for(i in unique(srr)) {
    j <- files[srr == i]
	cat(paste0(j[1], "\t", j[2], "\n"))
}
sink()
