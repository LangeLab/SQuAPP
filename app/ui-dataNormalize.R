fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Data Normalization"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        uiOutput("select_normalization_data"),
        hr(),
        awesomeRadio(
          inputId="select_normalization_method",
          label="Normalization methods",
          choices=c(
            "min-max"="max",
            "Divided by Sum"="sum",
            "Divided by Mean"="div.mean",
            "Divided by Median"="div.median",
            "Variance Stabilization"="vsn"
          ),
          inline=FALSE,
          selected="Divided by Median"
        ),
        hr(),
        materialSwitch(
          inputId="normalizeByGroupSwitch",
          label="Do you want to normalize by group?",
          value=FALSE,
          status="primary",
        ),
        conditionalPanel(
          condition="input.normalizeByGroupSwitch",
          uiOutput("select_normalize_group")
        ),
        hr(),
        actionButton(
          inputId="preview_normalization_distribution",
          label="Preview Normalization Distribution",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        conditionalPanel(
          condition="input.preview_normalization_distribution!=0",
          hr(),
          fluidRow(
            column(
              width=6,
              actionButton(
                inputId="submit_for_normalization",
                label="Submit for Normalization",
                icon=icon("play"),
                status="primary",
                size="sm"
              )
            ),
            column(
              width=6,
              conditionalPanel(
                condition="input.submit_for_normalization!=0",
                actionButton(
                  inputId="record_normalized_data",
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
          condition="input.preview_normalization_distribution!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Violin - Distribution of Data",
              plotOutput("show_viol_pre_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Density - Distribution of Data",
              plotOutput("show_dist_pre_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Paired Plots",
              dropdownButton(
                circle = FALSE,
                icon = icon("bars"),
                status = "warning",
                selectInput(
                  inputId="corr_method_paired_plot_pre_norm",
                  label="Select correlation method",
                  choices=c("Pearson"="pearson",
                            "Spearman Rank"="spearman",
                            "Kendall Rank"="kendall"),
                  selected="Pearson"
                ),
                uiOutput("samples2compare_paired_plot_pre_norm"),
                actionButton(
                  inputId="recreate_plot_paired_plot_pre_norm",
                  label="Re-create the plot",
                  icon=icon("play"),
                  status="warning",
                  size="sm"
                )
              ),
              plotOutput("show_pairplot_pre_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("normalization_data_preview") %>% withSpinner()
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("normalization_data_sumStat") %>% withSpinner()
            )
          )
        )
      ),
      box(
        title="Normalized State of Data",
        status="warning",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.submit_for_normalization!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Violin - Distribution of Data",
              plotOutput("show_viol_post_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Density - Distribution of Data",
              plotOutput("show_dist_post_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Paired Plots",
              dropdownButton(
                circle = FALSE,
                icon = icon("bars"),
                status = "warning",
                selectInput(
                  inputId="corr_method_paired_plot_post_norm",
                  label="Select correlation method",
                  choices=c("Pearson"="pearson",
                            "Spearman Rank"="spearman",
                            "Kendall Rank"="kendall"),
                  selected="Pearson"
                ),
                uiOutput("samples2compare_paired_plot_post_norm"),
                actionButton(
                  inputId="recreate_plot_paired_plot_post_norm",
                  label="Re-create the plot",
                  icon=icon("play"),
                  status="warning",
                  size="sm"
                )
              ),
              plotOutput("show_pairplot_post_norm") %>% withSpinner()
            ),
            tabPanel(
              title="Data Table",
              DT::dataTableOutput("normalized_data_preview") %>% withSpinner(),
              downloadButton("downloadNormalized", "Download Normalized Data")
            ),
            tabPanel(
              title="Summary Statistics",
              DT::dataTableOutput("normalized_data_sumStat") %>% withSpinner(),
              downloadButton("downloadNormalized_sumStat", "Download Summary Statistics")
            )
          )
        )
      )
    )
  )
)
