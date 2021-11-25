# Create data selection for visualizing feature comparison plots
output$select_visualFeature_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide",
            "termini", "ptm")[c(input$isExist_protein, input$isExist_peptide,
                                input$isExist_termini, input$isExist_ptm)]
  }
  selectInput("select_visualFeature_data",
               label="Select data level for feature comparison",
               choices=cc,
               selected=NULL)
})

# Create feature subsetting function based on statistical testing
output$select_visualFeature_Set <- renderUI({
  if(isTruthy(input$select_visualFeature_data)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_visualFeature_data]]
    # If selecting features method is from data
    if(input$select_features_method == "select"){
      # Create feature subset key "all": giving all available data points
      cc <- c("all")
      # If data has statistical result table
      if(isTruthy(dataList$stats)){
        # Add statistical datasets
        cc <- c(cc, "all significant", levels(dataList$stats$significance))
      }
      # Create
      selectInput("select_visualFeature_Set",
                   label="Select feature subset you want to use",
                   choices=cc,
                   selected=NULL)
    } else{ return() } } else { return() }
})

# Create x variable selecting tool
output$select_featurePlot_Intensity_x <- renderUI({
  if(isTruthy(input$select_visualFeature_data)){
    metadata <- variables$datasets[[input$select_visualFeature_data]]$meta
    id_col <- variables$datasets[[input$select_visualFeature_data]]$meta_id
    cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
                                                         id_col))]
    selectInput("select_featurePlot_Intensity_x",
                   label="Select variable to plot in x-axis",
                   choices=cc,
                   multiple=FALSE)
  } else { return() }

})
# Create x variable selecting tool
output$select_featurePlot_Intensity_color <- renderUI({
  if(isTruthy(input$select_visualFeature_data)){
    metadata <- variables$datasets[[input$select_visualFeature_data]]$meta
    id_col <- variables$datasets[[input$select_visualFeature_data]]$meta_id
    cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
                                                         id_col))]
    selectInput("select_featurePlot_Intensity_color",
                   label="Select variable to assign colors",
                   choices=cc,
                   multiple=FALSE)
  } else { return() }

})
# Create x variable selecting tool
output$select_featurePlot_Intensity_shape <- renderUI({
  if(isTruthy(input$select_visualFeature_data)){
    metadata <- variables$datasets[[input$select_visualFeature_data]]$meta
    id_col <- variables$datasets[[input$select_visualFeature_data]]$meta_id
    cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
                                                         id_col))]
    selectInput("select_featurePlot_Intensity_shape",
                   label="Select variable to assign shapes",
                   choices=cc,
                   multiple=FALSE)
  } else { return() }

})
# Create x variable selecting tool
output$select_featurePlot_Intensity_size_var <- renderUI({
  if(isTruthy(input$select_visualFeature_data)){
    metadata <- variables$datasets[[input$select_visualFeature_data]]$meta
    id_col <- variables$datasets[[input$select_visualFeature_data]]$meta_id
    cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
                                                         id_col))]
    selectInput("select_featurePlot_Intensity_size_var",
                   label="Select variable to assign sizes",
                   choices=cc,
                   multiple=FALSE)
  } else { return() }

})

# Create data table from user provided manual or automatic subsets
observeEvent(input$preview_featureTable, {
  # TODO: Add validations and checks to prevent crashes
  # Get the current data list
  dataList <- variables$datasets[[input$select_visualFeature_data]]
  # Get the subset rows with two different methods based on user selection
  if(input$select_features_method == "manual"){
    rows2select <- unlist(strsplit(input$select_visualFeature_plotSubset, ","))
  }else if(input$select_features_method == "select"){
    rows2select <- prepare_subset_preview_data(dataList,
                                               input$select_visualFeature_Set)
  }else if(input$select_features_method == "upload"){
    sendSweetAlert(
      session=session,
      title="WIP Error",
      text="File Upload functionality for selecting features is not finished development!",
      type="error"
    )
    return()
  } else{ return() }
  # Create a data preview based on the rows2select
  if(isTruthy(dataList$stats)){
    data <- robust_cbind(dataList$annot, dataList$stats[rows2select, ])
  }else{
    data <- dataList$annot[rows2select, ]
  }
  # Save current subset to the temporary_reactive variable
  variables$temp_data <- data
  # Output the data table
  output$show_featureTable <- shiny.preview.data(data, colIgnore='Fasta.sequence')
})


observeEvent(input$plotFeatureComparison, {
  # TODO: Add validations and checks to prevent crashes
  # Get the current data list
  dataList <- variables$datasets[[input$select_visualFeature_data]]
  # Get the preview data to get rownames
  data <- variables$temp_data
  # Select rows (features) to plot
  if(isTruthy(input$show_featureTable_rows_selected)){
    rows2select <- rownames(data[input$show_featureTable_rows_selected, ])
  }else{
    if(nrow(data) > 12){
      sendSweetAlert(
        session=session,
        title="Data Error",
        text="More than 12 rows are not suitable for this plot type!",
        type="error"
      )
      return()
    } else{ rows2select <- rownames(data) }
  }
  ### Create variables to be used in the plotting
  ## Intensity plot
  # Color variable
  if(input$ifColorIntensityPlot){
    color_var <- input$select_featurePlot_Intensity_color
  } else { color_var <- "black"}
  # Shape variable
  if(input$ifShapeIntensityPlot){
    shape_var <- input$select_featurePlot_Intensity_shape
  } else { shape_var <- 19}
  # Size variable
  if(input$ifSizeIntensityPlot){
    size_var <- input$select_featurePlot_Intensity_size_var
  } else { size_var <- 2}
  ## Correlation plot

  # Create renderPlot function for Intensity plot
  output$show_featInts_plot <- renderPlot({
    # Create the plot object with the
    res <- plot_protein_subsets(dataList,
                                feature_subset=rows2select,
                                x_var=input$select_featurePlot_Intensity_x,
                                color_var=color_var,
                                shape_var=shape_var,
                                size_var=size_var
                               )
    # Create name for the plot
    pname <- paste0("CompareFeatures_Intensity_",
                   input$select_visualFeature_data,
                   "_", Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_featInts_plot <- shiny.download.plot(pname, res, multi=F,
                                                         fig.width=12,
                                                         fig.height=6)
    return(res)

  })

  output$show_featCorr_plot <- renderPlot({
    # Plot different types of plots based on user
    if(input$ifDetailedCorr == FALSE){
      corr_method <- input$select_featuresPlot_correlation_method_fast
      # TODO: Plotting and Corners are issue with corrplot, check some fixes
      res <- plot_correlogram_fast(dataList,
                                   feature_subset=rows2select,
                                   corr_method=corr_method,
                                   cov_with_na="pairwise.complete.obs"
                                  )
    }else{
      corr_method <- input$select_featuresPlot_correlation_method_detail
      res <- plot_correlogram_detailed(dataList,
                                       feature_subset=rows2select,
                                       padjust="none",
                                       sig_level=0.05,
                                       stat_type=corr_method,
                                       colors=c("#1d3557", "white", "#e63946"),
                                       title="Correlalogram for selected features",
                                       subtitle="",
                                       caption=""
                                      )
    }
    # Create name for the plot
    pname <- paste0("CompareFeatures_Correlation_",
                   input$select_visualFeature_data,
                   "_", corr_method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_featCorr_plot <- shiny.download.plot(pname, res, multi=F,
                                                         fig.width=15,
                                                         fig.height=12)
    return(res)
  })

  # Reset the temp_data to NULL
  variables$temp_data <- NULL
})
