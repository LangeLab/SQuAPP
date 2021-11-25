fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Data Imputation"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_imputation_data"),
        hr(),
        awesomeRadio(
          inputId="select_imputation_method",
          label="Imputation methods",
          choices=c("min",
                    "knn",
                    "with",
                    "MinProb",
                    "Down-shifted Normal"),
          inline=FALSE,
          selected="min"
        ),
        conditionalPanel(
          condition="input.select_imputation_method=='with'",
          numericInput(
            "impute_with",
            "Value to impute missing values",
            value=0,
            min=0,
            max=1000
          )
        ),
        conditionalPanel(
          condition="input.select_imputation_method=='Down-shifted Normal'",
          sliderInput(
            "downshift_magnitude",
            "Value to down shift minimum normal distribution",
            value=3.5,
            min=1,
            max=5
          )
        ),
        hr(),
        materialSwitch(
          inputId="imputeByGroupSwitch",
          label="Do you want to impute by group?",
          value=FALSE,
          status="primary",
        ),
        conditionalPanel(
          condition="input.imputeByGroupSwitch",
          uiOutput("select_impute_group")
        ),
        actionButton(
          inputId="preview_imputation_distribution",
          label="Preview Imputation Distribution",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        conditionalPanel(
          condition="input.preview_imputation_distribution!=0",
          hr(),
          fluidRow(
            column(
              width=6,
              actionButton(
                inputId="submit_for_imputation",
                label="Submit for Imputation",
                icon=icon("play"),
                status="primary",
                size="sm"
              )
            ),
            column(
              width=6,
              conditionalPanel(
                condition="input.submit_for_imputation!=0",
                actionButton(
                  inputId="record_imputed_data",
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
          condition="input.preview_imputation_distribution!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Missing Values in Data",
              plotOutput("show_missing_values_to_impute") %>% withSpinner()
            ),
            tabPanel(
              title="Imputation Distribution",
              plotOutput("show_imputation_distribution_comparison") %>% withSpinner()
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("imputation_data_preview") %>% withSpinner()
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("imputation_data_sumStat") %>% withSpinner()
            )
          )
        )
      ),
      box(
        title="Imputed State of Data",
        status="warning",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.submit_for_imputation!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Split Violin",
              plotOutput("show_imputation_comparison_splitViolin") %>% withSpinner()
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("imputated_data_preview") %>% withSpinner(),
              downloadButton("downloadImputed", "Download Imputed Data")
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("imputed_data_sumStat") %>% withSpinner(),
              downloadButton("downloadImputed_sumStat", "Download Summary Statistics")
            )
          )
        )
      )
    )
  )
)
