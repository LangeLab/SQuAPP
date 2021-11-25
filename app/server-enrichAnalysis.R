# Create data selection for enrichment analysis
output$select_enrichment_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide",
            "termini", "ptm")[c(input$isExist_protein, input$isExist_peptide,
                                input$isExist_termini, input$isExist_ptm)]
  }
  selectInput("select_enrichment_data",
               label="Select data level for enrichment analysis:",
               choices=cc,
               selected=NULL)
})

# Render UI for group selection
output$set_group_value_enrichment_lolipop <- renderUI({
  # Get the current data list
  dataList <- variables$datasets[[input$select_enrichment_data]]
  # Check if the enrichment data is created
  if(isTruthy(dataList$enrich)){
    selectInput("set_group_value_enrichment_lolipop",
                label="Select source to subset in plot",
                choices=unique(dataList$enrich$source),
                multiple=FALSE,
                selected=NULL)
  }else{
    return()
  }
})

observeEvent(input$run_enrichment_analysis, {
  # TODO: Add more validations
  # Get the current data list
  dataList <- variables$datasets[[input$select_enrichment_data]]
  if(!isTruthy(dataList$stats)){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="For selected data, statistical test hasn't been done yet!",
      type="warning"
    )
    return()
  }else{
    # Run enrichment with gprofiler
    if(input$select_enrichment_method == "gprofiler"){
      enrich_data <- run_gprofiler(
        dataList,
        organism=input$select_enrichment_organism,
        run_multiple=input$ifMultiQuery,
        user_threshold=input$set_enrich_pval_threshold,
        correction_method=input$select_gprofiler_correction_method,
        custom_background=input$ifCustomBackground,
        sources=input$select_enrichment_data_sources
      )
    }
    # Plot the gprofiler's interactive summary plot
    output$show_enrichment_summary_plot <- renderPlotly({
      res <- gprofiler2::gostplot(enrich_data, capped = TRUE, interactive = TRUE)
      return(res)
    })
    # Get only result table
    enrich_data_res <- enrich_data$result
    # Plot enrichment individual plots
    output$show_enrichment_individual_plot <- renderPlot({
      # Allow interactive re-plotting
      if(input$update_enrichment_lolipop_plot){
        #Get subset group to plots
        group_var <- eventReactive(input$update_enrichment_lolipop_plot, {
          input$set_group_value_enrichment_lolipop
        })
        # Get p-value threshold
        pval_thr <- eventReactive(input$update_enrichment_lolipop_plot,{
          input$set_pvalue_cutoff
        })
        # Get decreasing or not information
        decrease_bool <- eventReactive(input$update_enrichment_lolipop_plot,{
          input$ifSortDecreasing
        })
        grp_var_name <- group_var()
        # Run the plotting function
        res <- enrichment_individual_plot(enrich_data_res,
                                          pval.thr=pval_thr(),
                                          group=grp_var_name,
                                          decreasing=decrease_bool())

      }else{
        # Run the plotting function
        res <- enrichment_individual_plot(enrich_data_res)
        grp_var_name <- "GO:BP"
      }
      # Create name for the plot
      pname <- paste0("Individual_Enrichment_Plot",
                      input$select_qualityCheck_data,
                      "_", grp_var_name, "_",
                      Sys.Date(), ".pdf")
      output$download_enrich_ind_plot <- shiny.download.plot(pname, res,
                                                             multi=F,
                                                             fig.width=8,
                                                             fig.height=9)

      # Return the plot
      return(res)
    })

    # Create a preview for enrichment data
    output$show_enrichment_result_table <- shiny.preview.data(enrich_data_res)
    # Create a file name for download
    fname_data <- paste0("enrichment_result_table_",
                          dataList$name,
                          "level_data_",
                          Sys.Date(),
                          ".csv")
    # Pass to the download button
    output$downloadEnrichResults <- shiny.download.data(fname_data, enrich_data_res)

    # Save the enrichment data to the data list
    dataList$enrich <- enrich_data_res

    # Save the update list to the reactive value
    variables$datasets[[input$select_enrichment_data]] <- dataList
  }

})
