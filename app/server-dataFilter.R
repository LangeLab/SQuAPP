# Create data selection for filtering the data
output$select_filtering_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_filtering_data",
               label="Select data level to apply filtering:",
               choices=cc,
               selected=NULL)
})

# Create sample selection to remove from the data
output$select_samples_to_remove <- renderUI({
  cc <- colnames(variables$datasets[[input$select_filtering_data]]$quant)
  selectInput("select_samples_to_remove",
              label="Select column(s) to be removed from the data:",
              choices=cc,
              multiple=TRUE,
              selectize=TRUE)
})

# Create grouping factor selection ui from the metadata
output$select_filterPreview_group <- renderUI({
  data_name <- input$select_filtering_data
  metadata <- variables$datasets[[data_name]]$meta
  id_col <- variables$datasets[[data_name]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_filterPreview_group",
               label="Select preview group factor",
               choices=cc,
               selected=NULL)
})

# Create grouping factor selection ui from the metadata
output$select_filter_group <- renderUI({
  data_name <- input$select_filtering_data
  metadata <- variables$datasets[[data_name]]$meta
  id_col <- variables$datasets[[data_name]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_filter_group",
               label="Select group factor for filtering",
               choices=cc,
               selected=NULL)
})

# Create Preview Quality check plots to preview
observeEvent(input$preview_quality_for_filter, {
  # TODO: Add validation and checks
  data_name <- input$select_filtering_data
  # Get the selected data level
  dataList <- variables$datasets[[data_name]]

  # Dynamically changed box title for better representation
  output$filt_org_box_title <- renderText({
    paste("Original State of", str_to_title(data_name), "Data")
  })
  output$filt_chng_box_title <- renderText({
    paste("Filtered State of", str_to_title(data_name), "Data")
  })

  if(dataList$filt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Filteration has been applied to the data!",
      type="warning"
    )
    return()
  }else{
    if_byGroup <- input$filterPreviewByGroupSwitch
    if(!if_byGroup){
      group_factor <- NULL
    }else{
      group_factor <- input$select_filterPreview_group
    }
    # Set parameters for original data preview to be used in reporting
    variables$reportVars[[data_name]]$dataFilter$parameters$original <- list(
      "Is Grouped?"=if_byGroup,
      "Group Factor"=group_factor
    )
    # Create Pre-filtering completeness plot from counts
    res_count <- plot_completeness_counts(dataList, group_factor=group_factor)
    # Create a download link to the count based completeness plot
    pname_count <- paste0(
      "dataCompleteness_with_count_", data_name, "_",
      group_factor, "_", Sys.Date(), ".pdf"
    )
    output$download_preFilter_count <- shiny.download.plot(
      pname_count, res_count, multi=F, fig.width=12, fig.height=4
    )
    # Save the plot to the report variables
    variables$reportVars[[data_name]]$dataFilter$plot$original$count <- res_count
    # Render plot to the user
    output$show_preFilter_count <- renderPlot({
      req(res_count)
      return(res_count)
    })

    # Create Pre-filtering completeness plot from percentage
    res_pctg <- plot_completeness_percentage(dataList, group_factor=group_factor)
    # Create a download link to percentage based completeness plot
    pname_pctg <- paste0(
      "dataCompleteness_with_percent_", data_name, "_",
      group_factor, "_", Sys.Date(), ".pdf"
    )
    output$download_preFilter_percent <- shiny.download.plot(
      pname_pctg, res_pctg, multi=F, fig.width=12, fig.height=4
    )
    # Save the plot to the report variables
    variables$reportVars[[data_name]]$dataFilter$plot$original$percentage <- res_pctg
    # Renter plot to the user
    output$show_preFilter_percent <- renderPlot({
      req(res_pctg)
      return(res_pctg)
    })

    # Preview the pre-filtering Data
    output$filtering_data_preview <- shiny.preview.data(
      cbind(dataList$annot, dataList$quant), colIgnore='Fasta.sequence'
    )

    # Create summary statistics for the pre-filtering data
    sumStat_df <- shiny.basicStats(dataList$quant)
    # Create preview for summary statistics created for pre-filtering data
    output$filtering_data_sumStat <- shiny.preview.data(
      sumStat_df, row.names=TRUE, pageLength=16
    )

    # Save original dataList to the report variables
    variables$reportVars[[data_name]]$dataFilter$data$original <- dataList
    # Save the summary statistics for the original data
    variables$reportVars[[data_name]]$dataFilter$summary$statistics$original <- sumStat_df
  }
})

