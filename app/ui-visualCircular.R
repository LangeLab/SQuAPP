fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Circular Network Summary"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_cirNet_dataLevels"),

        actionButton(
          inputId="combine_dataLevels",
          label="Combine Datasets",
          icon=icon("play"),
          statis="primary",
          size="sm"
        )
      ),
      conditionalPanel(
        condition="input.combine_dataLevels!=0",
        box(
          title=tagList(icon("filter"), "Setup Filtering for Connections"),
          status="primary",
          width=NULL,
          inputId="",
          collapsible=FALSE,

          h5("Protein Level"),
          materialSwitch(
            inputId="if_cirNet_filterProtein",
            label="Do you want to filter on protein level.",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_cirNet_filterProtein",
            awesomeRadio(
              inputId="select_cirNet_filterOn_protein",
              label="Which method to filter on",
              choices=c("Fold-change"="log2fc",
                        "Adjusted p-value"="pvalue"),
              inline=FALSE, selected="log2fc"
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_protein=='log2fc'",
              selectInput("select_cirNet_cond_logfc_protein",
                           label="Select filteration criteria",
                           choices=c("Both regulated"="all",
                                     "Up regulated"="up",
                                     "Down regulated"="down",
                                     "None regulated"="no regulate"),
                           selected=NULL)
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_protein=='pvalue'",
              uiOutput("select_cirNet_cond_pval_protein")
            )
          ),
          hr(),
          h5("Peptide Level"),
          materialSwitch(
            inputId="if_cirNet_filterPeptide",
            label="Do you want to filter on peptide level.",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_cirNet_filterPeptide",
            awesomeRadio(
              inputId="select_cirNet_filterOn_peptide",
              label="Which method to filter on",
              choices=c("Fold-change"="log2fc",
                        "Adjusted p-value"="pvalue"),
              inline=FALSE, selected="log2fc"
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_peptide=='log2fc'",
              selectInput("select_cirNet_cond_logfc_peptide",
                           label="Select filteration criteria",
                           choices=c("Both regulated"="all",
                                     "Up regulated"="up",
                                     "Down regulated"="down",
                                     "None regulated"="no regulate"),
                           selected=NULL)
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_peptide=='pvalue'",
              uiOutput("select_cirNet_cond_pval_peptide")
            )
          ),
          hr(),
          h5("Termini Level"),
          materialSwitch(
            inputId="if_cirNet_filterTermini",
            label="Do you want to filter on termini level.",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_cirNet_filterTermini",
            awesomeRadio(
              inputId="select_cirNet_filterOn_termini",
              label="Which method to filter on",
              choices=c("Fold-change"="log2fc",
                        "Adjusted p-value"="pvalue"),
              inline=FALSE, selected="log2fc"
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_termini=='log2fc'",
              selectInput("select_cirNet_cond_logfc_termini",
                           label="Select filteration criteria",
                           choices=c("Both regulated"="all",
                                     "Up regulated"="up",
                                     "Down regulated"="down",
                                     "None regulated"="no regulate"),
                           selected=NULL)
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_termini=='pvalue'",
              uiOutput("select_cirNet_cond_pval_termini")
            )
          ),
          hr(),
          h5("PTM Level"),
          materialSwitch(
            inputId="if_cirNet_filterPTM",
            label="Do you want to filter on ptm level.",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_cirNet_filterPTM",
            awesomeRadio(
              inputId="select_cirNet_filterOn_ptm",
              label="Which method to filter on",
              choices=c("Fold-change"="log2fc",
                        "Adjusted p-value"="pvalue"),
              inline=FALSE, selected="log2fc"
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_ptm=='log2fc'",
              selectInput("select_cirNet_cond_logfc_ptm",
                           label="Select filteration criteria",
                           choices=c("Both regulated"="all",
                                     "Up regulated"="up",
                                     "Down regulated"="down",
                                     "None regulated"="no regulate"),
                           selected=NULL)
            ),
            conditionalPanel(
              condition="input.select_cirNet_filterOn_ptm=='pvalue'",
              uiOutput("select_cirNet_cond_pval_ptm")
            )
          ),
          hr(),
          actionButton(
            inputId="plot_circularNetwork",
            label="Plot Circular Plot",
            icon=icon("play"),
            statis="warning",
            size="sm"
          )
        )
      )
    ),
    column(
      width=9,
      box(
        title="Summary Table",
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
            title="Concatenated Levels Data Summary",
            conditionalPanel(
              condition="input.combine_dataLevels!=0",
              DT::dataTableOutput("show_cirNet_concatData") %>% withSpinner(),
              downloadButton("download_cirNet_concatData", "Download Table")
            )
          ),
          tabPanel(
            title="Combined Connections Data Summary",
            conditionalPanel(
              condition="input.plot_circularNetwork!=0",
              DT::dataTableOutput("show_cirNet_combConnect") %>% withSpinner(),
              downloadButton("download_cirNet_combConnect", "Download Table")
            )
          )
        )
      ),
      box(
        title="Circular Network Summary Plot",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,

        conditionalPanel(
          condition="input.plot_circularNetwork!=0",
          plotOutput("show_circNet_plot", height="900px") %>% withSpinner(),
          downloadBttn("download_circNet_plot",
                       label="Download Plot",
                       style="minimal",
                       color="warning")

        )
      )
    )
  )
)
