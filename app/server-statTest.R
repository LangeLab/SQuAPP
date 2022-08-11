# Create data selection for statistical analysis
output$select_testing_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide",
            "termini", "ptm")[c(input$isExist_protein, input$isExist_peptide,
                                input$isExist_termini, input$isExist_ptm)]
  }
  selectInput("select_testing_data",
               label="Select data level for statistical testing:",
               choices=cc)
})
output$select_testing_variable <- renderUI({
  if(isTruthy(input$select_testing_data)){
    metadata <- variables$datasets[[input$select_testing_data]]$meta
    id_col <- variables$datasets[[input$select_testing_data]]$meta_id
    cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica", id_col))]
    selectInput("select_testing_variable",
                 label="Select metadata column for testing groups",
                 choices=cc,
                 multiple=FALSE)
  }else{return()}
})

output$select_testing_groups <- renderUI({
  if(isTruthy(input$select_testing_data)){
    metadata <- variables$datasets[[input$select_testing_data]]$meta
    test_var <- input$select_testing_variable
    cc <- unique(metadata[, test_var])
    selectInput("select_testing_groups",
                label="Select groups for testing",
                choices=cc,
                multiple=TRUE)
  }else{return()}
})

# output$select_blocking_variable <- renderUI({
#   data_name <- input$select_testing_data
#   metadata <- variables$datasets[[data_name]]$meta
#   id_col <- variables$datasets[[data_name]]$meta_id
#   testing_var <- input$select_testing_variable
#   cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
#                                                        id_col,
#                                                        testing_var))]
#   selectInput("select_blocking_variable",
#                  label="Select metadata column for blocking groups",
#                  choices=cc,
#                  multiple=FALSE)
# })
#
# output$select_blocking_groups <- renderUI({
#   data_name <- input$select_testing_data
#   if(isTruthy(input$select_blocking_variable)){
#     metadata <- variables$datasets[[data_name]]$meta
#     selectInput("select_blocking_groups",
#                 label="Select groups for blocking (Only 2 unique group allowed!)",
#                 choices=unique(metadata[, input$select_blocking_variable]),
#                 multiple=TRUE)
#   }else{return()}
# })

observeEvent(input$run_statistical_analysis, {
  # TODO: Add validation and checks here
  data_name <- input$select_testing_data
  # Get the current data list
  dataList <- variables$datasets[[data_name]]
  ## Gather the arguments from the UI
  # Get the testing method
  methodin <- input$select_testing_method
  # Get the group
  group_factor <- input$select_testing_variable
  # Get the test variables from the group
  test_variables <- input$select_testing_groups
  if((!isTruthy(test_variables)) || (length(test_variables) < 2)){
    sendSweetAlert(
      session=session,
      title="Warning",
      text="Make sure at least 2 groups passed for testing!",
      type="warning"
    )
    return()
  }

  # Get adjusted p-value method
  adj.method <- input$select_adjust_method
  # Get p-value threshold
  pval.thr <- input$set_pval.thr
  # Get log2fc threshold
  log2FC.thr <- input$set_logfc.thr

  # Blocking feature is disabled
  # # Get if blocking is allowed
  # flag.block <- input$testBlocksSwitch
  # # Get block factors
  # if(flag.block){blockfactor <- input$select_blocking_variable}else{blockfactor <- NULL}
  # # Get block levels
  # if(flag.block){blockLevels <- input$select_blocking_groups}else{blockLevels <- NULL}
  # # TODO: Add warning or error message if user puts 1 or 2 values
  flag.block <- FALSE
  blockfactor <- NULL
  blockLevels <- NULL

  # Get if weighting is allowed
  flag.weight <- input$testWeightingSwitch
  if((flag.weight)){
    NAweight <- input$selected_weigth
    if(!dataList$impt){
      sendSweetAlert(
        session=session,
        title="Data Error",
        text="Weigthing requires data imputation!",
        type="error"
      )
      return()
    }else{ NAind <- dataList$impute_index }
  }else{
    NAweight <- NULL
    NAind <- NULL
  }

  # # Create paramaters table and save to reportParams
  # variables$reportParam[[data_name]]$statTest$param <- data.frame(
  #   "parameters" = c(
  #     "testing method", "test variable", "test groups", "correction method",
  #     "adj-pval threshold", "fold-change threshold", "is weighted?", "weight value"),
  #   "values" = c(
  #     methodin, group_factor, paste0(test_variables, collapse=" vs "), adj.method, pval.thr, log2FC.thr,
  #     flag.weight, NAweight_str))

  # Run the statistical testing
dataList <- run_testing(dataList, methodin, group_factor, test_variables,
                        flag.block, blockfactor, blockLevels,
                        flag.weight, NAweight, NAind, adj.method,
                        pval.thr, log2FC.thr)

# Output the Volcano plot to visualize the results
output$show_volcano_plot <- renderPlot({
  if(input$update_volcano_plot){
    i_size <- eventReactive(input$update_volcano_plot, {
      input$set_volcano_point_size
    })
    res <- plot_volcano(dataList, pval.thr, log2FC.thr,
                        i_size=i_size())
  }else{
    res <- plot_volcano(dataList, pval.thr, log2FC.thr)
  }

  # Create download plot button
  pname <- paste0("VolcanoPlot_",
                  data_name,
                  "_",  Sys.Date(), ".pdf")
  # Download handler for the plot created
  output$download_volcano_plot <- shiny.download.plot(pname, res, multi=F,
                                                      fig.width=8, fig.height=4)
  return(res)
})

# Output the Volcano plot to visualize the results
output$show_ma_plot <- renderPlot({
  if(input$update_ma_plot){
    i_size <- eventReactive(input$update_ma_plot, {
      input$set_ma_point_size
    })
    res <- plot_ma(dataList,
                   i_size=i_size())
  }else{
    res <- plot_ma(dataList,)
  }

  # Create download plot button
  pname <- paste0("MAPlot",
                  data_name,
                  "_",  Sys.Date(), ".pdf")
  # Download handler for the plot created
  output$download_ma_plot <- shiny.download.plot(pname, res, multi=F,
                                                      fig.width=8, fig.height=4)
  return(res)
})

# Create stat data for data preview
stat_data <- robust_cbind(dataList$annot, dataList$stats)
# Subset only significant data
signf_data <- filter(stat_data, significance!="no significance")

# Create a preview for original data
output$show_significant_table <- shiny.preview.data(signf_data,
                                                    colIgnore='Fasta.sequence')

# Create a preview for original data
output$show_statistical_result_table <- shiny.preview.data(stat_data,
                                                           colIgnore='Fasta.sequence')
# Create a file name for download
fname_data <- paste0("testing_result_table_",
                      dataList$name,
                      "level_data_",
                      Sys.Date(),
                      ".csv")
# Pass to the download button
output$downloadStatResults <- shiny.download.data(fname_data,
                                                  robust_cbind(dataList$annot,
                                                               dataList$stats),
                                                  colIgnore="Fasta.sequence")
# Save the update list to the reactive value
variables$datasets[[data_name]] <- dataList

# update isRun for filtering
variables$reportParam[[data_name]]$statTest$isRun <- TRUE
})