# Apply the filtering with the given configuration
observeEvent(input$submit_for_filtering, {
  #TODO: Add validation and checks
  data_name <- input$select_filtering_data
  # Get the selected data level
  dataList <- variables$datasets[[data_name]]
  if(dataList$filt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Filteration has been applied to the data!",
      type="warning"
    )
    return()
  }else{
    # Save the input variables to local vars
    if_removeSample <- input$removeSampleSwitch

    if_filterData <- input$filterFeaturesSwitch
    if_filterByGroup <- input$filterByGroupSwitch

    # If user select to remove a samples
    if(if_removeSample){
      samples_to_remove <- input$select_samples_to_remove
      dataList <- remove_samples(dataList, samples_to_remove)
    }else{
      samples_to_remove <- NULL
    }

    # If user select to remove features by data completeness filter
    if(if_filterData){
      filter_level <- input$filter_level
      if(if_filterByGroup){
        group_factor <- input$select_filter_group
      }else{
        group_factor <- NULL
      }
      dataList <- filter_features(dataList,
                                  filterLevel=filter_level,
                                  group_factor=group_factor)
    }else{
      filter_level <- NULL
    }

    # Set parameters for original data preview to be used in reporting
    variables$reportVars[[data_name]]$dataFilter$parameters$filtered <- list(
      "Remove Samples?"=if_removeSample,
      "Samples to be Removed"=samples_to_remove,
      "Filtering Level"=filter_level,
      "Is Grouped?"=if_filterByGroup,
      "Group Factor"=group_factor
    )

    # Update filtered toggle variable
    dataList$filt <- TRUE

    # Create Pre-filtering completeness plot from counts
    res_count <- plot_completeness_counts(dataList, group_factor=group_factor)
    # Create a download link to the count based completeness plot
    pname_count <- paste0(
      "dataCompleteness_with_count_", data_name, "_",
       group_factor, "_", Sys.Date(), ".pdf"
    )
    output$download_postFilter_count <- shiny.download.plot(
      pname_count, res_count, multi=F, fig.width=12, fig.height=4
    )
    # Save the plot to the report variable
    variables$reportVars[[data_name]]$dataFilter$plot$filtered$count <- res_count
    # Render plot to the user
    output$show_postFilter_count <- renderPlot({
      req(res_count)
      return(res_count)
    })

    # Create Pre-filtering completeness plot from percentage
    res_pctg <- plot_completeness_percentage(dataList, group_factor=group_factor)
    # Create a download link to the percentage based completeness plot
    pname_pctg <- paste0(
      "dataCompleteness_with_percent_", data_name, "_",
      group_factor, "_", Sys.Date(), ".pdf"
    )
    output$download_postFilter_percent <- shiny.download.plot(
      pname, res, multi=F, fig.width=12, fig.height=4
    )
    # Save the plot to the report variable
    variables$reportVars[[data_name]]$dataFilter$plot$filtered$percentage <- res_pctg
    # Render plot to the user
    output$show_postFilter_percent <- renderPlot({
      req(res_pctg)
      return(res_pctg)
    })

    # Preview the Filtered Data
    output$filtered_data_preview <- shiny.preview.data(
      cbind(dataList$annot, dataList$quant), colIgnore='Fasta.sequence'
    )
    # Create a file name for download
    fname_data <- paste0(
      "filtered_", data_name, "level_data_", Sys.Date(), ".csv"
    )
    # Pass to the download button
    output$downloadFiltered <- shiny.download.data(
      fname_data,
      cbind(dataList$annot, dataList$quant),
      colIgnore="Fasta.sequence"
    )

    # Create summary statistics for the filtered data
    sumStat_df <- shiny.basicStats(dataList$quant)
    # Create preview for summary statistics created for filtered data
    output$filtered_data_sumStat <- shiny.preview.data(
      sumStat_df, row.names=TRUE, pageLength=16
    )
    # Create file name for download
    fname_summary_table <- paste0(
      "summaryStats_filtered_", data_name, "level_data_", Sys.Date(), ".csv"
    )
    # Pass to the download button
    output$downloadFiltered_sumStat <- shiny.download.data(
      fname_summary_table, sumStat_df, row.names=TRUE
    )

    # Save filtered dataList to the report variables
    variables$reportVars[[data_name]]$dataFilter$data$filtered <- dataList
    # Save the summary statistics for the filtered data
    variables$reportVars[[data_name]]$dataFilter$summary$statistics$filtered <- sumStat_df
  }
})

# Create confirmation for user to save the filtered data as original
observeEvent(input$record_filtered_data, {
  # Give an alert informing user that this will replace the data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_filtered",
    title="Do you want to confirm?",
    text="Filtered version of the data will replace the original state!",
    type="question"
  )
})

# If User confirmed record replace the value with the current variable
observeEvent(input$confirm_record_filtered, {
  # Get the data name from selected level
  data_name <- input$select_filtering_data
  # Make sure no error occurs
  if(isTruthy(input$confirm_record_filtered)){
    # If filtered data for the given data level is saved
    if(isTruthy(variables$reportVars[[data_name]]$dataFilter$data$filtered)){
      # Save the modified data list into its reactive list values
      variables$datasets[[data_name]] <- variables$reportVars[[data_name]]$dataFilter$data$filtered
    }
  }else{return()}
})
