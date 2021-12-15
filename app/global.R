packages <- c("shiny",
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
suppressPackageStartupMessages(lapply(packages, library, character.only = TRUE))

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

options(dplyr.summarise.inform = FALSE)
options(shiny.maxRequestSize=100*1024^2)

shinyOptions(cache = cachem::cache_disk("./app_cache/cache/"))


# Establishes a default theme for the app using "fresh" package with "bs4Dash"
# Reference: https://dreamrs.github.io/fresh/articles/vars-bs4dash.html
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

# Creates a robust uniprot organism-reference data
uniprotDB_path <- "../data/uniprot/data/"
reference_files <- list.files(path=uniprotDB_path, full.names=F)
reference_files_wpath <- list.files(path=uniprotDB_path, full.names=T)
reference_organisms <- str_replace(str_match(reference_files, "(.*)\\..*$")[,2], "_", " ")
references_vector <- setNames(reference_files_wpath, reference_organisms)
