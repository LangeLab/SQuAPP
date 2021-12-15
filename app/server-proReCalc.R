# if protein re-calculation button is clicked
observeEvent(input$process_proCalc, {
  # Get the reactive values and UI elements to within function vars
  dataList <- variables$datasets$peptide
  calcMethod <- input$sumMethod
  # Use the peptide list as an input for the protein calculation function
  recal_protein <- proteinRecalculate(dataList, calcMethod)

  # Create a preview for the data
  output$proReCalc_preview <- shiny.preview.data(recal_protein,
                                                 colIgnore='Fasta.sequence',
                                                 row.names=TRUE)
  # Create a file_name for download
  fname <- paste0("reCalcProteinData_with_", calcMethod, "_", Sys.Date(), ".csv")

  # Download handler
  output$downloadReCalc <- shiny.download.data(fname, recal_protein, row.names=T)

  # Save the data into the report reactive value
  variables$reportVars$peptide$proteinCalc$data$quant <- recal_protein
  # Save the parameters for reporting
  variables$reportVars$peptide$proteinCalc$parameters <- list(
    "Calculation Method"=calcMethod
  )
  # Create the plot
  res <- compare_protein_recalc_split_violin_plot(dataList$quant, recal_protein)

  # Create download plot button
  pname <- paste0("reCalcProteinData_with_", calcMethod, "_", Sys.Date(), ".pdf")
  output$download_reCalcprotein_splitViolin_plot <- shiny.download.plot(pname,
                                                                        res,
                                                                        multi=F,
                                                                        fig.width=12,
                                                                        fig.height=4)
  # Save the resulting plot to the report reactive variables.
  variables$reportVars$peptide$proteinCalc$plot <- res
  # Render static split violin plot
  output$show_reCalcProtein_splitViolin <- renderPlot({
    req(res)
    return(res)
  })

  # # Render plotly plot
  # output$compareIntensity_plotViolin <- plotly::renderPlotly({
  #   plot.splitViolin(df1=variables$datasets$protein$quant,
  #                    df1_name="Original",
  #                    color1="#bc6c25",
  #                    df2=recal_protein,
  #                    df2_name=calcMethod,
  #                    color2="#283618"
  #                  )
  # })
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
    # Get the newly calculated data from the reactive value saved for report
    recal_protein <- variables$reportVars$peptide$proteinCalc$data$quant
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
    variables$reportVars$peptide$proteinCalc$data$annot <- annotate.data

  }else{return()}
})
