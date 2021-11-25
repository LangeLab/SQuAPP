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
  metadata <- variables$datasets[[input$select_filtering_data]]$meta
  id_col <- variables$datasets[[input$select_filtering_data]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_filterPreview_group",
               label="Select preview group factor",
               choices=cc,
               selected=NULL)
})

# Create grouping factor selection ui from the metadata
output$select_filter_group <- renderUI({
  metadata <- variables$datasets[[input$select_filtering_data]]$meta
  id_col <- variables$datasets[[input$select_filtering_data]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_filter_group",
               label="Select group factor for filtering",
               choices=cc,
               selected=NULL)
})

# Create Preview Quality check plots to preview
observeEvent(input$preview_quality_for_filter, {
  # TODO: Add validation and checks

  # Get the selected data level
  dataList <- variables$datasets[[input$select_filtering_data]]
  if(dataList$filt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Filteration has been applied to the data!",
      type="warning"
    )
    return()
  }else{
    if(!input$filterPreviewByGroupSwitch){
      group_factor <- NULL
    }else{
      group_factor <- input$select_filterPreview_group
    }
    # Create Pre-filtering completeness plot from counts
    output$show_preFilter_count <- renderPlot({
      res <- plot_completeness_counts(dataList,
                                      group_factor=group_factor)
      # Create download plot button
      pname <- paste0("dataCompleteness_with_count_",
                      input$select_filtering_data,
                      "_", group_factor, "_",
                      Sys.Date(), ".pdf")
      output$download_preFilter_count <- shiny.download.plot(pname, res,
                                                             multi=F,
                                                             fig.width=12,
                                                             fig.height=4)
      return(res)
    })

    # Create Pre-filtering completeness plot from percentage
    output$show_preFilter_percent <- renderPlot({
      res <- plot_completeness_percentage(dataList,
                                          group_factor=group_factor)
      # Create download plot button
      pname <- paste0("dataCompleteness_with_percent_",
                      input$select_filtering_data,
                      "_", group_factor, "_",
                      Sys.Date(), ".pdf")
      output$download_preFilter_percent <- shiny.download.plot(pname, res,
                                                               multi=F,
                                                               fig.width=12,
                                                               fig.height=4)
      return(res)
    })

    # Preview the pre-filtering Data
    output$filtering_data_preview <- shiny.preview.data(cbind(dataList$annot,
                                                              dataList$quant),
                                                        colIgnore='Fasta.sequence')

    # Create summary statistics for the pre-filtering data
    sumStat_df <- shiny.basicStats(dataList$quant)
    # Create preview for summary statistics created for pre-filtering data
    output$filtering_data_sumStat <- shiny.preview.data(sumStat_df,
                                                        row.names=TRUE,
                                                        pageLength=16)

  }
})

# Apply the filtering with the given configuration
observeEvent(input$submit_for_filtering, {
  #TODO: Add validation and checks

  # Get the selected data level
  dataList <- variables$datasets[[input$select_filtering_data]]
  if(dataList$filt){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Filteration has been applied to the data!",
      type="warning"
    )
    return()
  }else{
    # If user select to remove a samples
    if(input$removeSampleSwitch){
      dataList <- remove_samples(dataList,
                                 input$select_samples_to_remove)
    }
    # If user select to remove features by data completeness filter
    if(input$filterFeaturesSwitch){
      if(!input$filterByGroupSwitch){
        group_factor <- NULL
      }else{
        group_factor <- input$select_filter_group
      }
      dataList <- filter_features(dataList,
                                  filterLevel=input$filter_level,
                                  group_factor=group_factor)
    }
    # Update filtered toggle variable
    dataList$filt <- TRUE
    # Save this to temporary reactive variable to replace with original if user wants
    variables$temp_data <- dataList

    # Create Pre-filtering completeness plot from counts
    output$show_postFilter_count <- renderPlot({
      res <- plot_completeness_counts(dataList,
                                      group_factor=group_factor)
      # Create download plot button
      pname <- paste0("dataCompleteness_with_count_",
                      input$select_filtering_data,
                      "_", group_factor, "_",
                      Sys.Date(), ".pdf")
      output$download_postFilter_count <- shiny.download.plot(pname, res,
                                                              multi=F,
                                                              fig.width=12,
                                                              fig.height=4)
      return(res)
    })

    # Create Pre-filtering completeness plot from percentage
    output$show_postFilter_percent <- renderPlot({
      res <- plot_completeness_percentage(dataList,
                                          group_factor=group_factor)
      # Create download plot button
      pname <- paste0("dataCompleteness_with_percent_",
                      input$select_filtering_data,
                      "_", group_factor, "_",
                      Sys.Date(), ".pdf")
      output$download_postFilter_percent <- shiny.download.plot(pname, res,
                                                                multi=F,
                                                                fig.width=12,
                                                                fig.height=4)
      return(res)
    })

    # Preview the Filtered Data
    output$filtered_data_preview <- shiny.preview.data(cbind(dataList$annot,
                                                             dataList$quant),
                                                       colIgnore='Fasta.sequence')
    # Create a file name for download
    fname_data <- paste0("filtered_",
                          dataList$name,
                          "level_data_",
                          Sys.Date(),
                          ".csv")
    # Pass to the download button
    output$downloadFiltered <- shiny.download.data(fname_data,
                                                   cbind(dataList$annot,
                                                         dataList$quant),
                                                   colIgnore="Fasta.sequence")

    # Create summary statistics for the filtered data
    sumStat_df <- shiny.basicStats(dataList$quant)
    # Create preview for summary statistics created for filtered data
    output$filtered_data_sumStat <- shiny.preview.data(sumStat_df,
                                                       row.names=TRUE,
                                                       pageLength=16)
    # Create file name for download
    fname_summary_table <- paste0("summaryStats_filtered_",
                                  dataList$name,
                                  "level_data_",
                                  Sys.Date(),
                                  ".csv")
    # Pass to the download button
    output$downloadFiltered_sumStat <- shiny.download.data(fname_summary_table,
                                                           sumStat_df,
                                                           row.names=TRUE)
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
  if(isTruthy(input$confirm_record_filtered)){
    # If temp_data is populated replace the variables in the reactive list
    if(!is.null(variables$temp_data)){
      # Save the modified data list into its reactive list values
      variables$datasets[[input$select_filtering_data]] <- variables$temp_data
    }
    # Empty the temp_data holder
    variables$temp_data <- NULL
  }else{return()}
})
