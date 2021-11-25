# Create data selection for normalization of the data
output$select_normalization_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide", "termini", "ptm")[c(input$isExist_protein,
                                                      input$isExist_peptide,
                                                      input$isExist_termini,
                                                      input$isExist_ptm)]
  }
  selectInput("select_normalization_data",
               label="Select data level to apply the normalization:",
               choices=cc,
               selected=NULL)
})

# Create grouping factor selection ui from the metadata
output$select_normalize_group <- renderUI({
  metadata <- variables$datasets[[input$select_normalization_data]]$meta
  id_col <- variables$datasets[[input$select_normalization_data]]$meta_id
  cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",id_col))]
  selectInput("select_normalize_group",
                 label="Select group factor for the normalization",
                 choices=cc,
                 multiple=FALSE,
                 selected=NULL)
})

output$samples2compare_paired_plot_pre_norm <- renderUI({
  quant_data <- variables$datasets[[input$select_normalization_data]]$quant
  selectizeInput("samples2compare_paired_plot_pre_norm",
                 label="Select samples to plot in paired plot:",
                 choices=colnames(quant_data),
                 multiple=TRUE,
                 options = list(maxItems = 15))
})

output$samples2compare_paired_plot_post_norm <- renderUI({
  quant_data <- variables$datasets[[input$select_normalization_data]]$quant
  selectizeInput("samples2compare_paired_plot_post_norm",
                 label="Select samples to plot in paired plot:",
                 choices=colnames(quant_data),
                 multiple=TRUE,
                 options = list(maxItems = 15))
})

# Previews the data before normalization
observeEvent(input$preview_normalization_distribution, {
  # TODO: Add validation and checks here

  # Get the current data list
  dataList <- variables$datasets[[input$select_normalization_data]]
  if(!input$normalizeByGroupSwitch){
    group_factor <- NULL
  }else{
    group_factor <- input$select_normalize_group
  }
  # Output the violin plot for the original distributions
  output$show_viol_pre_norm <- renderPlot({
    res <- plotviolin(dataList, group_factor, custom_title="")
    return(res)
  })
  # Output the global and sample-wise distribution plot for original data
  output$show_dist_pre_norm <- renderPlot({
    res <- global_and_sample_distribution_plot(dataList, group_factor)
    return(res)
  })
  # Output sample correlation plot for original data
  output$show_pairplot_pre_norm <- renderPlot({
    if(input$recreate_plot_paired_plot_pre_norm){
      col2subset <- eventReactive(input$recreate_plot_paired_plot_pre_norm, {
        input$samples2compare_paired_plot_pre_norm
      })
      cor.method <- eventReactive(input$recreate_plot_paired_plot_pre_norm, {
        input$corr_method_paired_plot_pre_norm
      })
      res <- plot_pair_panels(dataList$quant,
                              col2subset=col2subset(),
                              cor.method=cor.method())
    }else{
      res <- plot_pair_panels(dataList$quant,
                              col2subset=NULL,
                              cor.method="pearson")
    }
    return(res)
  })
  # Create a preview for original data
  output$normalization_data_preview <- shiny.preview.data(cbind(dataList$annot,
                                                                dataList$quant),
                                                          colIgnore='Fasta.sequence')
  # Create basicStats to preview
  sumStat_df <- shiny.basicStats(dataList$quant)
  # Create preview for summary statistics created for filtered data
  output$normalization_data_sumStat <- shiny.preview.data(sumStat_df,
                                                          row.names=TRUE,
                                                          pageLength=16)
})

# If user clicked the submit normalization button
observeEvent(input$submit_for_normalization, {
  # TODO: Add validation and checks here

  # Get the selected data level
  dataList <- variables$datasets[[input$select_normalization_data]]
  if(dataList$norm){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Data has already been normalized",
      type="warning"
    )
    return()
  }else{
    if(!input$normalizeByGroupSwitch){
      group_factor <- NULL
    }else{
      group_factor <- input$select_normalize_group
    }
    # Get the normalization method
    normalize_method <- input$select_normalization_method
    # Normalize the data with configuration
    dataList_new <- normalize_data(dataList, normalize_method, group_factor)

    # Output the violin plot for the normalized distributions
    output$show_viol_post_norm <- renderPlot({
      res <- plotviolin(dataList_new, group_factor, custom_title="")
      return(res)
    })
    # Output the global and sample-wise distribution plot for original data
    output$show_dist_post_norm <- renderPlot({
      res <- global_and_sample_distribution_plot(dataList_new, group_factor)
      return(res)
    })
    # Output sample correlation plot for original data
    output$show_pairplot_post_norm <- renderPlot({
      if(input$recreate_plot_paired_plot_post_norm){
        col2subset <- eventReactive(input$recreate_plot_paired_plot_post_norm, {
          input$samples2compare_paired_plot_post_norm
        })
        cor.method <- eventReactive(input$recreate_plot_paired_plot_post_norm, {
          input$corr_method_paired_plot_post_norm
        })
        res <- plot_pair_panels(dataList_new$quant,
                                col2subset=col2subset(),
                                cor.method=cor.method())
      }else{
        res <- plot_pair_panels(dataList_new$quant,
                                col2subset=NULL,
                                cor.method="pearson")
      }
      return(res)
    })
    # Create a preview for original data
    output$normalized_data_preview <- shiny.preview.data(cbind(dataList_new$annot,
                                                               dataList_new$quant),
                                                         colIgnore='Fasta.sequence')
    # Create a file name for download
    fname_data <- paste0("imputed_",
                          dataList_new$name,
                          "level_data_",
                          Sys.Date(),
                          ".csv")
    # Pass to the download button
    output$downloadNormalized <- shiny.download.data(fname_data,
                                                     cbind(dataList_new$annot,
                                                           dataList_new$quant),
                                                     colIgnore="Fasta.sequence")

    # Create basicStats to preview
    sumStat_df <- shiny.basicStats(dataList_new$quant)
    # Create preview for summary statistics created for normalized data
    output$normalized_data_sumStat <- shiny.preview.data(sumStat_df,
                                                         row.names=TRUE,
                                                         pageLength=16)
    # Create file name for download
    fname_summary_table <- paste0("summaryStats_normalized_",
                                   dataList$name,
                                   "level_data_",
                                   Sys.Date(),
                                   ".csv")
    # Pass to the download button
    output$downloadNormalized_sumStat <- shiny.download.data(fname_summary_table,
                                                             sumStat_df,
                                                             row.names=TRUE)

    dataList_new$norm <- TRUE
    variables$temp_data <- dataList_new
  }
})

observeEvent(input$record_normalized_data, {
  # If user select to keep the calculated values as the protein data
  confirmSweetAlert(
    session=session,
    inputId="confirm_record_normalized",
    title="Do you want to confirm?",
    text="Normalized version of the data will replace the original state!",
    type="question"
  )
})

observeEvent(input$confirm_record_normalized,{
  if(isTruthy(input$confirm_record_normalized)){
    # If temp_data is populated replace the variables in the reactive list
    if(!is.null(variables$temp_data)){
      # Save the modified data list into its reactive list values
      variables$datasets[[input$select_normalization_data]] <- variables$temp_data
    }
    variables$temp_data <- NULL
  }else{return()}
})
