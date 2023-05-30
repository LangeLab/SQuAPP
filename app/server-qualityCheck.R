# Select the data level for quality check
output$select_qualityCheck_data <- renderUI({
  # If example data is selected, contains all the data levels
  if(input$example_data == "yes"){
    cc <- c(
      "protein", 
      "peptide", 
      "termini", 
      "ptm"
    )
  # If not example data, only contains the data levels that exist
  }else{
    cc <- c(
      "protein", 
      "peptide", 
      "termini", 
      "ptm"
    )[c(
      input$isExist_protein,
      input$isExist_peptide,
      input$isExist_termini,
      input$isExist_ptm
    )]
  }
  if (length(cc) == 0){
    sendSweetAlert(
      session = session,
      title = "Configuration Error",
      text = "No metadata and quantitative data has been found! 
      Please use 'Data Upload' to select example data option 
      or upload your own data.",
      type = "error"
    )
    return()
  }
  # pass the data levels to the selectInput
  selectInput(
    "select_qualityCheck_data",
    label="Select data level to inspect the quality:",
    choices=cc,
    selected=NULL
  )
})

# Select the grouping factor for coloring
output$select_grouping_for_coloring <- renderUI({

  # Logical Checks
  # Check if a data-level is selected for quality check
  if (is.null(input$select_qualityCheck_data)){
    sendSweetAlert(
      session = session,
      title = "Configuration Error",
      text = "Need to select data for quality check!",
      type = "error"
    )
    return()
  }
  # Checks specific to user data  
  if(input$example_data != "yes"){
    # Check if metadata is uploaded
    if(is.null(variables$datasets$metadata)){
      sendSweetAlert(
        session = session,
        title = "Configuration Error",
        text = "Ensure metadata is provided in Data Upload!",
        type = "error"
      )
      return()
    }
    # Check if selected data-level is uploaded
    if(is.null(variables$datasets[[input$select_qualityCheck_data]])){
      sendSweetAlert(
        session = session,
        title = "Configuration Error",
        text = "Selected data level is not yet fully prepared!",
        type = "error"
      )
      return()
    }
    # Check if selected data-level is properly processed and have metadata
    if(is.null(variables$datasets[[input$select_qualityCheck_data]]$meta)){
      sendSweetAlert(
        session = session,
        title = "Configuration Error",
        text = "Metadata is not yet fully prepared!",
        type = "error"
      )
      return()
    }
  }

  # Get the datalist
  dataList <- variables$datasets[[input$select_qualityCheck_data]]
  # Find the columns to be removed from the list of choices
  if (dataList$repl){
    removeCols <- c(dataList$meta_id)
  }else{
    removeCols <- c(dataList$meta_id, dataList$meta_uniq)
  }
  # Remove the columns from the list of choices
  grouping_cols <- setdiff(colnames(dataList$meta), removeCols)

  # Create selection
  selectInput(
    "select_grouping_for_coloring",
    label="Select grouping factor for plots",
    choices=grouping_cols,
    selected=NULL
  )
})

