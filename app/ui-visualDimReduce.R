fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tags"), "Dimensional Reduction"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_dimReduction_data"),
        hr(),
        awesomeRadio(
          inputId="select_dimReduction_method",
          label="Select dimensional reduction method",
          choices=c("PCA", 't-SNE', "UMAP"),
          inline=FALSE, selected="PCA"
        ),
        uiOutput("select_dimReduction_featureSet"),
        conditionalPanel(
          condition="input.select_dimReduction_method=='t-SNE'",
          numericInput(
            inputId="tsne_perplexity",
            label="Provide perplexity for t-SNE",
            value=5,
            min=0
          )
        ),
        materialSwitch(
          inputId="ifSelectColor_ReducePlot",
          label="Do you want to color samples by a group?",
          value=FALSE, status="primary"
        ),
        conditionalPanel(
          condition="input.ifSelectColor_ReducePlot",
          uiOutput("select_dimReduction_colorGroup"),
        ),
        materialSwitch(
          inputId="ifSelectShape_ReducePlot",
          label="Do you want to further group with shape?",
          value=FALSE, status="primary"
        ),
        conditionalPanel(
          condition="input.ifSelectShape_ReducePlot",
          uiOutput("select_dimReduction_ShapeGroup")
        ),
        hr(),
        actionButton(
          inputId="run_dimReduction",
          label="Run Dimensional Reduction",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      )
    ),
    column(
      width=9,
      box(
        title="Reduced Plot",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_dimReduction!=0",
          dropdownButton(
            circle=FALSE,
            icon = icon("bars"),
            status = "warning",
            materialSwitch(
              inputId="ifLabels_ReducePlot",
              label="Show labels on the plot",
              value=FALSE, status="primary"
            ),
            conditionalPanel(
              condition="input.ifLabels_ReducePlot",
              materialSwitch(
                inputId="ifRepel_ReducePlot",
                label="Add repel for overlaping labels",
                value=FALSE, status="primary"
              )
            ),
            conditionalPanel(
              condition="input.ifSelectColor_ReducePlot",
              materialSwitch(
                inputId="ifElllipse_ReducePlot",
                label="Do you want to add ellipses for color groups?",
                value=FALSE, status="primary"
              ),
              materialSwitch(
                inputId="ifMeanPoint_ReducePlot",
                label="Do you want to add mean point for each groups?",
                value=FALSE, status="primary"
              )
            ),
            sliderInput(
              "setPointSize_ReducePlot",
              "Select point size for the plot",
              min = 0.5, value = 2, max = 5.5, step = .5
            )
            # actionButton(
            #   inputId="update_dimReduce_plot",
            #   label="Update Plot",
            #   icon=icon("play"),
            #   status="warning",
            #   size="sm"
            # )
          ),
          plotOutput("show_dimReduction_plot") %>% withSpinner(),
          downloadBttn("download_dimReduction_plot",
                       label="Download Plot",
                       style="minimal",
                       color="warning")
        )
      ),
      box(
        title="Reduced Table",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_dimReduction!=0",
          DT::dataTableOutput("show_dimReduction_table") %>% withSpinner(),
          downloadButton("downloadDimReductionTable", "Download Result Table")
        )
      )
    )
  )
)
