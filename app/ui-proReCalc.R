fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("calculator"), "Protein Re-calculation"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        selectInput("sumMethod", "Choose protein re-calculation method:",
                    choices=c("Sum of All"="sum_all",
                              "Average All"="mean_all",
                              "Sum of top 3"="sum_top3",
                              "Average of top 3"="mean_top3"),
                    multiple=F
        ),
        actionButton(
          inputId="process_proCalc",
          label="Re-calculate Proteins",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        hr(),
        conditionalPanel(
          condition="input.process_proCalc!=0",
          materialSwitch(
            inputId="saveAsProtein",
            label="Keep as protein data",
            value=FALSE,
            status="primary",
          )
        ),
        conditionalPanel(
          condition="input.saveAsProtein && input.process_proCalc!=0",
          actionButton(
            inputId="record_processed_proCalc",
            label="Record Proteins",
            icon=icon("file-export"),
            status="warning",
            size="sm"
          )
        )
      )
    ),
    column(
      width=9,
      box(
        title="Re-calculated Protein Data",
        solidHeader=TRUE,
        collapsed = FALSE,
        status="primary",
        width=NULL,
        conditionalPanel(
          condition="input.process_proCalc!=0",
          DT::dataTableOutput("proReCalc_preview") %>% withSpinner(),
          downloadBttn("downloadReCalc",
                       label="Download Recalculated Protein Data",
                       style="minimal",
                       color="warning")
        )
      ),
      conditionalPanel(
        condition="input.process_proCalc!=0",
        box(
          title="Comparison of Protein Intensities",
          solidHeader=TRUE,
          collapsed = FALSE,
          status="primary",
          width=NULL,
          # plotly::plotlyOutput("compareIntensity_plotViolin") %>% withSpinner()
          plotOutput("show_reCalcProtein_splitViolin") %>% withSpinner(),
          downloadBttn("download_reCalcprotein_splitViolin_plot",
                       label="Download Plot",
                       style="minimal",
                       color="warning")
        )
      )
    )
  )
)
