# Create data selection for impuation of the data
output$select_imputation_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_imputation_data",
               label="Select data level to apply the imputation:",
               choices=cc,
               selected=NULL)
})

# Create grouping factor selection ui from the metadata
output$select_impute_group <- renderUI({
  data_name <- input$select_imputation_data
  metadata <- variables$datasets[[data_name]]$meta
  id_col <- variables$datasets[[data_name]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_impute_group",
               label="Select group factor for the imputation",
               choices=cc,
               selected=NULL)
})

# Previews the data before imputation in different states to allow
#   user to configure the imputation settings in most informative way
observeEvent(input$preview_imputation_distribution, {
  data_name <- input$select_imputation_data
  # Get the current data
  dataList <- variables$datasets[[data_name]]

  # Dynamically changed box title for better representation
  output$impt_org_box_title <- renderText({
    paste("Original State of", str_to_title(data_name), "Data")
  })
  output$impt_chng_box_title <- renderText({
    paste("Imputed State of", str_to_title(data_name), "Data")
  })

  # Get user passed variables as local vars
  if_byGroup <- input$imputeByGroupSwitch
  impute_method <- input$select_imputation_method

  if(if_byGroup){
    group_factor <- input$select_impute_group
  }else{ group_factor <- NULL }

  if(impute_method=='Down-shifted Normal'){
    downshift_mag <- input$downshift_magnitude
  }else{ downshift_mag <- NULL }

  if(impute_method == "with"){
    impute_value <- input$impute_with
  }else{impute_value <- NULL}

  # Set parameters for original data preview to be used in reporting
  variables$reportVars[[data_name]]$dataImpute$parameters$original <- list(
    "Is Grouped?"=if_byGroup,
    "Group Factor"=group_factor,
    "Imputation Method"=impute_method,
    "Single Imputed Value"=impute_value,
    "Downshifting Magnitude"=downshift_mag
  )

  # Create missing value as stacked bar plot for data preview
  res_missingness <- missing_values.stacked_bar_plot(dataList, group_factor)
  # Save the plot to the report variables
  variables$reportVars[[data_name]]$dataImpute$plot$original$missingness <- res_missingness
  # Render plot to the user
  output$show_missing_values_to_impute <- renderPlot({
    req(res_missingness)
    return(res_missingness)
  })

  # Create imputation distribution and origianl distribution for direct comparison
  res_density <- imputed_value_distribution.density_plots(
    dataList,
    impute.method=impute_method,
    group_factor=group_factor,
    downshift_mag=downshift_mag
  )
  # Create a download link to the density comparison plot
  pname <- paste0(
    "dataImpute_Compare_Impute_Distribution_", data_name, "_",
    group_factor,  "_", Sys.Date(), ".pdf"
  )
  output$download_dataImpute_preview_comparison <- shiny.download.plot(
    pname, res_density, multi=F, fig.width=12, fig.height=4
  )
  # Save the plot to the report variables
  variables$reportVars[[data_name]]$dataImpute$plot$original$density <- res_density
  # Output the imputation distribution for user to visualize
  output$show_imputation_distribution_comparison <- renderPlot({
    req(res_density)
    return(res_density)
  })
  # Create a preview for original data
  output$imputation_data_preview <- shiny.preview.data(
    cbind(dataList$annot, dataList$quant), colIgnore='Fasta.sequence'
  )

  # Create basicStats to preview
  sumStat_df <- shiny.basicStats(dataList$quant)
  # Create preview for summary statistics created for filtered data
  output$imputation_data_sumStat <- shiny.preview.data(
    sumStat_df, row.names=TRUE, pageLength=16
  )

  # Save original dataList to the report variables
  variables$reportVars[[data_name]]$dataImpute$data$original <- dataList
  # Save the summary statistics for the original data
  variables$reportVars[[data_name]]$dataImpute$summary$statistics$original <- sumStat_df

})

