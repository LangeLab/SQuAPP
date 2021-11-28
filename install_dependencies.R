# Link to Original: https://gist.github.com/cmccoy/7239436
# Source: @cmccoy
# Modified by Enes Kemal Ergin
# Uses *_packages.txt files in dep/ folder to get list of packages to check and install

install_opts <- "--byte-compile"
reinstall <- FALSE

# Installation functions
installed <- data.frame(installed.packages())$Package
# Get the bioconductor from source
source("http://bioconductor.org/biocLite.R")

# function that checks if packages are installed
is.installed <- function(package.name) package.name %in% installed

pastemsg <- function(...) message(paste(...))

# base installer function modified with installation checker and message printing
installer <- function(install.fn, ...) {
  do.install <- function(package.name, check.installed=!reinstall) {
    if(check.installed && is.installed(package.name)) {
      pastemsg("Package", package.name, "is installed.")
    } else {
      pastemsg("Installing", package.name)
      install.fn(c(package.name), ...)
    }
  }
}

# Special installer for CRAN
install_cran <- installer(install.packages, repos="http://cran.fhcrc.org",
                          clean=TRUE, dependencies=TRUE,
                          INSTALL_opts=install_opts)

# Special installer for bioconductor
install_bioconductor <- installer(biocLite, ask=FALSE, INSTALL_opts=install_opts)

## Bioconductor Packages
# Read the file to get the list of bioconductor packages
bioconductor_ <- paste(readLines('bioconductor_packages.txt'), sep = "\n")
# Check if the file has packages
if(length(bioconductor_)){
  print("Calling for the bioconductor source!")
  # Call BiocInstaller Library to install bioconductor
  library(BiocInstaller)
  # Get the non-installed packages into list
  bioconductor_packages <- bioconductor_[!(bioconductor_ %in% installed.packages()[, "Package"])]
  # install bioconductor_packages
  for(p in bioconductor_packages) {
    tryCatch(install_bioconductor(p), error=warning)
  }
}

## CRAN Packages
# Read the files to get the list of cran packages
cran_ <- paste(readLines('cran_packages.txt'), sep = "\n")
# Check if the file has packages
if(length(cran_)){
  print("Installing Packages from Cran")
  # Get the non-installed packages into list
  cran_packages <- cran_[!(cran_ %in% installed.packages()[, "Package"])]
  # install CRAN packages
  for(p in cran_packages) {
    tryCatch(install_cran(p), error=warning)
  }
}

## GitHub Package
# Read the files to get the list of GitHub packages
github_ <- paste(readLines('github_packages.txt'), sep="\n")
# Check if the file has packages
if(length(github_)){
  print("Installing Packages from GitHub")
  # Get the non-installed packages into list
  github_packages <- github_[!(github_ %in% installed.packages()[, "Package"])]
  # Install GitHub packages
  for(p in github_packages) {
    pastemsg("Installing", p, "from GitHub")
    p <- list(p)
    p$args <- install_opts
    tryCatch(do.call('install_github', p), error=warning)
  }
}
