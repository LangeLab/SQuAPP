fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tags"), "Collapse Replica by Averaging"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_averaging_data"),
        hr(),
        actionButton(
          inputId="average_replicas",
          label="Average Replicas",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        hr(),
        conditionalPanel(
          condition="input.average_replicas!=0",
          materialSwitch(
            inputId="saveAveragedAsData",
            label="Want to replace it with original data",
            value=FALSE,
            status="primary",
          )
        ),
        conditionalPanel(
          condition="input.saveAveragedAsData && input.average_replicas!=0",
          actionButton(
            inputId="record_processed_averaged",
            label="Record as Original",
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
        title=textOutput('avg_org_box_title'),
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.average_replicas!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Distribution of All Samples",
              plotOutput("show_original_dist_averaging") %>% withSpinner
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("original_data_preview_averaging") %>% withSpinner()
            )
          )
        )
      ),
      box(
        title=textOutput('avg_chng_box_title'),
        status="warning",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.average_replicas!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Distribution of All Samples",
              plotOutput("show_averaged_dist_in_averaging") %>% withSpinner()
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("averaged_data_preview_averaging") %>% withSpinner(),
              downloadButton("downloadAveraged", "Download Averaged Data")
            )
          )
        )
      )
    )
  )
)
