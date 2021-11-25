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
  #TODO: Add req or validate statements (or sendSweetAlert)
  # Select the annotation part of the given annotation data
  annotData <- variables$datasets[[input$select_annot_data]]$annot
  modType <- variables$datasets[[input$select_annot_data]]$name
  # Expand the annotation
  df <- getSequenceWindow(annotData, input$expand_size, modType)

  # Create a preview for the data
  output$annotation_preview <- shiny.preview.data(df, colIgnore='Fasta.sequence')

  # Create a file_name for download
  fname <- paste0("expandedAnnotation_", modType, "_", Sys.Date(), ".csv")

  # Download handler
  output$downloadAnnotation <- shiny.download.data(fname, df)

  # Save over annot reactive value
  variables$datasets[[input$select_annot_data]]$annot <- df
})
