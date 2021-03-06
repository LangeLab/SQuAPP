# Define the main server
shinyServer(function(input, output, session){
  # Initialize reacrive variables to use throughout the app
  variables <- reactiveValues(
    # variable holding the refence proteome pre-loaded or uploaded
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
    temp_data=NULL,
    temp_plot=NULL,
    # Simple boolean holder list for quick checks being used in many places
    reportVars=list(
      "protein"=list(
        "qualityCheck"=NULL,
        "dataAverage"=NULL,
        "dataFilter"=NULL,
        "dataImpute"=NULL,
        "dataNormalize"=NULL,
        "statTest"=NULL,
        "enrichAnalysis"=NULL,
        "goVis"=NULL,
        "dimenReduc"=NULL,
        "clustering"=NULL,
        "featureCompare"=NULL
      ),
      "peptide"=list(
        "proteinCalc"=NULL,
        "qualityCheck"=NULL,
        "dataAverage"=NULL,
        "dataFilter"=NULL,
        "dataImpute"=NULL,
        "dataNormalize"=NULL,
        "statTest"=NULL,
        "enrichAnalysis"=NULL,
        "goVis"=NULL,
        "dimenReduc"=NULL,
        "clustering"=NULL,
        "featureCompare"=NULL
      ),
      "termini"=list(
        "dataAnnot"=NULL,
        "qualityCheck"=NULL,
        "dataAverage"=NULL,
        "dataFilter"=NULL,
        "dataImpute"=NULL,
        "dataNormalize"=NULL,
        "statTest"=NULL,
        "enrichAnalysis"=NULL,
        "goVis"=NULL,
        "dimenReduc"=NULL,
        "clustering"=NULL,
        "featureCompare"=NULL
      ),
      "ptm"=list(
        "dataAnnot"=NULL,
        "qualityCheck"=NULL,
        "dataAverage"=NULL,
        "dataFilter"=NULL,
        "dataImpute"=NULL,
        "dataNormalize"=NULL,
        "statTest"=NULL,
        "enrichAnalysis"=NULL,
        "goVis"=NULL,
        "dimenReduc"=NULL,
        "clustering"=NULL,
        "featureCompare"=NULL
      ),
      "shared"=list(
        "proteinDomain"=NULL,
        "circularNetwork"=NULL
      )
    ),
    reportFile=NULL
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