# Create plots from selected data
observeEvent(input$produce_plots, {
  # Logical Checks to ensure all inputs are valid
  # Check if a data-level is selected for quality check
  if (is.null(input$select_qualityCheck_data)){
    sendSweetAlert(
      session = session,
      title = "Configuration Error",
      text = "Need to select data for quality check!",
      type = "error"
    )
    return()
  }
  if (input$use_group_factor){
    if (is.null(input$select_grouping_for_coloring)){
      sendSweetAlert(
        session = session,
        title = "Configuration Error",
        text = "Enabled grouping by meta variable, 
        please select grouping factor to continue!",
        type = "error"
      )
      return()
    }
  }

  # Get the variable to be used in the observeEvent
  data_name <- input$select_qualityCheck_data
  # Get current data list
  dataList <- variables$datasets[[data_name]]

  # Dynamically changed qc box title
  output$qc_box_title <- renderText({
    paste(
      "Quality Check Visualizations -", 
      str_to_title(data_name)
    )
  })

  # print(dataList$name)
  # print(dataList$repl)
  # print(dataList$meta_id)
  # print(dataList$meta_uniq)
  # print(head(dataList$meta))
  # print(head(dataList$quant))
  # print(head(dataList$annot))

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
    "parameters" = c(
      "is grouped", 
      "grouping variable"
    ),
    "values" = c(
      input$use_group_factor, 
      group_factor
    )
  )
  
  ### Violin Plot ###
  # Create violin plot showing distribution of the samples
  res_violin <- plotviolin(
    dataList, 
    group_factor=group_factor, 
    custom_title=""
  )
  # Render plot to the user
  output$show_data_distributions <- renderPlot({
    req(res_violin)
    if(is.numeric(res_violin)){
      if(res_violin == 1){
        stop("More than 5 unique values in group_factor won't be plotted!")
      }else{
        stop("Unexpected error occurred, not data to plot!")
      }
    }else{
      # Create a download link to the violin plot
      pname_violin <- paste0(
        "QCPlots_ViolinDist_", 
        data_name,
        group_name, 
        "_", 
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_distributions <- shiny.download.plot(
        pname_violin, 
        res_violin, 
        multi=F, 
        fig.width=12, 
        fig.height=6
      )
      return(res_violin)
    }
  })
  # Save the violin plot for the report variable
  if(!is.numeric(res_violin)){
    # Save the violin plot for the quality check report section
    variables$reportParam[[data_name]]$qualityCheck$distPlot <- res_violin
  }

  ### CV Plot ###
  # Create CV Plot Object
  res_cv <- plot_cv(
    dataList, 
    group_factor=group_factor
  )
  # Render plot to the user
  output$show_cv_plots <- renderPlot({
    req(res_cv)
    # Dumb but effective specific error displaying system
    if(is.numeric(res_cv)){
      if(res_cv == 0){
        stop("Unexpected error occurred, not data to plot!")
      }else if(res_cv == 1){
        stop(
          "Data needs to have replicas or 
          more than 1 sample per group to create CV plot!"
        ) 
      }else if(res_cv == 2){
        stop(
          "No or a single samples are returned!\n
          Make sure the sample names are consistent
          between metadata id and quantitative data's column names!"
        )
      }else if(res_cv == 3 || res_cv == 4){
        stop(
          "An error occurred while calculating the CV values!"
        )
      }
    }else{
      # Create a download link to the CV plot
      pname_cv <- paste0(
        "QCPlots_CV_", 
        data_name, 
        group_name, 
        "_",
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_cv <- shiny.download.plot(
        pname_cv, 
        res_cv, 
        multi=F, 
        fig.width=12, 
        fig.height=6
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
  res_bar_id <- bar_plot_identified_features(
    dataList, 
    group_factor=group_factor
  )
  # Render plot to the user
  output$show_identified_features <- renderPlot({
    req(res_bar_id)
    if(is.numeric(res_bar_id)){
      if(res_bar_id == 0){
        stop("An error happened when creating this plot!")
      }
    }else{
      # Create download link to the Identified features plot
      pname_bar_id <- paste0(
        "QCPlots_IdentFeatures_", 
        data_name, 
        group_name, 
        "_", 
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_identifiedFeatures <- shiny.download.plot(
        pname_bar_id, 
        res_bar_id, 
        multi=F, 
        fig.width=12, 
        fig.height=6
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
  res_upset <- upsetplot(
    dataList, 
    group_factor=group_factor,
    selection=NULL # TODO: Add selection functionality...
  )
  # Render plot to the user
  output$show_shared_features <- renderPlot({
    req(res_upset)
    if(is.numeric(res_upset)){
      if(res_upset == 0){
        stop("An error happened when creating this plot!")
      }else if (res_upset == 1){
        stop("Illegal access to an unimplemented feature!")
      }
    }else{
      # Create download link to the Upset plot
      pname_upset <- paste0(
        "QCPlots_SharedFeatures_", 
        data_name, 
        group_name, 
        "_", 
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_sharedFeatures <- shiny.download.plot(
        pname_upset, 
        res_upset, 
        multi=F, 
        fig.width=12, 
        fig.height=6
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
  res_compl <- datacompleteness(
    dataList,
    group_factor=NULL # TODO: Update the function to use group factor
  )
  # Render plot to the user
  output$show_data_completeness <- renderPlot({
    req(res_compl)
    if(is.numeric(res_compl)){
      if(res_compl == 0){
        stop("An error happened when creating this plot!")
      }
    }else{
      # Create download plot button
      pname_compl <- paste0(
        "QCPlots_DataCompleteness_", 
        data_name, 
        group_name, 
        "_",
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_completeness <- shiny.download.plot(
        pname_compl, 
        res_compl, 
        multi=F, 
        fig.width=12, 
        fig.height=6
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
  res_miss <- plot_missing_values(
    dataList, 
    group_factor=group_factor
  )
  # Render plot to the user
  output$show_missing_values <- renderPlot({
    req(res_miss)
    # Dumb but effective specific error displaying system
    if(is.numeric(res_miss)){
      if(res_miss == 0){
        stop("An unexpected error happened when creating this plot!")
      }else if(res_miss == 1){
        stop("More than 5 unique values in group_factor won't be plotted!")
      }
    }else{
      # Create download plot button
      pname_miss <- paste0(
        "QCPlots_MissingValues_", 
        data_name, 
        group_name, 
        "_", 
        Sys.Date(), 
        ".pdf"
      )
      output$download_qc_missingvalues <- shiny.download.plot(
        pname_miss, 
        res_miss, 
        multi=F, 
        fig.width=12, 
        fig.height=6
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
