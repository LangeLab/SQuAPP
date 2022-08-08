################### RenderUI functions for Data Level Options ##################

############################## 1 - Data Setup ##################################

############### 1.2 - Data Annotation Options Render Functions #################

# Render termini - data annotation report option selection
output$render_report_opt_dataAnnot_termini <- renderUI({
  # If termini - data annotation is ran render the options
  if(isTruthy(variables$reportParam$termini$dataAnnot$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataAnnot_termini",
      label="1.2 - Data Annotation",
      choices=c("Parameters",
                "Result Data"),
      selected=c("Parameters",
                 "Result Data")
    )
  # If termini - data annotation is not ran render a place holder
  } else {
    placeholder_message(
      title="1.2 - Data Annotation",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm - data annotation report option selection
output$render_report_opt_dataAnnot_ptm <- renderUI({
  # If ptm - data annotation is ran render the options
  if(isTruthy(variables$reportParam$ptm$dataAnnot$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataAnnot_ptm",
      label="1.2 - Data Annotation",
      choices=c("Parameters",
                "Result Data"),
      selected=c("Parameters",
                 "Result Data")
    )
  # If ptm - data annotation is not ran render a place holder
  } else {
    placeholder_message(
      title="1.2 - Data Annotation",
      message="\tThis section is not executed yet..."
    )
  }
})

############## 1.3 - Protein Calculation Options Render Function ###############

# Render the protein recalculation report option selection
output$render_report_opt_proteinCalc <- renderUI({
  # If protein recalculation is done render the options
  if(isTruthy(variables$reportParam$peptide$proteinCalc$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_proteinCalc",
      label="1.2 - Protein Recalculation",
      choices=c("Parameters",
                "Result Data",
                "Split Violin Comparison"),
      selected=c("Parameters",
                 "Result Data",
                 "Split Violin Comparison")
    )
  # If protein recalculation is not completed render placeholder
  } else {
    placeholder_message(
      title="1.2 - Protein Recalculation",
      message="\tThis section is not executed yet..."
    )
  }
})

########################## 2 - Data Inspection #################################

################ 2.1 - Quality Check Options Render Functions ##################

# Render protein level quality check option selection
output$render_report_opt_qualityCheck_protein <- renderUI({
  # If QC is done
  if(isTruthy(variables$reportParam$protein$qualityCheck$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_qualityCheck_protein",
      label="2.1 - Quality Check",
      choices=c("Parameters",
                "Violin Plot",
                "CV Plot",
                "# of Identified Features",
                "Comparing Shared Features",
                "Data Completeness",
                "Missing Value Counts"),
      selected=c("Parameters",
                 "Violin Plot",
                 "CV Plot",
                 "# of Identified Features",
                 "Comparing Shared Features",
                 "Data Completeness",
                 "Missing Value Counts")
    )
  # If QC is not completed render placeholder
  } else {
    placeholder_message(
      title="2.1 - Quality Check",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level quality check option selection
output$render_report_opt_qualityCheck_peptide <- renderUI({
  # If QC is done
  if(isTruthy(variables$reportParam$peptide$qualityCheck$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_qualityCheck_peptide",
      label="2.1 - Quality Check",
      choices=c("Parameters",
                "Violin Plot",
                "CV Plot",
                "# of Identified Features",
                "Comparing Shared Features",
                "Data Completeness",
                "Missing Value Counts"),
      selected=c("Parameters",
                 "Violin Plot",
                 "CV Plot",
                 "# of Identified Features",
                 "Comparing Shared Features",
                 "Data Completeness",
                 "Missing Value Counts")
    )
  # If QC is not completed render placeholder
  } else {
    placeholder_message(
      title="2.1 - Quality Check",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level quality check option selection
output$render_report_opt_qualityCheck_termini <- renderUI({
  # If QC is done
  if(isTruthy(variables$reportParam$termini$qualityCheck$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_qualityCheck_termini",
      label="2.1 - Quality Check",
      choices=c("Parameters",
                "Violin Plot",
                "CV Plot",
                "# of Identified Features",
                "Comparing Shared Features",
                "Data Completeness",
                "Missing Value Counts"),
      selected=c("Parameters",
                 "Violin Plot",
                 "CV Plot",
                 "# of Identified Features",
                 "Comparing Shared Features",
                 "Data Completeness",
                 "Missing Value Counts")
    )
  # If QC is not completed render placeholder
  } else {
    placeholder_message(
      title="2.1 - Quality Check",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level quality check option selection
output$render_report_opt_qualityCheck_ptm <- renderUI({
  # If QC is done
  if(isTruthy(variables$reportParam$ptm$qualityCheck$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_qualityCheck_ptm",
      label="2.1 - Quality Check",
      choices=c("Parameters",
                "Violin Plot",
                "CV Plot",
                "# of Identified Features",
                "Comparing Shared Features",
                "Data Completeness",
                "Missing Value Counts"),
      selected=c("Parameters",
                 "Violin Plot",
                 "CV Plot",
                 "# of Identified Features",
                 "Comparing Shared Features",
                 "Data Completeness",
                 "Missing Value Counts")
    )
  # If QC is not completed render placeholder
  } else {
    placeholder_message(
      title="2.1 - Quality Check",
      message="\tThis section is not executed yet..."
    )
  }
})

############################ 3 - Data Processing ###############################

################# 3.1 - Data Averaging Options Render Functions ################

# Render protein level Options
output$render_report_opt_dataAverage_protein <- renderUI({
  # Check if the data level has replicas
  if(variables$reportParam$protein$isRepl){
    # If data averaging is done
    if(isTruthy(variables$reportParam$protein$dataAverage$isRun)){
      checkboxGroupInput(inline=TRUE,
        inputId="report_opt_dataAverage_protein",
        label="3.1 - Data Averaging",
        choices=c("Is Replaced?",
                  "Original State - Distributions",
                  "Original State - Data",
                  "Averaged State - Distributions",
                  "Averaged State - Data"),
        selected=c("Is Replaced?",
                   "Original State - Distributions",
                   "Averaged State - Distributions")
      )
      # If data averaging is not completed render a placeholder
    } else {
      placeholder_message(
        title="3.1 - Data Averaging",
        message="\tThis section is not executed yet..."
      )
    }
    # If data has no replicates this section is not relevant
  } else {
    placeholder_message(
      title="3.1 - Data Averaging",
      message="\tThis data level had no replicas to average..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_dataAverage_peptide <- renderUI({
  # Check if the data level has replicas
  if(variables$reportParam$peptide$isRepl){
    # If data averaging is done
    if(isTruthy(variables$reportParam$peptide$dataAverage$isRun)){
      checkboxGroupInput(inline=TRUE,
        inputId="report_opt_dataAverage_peptide",
        label="3.1 - Data Averaging",
        choices=c("Is Replaced?",
                  "Original State - Distributions",
                  "Original State - Data",
                  "Averaged State - Distributions",
                  "Averaged State - Data"),
        selected=c("Is Replaced?",
                   "Original State - Distributions",
                   "Averaged State - Distributions")
      )
      # If data averaging is not completed render a placeholder
    } else {
      placeholder_message(
        title="3.1 - Data Averaging",
        message="\tThis section is not executed yet..."
      )
    }
    # If data has no replicates this section is not relevant
  } else {
    placeholder_message(
      title="3.1 - Data Averaging",
      message="\tThis data level had no replicas to average..."
    )
  }
})

# Render termini level Options
output$render_report_opt_dataAverage_termini <- renderUI({
  # Check if the data level has replicas
  if(variables$reportParam$termini$isRepl){
    # If data averaging is done
    if(isTruthy(variables$reportParam$termini$dataAverage$isRun)){
      checkboxGroupInput(inline=TRUE,
        inputId="report_opt_dataAverage_termini",
        label="3.1 - Data Averaging",
        choices=c("Is Replaced?",
                  "Original State - Distributions",
                  "Original State - Data",
                  "Averaged State - Distributions",
                  "Averaged State - Data"),
        selected=c("Is Replaced?",
                   "Original State - Distributions",
                   "Averaged State - Distributions")
      )
      # If data averaging is not completed render a placeholder
    } else {
      placeholder_message(
        title="3.1 - Data Averaging",
        message="\tThis section is not executed yet..."
      )
    }
    # If data has no replicates this section is not relevant
  } else {
    placeholder_message(
      title="3.1 - Data Averaging",
      message="\tThis data level had no replicas to average..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_dataAverage_ptm <- renderUI({
  # Check if the data level has replicas
  if(variables$reportParam$ptm$isRepl){
    # If  data averaging is done
    if(isTruthy(variables$reportParam$ptm$dataAverage$isRun)){
      checkboxGroupInput(inline=TRUE,
        inputId="report_opt_dataAverage_ptm",
        label="3.1 - Data Averaging",
        choices=c("Is Replaced?",
                  "Original State - Distributions",
                  "Original State - Data",
                  "Averaged State - Distributions",
                  "Averaged State - Data"),
        selected=c("Is Replaced?",
                   "Original State - Distributions",
                   "Averaged State - Distributions")
      )
      # If data averaging is not completed render a placeholder
    } else {
      placeholder_message(
        title="3.1 - Data Averaging",
        message="\tThis section is not executed yet..."
      )
    }
    # If data has no replicates this section is not relevant
  } else {
    placeholder_message(
      title="3.1 - Data Averaging",
      message="\tThis data level had no replicas to average..."
    )
  }
})

################ 3.2 - Data Filtering Options Render Functions #################

# Render protein level Options
output$render_report_opt_dataFilter_protein <- renderUI({
  # If data filtering is done
  if(isTruthy(variables$reportParam$protein$dataFilter$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataFilter_protein",
      label="3.2 - Data Filtering",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Count Plot",
                "Original State - Percentage Plot",
                "Original State - Summary Statistics",
                "Filtered State - Data",
                "Filtered State - Count Plot",
                "Filtered State - Percentage Plot",
                "Filtered State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Filtered State - Percentage Plot",
                 "Filtered State - Summary Statistics")
    )
    # If data filtering is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.2 - Data Filtering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_dataFilter_peptide <- renderUI({
  # If data filtering is done
  if(isTruthy(variables$reportParam$peptide$dataFilter$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataFilter_peptide",
      label="3.2 - Data Filtering",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Count Plot",
                "Original State - Percentage Plot",
                "Original State - Summary Statistics",
                "Filtered State - Data",
                "Filtered State - Count Plot",
                "Filtered State - Percentage Plot",
                "Filtered State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Filtered State - Percentage Plot",
                 "Filtered State - Summary Statistics")
    )
    # If data filtering is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.2 - Data Filtering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opt_dataFilter_termini <- renderUI({
  # If level data filtering is done
  if(isTruthy(variables$reportParam$termini$dataFilter$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataFilter_termini",
      label="3.2 - Data Filtering",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Count Plot",
                "Original State - Percentage Plot",
                "Original State - Summary Statistics",
                "Filtered State - Data",
                "Filtered State - Count Plot",
                "Filtered State - Percentage Plot",
                "Filtered State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Filtered State - Percentage Plot",
                 "Filtered State - Summary Statistics")
    )
    # If data filtering is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.2 - Data Filtering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_dataFilter_ptm <- renderUI({
  # If data filtering is done
  if(isTruthy(variables$reportParam$ptm$dataFilter$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataFilter_ptm",
      label="3.2 - Data Filtering",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Count Plot",
                "Original State - Percentage Plot",
                "Original State - Summary Statistics",
                "Filtered State - Data",
                "Filtered State - Count Plot",
                "Filtered State - Percentage Plot",
                "Filtered State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Filtered State - Percentage Plot",
                 "Filtered State - Summary Statistics")
    )
    # If data filtering is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.2 - Data Filtering",
      message="\tThis section is not executed yet..."
    )
  }
})
############### 3.3 - Data Imputation Options Render Functions #################

# Render protein level Options
output$render_report_opt_dataImpute_protein <- renderUI({
  # If data imputation is done
  if(isTruthy(variables$reportParam$protein$dataImpute$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataImpute_protein",
      label="3.3 - Data Imputation",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Missing Value Counts",
                "Preview of Imputation Distributions",
                "Original State - Summary Statistics",
                "Imputed State - Data",
                "Imputed State - Missing Value Counts",
                "Sample-wise Imputation Distributions",
                "Imputed State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Imputed State - Summary Statistics",
                 "Preview of Imputation Distributions",
                 "Sample-wise Imputation Distributions"
                )
    )
    # If data imputation is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.3 - Data Imputation",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_dataImpute_peptide <- renderUI({
  # If data imputation is done
  if(isTruthy(variables$reportParam$peptide$dataImpute$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataImpute_peptide",
      label="3.3 - Data Imputation",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Missing Value Counts",
                "Preview of Imputation Distributions",
                "Original State - Summary Statistics",
                "Imputed State - Data",
                "Imputed State - Missing Value Counts",
                "Sample-wise Imputation Distributions",
                "Imputed State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Imputed State - Summary Statistics",
                 "Preview of Imputation Distributions",
                 "Sample-wise Imputation Distributions"
                )
    )
    # If data imputation is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.3 - Data Imputation",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opt_dataImpute_termini <- renderUI({
  # If data imputation level is done
  if(isTruthy(variables$reportParam$termini$dataImpute$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataImpute_termini",
      label="3.3 - Data Imputation",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Missing Value Counts",
                "Preview of Imputation Distributions",
                "Original State - Summary Statistics",
                "Imputed State - Data",
                "Imputed State - Missing Value Counts",
                "Sample-wise Imputation Distributions",
                "Imputed State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Imputed State - Summary Statistics",
                 "Preview of Imputation Distributions",
                 "Sample-wise Imputation Distributions"
                )
    )
    # If data imputation is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.3 - Data Imputation",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_dataImpute_ptm <- renderUI({
  # If data imputation level is done
  if(isTruthy(variables$reportParam$ptm$dataImpute$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataImpute_ptm",
      label="3.3 - Data Imputation",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Missing Value Counts",
                "Preview of Imputation Distributions",
                "Original State - Summary Statistics",
                "Imputed State - Data",
                "Imputed State - Missing Value Counts",
                "Sample-wise Imputation Distributions",
                "Imputed State - Summary Statistics"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Imputed State - Summary Statistics",
                 "Preview of Imputation Distributions",
                 "Sample-wise Imputation Distributions"
                )
    )
    # If data imputation is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.3 - Data Imputation",
      message="\tThis section is not executed yet..."
    )
  }
})

############## 3.4 - Data Normalization Options Render Functions ###############

# Render protein level Options
output$render_report_opt_dataNormalize_protein <- renderUI({
  # If data normalization is done
  if(isTruthy(variables$reportParam$protein$dataNormalize$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataNormalize_protein",
      label="3.4 - Data Normalization",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Summary Statistics",
                "Original State - Violin Distributions",
                "Original State - Density Distributions",
                "Original State - Detailed Paired Plots",
                "Normalized State - Data",
                "Normalized State - Summary Statistics",
                "Normalized State - Violin Distributions",
                "Normalized State - Density Distributions",
                "Normalized State - Detailed Paired Plots"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Original State - Density Distributions",
                 "Original State - Detailed Paired Plots",
                 "Normalized State - Summary Statistics",
                 "Normalized State - Density Distributions",
                 "Normalized State - Detailed Paired Plots")
    )
    # If data normalization is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.4 - Data Normalization",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_dataNormalize_peptide <- renderUI({
  # If data normalization is done
  if(isTruthy(variables$reportParam$peptide$dataNormalize$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataNormalize_peptide",
      label="3.4 - Data Normalization",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Summary Statistics",
                "Original State - Violin Distributions",
                "Original State - Density Distributions",
                "Original State - Detailed Paired Plots",
                "Normalized State - Data",
                "Normalized State - Summary Statistics",
                "Normalized State - Violin Distributions",
                "Normalized State - Density Distributions",
                "Normalized State - Detailed Paired Plots"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Original State - Density Distributions",
                 "Original State - Detailed Paired Plots",
                 "Normalized State - Summary Statistics",
                 "Normalized State - Density Distributions",
                 "Normalized State - Detailed Paired Plots")
    )
    # If data normalization is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.4 - Data Normalization",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opt_dataNormalize_termini <- renderUI({
  # If data normalization is done
  if(isTruthy(variables$reportParam$termini$dataNormalize$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataNormalize_termini",
      label="3.4 - Data Normalization",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Summary Statistics",
                "Original State - Violin Distributions",
                "Original State - Density Distributions",
                "Original State - Detailed Paired Plots",
                "Normalized State - Data",
                "Normalized State - Summary Statistics",
                "Normalized State - Violin Distributions",
                "Normalized State - Density Distributions",
                "Normalized State - Detailed Paired Plots"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Original State - Density Distributions",
                 "Original State - Detailed Paired Plots",
                 "Normalized State - Summary Statistics",
                 "Normalized State - Density Distributions",
                 "Normalized State - Detailed Paired Plots")
    )
    # If data normalization is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.4 - Data Normalization",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_dataNormalize_ptm <- renderUI({
  # If data normalization is done
  if(isTruthy(variables$reportParam$ptm$dataNormalize$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dataNormalize_ptm",
      label="3.4 - Data Normalization",
      choices=c("Is Replaced?",
                "Parameters",
                "Original State - Data",
                "Original State - Summary Statistics",
                "Original State - Violin Distributions",
                "Original State - Density Distributions",
                "Original State - Detailed Paired Plots",
                "Normalized State - Data",
                "Normalized State - Summary Statistics",
                "Normalized State - Violin Distributions",
                "Normalized State - Density Distributions",
                "Normalized State - Detailed Paired Plots"),
      selected=c("Is Replaced?",
                 "Parameters",
                 "Original State - Density Distributions",
                 "Original State - Detailed Paired Plots",
                 "Normalized State - Summary Statistics",
                 "Normalized State - Density Distributions",
                 "Normalized State - Detailed Paired Plots")
    )
    # If data normalization is not completed render a placeholder
  } else {
    placeholder_message(
      title="3.4 - Data Normalization",
      message="\tThis section is not executed yet..."
    )
  }
})

######################### 4 - Statistical Inference ############################

############# 4.1 - Statistical Testing Options Render Function ################

# Render protein level Options
output$render_report_opt_statTest_protein <- renderUI({
  # If statistical testing is done
  if(isTruthy(variables$reportParam$protein$statTest$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_statTest_protein",
      label="4.1 - Statistical Testing",
      choices= c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "All Result Data",
                 "Significant Data"),
      selected=c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "Significant Data")
    )
    # If statistical testing is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.1 - Statistical Testing",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_statTest_peptide <- renderUI({
  # If statistical testing is done
  if(isTruthy(variables$reportParam$peptide$statTest$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_statTest_peptide",
      label="4.1 - Statistical Testing",
      choices= c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "All Result Data",
                 "Significant Data"),
      selected=c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "Significant Data")
    )
    # If statistical testing is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.1 - Statistical Testing",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opt_statTest_termini <- renderUI({
  # If statistical testing is done
  if(isTruthy(variables$reportParam$termini$statTest$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_statTest_termini",
      label="4.1 - Statistical Testing",
      choices= c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "All Result Data",
                 "Significant Data"),
      selected=c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "Significant Data")
    )
    # If statistical testing is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.1 - Statistical Testing",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_statTest_ptm <- renderUI({
  # If statistical testing is done
  if(isTruthy(variables$reportParam$ptm$statTest$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_statTest_ptm",
      label="4.1 - Statistical Testing",
      choices= c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "All Result Data",
                 "Significant Data"),
      selected=c("Parameters",
                 "Volcano Plot",
                 "MA Plot",
                 "Significant Data")
    )
    # If statistical testing is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.1 - Statistical Testing",
      message="\tThis section is not executed yet..."
    )
  }
})

############# 4.2 - Enrichment Analysis Options Render Function ################

# Render protein level Options
output$render_report_opt_enrichAnalysis_protein <- renderUI({
  # If enrichment analysis is done
  if(isTruthy(variables$reportParam$protein$enrichAnalysis$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_enrichAnalysis_protein",
      label="4.2 - Enrichment Analysis",
      choices= c("Parameters",
                 "Result Table",
                 "Summary Plot"),
      selected=c("Parameters",
                 "Result Table",
                 "Summary Plot")
    )
    # If enrichment analysis is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.2 - Enrichment Analysis",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opt_enrichAnalysis_peptide <- renderUI({
  # If enrichment analysis is done
  if(isTruthy(variables$reportParam$peptide$enrichAnalysis$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_enrichAnalysis_peptide",
      label="4.2 - Enrichment Analysis",
      choices= c("Parameters",
                 "Result Table",
                 "Summary Plot"),
      selected=c("Parameters",
                 "Result Table",
                 "Summary Plot")
    )
    # If enrichment analysis is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.2 - Enrichment Analysis",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opt_enrichAnalysis_termini <- renderUI({
  # If enrichment analysis is done
  if(isTruthy(variables$reportParam$termini$enrichAnalysis$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_enrichAnalysis_termini",
      label="4.2 - Enrichment Analysis",
      choices= c("Parameters",
                 "Result Table",
                 "Summary Plot"),
      selected=c("Parameters",
                 "Result Table",
                 "Summary Plot")
    )
    # If enrichment analysis is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.2 - Enrichment Analysis",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opt_enrichAnalysis_ptm <- renderUI({
  # If enrichment analysis is done
  if(isTruthy(variables$reportParam$ptm$enrichAnalysis$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_enrichAnalysis_ptm",
      label="4.2 - Enrichment Analysis",
      choices= c("Parameters",
                 "Result Table",
                 "Summary Plot"),
      selected=c("Parameters",
                 "Result Table",
                 "Summary Plot")
    )
    # If enrichment analysis is not completed render a placeholder
  } else {
    placeholder_message(
      title="4.2 - Enrichment Analysis",
      message="\tThis section is not executed yet..."
    )
  }
})

########## 4.3 - GO Reduced Visualizations Options Render Function #############

# NOTE: This section is work in progress,
#   since the main methods are not yet implemented

######################## 5 - Summary Visualizations ############################

############ 5.1 - Dimensional Reduction Options Render Function ###############

# TODO: More flexible option would be to store all methods' results and show
#  the comparison in the report. However this would require a mid-size
#  overhaul of the generate report.

# Render protein level Options
output$render_report_opts_dimReduce_protein <- renderUI({
  # If dimensional reduction is done
  if(isTruthy(variables$reportParam$protein$dimReduce$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dimReduce_protein",
      label="5.1 - Dimensional Reduction",
      choices= c("Parameters",
                 "Reduced Table",
                 "Reduced Data"),
      selected=c("Parameters",
                 "Reduced Table",
                 "Reduced Data")
    )
    # If dimensional reduction is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.1 - Dimensional Reduction",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opts_dimReduce_peptide <- renderUI({
  # If dimensional reduction is done
  if(isTruthy(variables$reportParam$peptide$dimReduce$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dimReduce_peptide",
      label="5.1 - Dimensional Reduction",
      choices= c("Parameters",
                 "Reduced Table",
                 "Reduced Data"),
      selected=c("Parameters",
                 "Reduced Table",
                 "Reduced Data")
    )
    # If dimensional reduction is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.1 - Dimensional Reduction",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opts_dimReduce_termini <- renderUI({
  # If dimensional reduction is done
  if(isTruthy(variables$reportParam$termini$dimReduce$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dimReduce_termini",
      label="5.1 - Dimensional Reduction",
      choices= c("Parameters",
                 "Reduced Table",
                 "Reduced Data"),
      selected=c("Parameters",
                 "Reduced Table",
                 "Reduced Data")
    )
    # If dimensional reduction is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.1 - Dimensional Reduction",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opts_dimReduce_ptm <- renderUI({
  # If dimensional reduction is done
  if(isTruthy(variables$reportParam$ptm$dimReduce$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_dimReduce_ptm",
      label="5.1 - Dimensional Reduction",
      choices= c("Parameters",
                 "Reduced Table",
                 "Reduced Data"),
      selected=c("Parameters",
                 "Reduced Table",
                 "Reduced Data")
    )
    # If dimensional reduction is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.1 - Dimensional Reduction",
      message="\tThis section is not executed yet..."
    )
  }
})

################## 5.2 - Clustering Options Render Function ####################

# Render protein level Options
output$render_report_opts_cluster_protein <- renderUI({
  # If data clustering is done
  if(isTruthy(variables$reportParam$protein$cluster$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_cluster_protein",
      label="5.2 - Clustering",
      choices= c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Testing - Sum of Squares",
                 "Cluster Testing - Gap Statistics",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Silhouette Score",
                 "Cluster Result - Dendogram",
                 "Cluster Result - Membership"),
      selected=c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Dendogram")
    )
    # If clustering is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.2 - Clustering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opts_cluster_peptide <- renderUI({
  # If data clustering is done
  if(isTruthy(variables$reportParam$peptide$cluster$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_cluster_peptide",
      label="5.2 - Clustering",
      choices= c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Testing - Sum of Squares",
                 "Cluster Testing - Gap Statistics",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Silhouette Score",
                 "Cluster Result - Dendogram",
                 "Cluster Result - Membership"),
      selected=c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Dendogram")
    )
    # If clustering is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.2 - Clustering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opts_cluster_termini <- renderUI({
  # If data clustering is done
  if(isTruthy(variables$reportParam$termini$cluster$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_cluster_termini",
      label="5.2 - Clustering",
      choices= c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Testing - Sum of Squares",
                 "Cluster Testing - Gap Statistics",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Silhouette Score",
                 "Cluster Result - Dendogram",
                 "Cluster Result - Membership"),
      selected=c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Dendogram")
    )
    # If clustering is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.2 - Clustering",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opts_cluster_ptm <- renderUI({
  # If data clustering is done
  if(isTruthy(variables$reportParam$ptm$cluster$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_cluster_ptm",
      label="5.2 - Clustering",
      choices= c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Testing - Sum of Squares",
                 "Cluster Testing - Gap Statistics",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Silhouette Score",
                 "Cluster Result - Dendogram",
                 "Cluster Result - Membership"),
      selected=c("Parameters",
                 "Cluster Testing - Silhouette",
                 "Cluster Configuration",
                 "Cluster Result - PCA",
                 "Cluster Result - Dendogram")
    )
    # If clustering is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.2 - Clustering",
      message="\tThis section is not executed yet..."
    )
  }
})

############## 5.3 - Feature Comparison Options Render Function ################

# Render protein level Options
output$render_report_opts_feature_protein <- renderUI({
  # If feature comparison is done
  if(isTruthy(variables$reportParam$protein$feature$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_feature_protein",
      label="5.3 - Feature Comparison",
      choices= c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison"),
      selected=c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison")
    )
    # If feature comparison is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.3 - Feature Comparison",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render peptide level Options
output$render_report_opts_feature_peptide <- renderUI({
  # If feature comparison is done
  if(isTruthy(variables$reportParam$peptide$feature$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_feature_peptide",
      label="5.3 - Feature Comparison",
      choices= c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison"),
      selected=c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison")
    )
    # If feature comparison is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.3 - Feature Comparison",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render termini level Options
output$render_report_opts_feature_termini <- renderUI({
  # If feature comparison is done
  if(isTruthy(variables$reportParam$termini$feature$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_feature_termini",
      label="5.3 - Feature Comparison",
      choices= c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison"),
      selected=c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison")
    )
    # If feature comparison is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.3 - Feature Comparison",
      message="\tThis section is not executed yet..."
    )
  }
})

# Render ptm level Options
output$render_report_opts_feature_ptm <- renderUI({
  # If feature comparison is done
  if(isTruthy(variables$reportParam$ptm$feature$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_feature_ptm",
      label="5.3 - Feature Comparison",
      choices= c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison"),
      selected=c("Parameters",
                 "Selected Features Table",
                 "Plot Configuration",
                 "Intensity-based Comparison",
                 "Correlation-based Comparison")
    )
    # If feature comparison is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.3 - Feature Comparison",
      message="\tThis section is not executed yet..."
    )
  }
})

############### 5.4 - Protein Domain Options Render Function ###################

output$render_report_opts_proteinDomain <- renderUI({
  # If protein domain visualization is done
  if(isTruthy(variables$reportParam$shared$proteinDomain$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_proteinDomain",
      label="5.4 - Protein Domain Visualization",
      choices= c("Parameters",
                 "Domain Plot",
                 "Domain Data"),
      selected=c("Parameters",
                 "Domain Plot",
                 "Domain Data")
    )
    # If protein domain visualization is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.4 - Protein Domain Visualization",
      message="\tThis section is not executed yet..."
    )
  }
})


############## 5.5 - Circular Networks Options Render Function #################

output$render_report_opts_circularNetwork <- renderUI({
  # If circular network visualization is done
  if(isTruthy(variables$reportParam$shared$circularNetwork$isRun)){
    checkboxGroupInput(inline=TRUE,
      inputId="report_opt_circularNetwork",
      label="5.5 - Circular Network Visualization",
      choices= c("Parameters",
                 "Concatenated Data Summary",
                 "Combined Connections Data",
                 "Circular Network Plot"),
      selected=c("Parameters",
                 "Concatenated Data Summary",
                 "Combined Connections Data",
                 "Circular Network Plot")
    )
    # If circular network visualization is not completed render a placeholder
  } else {
    placeholder_message(
      title="5.5 - Circular Network Visualization",
      message="\tThis section is not executed yet..."
    )
  }
})

########################## Main Report Creation Logic ##########################
observeEvent(input$generateReport, {
  # Create a prcnt based progress bar when creating the report
  progressSweetAlert(
    session=session,
    id="report_progress",
    title="Grabbing the report template...",
    display_pct=TRUE,
    value=0
  )

  # Grab the custom reporting template for given format
  if(input$report_format == "HTML"){ spc_file <- "report_html.Rmd" } else { spc_file <- "report_def.Rmd" }

  src <- normalizePath(spc_file)
  owd <- setwd(tempdir())
  on.exit(setwd(owd))
  file.copy(src, spc_file, overwrite = TRUE)

  updateProgressBar(
    session=session,
    id="report_progress",
    title="Applying selected configuration...",
    value=10
  )
  # TODO: Here based on the user's selection of the parameters
  #  subset the report list into reportPars variable.
  # reportPars = list()

  updateProgressBar(
    session=session,
    id="report_progress",
    title="Checking compatibility of configuration...",
    value=30
  )

  # Check compatibility of the subsetted reportedPars

  updateProgressBar(
    session=session,
    id="report_progress",
    title="Passing configuration to renderer...",
    value=40
  )

  # Create a temporarty rds file
  tmp_file <- paste(
    paste0("tmp_", unique_session_id)
    ,"rds",
    sep="."
  )

  # Save the rds to harddrive for rmd renderer to read
  saveRDS(variables$reportParam, file=tmp_file)

  updateProgressBar(
    session=session,
    id="report_progress",
    title="Rendering the report...",
    value=50
  )

  out <- rmarkdown::render(
    spc_file,
    params = list(file_name=tmp_file),
    switch(
      input$report_format,
      "HTML"= rmarkdown::html_document(
        toc = TRUE,
        toc_float = TRUE,
        number_sections = TRUE,
        df_print= "paged",
        fig_width = 7,
        fig_height = 5,
        fig_caption = TRUE,
        code_folding = "hide"
      ),
      "Markdown"= rmarkdown::markdown_document()
    )
  )

  variables$report$reportFile <- out
  variables$report$runReport <- input$generateReport

  for(i in seq(51, 100, 3)){
    Sys.sleep(0.1)
    updateProgressBar(
      session = session,
      id = "report_progress",
      title = "Saving the report....",
      value = i
    )
  }

  closeSweetAlert(session = session)
  sendSweetAlert(session = session,
                 title = "DONE",
                 text = "Click [Download Report] to save your report.",
                 type = "success")

  # Remove the temporary rds file created
  file.remove(tmp_file)
})


################### Functions for Download Report #####################
output$report_download_button <- renderUI({
  if(isTruthy(variables$report$runReport)) {
    tagList(
      tags$h5("The prepared report can be download here:"),
      tags$br(),
      downloadBttn("download_the_report",
                   label="Download Report",
                   style="minimal",
                   color="warning")
    )
  } else {
    tagList(
      tags$br(),
      helpText("Click [Generate Report] for generation.")
    )
  }
})

output$download_the_report <- downloadHandler(
  filename = function(){
    paste(paste0('SQuAPP_Analysis_Report_', format(Sys.Date(), "%Y%m%d")),
      sep=".",
      switch(
        input$report_format,
        "HTML"=".html",
        "Markdown"=".md"
      )
    )
  },
  content = function(file){
    file.rename(variables$report$reportFile, file)
  }
)
