exps <- c('brainspan', 'simulation', 'hippo', 'snyder', 'stem')

data(hg19Ideogram, package = "biovizBase")
library('GenomicRanges')
genome <- sum(as.numeric(seqlengths(hg19Ideogram)[paste0("chr", c(1:22, "X", "Y"))]))

tab1 <- lapply(exps, function(e) {
    d <- dir(file.path('..', e, 'summaryInfo'), pattern = 'run')
    d <- d[length(d)]
    load(file.path('..', e, 'summaryInfo', d, 'summaryResults.Rdata'))
    data.frame('Data Set' = e, '% filtered' = summ[2], '% remaining' = summ[3], 'Mb remaining' = (genome - summ[1]) / 1e6, '# candidate DERs' = nRegs, check.names = FALSE, '# significant DERs' = fwer[1])
})
tab1 <- do.call(rbind, tab1)
rownames(tab1) <- NULL

library('xtable')

print.xtable(xtable(tab1, caption="Results summary", label="tab:basic", display=c("s", "s", "f", "f", "f", "d", "d")), include.rownames=FALSE, table.placement="H")