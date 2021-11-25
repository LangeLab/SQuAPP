# Create selection for the plots
output$select_qualityCheck_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_qualityCheck_data",
               label="Select data level to inspect the quality:",
               choices=cc,
               selected=NULL)
})

# Create selection for the grouping(coloring factor)
output$select_grouping_for_coloring <- renderUI({
  validate(need(input$select_qualityCheck_data,
                "Need to select data for quality check!"))
  # Get the datalist
  dataList <- variables$datasets[[input$select_qualityCheck_data]]
  # Create selection
  selectInput("select_grouping_for_coloring",
              label="Select grouping factor for plots",
              choices=colnames(dataList$meta),
              selected=NULL)
})

# Create plots from selected data
observeEvent(input$produce_plots, {
  # TODO: Create checks
  # Get current data list
  dataList <- variables$datasets[[input$select_qualityCheck_data]]

  if(!input$use_group_factor){
    group_factor <- NULL
  }else{
    group_factor <- input$select_grouping_for_coloring
  }

  output$show_data_distributions <- renderPlot({
    res <- plotviolin(dataList, group_factor=group_factor, custom_title="")
    # Create download plot button
    pname <- paste0("QCPlots_ViolinDist_",
                    input$select_qualityCheck_data,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_distributions <- shiny.download.plot(pname, res, multi=F,
                                                            fig.width=12,
                                                            fig.height=4)
    return(res)
  })

  output$show_cv_plots <- renderPlot({
    res <- plot_cv(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_CV_",
                    input$select_qualityCheck_data,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_cv <- shiny.download.plot(pname, res, multi=F,
                                                 fig.width=12,
                                                 fig.height=4)
    return(res)
  })

  output$show_identified_features <- renderPlot({
    res <- bar_plot_identified_features(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_IdentFeatures_",
                    input$select_qualityCheck_data,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_identifiedFeatures <- shiny.download.plot(pname, res, multi=F,
                                                                 fig.width=12,
                                                                 fig.height=4)
    return(res)
  })

  output$show_shared_features <- renderPlot({
    res <- upsetplot(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_SharedFeatures_",
                    input$select_qualityCheck_data,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_sharedFeatures <- shiny.download.plot(pname, res, multi=F,
                                                             fig.width=12,
                                                             fig.height=4)
    return(res)
  })

  output$show_data_completeness <- renderPlot({
    res <- datacompleteness(dataList)
    # Create download plot button
    pname <- paste0("QCPlots_DataCompleteness_",
                    input$select_qualityCheck_data,
                    "_",
                    Sys.Date(), ".pdf")
    output$download_qc_completeness <- shiny.download.plot(pname, res, multi=F,
                                                           fig.width=12,
                                                           fig.height=4)
    return(res)
  })

  output$show_missing_values <- renderPlot({
    res <- plot_missing_values(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_MissingValues_",
                    input$select_qualityCheck_data,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_missingvalues <- shiny.download.plot(pname, res, multi=F,
                                                             fig.width=12,
                                                             fig.height=4)
    return(res)
  })

})
