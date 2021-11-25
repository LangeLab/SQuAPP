fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Visualize Protein Domain"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_proteinDomain_dataLevels"),

        awesomeRadio(
          inputId="select_proteinDomain_method",
          label="Select method for selection features",
          choices=c("Select from data"="select",
                    "Manual input"="manual"),
          inline=FALSE, selected="select"
        ),
        conditionalPanel(
          condition="input.select_proteinDomain_method=='manual'",
          textInput(
            inputId="select_proteinDomain_protein",
            label="Enter protein accession identifier"
          ),
        ),
        conditionalPanel(
          condition="input.select_proteinDomain_method=='select'",
          uiOutput("select_proteinDomain_source4set"),
          uiOutput("select_proteinDomain_set"),
          actionButton(
            inputId="show_proteinDomain_setTable",
            label="Show Table for Selection",
            icon=icon("play"),
            status="primary",
            size="sm"
          )
        ),
        hr(),
        conditionalPanel(
          condition="input.show_proteinDomain_setTable!=0 ||
                     input.select_proteinDomain_method=='manual'",
          awesomeRadio(
            inputId="select_proteinDomain_intCalc_method",
            label="Select method to calculate intensity of all matching samples",
            choices=c("Take ratio with selected groups"="Ratio",
                      "Sum all sample values"="Sum",
                      "Average all samples values"= "Mean",
                      "Get median of all sample values"= "Median"),
            inline=FALSE, selected="Ratio"
          ),
          conditionalPanel(
            condition="input.select_proteinDomain_intCalc_method=='Ratio'",
            uiOutput("select_proteinDomain_intCalc_group"),
            uiOutput("select_proteinDomain_intCalc_values")
          ),
          hr(),
          actionButton(
            inputId="plot_proteinDomain",
            label="Create Protein Domain Plot",
            icon=icon("play"),
            status="primary",
            size="sm"
          )
        )
      )
    ),
    column(
      width=9,
      box(
        title="Data Tables",
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
            title="Protein Selection Table",
            conditionalPanel(
              condition="input.show_proteinDomain_setTable!=0",
              DT::dataTableOutput("show_proteinDomain_selectTable") %>% withSpinner(),
            )
          ),
          tabPanel(
            title="Uniprot Reference Data",
            conditionalPanel(
              condition="input.plot_proteinDomain!=0",
              DT::dataTableOutput("show_proDom_uniprotRefdata") %>% withSpinner(),
              downloadButton("download_proDom_UniprotRefData", "Download Table")
            )
          ),
          tabPanel(
            title="Protein Matching Features Data",
            conditionalPanel(
              condition="input.plot_proteinDomain!=0",
              DT::dataTableOutput("show_proDom_matchFeaturedata") %>% withSpinner(),
              downloadButton("download_proDom_matchFeatureData", "Download Table")
            )
          )
        )

      ),
      box(
        title="Protein Domain Plot",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.plot_proteinDomain!=0",
          plotOutput("show_proteinDomain_plot", height="750px") %>% withSpinner(),
          downloadBttn("download_proteinDomain_plot",
                       label="Download Plot",
                       style="minimal",
                       color="warning")
        )
      )
    )
  )
)
