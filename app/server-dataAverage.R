# Create data selection for averaging the data
output$select_averaging_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_averaging_data",
               label="Select data level to average replicas:",
               choices=cc,
               selected=NULL)
})

# Average the replicas of average_replicas
observeEvent(input$average_replicas, {
  # Get the data level name from user selection
  data_name <- input$select_averaging_data
  # Get current data list
  dataList <- variables$datasets[[data_name]]

  # Dynamically changed box title for better representation
  output$avg_org_box_title <- renderText({
    paste("Original State of", str_to_title(data_name), "Data")
  })
  output$avg_chng_box_title <- renderText({
    paste("Averaged State of", str_to_title(data_name), "Data")
  })

  # Adding additional checks
  if(dataList$avrg){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Data have already been averaged!",
      type="warning"
    )
    return()
  }else{
    if(dataList$repl){
      # Save the replica contain variable
      variables$reportParam[[data_name]]$isRepl <- TRUE
      # Run the averaging function
      dataList_new <- average_data(dataList)

      # Create Violin Plot for Original Distribution
      res_original <- plotviolin(dataList, group_factor=NULL, custom_title="")
      # Save the original distribution plot to the data averaging report section
      variables$reportParam[[data_name]]$dataAverage$org_distPlot <- res_original
      # Render plot to the user
      output$show_original_dist_averaging <- renderPlot({
        req(res_original)
        return(res_original)
      })
      # Create violin plot for the averaged version
      res_averaged <- plotviolin(dataList_new, group_factor=NULL, custom_title="")
      # Save the averaged distribution plot to the data averaging report section
      variables$reportParam[[data_name]]$dataAverage$prc_distPlot <- res_averaged
      # Create a download link to the averaged
      output$show_averaged_dist_in_averaging <- renderPlot({
        req(res_averaged)
        return(res_averaged)
      })

      # Create a preview for original data
      output$original_data_preview_averaging <- shiny.preview.data(
        cbind(dataList$annot, dataList$quant), colIgnore='Fasta.sequence'
      )
      # Create a preview for the averaged data
      output$averaged_data_preview_averaging <- shiny.preview.data(
        cbind(dataList_new$annot, dataList_new$quant), colIgnore='Fasta.sequence'
      )
      # Create a file name for download
      fname <- paste0(
        "replicaAveraged_", dataList$name, "level_data_", Sys.Date(), ".csv"
      )
      # Pass to the download button
      output$downloadAveraged <- shiny.download.data(
        fname,
        cbind(dataList_new$annot, dataList_new$quant),
        colIgnore="Fasta.sequence"
      )
      # Save the processed data into reactive value to be used
      #  in record processed function if selected
      variables$temp_data <- dataList_new

      # Create report data-average tables and save them for report
      variables$reportParam[[data_name]]$dataAverage$org_table <- report.preview.data(
        dataList$quant, colIgnore="Fasta.sequence", rowN=3)
      variables$reportParam[[data_name]]$dataAverage$prc_table <- report.preview.data(
        dataList_new$quant, colIgnore="Fasta.sequence", rowN=3)
      # Update the isRun variable
      variables$reportParam[[data_name]]$dataAverage$isRun <- TRUE
    }else{
      sendSweetAlert(
        session=session,
        title="Warning",
        text="Data doesn't have replica!",
        type="warning"
      )
    }
  }
})

observeEvent(input$record_processed_averaged, {
  # If user select to keep the calculated values as the protein data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_averaged",
    title="Do you want to confirm?",
    text="Averaged version of the data will replace the original state!",
    type="question"
  )
})

observeEvent(input$confirm_record_averaged,{
  data_name <- input$select_averaging_data
  if(isTruthy(input$confirm_record_averaged)){
    # If temp_data is populated replace the variables in the reactive list
    if(isTruthy(variables$temp_data)){
      # Update isReplaced variable with TRUE
      variables$reportParam[[data_name]]$dataAverage$isReplaced <- TRUE
      # Save averaged list into a variable
      data_list <- variables$temp_data
      # Save the modified data list into its reactive list values
      variables$datasets[[data_name]] <- data_list
      # reset the temp_data variable
      variables$temp_data <- NULL
    }else{return()}
  }else{return()}
})
