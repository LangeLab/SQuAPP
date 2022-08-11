  tagList(
  dashboardPage(
    dark=NULL, # Removes the skin change toggle
    # Title of the dashboard
    title = "SQuAPP V0.28",
    # Create Header
    header = dashboardHeader(
      skin = "light",
      status = "primary",
      border = TRUE,
      fixed = TRUE,
      title = "SQuAPP V0.28"
      # TODO: Need to make the collapsed and uncollapsed version of the title robust
      # title=tagList(
      #   img(src="hex-SQuAPP.png", width=50, height=50),
      #   span("SQuAPP V0.28")
      # )
    ),
    # Create the Collapsable Sidebar
    sidebar = dashboardSidebar(
      skin = "light",
      status = "primary",
      title = HTML("SQuAPP V0.28"),
      elevation = 3,
      opacity = 0.8,
      # Define individual menu items
      sidebarMenu(
        menuItem( "Home", tabName="home", icon=icon("house") , selected=TRUE ),
        menuItem( "Data Setup", tabName="dataSetup", icon=icon("upload"), startExpanded=FALSE,
          menuSubItem("Data Upload", tabName="dataInputTab"),
          conditionalPanel(
            condition="input.isExist_ptm ||
                       input.isExist_termini ||
                       input.submitExampleData!=0",
            menuSubItem("Data Annotation", tabName="dataAnnotTab")
          ),
          conditionalPanel(
            condition="input.isExist_peptide || input.submitExampleData!=0",
            menuSubItem("Protein Re-calculation", tabName="proCalcTab")
          )
        ),
        conditionalPanel(
          condition="input.submitExampleData!=0||
                     input.isExist_protein ||
                     input.isExist_peptide ||
                     input.isExist_termini ||
                     input.isExist_ptm",
          menuItem("Data Inspection", tabName="qualityCheckTab", icon=icon("magnifying-glass"))
        ),
        conditionalPanel(
          condition="input.produce_plots!=0",
          menuItem("Data Preprocessing", tabName="dataProcessTab", icon=icon("gear"), startExpanded=FALSE,
            menuSubItem("Averaging", tabName="dataAverageTab"),
            menuSubItem("Filtering", tabName="dataFilterTab"),
            menuSubItem("Imputation", tabName="dataImputeTab"),
            menuSubItem("Normalization", tabName="dataNormalizeTab")
          )
        ),
        conditionalPanel(
          condition="input.produce_plots!=0",
          menuItem("Statistical Inference", tabName="statInferTab", icon=icon("braille"), startExpanded=FALSE,
            menuSubItem("Statistical Testing", tabName="statTestTab"),
            conditionalPanel(
              condition="input.run_statistical_analysis!=0",
              menuSubItem("Enrichment Analysis", tabName="enrichAnalysisTab")
              # menuSubItem("GO Visualization", tabName="reduceGOTab")
            )
          )
        ),
        conditionalPanel(
          condition="input.run_statistical_analysis!=0",
          menuItem("Summary Visualizations", tabName="dataVisualTab", icon=icon("chart-line"), startExpanded=FALSE,
            menuSubItem("Dimensional Reduction", tabName="visualDimReduceTab"),
            menuSubItem("Clustering", tabName="visualClusterTab"),
            menuSubItem("Feature Comparisons", tabName="visualFeatureTab"),
            menuSubItem("Protein Domain", tabName="visualProteinTab"),
            menuSubItem("Circular Networks", tabName="visualCircularTab")
          )
        ),
        conditionalPanel(
          condition="input.run_statistical_analysis!=0",
          menuItem("Generate a Report", tabName="genReportTab", icon=icon("clipboard-list"))
        )
      )
    ),
    # TODO: I need to find a good use for controlbar and add it to the app
    # # Create controlbar
    # controlbar = dashboardControlbar(),
    # Create main body
    body = dashboardBody(
      # Custom theme defined in global.R
      use_theme(custom_theme),
      # UI contents of the each tabs
      tabItems(
        # Home UI Elements
        tabItem(
          tabName="home",
          tabBox(
            title="",
            width=NULL,
            add_TabPanel_homeTab(
              "Welcome", icon("house"),
              "mds/home.md"
            ),
            add_TabPanel_homeTab(
              "Dataset Setup", icon("upload"),
              "mds/dataSetup.md"
            ),
            add_TabPanel_homeTab(
              "Data Inspection", icon("magnifying-glass"),
              "mds/dataInspect.md"
            ),
            add_TabPanel_homeTab(
              "Data Preprocessing", icon("gear"),
              "mds/dataProcess.md"
            ),
            add_TabPanel_homeTab(
              "Statistical Inference", icon("braille"),
              "mds/statInfer.md"
            ),
            add_TabPanel_homeTab(
              "Summary Visualizations", icon("chart-line"),
              "mds/summaryVisuals.md"
            ),
            add_TabPanel_homeTab(
              "Generate a Report", icon("clipboard-list"),
              "mds/generateReport.md"
            )
          )
        ),
        # Data Input UI Elements
        tabItem(
          tabName="dataInputTab",
          source(file="ui-dataInput.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Data Annotation UI elements
        tabItem(
          tabName="dataAnnotTab",
          source(file="ui-annot.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Protein Calculation UI elements
        tabItem(
          tabName="proCalcTab",
          source(file="ui-proReCalc.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Quality Check UI elements
        tabItem(
          tabName="qualityCheckTab",
          source(file="ui-qualityCheck.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Data Filtering UI elements
        tabItem(
          tabName="dataFilterTab",
          source(file="ui-dataFilter.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Data Averaging UI elements
        tabItem(
          tabName="dataAverageTab",
          source(file="ui-dataAverage.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Data Imputation UI elements
        tabItem(
          tabName="dataImputeTab",
          source(file="ui-dataImpute.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Data Normalization UI elements
        tabItem(
          tabName="dataNormalizeTab",
          source(file="ui-dataNormalize.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Statistical Testing UI elements
        tabItem(
          tabName="statTestTab",
          source(file="ui-statTest.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Enrichment Analysis UI elements
        tabItem(
          tabName="enrichAnalysisTab",
          source(file="ui-enrichAnalysis.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Reduced and Visualized Go Enrichment Results
        # tabItem(
        #   tabName="reduceGOTab",
        #   source(file="ui-reduceGO.R", local=TRUE, encoding="UTF-8")$value
        # ),
        # Visualizing the Dimensional Reduction
        tabItem(
          tabName="visualDimReduceTab",
          source("ui-visualDimReduce.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Visualizing Data Clustering
        tabItem(
          tabName="visualClusterTab",
          source("ui-visualCluster.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Visualizing protein domain plots
        tabItem(
          tabName="visualFeatureTab",
          source("ui-visualFeature.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Visualizing protein domain plots
        tabItem(
          tabName="visualProteinTab",
          source("ui-visualProtein.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Visualizing circular network plots
        tabItem(
          tabName="visualCircularTab",
          source("ui-visualCircular.R", local=TRUE, encoding="UTF-8")$value
        ),
        # Generating the reports
        tabItem(
          tabName="genReportTab",
          source("ui-genReport.R", local=TRUE, encoding="UTF-8")$value
        )
      )
    ),
    # Create footer
    footer = dashboardFooter(
      fluidRow(
        column(
          width=3,
          align="center",
          img(src="bcchr.png",height=120,width=120)
        ),
        column(
            width = 6,
            align = "center",
            "Developed by",
            a(href="https://langelab.med.ubc.ca/", "Lange Lab"),
            "@",
            a(href="https://www.bcchr.ca/", "BC Children's Hospital"),
            "&",
            a(href="https://www.ubc.ca/", "University of British Columbia"),
            br(),
            "Code available on Github:", a(href = "https://github.com/LangeLab/SQuAPP", "LangeLab/SQuAPP"),
            br(),
            "For citing the app:",
            br(),
            "Copyright (C) 2021, code licensed under MIT "
            # TODO:
            #   1 - Complete the footer with more information
            #   2 - Create a markdown version of it for cleaner and easier modification
        ),
        column(
          width=3,
          align="center",
          img(src="ubc.png",height=120,width=120)
        )
      )
    )
  )
)
