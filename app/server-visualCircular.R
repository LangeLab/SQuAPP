# Create data levels for circular network data plot
output$select_cirNet_dataLevels <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_cirNet_dataLevels",
               label="Select data levels to include in circular network plot",
               choices=cc,
               selected=NULL,
               multiple=TRUE)
})

# Create filter condition selector render handle for protein
output$select_cirNet_cond_pval_protein <- renderUI({
  if(isTruthy(input$select_cirNet_dataLevels)){
    include_levels <- input$select_cirNet_dataLevels
    if("protein" %in% include_levels){
      dataList <- variables$datasets[["protein"]]
      if(isTruthy(dataList$stats)){
        s_l <- levels(dataList$stats$significance)
        cc <- c("All significant"="all", s_l)
        selectInput("select_cirNet_cond_pval_protein",
                     label="Select filteration criteria",
                     choices=cc,
                     selected=NULL)
      } else{ return() }
    } else{ return() }
  } else{ return() }
})

# Create filter condition selector render handle for peptide
output$select_cirNet_cond_pval_peptide <- renderUI({
  if(isTruthy(input$select_cirNet_dataLevels)){
    include_levels <- input$select_cirNet_dataLevels
    if("peptide" %in% include_levels){
      dataList <- variables$datasets[["peptide"]]
      if(isTruthy(dataList$stats)){
        s_l <- levels(dataList$stats$significance)
        cc <- c("All significant"="all", s_l)
        selectInput("select_cirNet_cond_pval_peptide",
                     label="Select filteration criteria",
                     choices=cc,
                     selected=NULL)
      } else{ return() }
    } else{ return() }
  } else{ return() }
})

# Create filter condition selector render handle for termini
output$select_cirNet_cond_pval_termini <- renderUI({
  if(isTruthy(input$select_cirNet_dataLevels)){
    include_levels <- input$select_cirNet_dataLevels
    if("termini" %in% include_levels){
      dataList <- variables$datasets[["termini"]]
      if(isTruthy(dataList$stats)){
        s_l <- levels(dataList$stats$significance)
        cc <- c("All significant"="all", s_l)
        selectInput("select_cirNet_cond_pval_termini",
                     label="Select filteration criteria",
                     choices=cc,
                     selected=NULL)
      } else{ return() }
    } else{ return() }
  } else{ return() }
})

# Create filter condition selector render handle for ptm
output$select_cirNet_cond_pval_ptm <- renderUI({
  if(isTruthy(input$select_cirNet_dataLevels)){
    include_levels <- input$select_cirNet_dataLevels
    if("ptm" %in% include_levels){
      dataList <- variables$datasets[["ptm"]]
      if(isTruthy(dataList$stats)){
        s_l <- levels(dataList$stats$significance)
        cc <- c("All significant"="all", s_l)
        selectInput("select_cirNet_cond_pval_ptm",
                     label="Select filteration criteria",
                     choices=cc,
                     selected=NULL)
      } else{ return() }
    } else{ return() }
  } else{ return() }
})

# Trigger the script if combine_dataLevels button is clicked
observeEvent(input$combine_dataLevels, {
  # TODO: add checks and validations
  if(isTruthy(input$select_cirNet_dataLevels)){
    include_levels <- input$select_cirNet_dataLevels
    # Check if the passed data levels is less than 2
    if(length(include_levels) < 2 ){
      sendSweetAlert(
        session=session,
        title="Data Input Error",
        text="Select at least 2 data levels to continue!",
        type="error"
      )
      return()
    } else{
      # Get the list object for datasets
      dataset_lists <- variables$datasets
      # Check if datasets have statistics components to continue
      stat_check_vector <- c()
      for(i in include_levels){
        if(!isTruthy(dataset_lists[[i]]$stats)){
          stat_check_vector <- c(stat_check_vector, i)
        }
      }
      # If stat check vector is not empty send an error message
      if(length(stat_check_vector)>0){
        err_msg <- paste("The statistical data is required for",
                         stringr::str_c(stat_check_vector, collapse=", "),
                         "data levels!")
        sendSweetAlert(
          session=session,
          title="Missing Analysis Error",
          text=err_msg,
          type="error"
        )
        return()
      }

      # Create circular quant data for concatenated data
      data <- create_circular_quant_data(dataset_lists, include_levels)
      # Get the data to temp_data reactive
      variables$temp_data <- data

      # Output the data table
      output$show_cirNet_concatData <- shiny.preview.data(data,
                                                          pageLength=5,
                                                          selection="none")
      # Create unique name for current data for download
      fname_data <- paste0("CircularNetwork_quant_data_", Sys.Date(), ".csv")
      output$download_cirNet_concatData <- shiny.download.data(fname_data, data)

    }
  } else{ return() }

})

