# Link to Original: https://gist.github.com/cmccoy/7239436
# Source: @cmccoy
# Modified by Enes Kemal Ergin
# Uses *_packages.txt files in dep/ folder to get list of packages to check and install


install_opts <- "--byte-compile" # Allow bytecompile
reinstall <- FALSE # Don't reinstall

# Installation functions
installed <- data.frame(installed.packages())$Package
# function that checks if packages are installed
is.installed <- function(package.name) package.name %in% installed
# Message printer
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

## Install CRAN packages
# Special installer for CRAN
install_cran <- installer(install.packages, repos="http://cran.fhcrc.org",
                          clean=TRUE, dependencies=TRUE,
                          INSTALL_opts=install_opts)

# Read the files to get the list of cran packages
cran_ <- paste(readLines('./dep/cran_packages.txt'), sep = "\n")
# Check if the file has packages
if(length(cran_)){
  print("Installing Packages from CRAN")
  # Get the non-installed packages into list
  cran_packages <- cran_[!(cran_ %in% installed.packages()[, "Package"])]
  # install CRAN packages
  for(p in cran_packages) {
    tryCatch(install_cran(p), error=warning)
  }
}

## GitHub Package
# Get the devtools from source if not installed
if(!require("devtools", quietly=TRUE))
  install.packages("devtools")

# Read the files to get the list of GitHub packages
github_ <- paste(readLines('./dep/github_packages.txt'), sep="\n")
# Check if the file has packages
if(length(github_)){
  print("Installing Packages from GitHub")
  # Get the non-installed packages into list
  github_packages <- github_[!(github_ %in% installed.packages()[, "Package"])]
  # Install GitHub packages
  for(p in github_packages) {
    pastemsg("Installing", p, "from GitHub")
    tryCatch(devtools::install_github(p, force=reinstall, upgrade="never"), error=warning)
  }
}

## Install Bioconductor Packages

# Get the bioconductor from source
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(version = "3.17")

# Read the file to get the list of bioconductor packages
bioconductor_ <- paste(readLines('./dep/bioconductor_packages.txt'), sep = "\n")
# Check if the file has packages
if(length(bioconductor_)){
  print("Calling for the bioconductor source!")
  # Get the non-installed packages into list
  bioconductor_packages <- bioconductor_[!(bioconductor_ %in% installed.packages()[, "Package"])]
  # install bioconductor_packages
  for(p in bioconductor_packages) {
    pastemsg("Installing", p, "using Bioconductor")
    tryCatch(BiocManager::install(p, ask=FALSE, force=reinstall), error=warning)
  }
}
