# Create data selection for protein domain plot
output$select_proteinDomain_dataLevels <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("peptide", "termini", "ptm")
  }else{
    cc <- c("peptide", "termini", "ptm")[c(input$isExist_peptide,
                                           input$isExist_termini,
                                           input$isExist_ptm)]
  }
  selectInput("select_proteinDomain_dataLevels",
               label="Select data levels to include in protein domain plot",
               choices=cc,
               selected=NULL,
               multiple=TRUE)
})

# Create data selection to determine which data level to be used
#  for the protein-selection table
output$select_proteinDomain_source4set <- renderUI({
  if(isTruthy(input$select_proteinDomain_dataLevels)){
    if(input$select_proteinDomain_method=="select"){
      if(input$example_data == "yes"){
        cc <- c("peptide", "termini", "ptm")
      }else{
        cc <- c("peptide", "termini", "ptm")[c(input$isExist_peptide,
                                               input$isExist_termini,
                                               input$isExist_ptm)]
      }
      #
      selectInput("select_proteinDomain_source4set",
                   label="Which data level's data to use for selecting protein?",
                   choices=cc,
                   selected=NULL)

    } else{ return() } } else{ return() }
})

# Create feature subsetting function based on statistical testing
output$select_proteinDomain_set <- renderUI({
  if(isTruthy(input$select_proteinDomain_source4set)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_proteinDomain_source4set]]
    # If selecting features method is from data
    if(input$select_proteinDomain_method == "select"){
      # Create feature subset key "all": giving all available data points
      cc <- c("all")
      # If data has statistical result table
      if(isTruthy(dataList$stats)){
        # Add statistical datasets
        cc <- c(cc, "all significant", levels(dataList$stats$significance))
      }
      #
      selectInput("select_proteinDomain_set",
                   label="Select feature subset you want to use",
                   choices=cc,
                   selected=NULL)

    } else{ return() } } else { return() }
})

# Create ui output to allow user to select variable from metadata for Ratio Calculation
output$select_proteinDomain_intCalc_group <- renderUI({
  if(input$select_proteinDomain_intCalc_method=="Ratio"){
    if(isTruthy(input$select_proteinDomain_dataLevels)){
      metadata <- variables$datasets[[(input$select_proteinDomain_dataLevels)[1]]]$meta
      id_col <- variables$datasets[[(input$select_proteinDomain_dataLevels)[1]]]$meta_id
      cc <- colnames(metadata)[!(colnames(metadata) %in% c("Replica",
                                                           id_col))]
      selectInput("select_proteinDomain_intCalc_group",
                     label="Select variable to get ratio values from",
                     choices=cc,
                     multiple=FALSE)
    } else{ return() }} else { return() }
})

# Create ui output to allow user to select values for ratio Calculation
output$select_proteinDomain_intCalc_values <- renderUI({
  if(input$select_proteinDomain_intCalc_method=="Ratio"){
    if(isTruthy(input$select_proteinDomain_dataLevels) &&
       isTruthy(input$select_proteinDomain_intCalc_group)){
       metadata <- variables$datasets[[(input$select_proteinDomain_dataLevels)[1]]]$meta
      selectizeInput("select_proteinDomain_intCalc_values",
                    label="Select groups for blocking (Only 2 unique group allowed!)",
                    choices=unique(metadata[, input$select_proteinDomain_intCalc_group]),
                    multiple=TRUE,
                    options = list(maxItems = 2))
    } else{ return() } } else{ return() }
})

# Button clicking event for showing the protein domain selection table
observeEvent(input$show_proteinDomain_setTable, {
  if(isTruthy(input$select_proteinDomain_source4set)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_proteinDomain_source4set]]
    if(isTruthy(input$select_proteinDomain_set)){
      rows2select <- prepare_subset_preview_data(dataList,
                                                 input$select_proteinDomain_set)
      # Create a data preview based on the rows2select
      if(isTruthy(dataList$stats)){
        data <- robust_cbind(dataList$annot, dataList$stats[rows2select, ])
      }else{
        data <- dataList$annot[rows2select, ]
      }
      # Get the data to temp_data reactive
      variables$temp_data <- data
      # Output the data table
      output$show_proteinDomain_selectTable <- shiny.preview.data(
        data,
        pageLength=5,
        colIgnore="Fasta.sequence",
        selection="single"
      )

    } else {return()}

  } else {return()}
})