# Main bulk script for plotting the circular network plot
observeEvent(input$plot_circularNetwork, {
  # TODO: add checks and validations
  if(isTruthy(variables$temp_data)){
    df <- variables$temp_data
    if(isTruthy(input$select_cirNet_dataLevels)){
      include_levels <- input$select_cirNet_dataLevels
      # Get the list object for datasets
      dataset_lists <- variables$datasets
      # Initialize vectors to be used in the filter vectors
      filterOn <- c("protein"="log2fc",
                    "peptide"="log2fc",
                    "termini"="log2fc",
                    "ptm"="log2fc")
      filterCond <- c("protein"="none",
                      "peptide"="none",
                      "termini"="none",
                      "ptm"="none")
      # Based on the data levels assign filter conditions
      # Assign filter conditions for protein level
      if("protein" %in% include_levels){
        if(input$if_cirNet_filterProtein){
          pro_filterOn <- input$select_cirNet_filterOn_protein
          # If Select filtering output
          if(pro_filterOn=="log2fc"){
            if(isTruthy(input$select_cirNet_cond_logfc_protein)){
              pro_filterCond <- input$select_cirNet_cond_logfc_protein
            } else{ return() }
          }else if(pro_filterOn=="pvalue"){
            if(isTruthy(input$select_cirNet_cond_pval_protein)){
              pro_filterCond <- input$select_cirNet_cond_pval_protein
            } else{ return() }
          } else{ return() }
          # Save the filterOn and filterCond into protein values in the shared vectors
          filterOn["protein"] <- pro_filterOn
          filterCond["protein"] <- pro_filterCond
        }
      }
      # Assign filter conditions for peptide level
      if("peptide" %in% include_levels){
        if(input$if_cirNet_filterPeptide){
          pep_filterOn <- input$select_cirNet_filterOn_peptide
          # If Select filtering output
          if(pep_filterOn=="log2fc"){
            if(isTruthy(input$select_cirNet_cond_logfc_peptide)){
              pep_filterCond <- input$select_cirNet_cond_logfc_peptide
            } else{ return() }
          }else if(pep_filterOn=="pvalue"){
            if(isTruthy(input$select_cirNet_cond_pval_peptide)){
              pep_filterCond <- input$select_cirNet_cond_pval_peptide
            } else{ return() }
          } else{ return() }
          # Save the filterOn and filterCond into peptide values in the shared vectors
          filterOn["peptide"] <- pep_filterOn
          filterCond["peptide"] <- pep_filterCond
        }
      }
      # Assign filter conditions for termini level
      if("termini" %in% include_levels){
        if(input$if_cirNet_filterTermini){
          ter_filterOn <- input$select_cirNet_filterOn_termini
          # If Select filtering output
          if(ter_filterOn=="log2fc"){
            if(isTruthy(input$select_cirNet_cond_logfc_termini)){
              ter_filterCond <- input$select_cirNet_cond_logfc_termini
            } else{ return() }
          }else if(ter_filterOn=="pvalue"){
            if(isTruthy(input$select_cirNet_cond_pval_termini)){
              ter_filterCond <- input$select_cirNet_cond_pval_termini
            } else{ return() }
          } else{ return() }
          # Save the filterOn and filterCond into termini values in the shared vectors
          filterOn["termini"] <- ter_filterOn
          filterCond["termini"] <- ter_filterCond
        }
      }
      # Assign filter conditions for ptm level
      if("ptm" %in% include_levels){
        if(input$if_cirNet_filterPTM){
          ptm_filterOn <- input$select_cirNet_filterOn_ptm
          # If Select filtering output
          if(ptm_filterOn=="log2fc"){
            if(isTruthy(input$select_cirNet_cond_logfc_ptm)){
              ptm_filterCond <- input$select_cirNet_cond_logfc_ptm
            } else{ return() }
          }else if(ptm_filterOn=="pvalue"){
            if(isTruthy(input$select_cirNet_cond_pval_ptm)){
              ptm_filterCond <- input$select_cirNet_cond_pval_ptm
            } else{ return() }
          } else{ return() }
          # Save the filterOn and filterCond into ptm values in the shared vectors
          filterOn["ptm"] <- ptm_filterOn
          filterCond["ptm"] <- ptm_filterCond
        }
      }

      # Create connections data by applying the filterations
      connection_df <- create_connections_data(df,
                                               dataset_lists,
                                               include_levels,
                                               filterOn,
                                               filterCond,
                                               windowSize=10)

      # Create custom color map with selection
      color_map <- create_data_level_color_map(dataset_lists, include_levels)

      if(nrow(connection_df) == 0){
        sendSweetAlert(
          session=session,
          title="Empty Dataframe Error",
          text="After filtering no connection matches returned for plotting!",
          type="error"
        )
        return()
      }else{
        # Output the data table
        output$show_cirNet_combConnect <- shiny.preview.data(connection_df,
                                                            pageLength=5,
                                                            selection="multiple")
        # Create unique name for current data for download
        fname_data <- paste0("CircularNetwork_connections_data_", Sys.Date(), ".csv")
        output$download_cirNet_combConnect <- shiny.download.data(fname_data, connection_df)

        # Create columns for customizing the connection links to plot
        connection_df$color <- "#a8dadc50"
        connection_df$width <- 0.75
        # If user selected
        if(isTruthy(input$show_cirNet_combConnect_rows_selected)){
          color_rows <- input$show_cirNet_combConnect_rows_selected
          connection_df[color_rows, "color"] <- "#14213d"
          connection_df[color_rows, "width"] <- 1.25
        }

        output$show_circNet_plot <- renderPlot({
          # Plot the circular_network_plot
          res <- plot_circular_network_summary(df, connection_df, color_map)

          # Create file name for the specific plot when downloading
          pname <- paste0("Circular_Network_Summary_Plot_", Sys.Date(), ".pdf")
          # Download handler for the plot created
          output$download_circNet_plot <- shiny.download.plot(pname, res,
                                                              multi=F,
                                                              fig.width=14,
                                                              fig.height=10)

          # Return the plot result
          return(res)
        })
      }
    } else{ return() }
  }else{ return() }

})
