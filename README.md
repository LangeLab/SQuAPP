# Simple Quantitative Analysis of Proteins and PTMs (SQuAPP)
SQuAPP is a workflow-based web application built on R-Shiny to enable a rapid high-level analysis of quantitative proteomics data. SQuAPP provides simple and streamlined access to many aspects of typical downstream analysis done with quantitative proteomics data. SQuAPP can bring multiple levels of proteomics data to process and visually compare them for further visualizations.

- [List of Features](#list-of-features)
- [Usage](#usage)
  - [Online Version](#online-version)
  - [Local Version](#local-version)
    - [Clone the Repository](#clone-the-repository)
    - [Install Dependencies](#install-dependencies)
    - [Run the App](#run-the-app)
  - [Docker Version](#docker-version)
- [References](#references)
- [Code of Conduct](#code-of-conduct)
- [Session Info](#session-info)

---

## List of Features
SQuAPP provides features for most commonly used downstream data analysis approaches as well as some new functionality to allow combining multiple data levels such as protein-peptide-ptms. Here is the full list of functionality that can be used within SQuAPP.

- **Data Setup**
  - Multiple level tabular data input from any tool
  - Data annotation for peptide and ptm data levels for expanded information that can be used for external tools such as ROLIM
  - Protein re-calculation from peptide level data
- **Data Inspection**
  - Global and Grouped quality check
    - Distribution of Samples: Violin
    - Coefficient of variation (CV)
    - Identified features
    - Data completeness
    - Missing values
- **Data Processing**
  - Collapsing replica with averaging
  - Sub-par sample filtering
  - Data completeness based filtering
  - Data imputation
  - Data normalization
- **Statistical Inference**
  - Statistical testing
  - Enrichment analysis
  - Reduced and grouped visualization for GO Enrichment *`(WIP)`*
- **Summary Visualizations**
  - Dimensional reduction
  - Data clustering
  - Feature intensity comparison
  - Protein domain
  - Circular network summary
- **Report Generation** *`(WIP)`*

---

## Tutorial


---

## Usage
SQuAPP can be used by different methods: online, local installation, and docker installation.

### Online Version
SQuAPP can be access through hosting shiny-server in our own servers using this [squapp.langelab.org](http://squapp.langelab.org/) Online version is to provide a quick access to the features without installing or configuring for the local version. Due to limitations of the server you might have access issues if the server is overloaded.

### Local Version
If you would like to use SQuAPP on your own computer to avoid server limitations you can follow these step to install it on your local computer.
> This part is still work in progress!


### Docker Version
> This part is still work in progress!

---

## Publication
> This part is still work in progress!

---

## References
> This part is still work in progress!

---

## Code of Conduct
Please note that SQuAPP is released with a [Contributor Code of Conduct](./CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

---

## Session Info
```R
> sessionInfo()
R version 4.1.0 (2021-05-18)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Pop!_OS 21.04

Matrix products: default
BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.13.so

locale:
 [1] LC_CTYPE=en_CA.UTF-8       LC_NUMERIC=C               LC_TIME=en_CA.UTF-8        LC_COLLATE=en_CA.UTF-8     LC_MONETARY=en_CA.UTF-8    LC_MESSAGES=en_CA.UTF-8    LC_PAPER=en_CA.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
[10] LC_TELEPHONE=C             LC_MEASUREMENT=en_CA.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] circlize_0.4.13       patchwork_1.1.1       ggpubr_0.4.0          plotly_4.10.0         ggplot2_3.3.5         limma_3.48.3          MsCoreUtils_1.4.0     reshape2_1.4.4        feather_0.3.5         stringr_1.4.0         tidyr_1.1.4          
[12] dplyr_1.0.7           fresh_0.2.0           shinycssloaders_1.0.0 shinyWidgets_0.6.2    tippy_0.1.0           DT_0.19               bs4Dash_2.0.3         shiny_1.7.1          

loaded via a namespace (and not attached):
 [1] fontawesome_0.2.2   httr_1.4.2          tools_4.1.0         backports_1.3.0     bslib_0.3.1         utf8_1.2.2          R6_2.5.1            DBI_1.1.1           lazyeval_0.2.2      BiocGenerics_0.38.0 colorspace_2.0-2    withr_2.4.2        
[13] tidyselect_1.1.1    curl_4.3.2          compiler_4.1.0      sass_0.4.0          scales_1.1.1        digest_0.6.28       foreign_0.8-81      rio_0.5.27          pkgconfig_2.0.3     htmltools_0.5.2     fastmap_1.1.0       htmlwidgets_1.5.4  
[25] rlang_0.4.12        GlobalOptions_0.1.2 readxl_1.3.1        rstudioapi_0.13     shape_1.4.6         jquerylib_0.1.4     generics_0.1.1      jsonlite_1.7.2      crosstalk_1.1.1     zip_2.2.0           car_3.0-11          magrittr_2.0.1     
[37] Rcpp_1.0.7          munsell_0.5.0       S4Vectors_0.30.2    fansi_0.5.0         abind_1.4-5         lifecycle_1.0.1     yaml_2.2.1          stringi_1.7.5       carData_3.0-4       MASS_7.3-54         plyr_1.8.6          grid_4.1.0         
[49] parallel_4.1.0      promises_1.2.0.1    forcats_0.5.1       crayon_1.4.1        haven_2.4.3         hms_1.1.1           pillar_1.6.4        markdown_1.1        ggsignif_0.6.3      stats4_4.1.0        glue_1.4.2          data.table_1.14.2  
[61] vctrs_0.3.8         httpuv_1.6.3        cellranger_1.1.0    gtable_0.3.0        purrr_0.3.4         clue_0.3-60         assertthat_0.2.1    cachem_1.0.6        xfun_0.27           openxlsx_4.2.4      mime_0.12           xtable_1.8-4       
[73] broom_0.7.9         rstatix_0.7.0       later_1.3.0         viridisLite_0.4.0   tibble_3.1.5        cluster_2.1.2       ellipsis_0.3.2   
```
