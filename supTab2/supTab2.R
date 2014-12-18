library("xtable")

tab2 <- data.frame("Data" = rep(c("brainspan", "simulation", "hippo", "snyder", "stem"), each=2),
    "Set" = rep(c("All", "Sig"), 5),
    "Ex" = c(165462, 78643, 155, 110, 2196, 362, 3744, 3, 316, 0),
    "In" = c(65951, 11390, 0, 0, 73, 20, 1884, 0, 296, 2),
    "Inter" = c(59507, 14637, 0, 0, 423, 118, 2298, 0, 1464, 14),
    "Ex + In" = c(13163, 8541, 14, 12, 101, 15, 184, 1, 32, 2),
    "Ex + Inter" = c(2490, 2181, 0, 0, 0, 0, 11, 0, 1, 0),
    "In + Inter" = c(1, 1, 0, 0, 0, 0, 0, 0, 0, 0),
    "All" = c(261, 260, 0, 0, 0, 0, 0, 0, 0, 0),
    "No overlap > 20 bp" = c(472839, 5, 300, 0, 29185, 0, 12024, 0, 517, 0), check.names=FALSE
)

tab2.final <- subset(tab2, Set == "Sig")[, -2]

print.xtable(xtable(tab2.final, caption="Number of statistically significant DERs overlapping (20 bp minimum) known annotation regions (UCSC hg19 knownGene): exons (\\emph{Ex}), introns (\\emph{In}), or intergenic (\\emph{Inter}).", label="tab:venn", digits = 0), include.rownames=FALSE, table.placement="H")

# Have to manually change > to \geq