# Main logic after create protein domain plot button is clicked
observeEvent(input$plot_proteinDomain, {
  ## Implement data setup level logical checks
  # Check if the proteinDomain_levels are valid
  if(isTruthy(input$select_proteinDomain_dataLevels) &&
     (length(input$select_proteinDomain_dataLevels)>0)){
    # Get the selected datasets
    dataset_lists <- variables$datasets[input$select_proteinDomain_dataLevels]
  }else{ return() }
  # Find the selected protein
  if(input$select_proteinDomain_method == "manual"){
    if(isTruthy(input$select_proteinDomain_protein)){
      selected_protein <- input$select_proteinDomain_protein
    }else{
      stop("Provide an accession number to continue!")
    }
  }else if(input$select_proteinDomain_method == "select"){
    if(isTruthy(input$show_proteinDomain_selectTable_rows_selected)){
      # Get the preview data to get rownames
      data <- variables$temp_data
      # Find the protein identifier from the selected row
      selected_protein <- data[input$show_proteinDomain_selectTable_rows_selected,
                               "Protein.identifier"]
    }else{
      stop("To select a protein select a row on the 'Protein Selection Table'")
    }
  }else{
    return()
  }
  ## Logical checks on the intensity calculation method related configuration
  if(isTruthy(input$select_proteinDomain_intCalc_method)){
    # Get the selected intensity method
    intensity_method <- input$select_proteinDomain_intCalc_method
    # If Ratio intensity method
    if(intensity_method == "Ratio"){
      if(isTruthy(input$select_proteinDomain_intCalc_group) &&
        (isTruthy(input$select_proteinDomain_intCalc_values))){
        group_variable <- input$select_proteinDomain_intCalc_group
        group_values <- input$select_proteinDomain_intCalc_values
      }else{
        stop("When selected ratio, provide group and values to continue!")
      }
    }else{
      group_variable <- NULL
      group_values <- NULL
    }
  }else {return()}

  # Create a domain compatible data with the current levels of data
  df <- create_protein_domain_data(selected_protein, dataset_lists)
  # Expand the create data with user-selected intensity calculation method
  df <- custom_protein_domain_intensities(df,
                                          intensity_method,
                                          group_variable,
                                          group_values)
  # Add column for the protein identifier for reference
  df$Protein.identifier <- selected_protein
  # Order columns for output
  df <- df %>% select(Protein.identifier , everything())

  # Run drawProteins to gather uniProt data on the selected_protein
  uniprot_data <- drawProteins::feature_to_dataframe(
    drawProteins::get_features(selected_protein)
  )
  uniprot_data$Protein.identifier <- selected_protein
  # Order columns for output
  uniprot_data <- uniprot_data %>% select(Protein.identifier , everything())

  # Create uniprot reference data output
  output$show_proDom_uniprotRefdata <- shiny.preview.data(uniprot_data)
  # Create unique name for uniprot reference data for download
  fname_uniprot <- paste0(selected_protein, "_uniprot_reference_data_",
                          Sys.Date(), ".csv")
  # Hook up the download button for uniprot reference data
  output$download_proDom_UniprotRefData <- shiny.download.data(fname_uniprot,
                                                               uniprot_data)

  # Create current data's protein domain output
  output$show_proDom_matchFeaturedata <- shiny.preview.data(df)
  # Create unique name for current data for download
  fname_data <- paste0(selected_protein, "_domain_data_", Sys.Date(), ".csv")
  # Hook up the download button for current data
  output$download_proDom_matchFeatureData <- shiny.download.data(fname_data, df)

  # Create the plot output function
  output$show_proteinDomain_plot <- renderPlot({
    # Plotting function
    res <- plot_protein_domain(df, uniprot_data, intensity_method)

    # Create file name for the specific plot when downloading
    pname <- paste0(selected_protein, "_domain_plot_", Sys.Date(), ".pdf")
    # Download handler for the plot created
    output$download_proteinDomain_plot <- shiny.download.plot(pname, res,
                                                              multi=F,
                                                              fig.width=14,
                                                              fig.height=8)

    # Return the plot result
    return(res)
  })

  variables$temp_data <- NULL
})
