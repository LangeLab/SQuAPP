# if protein re-calculation button is clicked
observeEvent(input$process_proCalc, {
  #TODO: Add req or validate statements (or sendSweetAlert)

  # Use the peptide list as an input for the protein calculation function
  recal_protein <- proteinRecalculate(variables$datasets$peptide, input$sumMethod)

  # Create a preview for the data
  output$proReCalc_preview <- shiny.preview.data(recal_protein,
                                                 colIgnore='Fasta.sequence',
                                                 row.names=TRUE)
  # Create a file_name for download
  fname <- paste0("reCalcProteinData_with_", input$sumMethod, "_", Sys.Date(), ".csv")

  # Download handler
  output$downloadReCalc <- shiny.download.data(fname, recal_protein, row.names=T)

  # Save the data into reactive value
  variables$temp_data <- recal_protein
  # # Render plotly plot
  # output$compareIntensity_plotViolin <- plotly::renderPlotly({
  #   plot.splitViolin(df1=variables$datasets$protein$quant,
  #                    df1_name="Original",
  #                    color1="#bc6c25",
  #                    df2=recal_protein,
  #                    df2_name=input$sumMethod,
  #                    color2="#283618"
  #                  )
  # })
  # Render static split violin plot
  output$show_reCalcProtein_splitViolin <- renderPlot({
    res <- compare_protein_recalc_split_violin_plot(variables$datasets$protein$quant,
                                                    recal_protein)
    # Create download plot button
    pname <- paste0("reCalcProteinData_with_", input$sumMethod, "_", Sys.Date(), ".pdf")
    output$download_reCalcprotein_splitViolin_plot <- shiny.download.plot(pname,
                                                                          res,
                                                                          multi=F,
                                                                          fig.width=12,
                                                                          fig.height=4)
    return(res)
  })
  variables$temp_plot <- NULL
})

# If user wants to save the protein calculated
observeEvent(input$record_processed_proCalc, {
  # If user select to keep the calculated values as the protein data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_proReCalc",
    title="Do you want to confirm?",
    text="Re-calculated protein intensities will replace the original protein level data!",
    type="question"
  )
  if(isTruthy(input$confirm_record_proReCalc)){
    recal_protein <- variables$temp_data
    # Create expanded annotation for annot.data
    annotate.data <- expandAnnotation(proteinIdentifier=rownames(recal_protein),
                                      strippedSeq=NULL,
                                      modifiedSeq=NULL,
                                      uniprotDB=variables$reference,
                                      data_type="protein")
    # Set rownames to the annot data
    rownames(annotate.data) <- rownames(recal_protein)
    # Save the new data into reactive values
    variables$datasets$protein$quant <- recal_protein
    variables$datasets$protein$annot <- annotate.data
    # Reset the temporary variable
    variables$temp_data <- NULL
  }else{return()}
})
