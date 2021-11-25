fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Data Quality Check"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_qualityCheck_data"),
        materialSwitch(
          inputId="use_group_factor",
          label="Plot data with a grouping factor",
          value=FALSE,
          status="primary"),
        conditionalPanel(
          condition="input.use_group_factor",
          uiOutput("select_grouping_for_coloring")),
        hr(),
        actionButton(
          inputId="produce_plots",
          label="Create Plots",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      )
    ),
    column(
      width=9,
      box(
        title="Distribution of All Samples",
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        conditionalPanel(
          condition="input.produce_plots!=0",
          tabBox(
            title="",
            width=NULL,
            tabPanel(
              title="Violin Plot",
              plotOutput("show_data_distributions") %>% withSpinner(),
              downloadBttn("download_qc_distributions",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="CV Plot",
              plotOutput("show_cv_plots") %>% withSpinner(),
              downloadBttn("download_qc_cv",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Identified Features Comparison",
              plotOutput("show_identified_features") %>% withSpinner(),
              downloadBttn("download_qc_identifiedFeatures",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Comparing Shared Features",
              plotOutput("show_shared_features") %>% withSpinner(),
              downloadBttn("download_qc_sharedFeatures",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Data completeness",
              plotOutput("show_data_completeness") %>% withSpinner(),
              downloadBttn("download_qc_completeness",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Missing Values",
              plotOutput("show_missing_values") %>% withSpinner(),
              downloadBttn("download_qc_missingvalues",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            )
            # tabPanel(
            #   title="Sample Correlation Plot",
            #   plotOutput("show_sample_correlation") %>% withSpinner()
            # )
          )
        )
      )
    )
  )
)
