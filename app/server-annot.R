# Create selection for annotation section
output$select_annot_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("termini", "ptm")
  }else{
    cc <- c("termini", "ptm")[c(input$isExist_termini,
                                input$isExist_ptm)]
  }
  selectInput("select_annot_data",
               label="Please select the dataset to create sequence based annotation.",
               choices=cc,
               selected=NULL)
})

# If annotation processing is started through button
observeEvent(input$process_annot, {
  # Checks if the data level is selected!
  if(isTruthy(input$select_annot_data)){
    cur_level <- input$select_annot_data
  }else{
    sendSweetAlert(
      session=session,
      title="Load Error",
      text="Select a data level to expand it's annotation!",
      type="error"
    )
    return()
  }

  # Select the annotation part of the given annotation data
  annotData <- variables$datasets[[cur_level]]$annot
  modType <- variables$datasets[[cur_level]]$name
  e_size <- input$expand_size

  # Dynamically changed box title for better representation
  output$annot_box_title <- renderText({paste("Expanded Annotation -",
                                              str_to_title(cur_level))})

  # Expand the annotation
  df <- getSequenceWindow(annotData, e_size, modType)

  # Create a preview for the data
  output$annotation_preview <- shiny.preview.data(df, colIgnore='Fasta.sequence')

  # Create a file_name for download
  fname <- paste0("expandedAnnotation_", modType, "_", Sys.Date(), ".csv")

  # Download handler
  output$downloadAnnotation <- shiny.download.data(fname, df)

  # Save over annot reactive value
  variables$datasets[[cur_level]]$annot <- df

  # Save the parameters used to create
  variables$reportVars[[cur_level]]$dataAnnot$parameters <- list(
    "Modification Type"=modType,
    "Expansion Size"=e_size,
    "Window Size"=(e_size*2)+1
  )
  # Save the annotation data for report
  variables$reportVars[[cur_level]]$dataAnnot$data$annot <- df
})
