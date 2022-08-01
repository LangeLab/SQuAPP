fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tags"), "Statistical Testing"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_testing_data"),
        hr(),
        awesomeRadio(
          inputId="select_testing_method",
          label="Statistical Testing Method",
          choices=(c("Limma"="limma")),
          inline=FALSE, selected="limma"
        ),
        uiOutput("select_testing_variable"),
        uiOutput("select_testing_groups"),
        hr(),
        selectInput(
          inputId="select_adjust_method",
          label="Select Multiple Testing Correction Method",
          choices=c(
            "Bonferroni Correction"="bonferroni",
            "Holm Correction"="holm",
            "Hochberg Correction"="hochberg",
            "Hommel Correction"="hommel",
            "Benjamini & Hochberg Correction (FDR)"="BH",
            "Benjamini & Yekutieli Correction"="BY"),
          multiple=FALSE, selected="BH"
        ),
        sliderInput(
            inputId = "set_pval.thr",
            label = "Adjusted P-value Threshold",
            width=NULL, min = 0.001, value = 0.05, max = 0.2, step = 0.01
        ),
        sliderInput(
            "set_logfc.thr",
            "Fold Change Threshold",
            min = 0, value = 1, max = 5, step = 0.5
        ),
        hr(),
        materialSwitch(
          inputId="testWeightingSwitch",
          label="Do you want a weighted testing?",
          value=FALSE, status="primary"
        ),
        conditionalPanel(
          condition="input.testWeightingSwitch",
          sliderInput(
            "selected_weigth",
            "Weight to give imputed values",
            width=NULL, min=0.00001, max=1, value=0.001)
        ),
        hr(),
        # materialSwitch(
        #   inputId="testBlocksSwitch",
        #   label="Do you want to test with 2 blocks?",
        #   value=FALSE, status="primary"
        # ),
        # conditionalPanel(
        #   condition="input.testBlocksSwitch",
        #   uiOutput("select_blocking_variable"),
        #   uiOutput("select_blocking_groups")
        # ),
        # hr(),
        actionButton(
          inputId="run_statistical_analysis",
          label="Run Statistical Analysis",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      )
    ),
    column(
      width=9,
      box(
        title="Visual Summary of the Testing",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_statistical_analysis!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Volcano Plot",
              dropdownButton(
                circle = FALSE,
                icon = icon("bars"),
                status = "warning",
                sliderInput(
                    "set_volcano_point_size",
                    "Point Size",
                    min = 1, value = 3, max = 5, step = 0.5
                ),
                actionButton(
                  inputId="update_volcano_plot",
                  label="Update volcano plot",
                  icon=icon("play"),
                  status="warning",
                  size="sm"
                )
              ),
              plotOutput("show_volcano_plot") %>% withSpinner(),
              downloadBttn("download_volcano_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="MA Plot",
              dropdownButton(
                circle = FALSE,
                icon = icon("bars"),
                status = "warning",
                sliderInput(
                    "set_ma_point_size",
                    "Point Size",
                    min = 1, value = 3, max = 5, step = 0.5
                ),
                actionButton(
                  inputId="update_ma_plot",
                  label="Update MA plot",
                  icon=icon("play"),
                  status="warning",
                  size="sm"
                )
              ),
              plotOutput("show_ma_plot") %>% withSpinner(),
              downloadBttn("download_ma_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            )
          )
        )
      ),
      box(
        title="Result Table",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_statistical_analysis!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Significant Data",
              DT::dataTableOutput("show_significant_table") %>% withSpinner()
            ),
            tabPanel(
              title="Full Results Data",
              DT::dataTableOutput("show_statistical_result_table") %>% withSpinner(),
              downloadButton("downloadStatResults", "Download Result Table")
            )
          )

        )
      )
    )
  )
)
