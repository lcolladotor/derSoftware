library('RCurl')

source_https <- function(url, ...) { 
  # parse and evaluate each .R script
  sapply(c(url, ...), function(u) {
    eval(parse(text = getURL(u, followlocation = TRUE, cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))), envir = .GlobalEnv)
  })
}

source_https('https://gist.githubusercontent.com/lcolladotor/bf85e2c7d5d1f8197707/raw/adf184dd1ba5377b16d8b68b038ca7341b63e750/fix-calculatePvalues.R')

fixChrs('chr', maxClusterGap = 3000)
