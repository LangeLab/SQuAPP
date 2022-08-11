# Create data selection for normalization of the data
output$select_normalization_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_normalization_data",
               label="Select data level to apply the normalization:",
               choices=cc,
               selected=NULL)
})

# Create grouping factor selection ui from the metadata
output$select_normalize_group <- renderUI({
  metadata <- variables$datasets[[input$select_normalization_data]]$meta
  id_col <- variables$datasets[[input$select_normalization_data]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_normalize_group",
                 label="Select group factor for the normalization",
                 choices=cc,
                 multiple=FALSE,
                 selected=NULL)
})

output$samples2compare_paired_plot_pre_norm <- renderUI({
  quant_data <- variables$datasets[[input$select_normalization_data]]$quant
  selectizeInput("samples2compare_paired_plot_pre_norm",
                 label="Select samples to plot in paired plot:",
                 choices=colnames(quant_data),
                 multiple=TRUE,
                 options = list(maxItems = 15))
})

output$samples2compare_paired_plot_post_norm <- renderUI({
  quant_data <- variables$datasets[[input$select_normalization_data]]$quant
  selectizeInput("samples2compare_paired_plot_post_norm",
                 label="Select samples to plot in paired plot:",
                 choices=colnames(quant_data),
                 multiple=TRUE,
                 options = list(maxItems = 15))
})

# Previews the data before normalization
observeEvent(input$preview_normalization_distribution, {
  # TODO: Add validation and checks
  data_name <- input$select_normalization_data
  # Get the current data
  dataList <- variables$datasets[[data_name]]

  # Get user passed variables as local vars
  if_byGroup <- input$normalizeByGroupSwitch

  if(if_byGroup){
    group_factor <- input$select_normalize_group
  }else{ group_factor <- NULL }

  # Create violin plot of sample-intensities
  res_violinPlot <- plotviolin(dataList, group_factor, custom_title="")
  # Save the plot to the report variables
  variables$reportParam[[data_name]]$dataNormalize$org_violinDist <- res_violinPlot
  # Render plot to the user
  output$show_viol_pre_norm <- renderPlot({
    req(res_violinPlot)
    return(res_violinPlot)
  })

  # Create density plot of sample-intensities
  res_densityPlot <- global_and_sample_distribution_plot(dataList, group_factor)
  # Save the plot to the report variables
  variables$reportParam[[data_name]]$dataNormalize$org_denstyDist <- res_densityPlot
  # Render plot to the user
  output$show_dist_pre_norm <- renderPlot({
    req(res_densityPlot)
    return(res_densityPlot)
  })
  # Complex paired plot input and render
  output$show_pairplot_pre_norm <- renderPlot({
    if(input$recreate_plot_paired_plot_pre_norm){
      col2subset <- eventReactive(input$recreate_plot_paired_plot_pre_norm, {
        input$samples2compare_paired_plot_pre_norm
      })
      cor.method <- eventReactive(input$recreate_plot_paired_plot_pre_norm, {
        input$corr_method_paired_plot_pre_norm
      })
      res <- plot_pair_panels(dataList$quant, col2subset=col2subset(), cor.method=cor.method())
    }else{
      res <- plot_pair_panels(dataList$quant, col2subset=NULL, cor.method="pearson")
    }
    # Save the plot to the report variables
    variables$reportParam[[data_name]]$dataNormalize$org_pairedPlot <- res
    return(res)
  })

  # Create a preview for original data
  output$normalization_data_preview <- shiny.preview.data(
    cbind(dataList$annot, dataList$quant), colIgnore='Fasta.sequence'
  )
  # Save original table to reportParam for the original state to reportParam
  variables$reportParam[[data_name]]$dataNormalize$org_table <- report.preview.data(
    dataList$quant, colIgnore="Fasta.sequence", rowN=3)

  # Create basicStats to preview
  sumStat_df <- shiny.basicStats(dataList$quant)
  # Create preview for summary statistics created for filtered data
  output$normalization_data_sumStat <- shiny.preview.data(
    sumStat_df, row.names=TRUE, pageLength=16
  )
  # Save the summary stat table for the original state to reportParam
  variables$reportParam[[data_name]]$dataNormalize$org_summaryStat <- sumStat_df
})

