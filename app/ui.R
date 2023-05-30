dashboardPage(
  dark = NULL, # Removes the skin change toggle
  # Title of the dashboard
  title = "SQuAPP V0.30",
  # Create Header
  header = dashboardHeader(
    title = "SQuAPP V0.30",
    skin = "light",
    status = "primary",
    border = TRUE,
    fixed = TRUE
  ), # End header 
  # Create the Collapsable Sidebar
  sidebar = dashboardSidebar(
    title = HTML("SQuAPP V0.30"),
    skin = "light",
    status = "primary",
    elevation = 3,
    opacity = 0.8,
    sidebarMenu(
      id="sidebar",
      menuItem( 
        text="Home", 
        tabName="home", 
        icon=icon("house"), 
        selected=TRUE 
      ),
      menuItem( 
        text="Data Setup", 
        tabName="dataSetup", 
        icon=icon("upload"), 
        startExpanded=TRUE,
        menuSubItem(
          text="Data Upload", 
          tabName="dataInputTab"
        ),
        menuSubItem(
          text="Data Annotation", 
          tabName="dataAnnotTab"
        ),
        menuSubItem(
          text="Protein Re-calculation", 
          tabName="proCalcTab"
        )
      ),
      menuItem(
        text="Data Inspection", 
        tabName="qualityCheckTab", 
        icon=icon("magnifying-glass")
      ),
      menuItem(
        text="Data Preprocessing", 
        tabName="dataProcessTab", 
        icon=icon("gear"),
        startExpanded=FALSE,
        menuSubItem(
          text="Averaging", 
          tabName="dataAverageTab"
        ),
        menuSubItem(
          text="Filtering", 
          tabName="dataFilterTab"
        ),
        menuSubItem(
          text="Imputation", 
          tabName="dataImputeTab"
        ),
        menuSubItem(
          text="Normalization", 
          tabName="dataNormalizeTab"
        )
      ),
      menuItem(
        text="Statistical Inference", 
        tabName="statInferTab", 
        icon=icon("braille"),
        startExpanded=FALSE,
        menuSubItem(
          text="Statistical Testing", 
          tabName="statTestTab"
        ),
        menuSubItem(
          text="Enrichment Analysis", 
          tabName="enrichAnalysisTab"
        ),
        menuSubItem(
          text="GO Visualization", 
          tabName="reduceGOTab"
        )
      ),
      menuItem(
        text="Summary Visualizations", 
        tabName="dataVisualTab", 
        icon=icon("chart-line"),
        startExpanded=FALSE,
        menuSubItem(
          text="Dimensional Reduction", 
          tabName="visualDimReduceTab"
        ),
        menuSubItem(
          text="Clustering", 
          tabName="visualClusterTab"
        ),
        menuSubItem(
          text="Feature Comparisons", 
          tabName="visualFeatureTab"
        ),
        menuSubItem(
          text="Protein Domain", 
          tabName="visualProteinTab"
        ),
        menuSubItem(
          text="Circular Networks", 
          tabName="visualCircularTab"
        )
      ),
      menuItem(
        text="Generate a Report", 
        tabName="genReportTab", 
        icon=icon("clipboard-list")
      )
    )
  ), # End of sidebar
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
            "Welcome", 
            icon("house"),
            "mds/home.md"
          ),
          add_TabPanel_homeTab(
            "Dataset Setup", 
            icon("upload"),
            "mds/dataSetup.md"
          ),
          add_TabPanel_homeTab(
            "Data Inspection", 
            icon("magnifying-glass"),
            "mds/dataInspect.md"
          ),
          add_TabPanel_homeTab(
            "Data Preprocessing", 
            icon("gear"),
            "mds/dataProcess.md"
          ),
          add_TabPanel_homeTab(
            "Statistical Inference", 
            icon("braille"),
            "mds/statInfer.md"
          ),
          add_TabPanel_homeTab(
            "Summary Visualizations", 
            icon("chart-line"),
            "mds/summaryVisuals.md"
          ),
          add_TabPanel_homeTab(
            "Generate a Report", 
            icon("clipboard-list"),
            "mds/generateReport.md"
          )
        )
      ), # End home tab
      # Data Input UI Elements
      tabItem(
        tabName="dataInputTab",
        source(
          file="ui-dataInput.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Data Annotation UI elements
      tabItem(
        tabName="dataAnnotTab",
        source(
          file="ui-annot.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Protein Calculation UI elements
      tabItem(
        tabName="proCalcTab",
        source(
          file="ui-proReCalc.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Quality Check UI elements
      tabItem(
        tabName="qualityCheckTab",
        source(
          file="ui-qualityCheck.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Data Filtering UI elements
      tabItem(
        tabName="dataFilterTab",
        source(
          file="ui-dataFilter.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Data Averaging UI elements
      tabItem(
        tabName="dataAverageTab",
        source(
          file="ui-dataAverage.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Data Imputation UI elements
      tabItem(
        tabName="dataImputeTab",
        source(
          file="ui-dataImpute.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Data Normalization UI elements
      tabItem(
        tabName="dataNormalizeTab",
        source(
          file="ui-dataNormalize.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Statistical Testing UI elements
      tabItem(
        tabName="statTestTab",
        source(
          file="ui-statTest.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Enrichment Analysis UI elements
      tabItem(
        tabName="enrichAnalysisTab",
        source(
          file="ui-enrichAnalysis.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # # Reduced and Visualized Go Enrichment Results
      # tabItem(
      #   tabName="reduceGOTab",
      #   source(
      #     file="ui-reduceGO.R", 
      #     local=TRUE, 
      #     encoding="UTF-8"
      #   )$value
      # ),
      # Visualizing the Dimensional Reduction
      tabItem(
        tabName="visualDimReduceTab",
        source(
          "ui-visualDimReduce.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Visualizing Data Clustering
      tabItem(
        tabName="visualClusterTab",
        source(
          "ui-visualCluster.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Visualizing protein domain plots
      tabItem(
        tabName="visualFeatureTab",
        source(
          "ui-visualFeature.R", 
          local=TRUE,
          encoding="UTF-8"
        )$value
      ),
      # Visualizing protein domain plots
      tabItem(
        tabName="visualProteinTab",
        source(
          "ui-visualProtein.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Visualizing circular network plots
      tabItem(
        tabName="visualCircularTab",
        source(
          "ui-visualCircular.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      ),
      # Generating the reports
      tabItem(
        tabName="genReportTab",
        source(
          "ui-genReport.R", 
          local=TRUE, 
          encoding="UTF-8"
        )$value
      )
    )
  ), # End dashboard body
  # Create footer
  footer = dashboardFooter(
    fluidRow(
      column(
        width=3,
        align="center",
        img(
          src="bcchr.png",
          height=120,
          width=120
        )
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
        "Code available on Github:", 
        a(href = "https://github.com/LangeLab/SQuAPP", "LangeLab/SQuAPP"),
        br(),
        "For citing the app:",
        a(
          href = "https://doi.org/10.1093/bioinformatics/btac628",
          "SQuAPP - Simple Quantitative Analysis of Proteins & PTMs"
        ),
        "doi:10.1093/bioinformatics/btac628",
        br(),
        "Copyright (C) 2023, code licensed under MIT "
        # TODO:
        #   1 - Complete the footer with more information
        #   2 - Create a markdown version of it for cleaner and easier modification
      ),
      column(
        width=3,
        align="center",
        img(
          src="ubc.png",
          height=120,
          width=120
        )
      )
    )
  )
)
