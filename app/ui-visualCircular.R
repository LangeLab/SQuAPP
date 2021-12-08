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
          status="primary",
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

          materialSwitch(
            inputId="if_customFiltering",
            label="Do you want custom filtering?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_customFiltering!=1",
            selectInput(
              "select_cirNet_preDef_filtering",
              label="Select a pre-defined filtering scenario",
              choices=c("Reverse regulated modifications on unchanged protein"="reverse_mods",
                        "Consistent up regulation of all data levels"="const_up",
                        "Consistent down regulation of all data levels"="const_down",
                        "Reverse regulated peptide and protein" = "reverse_peps")
            )
          ),
          conditionalPanel(
            condition="input.if_customFiltering",
            materialSwitch(
              inputId="if_cirNet_filterProtein",
              label="Protein Level",
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
                choices=c("All regulated"="all",
                "Up regulated"="up",
                "Down regulated"="down",
                "None regulated"="no regulate"),
                selected="all")
              ),
              conditionalPanel(
                condition="input.select_cirNet_filterOn_protein=='pvalue'",
                uiOutput("select_cirNet_cond_pval_protein")
              )
            ),
            hr(),
            materialSwitch(
              inputId="if_cirNet_filterPeptide",
              label="Peptide Level",
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
                choices=c("All regulated"="all",
                "Up regulated"="up",
                "Down regulated"="down",
                "None regulated"="no regulate"),
                selected="all")
              ),
              conditionalPanel(
                condition="input.select_cirNet_filterOn_peptide=='pvalue'",
                uiOutput("select_cirNet_cond_pval_peptide")
              )
            ),
            hr(),
            materialSwitch(
              inputId="if_cirNet_filterTermini",
              label="Termini Level",
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
                choices=c("All regulated"="all",
                "Up regulated"="up",
                "Down regulated"="down",
                "None regulated"="no regulate"),
                selected="all")
              ),
              conditionalPanel(
                condition="input.select_cirNet_filterOn_termini=='pvalue'",
                uiOutput("select_cirNet_cond_pval_termini")
              )
            ),
            hr(),
            materialSwitch(
              inputId="if_cirNet_filterPTM",
              label="PTM Level",
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
                choices=c("All regulated"="all",
                "Up regulated"="up",
                "Down regulated"="down",
                "None regulated"="no regulate"),
                selected="all")
              ),
              conditionalPanel(
                condition="input.select_cirNet_filterOn_ptm=='pvalue'",
                uiOutput("select_cirNet_cond_pval_ptm")
              )
            )
          ),
          materialSwitch(
            inputId="if_cirNet_provideColor",
            label="Do you want to assign colors to connections?",
            value=FALSE, status="primary"
          ),
          conditionalPanel(
            condition="input.if_cirNet_provideColor!=1",
            actionButton(
              inputId="plot_circularNetwork",
              label="Plot Circular Plot",
              icon=icon("play"),
              status="warning",
              size="sm"
            )
          )
        )
      ),
      conditionalPanel(
        condition="input.if_cirNet_provideColor",
        box(
          title=tagList(icon("paint-brush"), "Setup Coloring for Connections"),
          status="primary",
          width=NULL,
          inputId="",
          collapsible=FALSE,

          colourInput("col_cirNet_propep", "Protein-Peptide", "#005f73"),
          colourInput("col_cirNet_proter", "Protein-Termini", "#ae2012"),
          colourInput("col_cirNet_proptm", "Protein-PTM", "#ee9b00"),
          colourInput("col_cirNet_pepter", "Peptide-Termini", "#8338ec"),
          colourInput("col_cirNet_pepptm", "Peptide-PTM", "#386641"),
          colourInput("col_cirNet_terptm", "Termini-PTM", "#7f5539"),

          actionButton(
            inputId="plot_circularNetwork_with_color",
            label="Plot Circular Plot",
            icon=icon("play"),
            status="warning",
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
              condition="input.plot_circularNetwork!=0 ||
                         input.plot_circularNetwork_with_color!=0",
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
          condition="input.plot_circularNetwork!=0 ||
                     input.plot_circularNetwork_with_color!=0",
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
