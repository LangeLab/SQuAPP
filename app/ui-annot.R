fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tags"), "Data Annotation"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_annot_data"),
        sliderInput("expand_size",
                    "Number of amino-acid to expand around residue:",
                     width=NULL, min=1, max=7, value=4),
        actionButton(
          inputId="process_annot",
          label="Annotate Data",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      )
    ),
    column(
      width=9,
      box(
        title=textOutput('annot_box_title'),
        solidHeader=TRUE,
        collapsed = FALSE,
        status="primary",
        width=NULL,
        conditionalPanel(
          condition="input.process_annot!=0",
          DT::dataTableOutput("annotation_preview") %>% withSpinner(),
          downloadBttn("downloadAnnotation",
                       label="Download Expanded Annotation",
                       style="minimal",
                       color="warning")
        )
      )
    )
  )
)