# If user clicked the submit imputation button
observeEvent(input$submit_for_imputation, {
  # Get the name of the selected data level
  data_name <- input$select_imputation_data
  # Get the current data
  dataList <- variables$datasets[[data_name]]
  # Check if the data has already been imputation
  if(dataList$impt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Data has already been imputed",
      type="warning"
    )
    return()
  }else{
    # Get user passed variables as local vars
    if_byGroup <- input$imputeByGroupSwitch
    impute_method <- input$select_imputation_method

    if(if_byGroup){
      group_factor <- input$select_impute_group
    }else{ group_factor <- NULL }

    if(impute_method=='Down-shifted Normal'){
      downshift_mag <- input$downshift_magnitude
    }else{ downshift_mag <- NULL }

    if(impute_method == "with"){
      impute_value <- input$impute_with
    }else{impute_value <- NULL}

    # Set parameters for imputed data to be used in reporting
    variables$reportVars[[data_name]]$dataImpute$parameters$imputed <- list(
      "Is Grouped?"=if_byGroup,
      "Group Factor"=group_factor,
      "Imputation Method"=impute_method,
      "Single Imputed Value"=impute_value,
      "Downshifting Magnitude"=downshift_mag
    )

    # Impute the data based on the configuration
    dataList_new <- impute_data(dataList,
                                impute_method=impute_method,
                                group_factor=group_factor,
                                downshift_mag=downshift_mag,
                                impute_value=impute_value)

    # Create imputation comparison splitViolin plot
    res <- compare.imputation_split_violin_plot(dataList,
                                                dataList_new,
                                                group_factor=group_factor)
    # Create a download link to the split violin that compares the values
    pname <- paste0(
      "dataImpute_Comparison_", data_name, "_",
       group_factor, "_", Sys.Date(), ".pdf"
    )
    output$download_dataImpute_splitViolin <- shiny.download.plot(
      pname, res, multi=F, fig.width=12, fig.height=6
    )
    # Save the plot to the report variable
    variables$reportVars[[data_name]]$dataImpute$plot$imputed$splitViolin <- res
    # Render plot to the user
    output$show_imputation_comparison_splitViolin <- renderPlot({
      req(res)
      return(res)
    })

    # Create a preview for imputed data
    output$imputated_data_preview <- shiny.preview.data(
      cbind(dataList_new$annot, dataList_new$quant),
      colIgnore='Fasta.sequence'
    )
    # Create a file name for download
    fname_data <- paste0(
      "imputed_", data_name, "level_data_", Sys.Date(), ".csv"
    )
    # Pass to the download button
    output$downloadImputed <- shiny.download.data(
      fname_data,
      cbind(dataList_new$annot, dataList_new$quant),
      colIgnore="Fasta.sequence"
    )

    # Create summary statistics for the imputed data
    sumStat_df <- shiny.basicStats(dataList_new$quant)
    # Create preview for summary statistics created for filtered data
    output$imputed_data_sumStat <- shiny.preview.data(
      sumStat_df, row.names=TRUE, pageLength=16
    )
    # Create file name for download
    fname_summary_table <- paste0(
      "summaryStats_imputed_", data_name, "level_data_", Sys.Date(), ".csv"
    )
    # Pass to the download button
    output$downloadImputed_sumStat <- shiny.download.data(
      fname_summary_table, sumStat_df, row.names=TRUE
    )
    # Update imputation toggle
    dataList_new$impt <- TRUE
  }
  # Save filtered dataList to the report variables
  variables$reportVars[[data_name]]$dataImpute$data$imputed <- dataList_new
  # Save the summary statistics for the filtered data
  variables$reportVars[[data_name]]$dataImpute$summary$statistics$imputed <- sumStat_df
})

# Record the Imputed data as the original data in the reactive variables for further analysis
observeEvent(input$record_imputed_data, {
  # Give an alert informing user that this will replace the data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_imputed",
    title="Do you want to confirm?",
    text="Imputed version of the data will replace the original state!",
    type="question"
  )
})

observeEvent(input$confirm_record_imputed,{
  # Get the data name from selected level
  data_name <- input$select_imputation_data
  # Make sure no error occurs
  if(isTruthy(input$confirm_record_imputed)){
    # If imputed data for the given data level is saved
    if(isTruthy(variables$reportVars[[data_name]]$dataImpute$data$imputed)){
      # Save the modified data list into its reactive list values
      variables$datasets[[data_name]] <- variables$reportVars[[data_name]]$dataImpute$data$imputed
    }
  }else{return()}
})
