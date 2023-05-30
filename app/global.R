# Main packages to be used in the app
packages <- c(
  "shiny",
  "DT",
  "tippy",
  "fresh",
  "bs4Dash",
  "shinyWidgets",
  "shinycssloaders",
  "colourpicker",
  "dplyr",
  "tidyr",
  "stringr",
  "feather",
  "reshape2",
  "plotly",
  "ggplot2",
  "ggpubr",
  "patchwork",
  "circlize"
)
# Load all the packages without printing the messages
suppressPackageStartupMessages(
  lapply(
    packages, 
    library, 
    character.only = TRUE
  )
)

# Source all the utility scripts
source('utils-ui.R')
source('utils-plots.R')
source('utils-server.R')
source('utils-dataInput.R')
source('utils-annot.R')
source('utils-proReCalc.R')
source('utils-qualityCheck.R')
source('utils-dataFilter.R')
source('utils-dataAverage.R')
source('utils-dataImpute.R')
source('utils-dataNormalize.R')
source('utils-statTest.R')
source('utils-enrichAnalysis.R')
source('utils-visualDimReduce.R')
source('utils-visualCluster.R')
source('utils-visualFeature.R')
source('utils-visualProtein.R')
source('utils-visualCircular.R')
source('utils-genReport.R')

# To suppress the summaries warning
options(dplyr.summarise.inform = FALSE) 
# Allow large data-sets to be imputed
options(shiny.maxRequestSize=100*1024^2) 

# Customize the theme of the app
custom_theme <- create_theme(
  bs4dash_status(
    primary="#457b9d",
    secondary="#f1faee",
    info="#E5E0FF",
    success="#606c38",
    warning="#fca311",
    danger="#e63946",
    light="#669bbc",
    dark="#011627"
  )
)

# Creates a robust UniProt organism-reference data
uniprotDB_path <- "../data/uniprot/data/"
reference_files <- list.files(
  path=uniprotDB_path, 
  full.names=F
)
reference_files_wpath <- list.files(
  path=uniprotDB_path, 
  full.names=T
)
reference_organisms <- str_replace(
  str_match(
    reference_files, 
    "(.*)\\..*$")[,2], 
    "_", 
    " "
)
references_vector <- setNames(
  reference_files_wpath, 
  reference_organisms
)

# This random string making Rds unique for each session
# NOTE: Rds is only written to pass to Rmd render after 
#   that it is removed from the system.
unique_session_id <- as.character(floor(runif(1)*1e20))