# If user clicked the submit normalization button
observeEvent(input$submit_for_normalization, {
  # Initialize null states for useful variables as well as empty str versions for param table
  group_factor <- NULL
  group_factor_str <- ""

  # TODO: Add validation and checks
  data_name <- input$select_normalization_data
  # Get the current data
  dataList <- variables$datasets[[data_name]]

  if(dataList$norm){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Data has already been normalized",
      type="warning"
    )
    return()
  }else{
    # Get user passed variables as local vars
    if_byGroup <- input$normalizeByGroupSwitch
    if(if_byGroup){
      group_factor <- input$select_normalize_group
      group_factor_str <- group_factor
    }

    # Get the normalization method
    normalize_method <- input$select_normalization_method
    # Normalize the data with configuration
    dataList_new <- normalize_data(dataList, normalize_method, group_factor)

    # Create paramaters table and save to reportParams
    variables$reportParam[[data_name]]$dataNormalize$param <- data.frame(
      "parameters" = c("is normalization grouped?", "grouping", "method"),
      "values" = c(if_byGroup, group_factor_str, normalize_method))

    # Save the processed data into reactive value to be used
    #  in record processed function if selected
    variables$temp_data <- dataList_new

    # Create violin plot of sample-intensities
    res_violinPlot <- plotviolin(dataList_new, group_factor, custom_title="")
    # Save the plot to the report variables
    variables$reportParam[[data_name]]$dataNormalize$prc_violinDist <- res_violinPlot
    # Render plot to the user
    output$show_viol_post_norm <- renderPlot({
      req(res_violinPlot)
      return(res_violinPlot)
    })

    # Create density plot of sample-intensities
    res_densityPlot <- global_and_sample_distribution_plot(dataList_new, group_factor)
    # Save the plot to the report variables
    variables$reportParam[[data_name]]$dataNormalize$prc_denstyDist <- res_densityPlot
    # Render plot to the user
    output$show_dist_post_norm <- renderPlot({
      req(res_densityPlot)
      return(res_densityPlot)
    })

    # Complex paired plot input and render
    output$show_pairplot_post_norm <- renderPlot({
      if(input$recreate_plot_paired_plot_post_norm){
        col2subset <- eventReactive(input$recreate_plot_paired_plot_post_norm, {
          input$samples2compare_paired_plot_post_norm
        })
        cor.method <- eventReactive(input$recreate_plot_paired_plot_post_norm, {
          input$corr_method_paired_plot_post_norm
        })
        res <- plot_pair_panels(dataList_new$quant, col2subset=col2subset(), cor.method=cor.method())
      }else{
        res <- plot_pair_panels(dataList_new$quant, col2subset=NULL, cor.method="pearson")
      }
      # Save the plot to the report variables
      variables$reportParam[[data_name]]$dataNormalize$prc_pairedPlot <- res
      return(res)
    })

    # Create a preview for original data
    output$normalized_data_preview <- shiny.preview.data(
      cbind(dataList_new$annot,dataList_new$quant),colIgnore='Fasta.sequence'
    )
    # Create a file name for download
    fname_data <- paste0("imputed_", dataList_new$name, "level_data_", Sys.Date(), ".csv")
    # Pass to the download button
    output$downloadNormalized <- shiny.download.data(
      fname_data, cbind(dataList_new$annot, dataList_new$quant),
      colIgnore="Fasta.sequence"
    )
    # Save processed table to reportParam for the processed state to reportParam
    variables$reportParam[[data_name]]$dataNormalize$prc_table <- report.preview.data(
      dataList_new$quant, colIgnore="Fasta.sequence", rowN=3)

    # Create basicStats to preview
    sumStat_df <- shiny.basicStats(dataList_new$quant)
    # Create preview for summary statistics created for normalized data
    output$normalized_data_sumStat <- shiny.preview.data(sumStat_df,
                                                         row.names=TRUE,
                                                         pageLength=16)
    # Create file name for download
    fname_summary_table <- paste0(
      "summaryStats_normalized_", dataList$name, "level_data_", Sys.Date(), ".csv"
    )
    # Pass to the download button
    output$downloadNormalized_sumStat <- shiny.download.data(fname_summary_table,
                                                             sumStat_df,
                                                             row.names=TRUE)
    #
    # Save the summary statistics for the filtered data
    variables$reportParam[[data_name]]$dataNormalize$prc_summaryStat <- sumStat_df

    # update isRun for filtering
    variables$reportParam[[data_name]]$dataNormalize$isRun <- TRUE
  }
})

# Create confirmation for user to save the normalized data as original
observeEvent(input$record_normalized_data, {
  # Give an alert informing user that this will replace the data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_normalized",
    title="Do you want to confirm?",
    text="Normalized version of the data will replace the original state!",
    type="question"
  )
})

# If User confirmed record replace the processed data with the current data
observeEvent(input$confirm_record_normalized,{
  # Get the data name from selected level
  data_name <- input$select_normalization_data
  if(isTruthy(input$confirm_record_normalized)){
    # If temp_data is populated replace the variables in the reactive list
    if(isTruthy(variables$temp_data)){
      # Update isReplaced variable with TRUE
      variables$reportParam[[data_name]]$dataNormalize$isReplaced <- TRUE
      # Save the modified data list into its reactive list values
      variables$datasets[[data_name]] <- variables$temp_data
      # Update the normalization status in the main dataList
      variables$datasets[[data_name]]$norm <- TRUE
      # reset the temp_data variable
      variables$temp_data <- NULL
    }else{return()}
  }else{return()}
})
