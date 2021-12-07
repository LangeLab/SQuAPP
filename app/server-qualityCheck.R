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
  # Get the variable to be used in the observeEvent
  data_name <- input$select_qualityCheck_data
  # Get current data list
  dataList <- variables$datasets[[data_name]]

  # Dynamically changed box title for better representation
  output$qc_box_title <- renderText({
    paste("Quality Check Visualizations -", str_to_title(data_name))
  })

  if(!input$use_group_factor){
    group_factor <- NULL
    group_name <- ""
  }else{
    group_factor <- input$select_grouping_for_coloring
    group_name <- paste0("_", group_factor)
  }

  output$show_data_distributions <- renderPlot({
    res <- plotviolin(dataList, group_factor=group_factor, custom_title="")
    # Create download plot button
    pname <- paste0("QCPlots_ViolinDist_",
                    data_name,
                    "_", group_factor, "_",
                    Sys.Date(), ".pdf")
    output$download_qc_distributions <- shiny.download.plot(pname, res, multi=F,
                                                            fig.width=12,
                                                            fig.height=6)
    return(res)
  })

  output$show_cv_plots <- renderPlot({
    res <- plot_cv(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_CV_", data_name,
                    group_name, "_", Sys.Date(), ".pdf")
    output$download_qc_cv <- shiny.download.plot(pname, res, multi=F,
                                                 fig.width=12,
                                                 fig.height=6)
    return(res)
  })

  output$show_identified_features <- renderPlot({
    res <- bar_plot_identified_features(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_IdentFeatures_", data_name,
                    group_name, "_", Sys.Date(), ".pdf")
    output$download_qc_identifiedFeatures <- shiny.download.plot(pname, res, multi=F,
                                                                 fig.width=12,
                                                                 fig.height=6)
    return(res)
  })

  output$show_shared_features <- renderPlot({
    res <- upsetplot(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_SharedFeatures_", data_name,
                    group_name, "_", Sys.Date(), ".pdf")
    output$download_qc_sharedFeatures <- shiny.download.plot(pname, res, multi=F,
                                                             fig.width=12,
                                                             fig.height=6)
    return(res)
  })

  output$show_data_completeness <- renderPlot({
    res <- datacompleteness(dataList)
    # Create download plot button
    pname <- paste0("QCPlots_DataCompleteness_", data_name,
                    group_name, "_", Sys.Date(), ".pdf")
    output$download_qc_completeness <- shiny.download.plot(pname, res, multi=F,
                                                           fig.width=12,
                                                           fig.height=6)
    return(res)
  })

  output$show_missing_values <- renderPlot({
    res <- plot_missing_values(dataList, group_factor=group_factor)
    # Create download plot button
    pname <- paste0("QCPlots_MissingValues_", data_name,
                    group_name, "_", Sys.Date(), ".pdf")
    output$download_qc_missingvalues <- shiny.download.plot(pname, res, multi=F,
                                                             fig.width=12,
                                                             fig.height=6)
    return(res)
  })

})
