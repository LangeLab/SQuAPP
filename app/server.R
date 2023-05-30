# Define the main server
shinyServer(function(input, output, session){
  # Initialize reactive variables to use throughout the app
  variables <- reactiveValues(
    # variable holding the reference proteome pre-loaded or uploaded
    reference=NULL,
    # Temporary list for data input script
    uploads=list("metadata"=NULL,
                 "protein"=NULL,
                 "peptide"=NULL,
                 "termini"=NULL,
                 "ptm"=NULL),
    # Main list to hold different data levels uploaded in the app
    datasets=list("protein"=NULL,
                  "peptide"=NULL,
                  "termini"=NULL,
                  "ptm"=NULL),
    # Temporary holder variables
    temp_data=NULL,
    temp_plot=NULL,
    # Exclusive list that holds report variables 
    #   to be passed to Rmd in generate report
    reportParam=list(
      # protein level
      "protein"=list(
        "isRepl"=FALSE,
        # data setup variables
        "dataSetup"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # quality check plot variables
        "qualityCheck"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "distPlot"=NULL,
          "cvPlot"=NULL,
          "identCount"=NULL,
          "sharedCount"=NULL,
          "completeness"=NULL,
          "missingCount"=NULL
        ),
        # data processing - averaging variables
        "dataAverage"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_distPlot"=NULL,
          "org_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_table"=NULL
        ),
        # data processing - filtering variables
        "dataFilter"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_countPlot"=NULL,
          "org_percentPlot"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_countPlot"=NULL,
          "prc_percentPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - imputing variables
        "dataImpute"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_missingCount"=NULL,
          "prv_imputeDist"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - normalizing variables
        "dataNormalize"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_summaryStat"=NULL,
          "org_violinDist"=NULL,
          "org_denstyDist"=NULL,
          "org_pairedPlot"=NULL,
          "prc_table"=NULL,
          "prc_summaryStat"=NULL,
          "prc_violinDist"=NULL,
          "prc_denstyDist"=NULL,
          "prc_pairedPlot"=NULL
        ),
        # statistical inference - testing variables
        "statTest"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "maPlot"=NULL,
          "volcanoPlot"=NULL,
          "all_table"=NULL,
          "signf_table"=NULL
        ),
        # statistical inference - enrichment variables
        "enrichAnalysis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # statistical inference - reduced go variables
        "goVis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # summary visualizations - dimensional reduction variables
        "dimenReduc"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        "cluster"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "test_silhouette"=NULL,
          "test_sumSquare"=NULL,
          "test_gapStat"=NULL,
          "cluster_config"=NULL,
          "res_pca"=NULL,
          "res_silhouette"=NULL,
          "res_dendogram"=NULL,
          "res_membership"=NULL
        ),
        "feature"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "selectTable"=NULL,
          "plot_config"=NULL,
          "intensityPlot"=NULL,
          "corrPlot"=NULL
        )
      ),
      "peptide"=list(
        "isRepl"=FALSE,
        # data setup variables
        "dataSetup"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # protein calculation variables
        "proteinCalc"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # quality check plot variables
        "qualityCheck"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "distPlot"=NULL,
          "cvPlot"=NULL,
          "identCount"=NULL,
          "sharedCount"=NULL,
          "completeness"=NULL,
          "missingCount"=NULL
        ),
        # data processing - averaging variables
        "dataAverage"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_distPlot"=NULL,
          "org_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_table"=NULL
        ),
        # data processing - filtering variables
        "dataFilter"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_countPlot"=NULL,
          "org_percentPlot"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_countPlot"=NULL,
          "prc_percentPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - imputing variables
        "dataImpute"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_missingCount"=NULL,
          "prv_imputeDist"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - normalizing variables
        "dataNormalize"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_summaryStat"=NULL,
          "org_violinDist"=NULL,
          "org_denstyDist"=NULL,
          "org_pairedPlot"=NULL,
          "prc_table"=NULL,
          "prc_summaryStat"=NULL,
          "prc_violinDist"=NULL,
          "prc_denstyDist"=NULL,
          "prc_pairedPlot"=NULL
        ),
        # statistical inference - testing variables
        "statTest"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "maPlot"=NULL,
          "volcanoPlot"=NULL,
          "all_table"=NULL,
          "signf_table"=NULL
        ),
        # statistical inference - enrichment variables
        "enrichAnalysis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # statistical inference - reduced go variables
        "goVis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # summary visualizations - dimensional reduction variables
        "dimenReduc"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        "cluster"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "test_silhouette"=NULL,
          "test_sumSquare"=NULL,
          "test_gapStat"=NULL,
          "cluster_config"=NULL,
          "res_pca"=NULL,
          "res_silhouette"=NULL,
          "res_dendogram"=NULL,
          "res_membership"=NULL
        ),
        "feature"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "selectTable"=NULL,
          "plot_config"=NULL,
          "intensityPlot"=NULL,
          "corrPlot"=NULL
        )
      ),
      # termini level
      "termini"=list(
        "isRepl"=FALSE,
        # data setup variables
        "dataSetup"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # data annotation variables
        "dataAnnot"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # quality check plot variables
        "qualityCheck"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "distPlot"=NULL,
          "cvPlot"=NULL,
          "identCount"=NULL,
          "sharedCount"=NULL,
          "completeness"=NULL,
          "missingCount"=NULL
        ),
        # data processing - averaging variables
        "dataAverage"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_distPlot"=NULL,
          "org_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_table"=NULL
        ),
        # data processing - filtering variables
        "dataFilter"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_countPlot"=NULL,
          "org_percentPlot"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_countPlot"=NULL,
          "prc_percentPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - imputing variables
        "dataImpute"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_missingCount"=NULL,
          "prv_imputeDist"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - normalizing variables
        "dataNormalize"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_summaryStat"=NULL,
          "org_violinDist"=NULL,
          "org_denstyDist"=NULL,
          "org_pairedPlot"=NULL,
          "prc_table"=NULL,
          "prc_summaryStat"=NULL,
          "prc_violinDist"=NULL,
          "prc_denstyDist"=NULL,
          "prc_pairedPlot"=NULL
        ),
        # statistical inference - testing variables
        "statTest"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "maPlot"=NULL,
          "volcanoPlot"=NULL,
          "all_table"=NULL,
          "signf_table"=NULL
        ),
        # statistical inference - enrichment variables
        "enrichAnalysis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # statistical inference - reduced go variables
        "goVis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # summary visualizations - dimensional reduction variables
        "dimenReduc"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        "cluster"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "test_silhouette"=NULL,
          "test_sumSquare"=NULL,
          "test_gapStat"=NULL,
          "cluster_config"=NULL,
          "res_pca"=NULL,
          "res_silhouette"=NULL,
          "res_dendogram"=NULL,
          "res_membership"=NULL
        ),
        "feature"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "selectTable"=NULL,
          "plot_config"=NULL,
          "intensityPlot"=NULL,
          "corrPlot"=NULL
        )
      ),
      "ptm"=list(
        "isRepl"=FALSE,
        # data setup variables
        "dataSetup"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # data annotation variables
        "dataAnnot"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL
        ),
        # quality check plot variables
        "qualityCheck"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "distPlot"=NULL,
          "cvPlot"=NULL,
          "identCount"=NULL,
          "sharedCount"=NULL,
          "completeness"=NULL,
          "missingCount"=NULL
        ),
        # data processing - averaging variables
        "dataAverage"=list(
          "isRun"=FALSE,
          "isReplaced"=FALSE,
          "org_distPlot"=NULL,
          "org_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_table"=NULL
        ),
        # data processing - filtering variables
        "dataFilter"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_countPlot"=NULL,
          "org_percentPlot"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_countPlot"=NULL,
          "prc_percentPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - imputing variables
        "dataImpute"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_missingCount"=NULL,
          "prv_imputeDist"=NULL,
          "org_summaryStat"=NULL,
          "prc_table"=NULL,
          "prc_distPlot"=NULL,
          "prc_summaryStat"=NULL
        ),
        # data processing - normalizing variables
        "dataNormalize"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "isReplaced"=FALSE,
          "org_table"=NULL,
          "org_summaryStat"=NULL,
          "org_violinDist"=NULL,
          "org_denstyDist"=NULL,
          "org_pairedPlot"=NULL,
          "prc_table"=NULL,
          "prc_summaryStat"=NULL,
          "prc_violinDist"=NULL,
          "prc_denstyDist"=NULL,
          "prc_pairedPlot"=NULL
        ),
        # statistical inference - testing variables
        "statTest"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "maPlot"=NULL,
          "volcanoPlot"=NULL,
          "all_table"=NULL,
          "signf_table"=NULL
        ),
        # statistical inference - enrichment variables
        "enrichAnalysis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # statistical inference - reduced go variables
        "goVis"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        # summary visualizations - dimensional reduction variables
        "dimenReduc"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "table"=NULL,
          "plot"=NULL
        ),
        "cluster"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "test_silhouette"=NULL,
          "test_sumSquare"=NULL,
          "test_gapStat"=NULL,
          "cluster_config"=NULL,
          "res_pca"=NULL,
          "res_silhouette"=NULL,
          "res_dendogram"=NULL,
          "res_membership"=NULL
        ),
        "feature"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "selectTable"=NULL,
          "plot_config"=NULL,
          "intensityPlot"=NULL,
          "corrPlot"=NULL
        )
      ),
      "shared"=list(
        "reference"=list(
          "param"=NULL,
          "table"=NULL
        ),
        "metadata"=list(
          "param"=NULL,
          "table"=NULL
        ),
        "proteinDomain"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "plot"=NULL,
          "table"=NULL
        ),
        "circularNetwork"=list(
          "isRun"=FALSE,
          "param"=NULL,
          "concat_table"=NULL,
          "connect_table"=NULL,
          "plot_config"=NULL,
          "plot"=NULL
        )
      )
    ),
    report=list(
      "runReport"=NULL,
      "reportFile"=NULL
    )
  )
  
  # Data Input server script
  source(file="server-dataInput.R", local=TRUE, encoding="UTF-8")
  # Data annot server script
  source(file="server-annot.R", local=TRUE, encoding="UTF-8")
  # Protein re-calculation server script
  source(file="server-proReCalc.R", local=TRUE, encoding="UTF-8")
  # Quality check server script
  source(file="server-qualityCheck.R", local=TRUE, encoding="UTF-8")
  # Data filtering server script
  source(file="server-dataFilter.R", local=TRUE, encoding="UTF-8")
  # Data averaging server script
  source(file="server-dataAverage.R", local=TRUE, encoding="UTF-8")
  # Data imputation server script
  source(file="server-dataImpute.R", local=TRUE, encoding="UTF-8")
  # Data normalization server script
  source(file="server-dataNormalize.R", local=TRUE, encoding="UTF-8")
  # Statistical Testing server script
  source(file="server-statTest.R", local=TRUE, encoding="UTF-8")
  # Enrichment Analysis server script
  source(file="server-enrichAnalysis.R", local=TRUE, encoding="UTF-8")
  # Dimensional Reduction visualizations server script
  source(file="server-visualDimReduce.R", local=TRUE, encoding="UTF-8")
  # Clustering visualizations server script
  source(file="server-visualCluster.R", local=TRUE, encoding="UTF-8")
  # Protein Domain visualizations server script
  source(file="server-visualFeature.R", local=TRUE, encoding="UTF-8")
  # Protein Domain visualizations server script
  source(file="server-visualProtein.R", local=TRUE, encoding="UTF-8")
  # Circular plot visualizations server script
  source(file="server-visualCircular.R", local=TRUE, encoding="UTF-8")
  # Report generation server script
  source(file="server-genReport.R", local=TRUE, encoding="UTF-8")
  
})

