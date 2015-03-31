library('knitr')
load('peaks.Rdata')

d <- subset(peaks, analysis != 'HTML report')
d$experiment[d$experiment == 'brainspan'] <- 'BrainSpan'
d$experiment[d$experiment == 'simulation'] <- 'Simulation'
d$experiment[d$experiment == 'snyder'] <- 'Snyder'
d$experiment[d$experiment == 'hippo'] <- 'Hippo'
colnames(d) <- c('Memory by core', 'Wall time (hrs)', 'Memory (GB)', 'Peak cores', 'Data set', 'Analysis')
kable(d, format = 'latex', row.names = FALSE, digits = 1, caption = 'Summary of computing resources required for each analysis. Shows maximum memory (GB), maximum number of cores and maximum memory (GB) per core used in any step of the analysis as well as overall wall time (in hours).')