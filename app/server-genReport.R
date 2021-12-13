runReport <- reactiveValues(runReportValue = FALSE)

################### RenderUI functions for Data Level Optiond ##################

### 1.2 - Data Annotation Options Render Functions

# Render termini - data annotation report option selection
output$render_report_opt_dataAnnot_termini <- renderUI({
  # If termini - data annotation is ran render the options
  if(isTruthy(variables$reportChecks$termini$dataAnnot)){
    checkboxGroupInput(
      inputId="report_opt_dataAnnot_termini",
      label="1.2 - Data Annotation",
      choices=c("Parameters",
                "Summary Info",
                "Prepared Data"),
      selected=c("Parameters",
                 "Summary Info",
                 "Prepared Data")
    )
  # If termini - data annotation is not ran render a place holder
  } else {
    tagList(
      tags$b("1.2 - Data Annotation"),
      tags$br(),
      tags$em("This section is not executed yet...")
    )
  }
})

# Render ptm - data annotation report option selection
output$render_report_opt_dataAnnot_ptm <- renderUI({
  # If ptm - data annotation is ran render the options
  if(isTruthy(variables$reportChecks$ptm$dataAnnot)){
    checkboxGroupInput(
      inputId="report_opt_dataAnnot_ptm",
      label="1.2 - Data Annotation",
      choices=c("Parameters",
                "Summary Info",
                "Prepared Data"),
      selected=c("Parameters",
                 "Summary Info",
                 "Prepared Data")
    )
  # If ptm - data annotation is not ran render a place holder
  } else {
    tagList(
      tags$b("1.2 - Data Annotation"),
      tags$br(),
      tags$em("This section is not executed yet...")
    )
  }
})

### 1.3 - Protein Calculation Options Render Function

# Render the protein recalculation report option selection
output$render_report_opt_proteinCalc <- renderUI({
  # If protein recalculation is done render the options
  if(isTruthy(variables$reportChecks$peptide$proteinCalc)){
    checkboxGroupInput(
      inputId="report_opt_proteinCalc",
      label="1.3 - Protein Recalculation",
      choices=c("Parameters",
                "Prepared Data",
                "Split Violin Comparison"),
      selected=c("Parameters",
                 "Prepared Data",
                 "Split Violin Comparison")
    )
  # If protein recalculation is not completed render placeholder
  } else {
    tagList(
      tags$b("1.3 - Protein Recalculation"),
      tags$br(),
      tags$em("This section is not executed yet...")
    )
  }
})

### 2.1 - Quality Check Options Render Functions
