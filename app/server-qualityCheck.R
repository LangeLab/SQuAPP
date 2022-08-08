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

  # Update isRun variable for report checks
  variables$reportParam[[data_name]]$qualityCheck$isRun <- TRUE
  # Save quality check parameters for selected data level
  variables$reportParam[[data_name]]$qualityCheck$param <-data.frame(
    "parameters" = c("is grouped", "grouping variable"),
    "values" = c(input$use_group_factor, group_factor)
  )

  ### Violin Plot ###
  # Create violin plot showing distribution of the samples
  res_violin <- plotviolin(dataList, group_factor=group_factor, custom_title="")

  # Render plot to the user
  output$show_data_distributions <- renderPlot({
    req(res_violin)
    if(is.numeric(res_violin)){
      if(res_violin == 1){
        stop("More than 5 unique values in group_factor won't be plotted!")
      }
    }else{
      # Create a download link to the violin plot
      pname_violin <- paste0(
        "QCPlots_ViolinDist_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_distributions <- shiny.download.plot(
        pname_violin, res_violin, multi=F, fig.width=12, fig.height=6
      )
      return(res_violin)
    }
  })

  if(!is.numeric(res_violin)){
    # Save the violin plot for the quality check report section
    variables$reportParam[[data_name]]$qualityCheck$distPlot <- res_violin
  }

  ### CV Plot ###
  # Create a CV plot showing the coefficient of variation
  res_cv <- plot_cv(dataList, group_factor=group_factor)
  # Render plot to the user
  output$show_cv_plots <- renderPlot({
    req(res_cv)
    # Dumb but effective specific error displaying system
    if(is.numeric(res_cv)){
      if(res_cv == 1){
        stop("No samples are returned!\n
              Make sure the sample names are consistent
              between metadata id and quantitative data's column names!")
      }else if(res_cv == 2){
        stop("Only single sample has returned!\n
              Make sure the sample names are consistent between metadata id
              and quantitative data's column names!")
      }else if(res_cv == 3){
        stop("Data needs to have replicas to create CV plot!")
      }
    }else{
      # Create a download link to the CV plot
      pname_cv <- paste0(
        "QCPlots_CV_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_cv <- shiny.download.plot(
        pname_cv, res_cv, multi=F, fig.width=12, fig.height=6
      )
      return(res_cv)
    }
  })
  # If the plot var is not numeric continue with saving to the variable
  if(!is.numeric(res_cv)){
    # Save the cv plot for the quality check report section
    variables$reportParam[[data_name]]$qualityCheck$cvPlot <- res_cv
  }

  ### Identified Feature Numbers Plot ###
  # Create a bar plot showing identified features per sample
  res_bar_id <- bar_plot_identified_features(dataList, group_factor=group_factor)
  # Render plot to the user
  output$show_identified_features <- renderPlot({
    req(res_bar_id)
    if(is.numeric(res_bar_id)){
      if(res_bar_id == 1){
        stop("An error happened when creating this plot!")
      }
    }else{
      # Create download link to the Identified features plot
      pname_bar_id <- paste0(
        "QCPlots_IdentFeatures_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_identifiedFeatures <- shiny.download.plot(
        pname_bar_id, res_bar_id, multi=F, fig.width=12, fig.height=6
      )
      return(res_bar_id)
    }
  })
  # If the plot var is not numeric continue with report var save
  if(!is.numeric(res_bar_id)){
    # Save the upset plot showing shared features for quality check report section
    variables$reportParam[[data_name]]$qualityCheck$identCount <- res_bar_id
  }

  ### Shared Features Upset Plot ###
  # Create an upset plot with shared feature set
  res_upset <- upsetplot(dataList, group_factor=group_factor)
  # Render plot to the user
  output$show_shared_features <- renderPlot({
    req(res_upset)
    if(is.numeric(res_upset)){
      if(res_bar_id == 1){
        stop("An error happened when creating this plot!")
      }
    }else{
      # Create download link to the Upset plot
      pname_upset <- paste0(
        "QCPlots_SharedFeatures_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_sharedFeatures <- shiny.download.plot(
        pname_upset, res_upset, multi=F, fig.width=12, fig.height=6
      )
      return(res_upset)
    }
  })
  # If the plot var is not numeric continue with report var save
  if(!is.numeric(res_upset)){
    # Save the upset plot showing shared features for quality check report section
    variables$reportParam[[data_name]]$qualityCheck$sharedCount <- res_upset
  }

  ### Data Completeness Plot ###
  # Create the point plot showing completeness of the data
  res_compl <- datacompleteness(dataList)
  # Render plot to the user
  output$show_data_completeness <- renderPlot({
    req(res_compl)
    if(is.numeric(res_compl)){
      if(res_compl == 1){
        stop("An error happened when creating this plot!")
      }
    }else{
      # Create download plot button
      pname_compl <- paste0(
        "QCPlots_DataCompleteness_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_completeness <- shiny.download.plot(
        pname_compl, res_compl, multi=F, fig.width=12, fig.height=6
      )
      return(res_compl)
    }
  })
  # If the plot var is not numeric continue with report var save
  if(!is.numeric(res_compl)){
    # Save the data completeness plot for quality check report section
    variables$reportParam[[data_name]]$qualityCheck$completeness <- res_compl
  }

  ### Data Missingness Plot ###
  # Create the stacked bar plot showing missingness of each sample
  res_miss <- plot_missing_values(dataList, group_factor=group_factor)
  # Render plot to the user
  output$show_missing_values <- renderPlot({
    req(res_miss)
    # Dumb but effective specific error displaying system
    if(is.numeric(res_miss)){
      if(res_miss == 1){
        stop("More than 5 unique values in group_factor won't be plotted!")
      }
    }else{
      # Create download plot button
      pname_miss <- paste0(
        "QCPlots_MissingValues_", data_name, group_name, "_", Sys.Date(), ".pdf"
      )
      output$download_qc_missingvalues <- shiny.download.plot(
        pname_miss, res_miss, multi=F, fig.width=12, fig.height=6
      )
      return(res_miss)
    }
  })
  # If the plot var is not numeric continue with report var save
  if(!is.numeric(res_miss)){
    # Save the data missingness plot for quality check report section
    variables$reportParam[[data_name]]$qualityCheck$missingCount <- res_miss
  }


})
