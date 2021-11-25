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
  metadata <- variables$datasets[[input$select_imputation_data]]$meta
  id_col <- variables$datasets[[input$select_imputation_data]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_impute_group",
               label="Select group factor for the imputation",
               choices=cc,
               selected=NULL)
})

# Previews the data before imputation in different states to allow
#   user to configure the imputation settings in most informative way
observeEvent(input$preview_imputation_distribution, {
  # TODO: Add validation and checks here

  # Get the current data
  dataList <- variables$datasets[[input$select_imputation_data]]
  if(!input$imputeByGroupSwitch){
    group_factor <- NULL
  }else{
    group_factor <- input$select_impute_group
  }
  if(!input$select_imputation_method=='Down-shifted Normal'){
    downshift_mag <- NULL
  }else{
    downshift_mag <- input$downshift_magnitude
  }
  # Output the missing value plot
  output$show_missing_values_to_impute <- renderPlot({
    res <- missing_values.stacked_bar_plot(dataList, group_factor)
    return(res)
  })
  # Output the imputation distribution for user to visualize
  output$show_imputation_distribution_comparison <- renderPlot({
    res <- imputed_value_distribution.density_plots(
      dataList,
      impute.method=input$select_imputation_method,
      group_factor=group_factor,
      downshift_mag=downshift_mag
    )
    return(res)
  })
  # Create a preview for original data
  output$imputation_data_preview <- shiny.preview.data(cbind(dataList$annot,
                                                             dataList$quant),
                                                       colIgnore='Fasta.sequence')

  # Create basicStats to preview
  sumStat_df <- shiny.basicStats(dataList$quant)
  # Create preview for summary statistics created for filtered data
  output$imputation_data_sumStat <- shiny.preview.data(sumStat_df,
                                                       row.names=TRUE,
                                                       pageLength=16)


})

# If user clicked the submit imputation button
observeEvent(input$submit_for_imputation, {
  # TODO: Add validation and checks here

  # Get the selected data level
  dataList <- variables$datasets[[input$select_imputation_data]]
  if(dataList$impt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Data has already been imputed",
      type="warning"
    )
    return()
  }else{
    if(input$imputeByGroupSwitch){
      group_factor <- input$select_impute_group
    }else{group_factor <- NULL}
    # Get the impute method
    impute_method <- input$select_imputation_method
    # Get imputation specific variables
    if(impute_method == "with"){
      impute_value <- input$impute_with
    }else{impute_value <- NULL}
    if(impute_method == "Down-shifted Normal"){
      downshift_mag <- input$downshift_magnitude
    }else{downshift_mag <- NULL}
    # Impute the data based on the configuration
    dataList_new <- impute_data(dataList,
                            impute_method=impute_method,
                            group_factor=group_factor,
                            downshift_mag=downshift_mag,
                            impute_value=impute_value)
    # Create imputation comparison splitViolin plot
    output$show_imputation_comparison_splitViolin <- renderPlot({
      res <- compare.imputation_split_violin_plot(dataList,
                                                  dataList_new,
                                                  group_factor=group_factor)
      return(res)
    })

    # Create a preview for imputed data
    output$imputated_data_preview <- shiny.preview.data(cbind(dataList_new$annot,
                                                              dataList_new$quant),
                                                        colIgnore='Fasta.sequence')
    # Create a file name for download
    fname_data <- paste0("imputed_",
                          dataList_new$name,
                          "level_data_",
                          Sys.Date(),
                          ".csv")
    # Pass to the download button
    output$downloadImputed <- shiny.download.data(fname_data,
                                                   cbind(dataList_new$annot,
                                                         dataList_new$quant),
                                                   colIgnore="Fasta.sequence")

    # Create summary statistics for the imputed data
    sumStat_df <- shiny.basicStats(dataList_new$quant)
    # Create preview for summary statistics created for filtered data
    output$imputed_data_sumStat <- shiny.preview.data(sumStat_df,
                                                      row.names=TRUE,
                                                      pageLength=16)
    # Create file name for download
    fname_summary_table <- paste0("summaryStats_imputed_",
                                  dataList_new$name,
                                  "level_data_",
                                  Sys.Date(),
                                  ".csv")
    # Pass to the download button
    output$downloadImputed_sumStat <- shiny.download.data(fname_summary_table,
                                                          sumStat_df,
                                                          row.names=TRUE)
                                                          # Update imputation toggle
    dataList_new$impt <- TRUE
  }
  variables$temp_data <- dataList_new
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
  if(isTruthy(input$confirm_record_imputed)){
    # If temp_data is populated replace the variables in the reactive list
    if(!is.null(variables$temp_data)){
      # Save the modified data list into its reactive list values
      variables$datasets[[input$select_imputation_data]] <- variables$temp_data
    }
    # Empty the temp_data holder
    variables$temp_data <- NULL
  }else{return()}
})
