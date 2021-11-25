fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Filtering Data"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_filtering_data"),
        materialSwitch(
          inputId="filterPreviewByGroupSwitch",
          label="Do you want to preview plots with grouping?",
          value=FALSE,
          status="primary"
        ),
        conditionalPanel(
          condition="input.filterPreviewByGroupSwitch",
          uiOutput("select_filterPreview_group")
        ),
        hr(),
        actionButton(
          inputId="preview_quality_for_filter",
          label="Preview Data Quality",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        hr(),
        conditionalPanel(
          condition="input.preview_quality_for_filter!=0",
          h4("Configure Filtering Steps"),
          hr(),
          materialSwitch(
            inputId="removeSampleSwitch",
            label="Want to remove Sample(s)?",
            value=FALSE,
            status="primary",
          ),
          conditionalPanel(
            condition="input.removeSampleSwitch",
            uiOutput("select_samples_to_remove")
          ),
          hr(),
          materialSwitch(
            inputId="filterFeaturesSwitch",
            label="Want to filter features by data completeness?",
            value=FALSE,
            status="primary"
          ),
          conditionalPanel(
            condition="input.filterFeaturesSwitch",
            sliderInput(
              "filter_level",
              "Percentage of data completeness to allow",
              width=NULL, min=1, max=99, value=50
            ),
            materialSwitch(
              inputId="filterByGroupSwitch",
              label="Do you want to filter by metadata groups?",
              value=FALSE,
              status="primary"
            ),
            conditionalPanel(
              condition="input.filterByGroupSwitch",
              uiOutput("select_filter_group")
            )
          ),
          hr(),
          fluidRow(
            column(
              width=6,
              actionButton(
                inputId="submit_for_filtering",
                label="Submit for Filtering",
                icon=icon("play"),
                status="primary",
                size="sm"
              )
            ),
            column(
              width=6,
              conditionalPanel(
                condition="input.submit_for_filtering!=0",
                actionButton(
                  inputId="record_filtered_data",
                  label="Record as Original",
                  icon=icon("file-export"),
                  status="warning",
                  size="sm"
                )
              )
            )
          )
        )
      )
    ),
    column(
      width=9,
      box(
        title="Original State of Data",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.preview_quality_for_filter!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Data Completenes - Count Plot",
              plotOutput("show_preFilter_count") %>% withSpinner(),
              downloadBttn("download_preFilter_count",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Data Completenes - Percentage Plot",
              plotOutput("show_preFilter_percent") %>% withSpinner(),
              downloadBttn("download_preFilter_percent",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("filtering_data_preview") %>% withSpinner(),
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("filtering_data_sumStat") %>% withSpinner(),
            )
          )
        )
      ),
      box(
        title="Filtered State of Data",
        status="warning",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.submit_for_filtering!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Data Completenes - Count Plot",
              plotOutput("show_postFilter_count") %>% withSpinner(),
              downloadBttn("download_postFilter_count",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Data Completenes - Percentage Plot",
              plotOutput("show_postFilter_percent") %>% withSpinner(),
              downloadBttn("download_postFilter_percent",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("filtered_data_preview") %>% withSpinner(),
              downloadBttn("downloadFiltered",
                           label="Download Filtered Data",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("filtered_data_sumStat") %>% withSpinner(),
              downloadBttn("downloadFiltered_sumStat",
                           label="Download Summary Statistics",
                           style="minimal",
                           color="warning")
            )
          )
        )
      )
    )
  )
)
