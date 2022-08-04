fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tags"), "Enrichment Analysis"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_enrichment_data"),
        hr(),
        selectInput(
          inputId="select_enrichment_organism",
          label="Select organism to run analysis",
          choices=c(
            "Arabidopsis thaliana"="athaliana",
            "Bos taurus"="btaurus",
            "Drosophila melanogaster"="dmelanogaster",
            "Escherichia coli"="ecoli",
            "Homo sapiens"="hsapiens",
            "Mus musculus"="mmusculus",
            "Rattus norvegicus"="rnorvegicus",
            "Saccharomyces cerevisiae"="scerevisiae"
          ),
            selected="hsapiens",
            multiple=F
        ),
        awesomeRadio(
          inputId="select_enrichment_method",
          label="Select Enrichment Analysis Tool",
          choices=c("g:Profiler"="gprofiler"),
          inline=FALSE, selected="gprofiler"
        ),
        sliderInput(
            inputId = "set_enrich_pval_threshold",
            label = "Set custom p-value threshold",
            width=NULL, min = 0.001, value = 0.05, max = 0.1, step = 0.001
        ),
        conditionalPanel(
          condition="input.select_enrichment_method=='gprofiler'",
          awesomeRadio(
            inputId="select_gprofiler_correction_method",
            label="Select Multiple Test Correction Method",
            choices=c(
              "g:SCS threshold"="g_SCS",
              "bonferroni"="bonferroni",
              "false discovery rate"="fdr"
            ),
            inline=FALSE, selected="g_SCS"
          ),
          materialSwitch(
            inputId="ifMultiQuery",
            label="Run Unique significant groups as different queries",
            value=FALSE, status="primary"
          ),
          materialSwitch(
            inputId="ifCustomBackground",
            label="Use all identifier genes as custom background",
            value=FALSE, status="primary"
          ),
          selectInput(
            inputId="select_enrichment_data_sources",
            label="Select enrichment data sources",
            choices=c(
              "GO - Biological Process"="GO:BP",
              "GO - Molecular Function"="GO:MF",
              "GO - Cellular Component"="GO:CC",
              "Pathways - KEGG"="KEGG",
              "Pathways - Reactome"="REAC",
              "Pathways - Wikipathways"="WP",
              "Protein Complexes"="CORUM",
              "miRNA targets"="MIRNA",
              "Regulatory Motif Matches"="TF",
              "Tissue Specificity"="HP",
              "Human Disease Phenotypes"="HPA"
            ),
            selected=c("GO:BP", "GO:MF", "GO:CC", "KEGG", "REAC", "WP", "CORUM"),
            multiple=TRUE
          )
        ),
        hr(),
        actionButton(
          inputId="run_enrichment_analysis",
          label="Run Enrichment Analysis",
          icon=icon("play"),
          status="primary",
          size="sm"
        )
      )
    ),
    column(
      width=9,
      box(
        title="Enrichment Plots",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_enrichment_analysis!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Summary Plot",
              plotlyOutput("show_enrichment_summary_plot") %>% withSpinner()
            ),
            tabPanel(
              title="Individual Plot",
              dropdownButton(
                circle=FALSE,
                icon = icon("bars"),
                status = "warning",
                uiOutput("set_group_value_enrichment_lolipop"),
                sliderInput(
                  "set_pvalue_cutoff",
                  "P-value filter cutoff (-log10)",
                  min = 1, value = 1, max = 15, step = 2
                ),
                materialSwitch(
                  inputId="ifSortDecreasing",
                  label="Sort the values by decreasing order",
                  value=FALSE, status="primary"
                ),
                actionButton(
                  inputId="update_enrichment_lolipop_plot",
                  label="Update Plot",
                  icon=icon("play"),
                  status="warning",
                  size="sm"
                )
              ),
              plotOutput("show_enrichment_individual_plot") %>% withSpinner(),
              downloadBttn("download_enrich_ind_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            )
          )
        )
      ),
      box(
        title="Result Table",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,
        conditionalPanel(
          condition="input.run_enrichment_analysis!=0",
          # dropdownButton(
          #   circle = FALSE,
          #   icon = icon("bars"),
          #   status = "warning",
          #   uiOutput("select_knowledgebases"),
          #   actionButton(
          #     inputId="update_enrichment_result_table",
          #     label="Update Table",
          #     icon=icon("play"),
          #     status="warning",
          #     size="sm"
          #   )
          # ),
          DT::dataTableOutput("show_enrichment_result_table") %>% withSpinner(),
          downloadButton("downloadEnrichResults", "Download Result Table")
        )
      )
    )
  )
)
