# Create data selection for dimensional reduction
output$select_dimReduction_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide",
            "termini", "ptm")[c(input$isExist_protein, input$isExist_peptide,
                                input$isExist_termini, input$isExist_ptm)]
  }
  selectInput("select_dimReduction_data",
               label="Select data level for dimensional reduction",
               choices=cc,
               selected=NULL)
})

# Create data subsetting element for dimensional reduction
output$select_dimReduction_featureSet <- renderUI({
  if(isTruthy(input$select_dimReduction_data)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_dimReduction_data]]
    cc <- c("all")
    if(isTruthy(dataList$stats)){
      cc <- c(cc, "all significant", levels(dataList$stats$significance))
    }
    selectInput("select_dimReduction_featureSet",
                 label="Select feature subset you want to use",
                 choices=cc,
                 selected=NULL)
  }else{ return() }
})

# Get groups for coloring
output$select_dimReduction_colorGroup <- renderUI({
  if(isTruthy(input$select_dimReduction_data)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_dimReduction_data]]
    # Get column names from metadata
    cc <- colnames(dataList$meta)[!(colnames(dataList$meta) %in% c("Replica",dataList$meta_id))]
    selectInput("select_dimReduction_colorGroup",
                   label="Select color group",
                   choices=cc, multiple=FALSE, selected=NULL)
  }else{ return() }

})

# Get groups for shaping
output$select_dimReduction_ShapeGroup <- renderUI({
  if(isTruthy(input$select_dimReduction_data)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_dimReduction_data]]
    # Get column names from metadata
    cc <- colnames(dataList$meta)[!(colnames(dataList$meta) %in% c("Replica",dataList$meta_id))]
    selectInput("select_dimReduction_ShapeGroup",
                   label="Select shape group",
                   choices=cc, multiple=FALSE, selected=NULL)
  }else{ return() }
})


# After the run dimensional direction button clicked
observeEvent(input$run_dimReduction, {
  # TODO: Add validations and checks to prevent crashes
  # Get the current data list
  dataList <- variables$datasets[[input$select_dimReduction_data]]
  # Save the variables for dimensional reduction for later
  feature_selection <- input$select_dimReduction_featureSet
  method <- input$select_dimReduction_method
  # Create t-SNE specific checks to make sure it won't break down.
  if(method=="t-SNE"){
    if(3 * input$tsne_perplexity > ncol(dataList$quant) - 1){
      sendSweetAlert(
        session=session,
        title="Warning",
        text="Perplexity should not be bigger than (samplesize - 1) / 3",
        type="warning"
      )
      return()
    }else{
      tsne_perp <- input$tsne_perplexity
    }
  }else{
    tsne_perp<-NULL
  }
  # Create title from the variables
  customTitle <- paste(method, "with", feature_selection, "features")
  # Run the dimensional reduction Function
  df <- reduce_dimensions(dataList, feature_selection, method, tsne_perp)
  # Plot the dimensional reduction plot
  output$show_dimReduction_plot <- renderPlot({
    if(isTruthy(input$ifLabels_ReducePlot)){
      show_labels <- input$ifLabels_ReducePlot
      add_repel <- input$ifRepel_ReducePlot
    }else{
      show_labels <- FALSE
      add_repel <- FALSE
    }
    if(input$ifSelectColor_ReducePlot){
      add_ellipse <- input$ifElllipse_ReducePlot
      show_mean_point <- input$ifMeanPoint_ReducePlot
      color_group <- input$select_dimReduction_colorGroup
    }else{
      add_ellipse <- FALSE
      show_mean_point <- FALSE
      color_group <- "black"
    }
    if(input$ifSelectShape_ReducePlot){
      shape_group <- input$select_dimReduction_ShapeGroup
    }else{
      shape_group <- 19
    }
    if(isTruthy(input$setPointSize_ReducePlot)){
      point_size <- input$setPointSize_ReducePlot
    }else{point_size <- 2}
    # Plot the dimensional reduction with interactive variables
    res <- plot_dimensions(df, customTitle,
                           show_labels=show_labels,
                           add_repel=add_repel,
                           add_ellipse=add_ellipse,
                           show_mean_point=show_mean_point,
                           color_group=color_group,
                           shape_group=shape_group,
                           point_size=point_size)

    # Create name for the plot
    pname <- paste0("DimensionalReduction_",
                    input$select_dimReduction_data,
                    "_", method, "_",
                    Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_dimReduction_plot <- shiny.download.plot(pname, res,
                                                             multi=F,
                                                             fig.width=12,
                                                             fig.height=6)

    # Return the plot
    return(res)
  })

  # Create a preview for dimensional reduced data
  output$show_dimReduction_table <- shiny.preview.data(df)
  # Create a file name for download
  fname_data <- paste0("dimensional_reduction_result_table_",
                        dataList$name, "level_data_",
                        Sys.Date(), ".csv")
  # Pass to the download button
  output$downloadDimReductionTable <- shiny.download.data(fname_data, df)

  # Save the dimensional reduced data to the data list
  dataList$dimRed <- df

  # Save the update list to the reactive value
  variables$datasets[[input$select_dimReduction_data]] <- dataList
})
