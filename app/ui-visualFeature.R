fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Feature Comparisons"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_visualFeature_data"),
        hr(),
        awesomeRadio(
          inputId="select_features_method",
          label="Select method for selection features",
          choices=c("Manual Input of Features"="manual",
                    "Upload file with Features"="upload",
                    "Select from Statistical Results"="select"
                   ),
          inline=FALSE, selected="manual"
        ),
        conditionalPanel(
          condition="input.select_features_method=='manual'",
          textInput(
            inputId="select_visualFeature_plotSubset",
            label="Enter feature names (separate by comma)"
          )
        ),
        conditionalPanel(
          condition="input.select_features_method=='select'",
          uiOutput("select_visualFeature_Set"),
        ),
        hr(),
        actionButton(
          inputId="preview_featureTable",
          label="Preview Features",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      ),
      conditionalPanel(
        condition="input.preview_featureTable!=0",
        box(
          title=tagList(icon("wrench"), "Plot Axis Configuration"),
          status="primary",
          width=NULL,
          inputId="",
          collapsible=FALSE,

          h5("Intensity Plot"),
          uiOutput("select_featurePlot_Intensity_x"),
          materialSwitch(
            inputId="ifColorIntensityPlot",
            label="Do you want to add coloring variable?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.ifColorIntensityPlot",
            uiOutput("select_featurePlot_Intensity_color")
          ),
          materialSwitch(
            inputId="ifShapeIntensityPlot",
            label="Do you want to add shape variable?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.ifShapeIntensityPlot",
            uiOutput("select_featurePlot_Intensity_shape")
          ),
          materialSwitch(
            inputId="ifSizeIntensityPlot",
            label="Do you want to add size variable?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.ifSizeIntensityPlot",
            uiOutput("select_featurePlot_Intensity_size_var")
          ),
          h5("Correlation Plot"),
          materialSwitch(
            inputId="ifDetailedCorr",
            label="Do you want to create detailed correlation plot?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.ifDetailedCorr!=1",
            awesomeRadio(
              inputId="select_featuresPlot_correlation_method_fast",
              label="Select the correlation method",
              choices=c("pearson", "spearman", "kendall"),
              inline=FALSE, selected="pearson")
          ),
          conditionalPanel(
            condition="input.ifDetailedCorr==1",
            awesomeRadio(
              inputId="select_featuresPlot_correlation_method_detail",
              label="Select method for selection features",
              choices=c("pearson"="parametric",
                        "spearman"="nonparametric",
                        "winsorized pearson"="robust"),
              inline=FALSE, selected="parametric")
          ),
          actionButton(
            inputId="plotFeatureComparison",
            label="Plot Comparisons",
            icon=icon("play"),
            status="warning",
            size="sm"
          )
        )
      )
    ),
    column(
      width=9,
      conditionalPanel(
        condition="input.preview_featureTable!=0",
        box(
          title="Preview Selected Features",
          status="primary",
          width=NULL,
          inputId="",
          solidHeader=TRUE,
          collapsible=TRUE,

          DT::dataTableOutput("show_featureTable") %>% withSpinner()
        )
      ),
      conditionalPanel(
        condition="input.plotFeatureComparison!=0",
        box(
          title="Visualize Comparisons",
          status="primary",
          width=NULL,
          inputId="",
          solidHeader=TRUE,
          collapsible=TRUE,

          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,

            tabPanel(
              title="Feature Intensities",
              plotOutput("show_featInts_plot") %>% withSpinner(),
              downloadBttn("download_featInts_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Feature Correlations",
              plotOutput("show_featCorr_plot") %>% withSpinner(),
              downloadBttn("download_featCorr_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            )
          )
        )
      )
    )
  )
)
