library('RCurl')

source_https <- function(url, ...) { 
  # parse and evaluate each .R script
  sapply(c(url, ...), function(u) {
    eval(parse(text = getURL(u, followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), envir = .GlobalEnv)
  })
}

source_https('https://gist.githubusercontent.com/lcolladotor/bf85e2c7d5d1f8197707/raw/4bd174f373b3d84f6ff8af16995335c7c0b6809a/fix-calculatePvalues.R')

fixChrs('chr', maxClusterGap = 3000, lowMemDir = tempdir())
