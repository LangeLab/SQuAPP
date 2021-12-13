fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("cogs"), "Create a Report"),
        width=NULL,
        solidHeader=TRUE,
        status="primary",
        footer="",
        awesomeRadio(
          inputId='report_format',
          label='Report Format',
          choices=c("PDF", "HTML", "Markdown"),
          status="primary",
          selected="HTML"
        ),
        actionButton(
          inputId="generateReport",
          label="Generate Report",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),

        uiOutput("report_download")
      )
    ),
    column(
      width=9,
      conditionalPanel(
        condition="input.submitExampleData!=0 ||
                   input.isExist_protein",
        box(
          title="Protein Content Configuration",
          width=NULL,
          solidHeader=TRUE,
          collapsed=TRUE,
          status="primary",
          footer="",
          h4("1 - Data Setup"),
          checkboxGroupInput(
            inputId="report_opt_dataInput_protein",
            label="1.1 - Data Upload",
            choices=c("Parameters",
                      "Summary Info",
                      "Original Data",
                      "Prepared Data"),
            selected=c("Parameters",
                       "Summary Info",
                       "Prepared Data"),
            inline=TRUE
          ),
          hr(),

          h4("2 - Data Inspection"),
          uiOutput("render_report_opt_qualityCheck_protein"),
          hr(),

          h4("3 - Data Preprocessing"),
          uiOutput("render_report_opt_dataAverage_protein"),
          uiOutput("render_report_opt_dataFilter_protein"),
          uiOutput("render_report_opt_dataImpute_protein"),
          uiOutput("render_report_opt_dataNormalize_protein"),
          hr(),

          h4("4 - Statistical Inference"),
          uiOutput("render_report_opt_statTest_protein"),
          uiOutput("render_report_opt_enrichAnalysis_protein"),
          uiOutput("render_report_opt_goVis_protein"),
          hr(),

          h4("5 - Summary Visualizations"),
          uiOutput("render_report_opts_dimReduce_protein"),
          uiOutput("render_report_opts_cluster_protein"),
          uiOutput("render_report_opts_feature_protein")
        )
      ),
      conditionalPanel(
        condition="input.submitExampleData!=0 ||
                   input.isExist_peptide",
        box(
          title="Peptide Content Configuration",
          width=NULL,
          solidHeader=TRUE,
          collapsed=TRUE,
          status="primary",
          footer="",
          h4("1 - Data Setup"),
          checkboxGroupInput(
            inputId="report_opt_dataInput_peptide",
            label="1.1 - Data Upload",
            choices=c("Parameters",
                      "Summary Info",
                      "Original Data",
                      "Prepared Data"),
            selected=c("Parameters",
                       "Summary Info",
                       "Prepared Data"),
            inline=TRUE
          ),
          uiOutput("render_report_opt_proteinCalc"),
          hr(),

          h4("2 - Data Inspection"),
          uiOutput("render_report_opt_qualityCheck_peptide"),
          hr(),

          h4("3 - Data Preprocessing"),
          uiOutput("render_report_opt_dataAverage_peptide"),
          uiOutput("render_report_opt_dataFilter_peptide"),
          uiOutput("render_report_opt_dataImpute_peptide"),
          uiOutput("render_report_opt_dataNormalize_peptide"),
          hr(),

          h4("4 - Statistical Inference"),
          uiOutput("render_report_opt_statTest_peptide"),
          uiOutput("render_report_opt_enrichAnalysis_peptide"),
          uiOutput("render_report_opt_goVis_peptide"),
          hr(),

          h4("5 - Summary Visualizations"),
          uiOutput("render_report_opts_dimReduce_peptide"),
          uiOutput("render_report_opts_cluster_peptide"),
          uiOutput("render_report_opts_feature_peptide")
        )
      ),
      conditionalPanel(
        condition="input.submitExampleData!=0 ||
                   input.isExist_termini",
        box(
          title="Termini Content Configuration",
          width=NULL,
          solidHeader=TRUE,
          collapsed=TRUE,
          status="primary",
          footer="",
          h4("1 - Data Setup"),
          checkboxGroupInput(
            inputId="report_opt_dataInput_termini",
            label="1.1 - Data Upload",
            choices=c("Parameters",
                      "Summary Info",
                      "Original Data",
                      "Prepared Data"),
            selected=c("Parameters",
                       "Summary Info",
                       "Prepared Data"),
            inline=TRUE
          ),
          uiOutput("render_report_opt_dataAnnot_termini"),
          hr(),

          h4("2 - Data Inspection"),
          uiOutput("render_report_opt_qualityCheck_termini"),
          hr(),

          h4("3 - Data Preprocessing"),
          uiOutput("render_report_opt_dataAverage_termini"),
          uiOutput("render_report_opt_dataFilter_termini"),
          uiOutput("render_report_opt_dataImpute_termini"),
          uiOutput("render_report_opt_dataNormalize_termini"),
          hr(),

          h4("4 - Statistical Inference"),
          uiOutput("render_report_opt_statTest_termini"),
          uiOutput("render_report_opt_enrichAnalysis_termini"),
          uiOutput("render_report_opt_goVis_termini"),
          hr(),

          h4("5 - Summary Visualizations"),
          uiOutput("render_report_opts_dimReduce_termini"),
          uiOutput("render_report_opts_cluster_termini"),
          uiOutput("render_report_opts_feature_termini")
        )
      ),
      conditionalPanel(
        condition="input.submitExampleData!=0 ||
                   input.isExist_ptm",
        box(
          title="PTM Content Configuration",
          width=NULL,
          solidHeader=TRUE,
          collapsed=TRUE,
          status="primary",
          footer="",

          h4("1 - Data Setup"),
          checkboxGroupInput(
            inputId="report_opt_dataInput_ptm",
            label="1.1 - Data Upload",
            choices=c("Parameters",
                      "Summary Info",
                      "Original Data",
                      "Prepared Data"),
            selected=c("Parameters",
                       "Summary Info",
                       "Prepared Data"),
            inline=TRUE
          ),
          uiOutput("render_report_opt_dataAnnot_ptm"),
          hr(),

          h4("2 - Data Inspection"),
          uiOutput("render_report_opt_qualityCheck_ptm"),
          hr(),

          h4("3 - Data Preprocessing"),
          uiOutput("render_report_opt_dataAverage_ptm"),
          uiOutput("render_report_opt_dataFilter_ptm"),
          uiOutput("render_report_opt_dataImpute_ptm"),
          uiOutput("render_report_opt_dataNormalize_ptm"),
          hr(),

          h4("4 - Statistical Inference"),
          uiOutput("render_report_opt_statTest_ptm"),
          uiOutput("render_report_opt_enrichAnalysis_ptm"),
          uiOutput("render_report_opt_goVis_ptm"),
          hr(),

          h4("5 - Summary Visualizations"),
          uiOutput("render_report_opts_dimReduce_ptm"),
          uiOutput("render_report_opts_cluster_ptm"),
          uiOutput("render_report_opts_feature_ptm")

        )
      ),
      conditionalPanel(
        condition="input.submitExampleData!=0||
                   input.isExist_protein ||
                   input.isExist_peptide ||
                   input.isExist_termini ||
                   input.isExist_ptm",
        box(
          title="Shared Content Configuration",
          width=NULL,
          solidHeader=TRUE,
          collapsed=TRUE,
          status="primary",
          footer="",

          uiOutput("render_report_opts_proteinDomain"),
          uiOutput("render_report_opts_circularNetwork")
        )
      )
    )
  )
)
