# When user selects example data, load, create report parameters,
#   and populate all other variables with example data
observeEvent(input$submitExampleData, {
  # Simple check to ensure if the example data is selected
  req((input$example_data)=='yes')
  ## Load Prepared Example Data
  load('../data/prepared/protein_data.RData')
  load('../data/prepared/peptide_data.RData')
  load('../data/prepared/termini_data.RData')
  load('../data/prepared/ptm_data.RData')

  # Metadata
  metadata <- protein.list$meta
  # Save to reactive variables
  variables$uploads$metadata <- metadata

  # Save the opened data to reactive variables
  variables$datasets$protein <- protein.list
  variables$datasets$peptide <- peptide.list
  variables$datasets$termini <- termini.list
  variables$datasets$ptm <- ptm.list

  # Save the uniprot reference data for example data
  variables$reference <- feather::read_feather(
    path=references_vector["Homo sapiens"]
  )

  ## Build a dataframe from the list for each feature level
  protein <- cbind(protein.list$annot, protein.list$quant)
  peptide <- cbind(peptide.list$annot, peptide.list$quant)
  termini <- cbind(termini.list$annot, termini.list$quant)
  ptm <- cbind(ptm.list$annot, ptm.list$quant)

  # Create datatable renders to show in the UI
  output$example_metaData_prepared <- shiny.preview.data(
    metadata, 
    colIgnore="Fasta.sequence"
  )
  output$example_proteinData_prepared <- shiny.preview.data(
    protein, 
    colIgnore="Fasta.sequence"
  )
  output$example_peptideData_prepared <- shiny.preview.data(
    peptide, 
    colIgnore="Fasta.sequence"
  )
  output$example_terminiData_prepared <- shiny.preview.data(
    termini, 
    colIgnore="Fasta.sequence"
  )
  output$example_ptmData_prepared <- shiny.preview.data(
    ptm, 
    colIgnore="Fasta.sequence"
  )

  ## Create and Save Report Variables 
  variables$reportParam$protein$dataSetup$isRun <- TRUE
  variables$reportParam$peptide$dataSetup$isRun <- TRUE
  variables$reportParam$termini$dataSetup$isRun <- TRUE
  variables$reportParam$ptm$dataSetup$isRun <- TRUE
  # Create report preview tables and save them in reportParam-level-dataSetup variables
  variables$reportParam$shared$reference$table <- report.preview.data(
    variables$reference, 
    colIgnore=c("Fasta.sequence", "Gene.name"), 
    rowN=3
  )
  variables$reportParam$shared$metadata$table <- report.preview.data(
    metadata, 
    colIgnore="Fasta.sequence", 
    rowN=3
  )
  variables$reportParam$protein$dataSetup$table <- report.preview.data(
    protein, 
    colIgnore="Fasta.sequence", 
    rowN=3
  )
  variables$reportParam$peptide$dataSetup$table <- report.preview.data(
    peptide, 
    colIgnore="Fasta.sequence", 
    rowN=3
  )
  variables$reportParam$termini$dataSetup$table <- report.preview.data(
    termini, 
    colIgnore="Fasta.sequence", 
    rowN=3
  )
  variables$reportParam$ptm$dataSetup$table <- report.preview.data(
    ptm, 
    colIgnore="Fasta.sequence", 
    rowN=3
  )
  # Update the param variables (to be used in the report)
  # TODO: Find a better way to do this (a function or static json to pass)
  variables$reportParam$shared$reference$param <- data.frame(
    "parameters" = c(
      "organism", 
      "source", 
      "isCustom", 
      "date"
    ),
    "values" = c(
      "Homo Sapiens",
      "Reviewed (Swiss-Prot) + Unreviewed (TrEMBL)",
      "non-customized",
      "2022-08-07"
    )
  )
  variables$reportParam$shared$metadata$param <- data.frame(
    "parameters" = c(
      "file name",
      "file format", 
      "id column", 
      "contain replica?", 
      "unique column"
    ),
    "values" = c(
      "meta_data.csv", 
      "comma-separated", 
      "ID", 
      "Yes", 
      "SampleName"
    )
  )
  variables$reportParam$protein$dataSetup$param <- data.frame(
    "parameters" = c(
      "file name",
      "file format", 
      "id column", 
      "contain replica?"
    ),
    "values" = c(
      "protein_data.csv", 
      "comma-separated", 
      "PG.ProteinAccessions", 
      "Yes"
    )
  )
  variables$reportParam$peptide$dataSetup$param <- data.frame(
    "parameters" = c(
      "file name", 
      "file format", 
      "id column",
      "protein id column", 
      "stripped seq column",
      "contain replica?"
    ),
    "values" = c(
      "peptide_data.csv", 
      "comma-separated", 
      "PEP.StrippedSequence",
      "PG.ProteinAccessions",
      "PEP.StrippedSequence", 
      "Yes"
    )
  )
  variables$reportParam$termini$dataSetup$param <- data.frame(
    "parameters" = c(
      "file name",
      "file format", 
      "Termini Type", 
      "id column",
      "protein id column", 
      "stripped seq column",
      "modified seq column", 
      "contain replica?"
    ),
    "values" = c(
      "termini_data_cleaned.csv",
      "comma-separated", 
      "N-Term",
      "EG.PrecursorId",
      "PG.ProteinAccessions", 
      "PEP.StrippedSequence",
      "EG.PrecursorId", 
      "Yes"
    )
  )
  variables$reportParam$ptm$dataSetup$param <- data.frame(
    "parameters" = c(
      "file name", 
      "file format", 
      "PTM Type", 
      "id column",
      "protein id column", 
      "stripped seq column",
      "modified seq column", 
      "contain replica?"
    ),
    "values" = c(
      "peptide_data.csv", 
      "comma-separated", 
      "Phosphorylation",
      "PTM_collapse_key", 
      "PG.ProteinGroups", 
      "PEP.StrippedSequence",
      "PTM_group", 
      "No"
    )
  )
})

# Upload a custom uniprot reference proteome by user
observeEvent(input$uploadReference, {
  # Save the uniprot reference data to main list
  variables$reference <- makeUniProtData(
    input$uploadReference$datapath
  )
  # TODO: Give more informative error messages
  if (is.numeric(variables$reference)) {
    sendSweetAlert(
      session=session,
      title="Upload Error",
      text="The uploaded file is not a valid UniProt reference proteome",
      type="error"
    )
    return()
  # If no error codes are returned continue with saving the reference
  }else{
    # Update the report list with created reference table
    variables$reportParam$shared$reference$table <- report.preview.data(
      variables$reference, 
      colIgnore=c("Fasta.sequence", "Gene.name"), 
      rowN=3
    )
    # TODO: Add param variables to the report for custom reference 
  }
})

# Load the references based on user's selection
observeEvent(input$load_reference, {
  # Get user provided reference or references
  refs <- input$select_reference
  # Check if user selected reference before submittion for load
  if(is.null(input$select_reference)){
    sendSweetAlert(
      session=session,
      title="Load Error",
      text="Select at least one reference organisms from the list",
      type="error"
    )
    return()
  }else{
    # If more than 1 reference is selected
    if(length(refs) > 1){
      # Loop through the given references
      dfs <- data.frame()
      orgs = c()
      for(i in refs){
        # Opens the current data
        df <- feather::read_feather(references_vector[i])
        # Merge the data to combined data
        dfs <- rbind(dfs, df)
      }
    }else{
      dfs <- feather::read_feather(references_vector[refs])
    }
    if(isTruthy(dfs) && nrow(dfs) > 0){
      # TODO: Replace this with better button like sytle for the message
      output$reference_loaded <- renderText({"Reference Uploaded!"})
    }
    # Save the uniprot reference data
    variables$reference <- dfs
    # Update the report list with created reference table
    variables$reportParam$shared$reference$table <- report.preview.data(
      dfs, 
      colIgnore=c("Fasta.sequence", "Gene.name"), 
      rowN=3
    )
    # Update the param variables
    variables$reportParam$shared$reference$param <- data.frame(
      "parameters" = c(
        "organism", 
        "source", 
        "isCustom", 
        "date"
      ),
      "values" = c(
        paste(refs, collapse=" + "),
        "Reviewed (Swiss-Prot) + Unreviewed (TrEMBL)",
        "non-customized",
        "2022-08-07"
      )
    )
  }
})

# Metadata Preview - Opens the data and previews the opened data
observeEvent(input$show_metadata_preview,{
  # Check if the logic is valid for preview
  validate(
    need(
      input$uploadMetadata,
      message="Upload file to preview"
    ),
    need(
      input$metadata_file_type,
      message="Select how file upload is separated"
    )
  )
  # Opens the metadata
  df <- openData(
    input$uploadMetadata$datapath, 
    file_sep=input$metadata_file_type
  )
  # Create an error message if the opened data is not a data.frame
  # TODO: Give more informative error messages
  if (length(df)==1 & is.numeric(df)) {
    sendSweetAlert(
      session=session,
      title="Upload Error",
      text="The uploaded file is not a valid metadata file, 
      please check the file and select the correct file type",
      type="error"
    )
    return()
  }
  # Create dataTableOutput from the opened data
  output$metaData_preview <- shiny.preview.data(
    df, 
    colIgnore=NULL
  )
  # Create drop-down input selection to get sampleNames
  output$metadata_sampleName_col <- renderUI({
    selectizeInput(
      "metadata_sampleName_col",
      "Select sample name column",
      choices=colnames(df) 
    )
  })
  # Create drop-down input selection if metadata contains replica samples
  output$metadata_uniqueSample_col <- renderUI({
    req(input$metadata_whether_replica)
    selectizeInput(
      "metadata_uniqueSample_col",
      "Select unique sample name column",
      choices=colnames(df) 
    )
  })
  # Create drop-down to select replica column
  output$metadata_replica_col <- renderUI({
    selectizeInput(
      "metadata_replica_col",
      "Select a column describing replicate info (Rep1, Rep2 or 1, 2)",
      choices=colnames(df) 
    )
  })

  # Save the opened metadata into reactive variable
  variables$uploads$metadata <- df
})

# Metadata Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_metadata,{
  # Check if the logic is valid for processing
  if (is.null(variables$uploads$metadata)) {
    sendSweetAlert(
      session=session,
      title="Metadata Variable Error",
      text="Error occured in opening metadata!",
      type="error"
    )
    return()
  }
  # Run the clean metadata to be prepared for the data
  df <- cleanMetadata(
    meta_data = variables$uploads$metadata, 
    meta_id_col = input$metadata_sampleName_col, 
    is_replicate = input$metadata_whether_replica, 
    meta_unique_col = input$metadata_uniqueSample_col,
    NA_replace_st="Unknown"
  )
  # if an error happend at cleanMetadata
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: ID column has duplicate values
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Metadata Variable Error",
        text="The selected ID column has duplicate values! 
        (ID column represents sample names with replicate indicators,
        this column should match to samples 
        names in quantitative data with replicates)",
        type="error"
      )
      return()
    }else if (df == 1){
      # Error Code 1: ID column has NA values
      sendSweetAlert(
        session=session,
        title="Metadata Variable Error",
        text="The selected ID column has NA values!",
        type="error"
      )
      return()
    }else if (df == 3) {
      # Error Code 3: Unique column and ID column is the same
      sendSweetAlert(
        session=session,
        title="Metadata Variable Error",
        text="The selected Unique ID column and ID column is the same!",
        type="error"
      )
      return()
    }else if (df == 4) {
      # Error Code 4: Unique ID column has NA values
      sendSweetAlert(
        session=session,
        title="Metadata Variable Error",
        text="The selected Unique ID column has NA values!",
        type="error"
      )
      return()
    }
    else{
      sendSweetAlert(
        session=session,
        title="Unexpected Error",
        text="An unexpected error occured while processing metadata! 
        Please contact the developer through GitHub or email.",
        type="error"
      )
      return()
    }
  }
  # Create dataTableOutput from the opened data
  output$metaData_prepared <- shiny.preview.data(
    df, 
    colIgnore=NULL
  )
  # Save the prepared metadata alongside with user provided parameters into a list
  variables$datasets$metadata <- list(
    name="metadata",
    isRep=input$metadata_whether_replica,
    idCol=input$metadata_sampleName_col,
    uniqCol=input$metadata_uniqueSample_col,
    replCol=input$metadata_replica_col,
    data=df
  )
  # Create unique file name
  fname <- paste0("prepared_metadata_", Sys.Date(), ".csv")
  # Download handler
  output$downloadMetadataPrepared <- shiny.download.data(fname, df)
})

# Protein Data Preview - Opens the data and previews it
observeEvent(input$show_protein_preview,{
  # Validate before preview
  if (is.null(input$uploadProteinData)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please upload a protein data to preview!",
      type="error"
    )
    return()
  }
  if (is.null(input$protein_file_type)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select how the protein data file is separated!",
      type="error"
    )
    return()
  }
  if (is.null(variables$datasets$metadata)){
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please process metadata before processing protein data!",
      type="error"
    )
    return()
  }
  # Opens the data
  df <- openData(
    input$uploadProteinData$datapath, 
    file_sep=input$protein_file_type
  )
  # If df is numeric, then an error occured - only error 0
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: ID column has duplicate values
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Upload Error",
        text="The uploaded file is not a valid file with 
        given path and file extension! Please ensure the 
        file path and the correct file type is selected.",
        type="error"
      )
      return()
    }else{
      sendSweetAlert(
        session=session,
        title="Unexpected Error",
        text="An unexpected error occured while opening protein data! 
        Please contact the developer through GitHub or email.",
        type="error"
      )
      return()
    }
  }

  meta_list <- variables$datasets$metadata
  if (
    length(intersect(names(df), meta_list$data[, meta_list$idCol])) == 0
  ){
    if(!is.null(meta_list$uniqCol)){
      if (
        length(intersect(names(df), meta_list$data[, meta_list$uniqCol])) == 0
      ){
        sendSweetAlert(
          session=session,
          title="Protein Data Error",
          text="No sample name overlap between metadata and data!",
          type="error"
        )
        return() 
      }else{
        sampleNames <- meta_list$data[, meta_list$uniqCol]
      }
    }else{
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="No sample name overlap between metadata and data!",
        type="error"
      )
      return()
    }
  }else{
    sampleNames <- variables$datasets$metadata$data[
        , 
        variables$datasets$metadata$idCol
    ]
  } 

  # Find the info columns, columnNames that are not in sampleNames
  infoCols <- names(df)[!names(df) %in% sampleNames]
  # Create a dataTableOutput to preview opened data
  output$proteinData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$protein_identifier_col <- renderUI({
    selectizeInput(
      "protein_identifier_col",
      "Select identifier column",
      choices=infoCols
    )
  })
  # Save the opened protein data into reactive variable
  variables$uploads$protein <- df
})

# Processing Protein Data - Prepares the protein data for analysis
observeEvent(input$process_protein_data, {
  # Validate before processing
  if (is.null(input$protein_identifier_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select an identifier column!",
      type="error"
    )
    return()
  }
  # Check if the variables$reference is NULL
  if (is.null(variables$reference)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Protein processing requires reference database! 
      Please select a reference fasta file or 
      upload your own before continuing",
      type="error"
    )
    return()
  }
  
  # Prepare the protein data with cleaning and annotation
  df <- prepareInputData(
    data=variables$uploads$protein,
    id_col=input$protein_identifier_col,
    meta_list = variables$datasets$metadata,
    data_type="protein",
    uniprotDB=variables$reference,
    contains_rep=input$protein_whether_replica,
    pro_col=NULL,
    strSeq_col=NULL,
    modSeq_col=NULL
  )

  # If df is numeric, means an error occured in prepareInputData
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: Unexpected Error at Protein Data Processing
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="An unexpected error occured while processing protein data! 
        Data passed from preview is not a dataframe or no values are passed",
        type="error"
      )
      return()
    }
    # Error Code 1: Missing annotation column(s)
    else if (df == 1) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="The selected identifier column is not in the data!",
        type="error"
      )
      return()
    }
    # Error Code 2: only annotation columns are passed
    else if (df == 2) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="No quantitative columns are available!",
        type="error"
      )
      return()
    }
    # Error Code 3: no overlap between data and metadata
    else if (df == 3) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="There are no overlapping samples between 
        the metadata and the data! Ensure the metadata's 
        selected identifier column has the name of the 
        quantitative data column names.",
        type="error"
      )
      return()
    }
    # Error Code 4: Metadata has more samples than data
    else if (df == 4) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="Some samples from metadata are not in the data! 
        Make sure the metadata fully matches the data.",
        type="error"
      )
      return()
    }
    # Error Code 5: All features identifiers are missing
    else if (df == 5) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="Proteins identifiers are NA! 
        [If this is an unexpected error, report by GitHub or email]",
        type="error"
      )
      return()
    }
    # Error Code 6: Error at the explode data step
    else if (df == 6) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="An error occured while exploding the data!",
        type="error"
      )
      return()
    }
    # Error Code 7: Data conversion to numeric type failed
    else if (df == 7) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="An error occured while converting quantitative 
        data columns to numeric type! Please ensure the
        contents of the quantitative columns don't contain unique strings.",
        type="error"
      )
      return()
    }
    # Error Code 8: No quantitative data is left after filtering
    else if (df == 8) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="No quantitative data is left after filtering!",
        type="error"
      )
      return()
    }
    # Error Code 9: Error at the expand annotation step
    else if (df == 9) {
      sendSweetAlert(
        session=session,
        title="Protein Data Error",
        text="An error occured while expanding the annotation!",
        type="error"
      )
      return()
    }
  }
  # Create dataTableOutput from the opened data
  output$proteinData_prepared <- shiny.preview.data(
    cbind(
      df$annot, 
      df$quant
    ), 
    colIgnore='Fasta.sequence'
  )
  # Save the prepared protein data into reactive variable
  variables$datasets$protein <- df
  # Create data download handler
  output$downloadProteinPrepared <- shiny.download.data(
    fname = paste0(
      "prepared_proteinData_", 
      Sys.Date(), 
      ".csv"
    ), 
    data = cbind(
      df$annot, 
      df$quant
    )
  )
})

# Peptide Data Preview - Opens the data and previews it
observeEvent(input$show_peptide_preview,{
  # Validate before preview
  if (is.null(input$uploadPeptideData)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please upload a peptide data to preview!",
      type="error"
    )
    return()
  }
  if (is.null(input$peptide_file_type)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select how the peptide data file is separated!",
      type="error"
    )
    return()
  }
  if (is.null(variables$datasets$metadata)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please process metadata before processing peptide data!",
      type="error"
    )
    return()
  }
  # Opens the data
  df <- openData(
    input$uploadPeptideData$datapath, 
    file_sep=input$peptide_file_type
  )
  # If df is numeric, then an error occured - only error 0
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: 
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Upload Error",
        text="The uploaded file is not a valid file with 
        given path and file extension! Please ensure the 
        file path and the correct file type is selected.",
        type="error"
      )
      return()
    }else{
      sendSweetAlert(
        session=session,
        title="Unexpected Error",
        text="An unexpected error occured while opening peptide data! 
        Please contact the developer through GitHub or email.",
        type="error"
      )
      return()
    }
  }

  meta_list <- variables$datasets$metadata
  if (
    length(intersect(names(df), meta_list$data[, meta_list$idCol])) == 0
  ){
    if(!is.null(meta_list$uniqCol)){
      if (
        length(intersect(names(df), meta_list$data[, meta_list$uniqCol])) == 0
      ){
        sendSweetAlert(
          session=session,
          title="Peptide Data Error",
          text="No sample name overlap between metadata and data!",
          type="error"
        )
        return() 
      }else{
        sampleNames <- meta_list$data[, meta_list$uniqCol]
      }
    }else{
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="No sample name overlap between metadata and data!",
        type="error"
      )
      return()
    }
  }else{
    sampleNames <- variables$datasets$metadata$data[
        , 
        variables$datasets$metadata$idCol
    ]
  } 

  # Find the info columns, columnNames that are not in sampleNames
  infoCols <- names(df)[!names(df) %in% sampleNames]
  # Create a dataTableOutput to preview opened data
  output$peptideData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$peptide_identifier_col <- renderUI({
    selectizeInput(
      "peptide_identifier_col",
      "Select identifier column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select proteinAcc column
  output$peptide_proteinAcc_col <- renderUI({
    selectizeInput(
      "peptide_proteinAcc_col",
      "Select protein id column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select proteinAcc column
  output$peptide_strippedSeq_col <- renderUI({
    selectizeInput(
      "peptide_strippedSeq_col",
      "Select stripped sequence column",
      choices=infoCols
    )
  })
  # Save the opened protein data into reactive variable
  variables$uploads$peptide <- df
})

# Process Peptide Data - Processes the peptide data for analysis
observeEvent(input$process_peptide_data,{
  # Validate before processing
  if (is.null(input$peptide_identifier_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select an identifier column!",
      type="error"
    )
    return()
  }
  if (is.null(input$peptide_proteinAcc_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a protein id column!",
      type="error"
    )
    return()
  }
  if (is.null(input$peptide_strippedSeq_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a stripped sequence column!",
      type="error"
    )
    return()
  }
  # Check if the variables$reference is NULL
  if (is.null(variables$reference)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Peptide processing requires reference database! 
      Please select a reference fasta file or 
      upload your own before continuing",
      type="error"
    )
    return()
  }
  # Prepare the peptide data with cleaning and annotation
  df <- prepareInputData(
    data=variables$uploads$peptide,
    id_col=input$peptide_identifier_col,
    meta_list = variables$datasets$metadata,
    data_type="peptide",
    uniprotDB=variables$reference,
    contains_rep=input$peptide_whether_replica,
    pro_col=input$peptide_proteinAcc_col,
    strSeq_col=input$peptide_strippedSeq_col,
    modSeq_col=NULL
  )

  # If df is numeric, means an error occured in prepareInputData
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: Unexpected Error at Peptide Data Processing
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="An unexpected error occured while processing peptide data! 
        Data passed from preview is not a dataframe or no values are passed",
        type="error"
      )
      return()
    }
    # Error Code 1: Missing annotation column(s)
    else if (df == 1) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="The selected identifier column is not in the data!",
        type="error"
      )
      return()
    }
    # Error Code 2: only annotation columns are passed
    else if (df == 2) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="No quantitative columns are available!",
        type="error"
      )
      return()
    }
    # Error Code 3: no overlap between data and metadata
    else if (df == 3) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="There are no overlapping samples between 
        the metadata and the data! Ensure the metadata's 
        selected identifier column has the name of the 
        quantitative data column names.",
        type="error"
      )
      return()
    }
    # Error Code 4: Metadata has more samples than data
    else if (df == 4) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="Some samples from metadata are not in the data! 
        Make sure the metadata fully matches the data.",
        type="error"
      )
      return()
    }
    # Error Code 5: All features identifiers are missing
    else if (df == 5) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="Proteins identifiers are NA! 
        [If this is an unexpected error, report by GitHub or email]",
        type="error"
      )
      return()
    }
    # Error Code 6: Error at the explode data step
    else if (df == 6) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="An error occured while exploding the data!",
        type="error"
      )
      return()
    }
    # Error Code 7: Data conversion to numeric type failed
    else if (df == 7) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="An error occured while converting quantitative 
        data columns to numeric type! Please ensure the
        contents of the quantitative columns don't contain unique strings.",
        type="error"
      )
      return()
    }
    # Error Code 8: No quantitative data is left after filtering
    else if (df == 8) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="No quantitative data is left after filtering!",
        type="error"
      )
      return()
    }
    # Error Code 9: Error at the expand annotation step
    else if (df == 9) {
      sendSweetAlert(
        session=session,
        title="Peptide Data Error",
        text="An error occured while expanding the annotation!",
        type="error"
      )
      return()
    }
  }

  # Create dataTableOutput from the opened data
  output$peptideData_prepared <- shiny.preview.data(
    cbind(
      df$annot, 
      df$quant
    ), 
    colIgnore='Fasta.sequence'
  )
  # Save the prepared protein data into reactive variable
  variables$datasets$peptide <- df
  # Download handler
  output$downloadPeptidePrepared <- shiny.download.data(
    fname = paste0(
      "prepared_peptideData_", 
      Sys.Date(), 
      ".csv"
    ), 
    data = cbind(
      df$annot, 
      df$quant
    )
  )
})

# Termini Data Preview - Opens the data and previews it
observeEvent(input$show_termini_preview,{
  # Validate before preview
  if (is.null(input$uploadTerminiData)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please upload a termini data to preview!",
      type="error"
    )
    return()
  }
  if (is.null(input$termini_file_type)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select how the peptide data file is separated!",
      type="error"
    )
    return()
  }
  if (is.null(variables$datasets$metadata)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please process metadata before processing peptide data!",
      type="error"
    )
    return()
  }
  # Opens the data
  df <- openData(
    input$uploadTerminiData$datapath, 
    file_sep=input$termini_file_type
  )
  # If df is numeric, then an error occured - only error 0
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: 
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Upload Error",
        text="The uploaded file is not a valid file with 
        given path and file extension! Please ensure the 
        file path and the correct file type is selected.",
        type="error"
      )
      return()
    }else{
      sendSweetAlert(
        session=session,
        title="Unexpected Error",
        text="An unexpected error occured while opening termini data! 
        Please contact the developer through GitHub or email.",
        type="error"
      )
      return()
    }
  }  

  meta_list <- variables$datasets$metadata
  if (
    length(intersect(names(df), meta_list$data[, meta_list$idCol])) == 0
  ){
    if(!is.null(meta_list$uniqCol)){
      if (
        length(intersect(names(df), meta_list$data[, meta_list$uniqCol])) == 0
      ){
        sendSweetAlert(
          session=session,
          title="Termini Data Error",
          text="No sample name overlap between metadata and data!",
          type="error"
        )
        return() 
      }else{
        sampleNames <- meta_list$data[, meta_list$uniqCol]
      }
    }else{
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="No sample name overlap between metadata and data!",
        type="error"
      )
      return()
    }
  }else{
    sampleNames <- variables$datasets$metadata$data[
        , 
        variables$datasets$metadata$idCol
    ]
  }  

  # Find the info columns, columnNames that are not in sampleNames
  infoCols <- names(df)[!names(df) %in% sampleNames]
  # Create a dataTableOutput to preview opened data
  output$terminiData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$termini_identifier_col <- renderUI({
    selectizeInput(
      "termini_identifier_col",
      "Select identifier column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select proteinAcc column
  output$termini_proteinAcc_col <- renderUI({
    selectizeInput(
      "termini_proteinAcc_col",
      "Select protein id column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select strippedSequence column
  output$termini_strippedSeq_col <- renderUI({
    selectizeInput(
      "termini_strippedSeq_col",
      "Select stripped sequence column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select modified sequence column
  output$termini_modifiedSeq_col <- renderUI({
    selectizeInput(
      "termini_modifiedSeq_col",
      "Select modified sequence column",
      choices=infoCols
    )
  })
  # Save the opened termini data into reactive variable
  variables$uploads$termini <- df
})

# Process Termini Data - Processes the termini data for analysis
observeEvent(input$process_termini_data,{
  # Validate before processing
  if (is.null(input$termini_identifier_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select an identifier column!",
      type="error"
    )
    return()
  }
  if (is.null(input$termini_proteinAcc_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a protein id column!",
      type="error"
    )
    return()
  }
  if (is.null(input$termini_strippedSeq_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a stripped sequence column!",
      type="error"
    )
    return()
  }
  if (is.null(input$termini_modifiedSeq_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a modified sequence column!",
      type="error"
    )
    return()
  }
  # Check if the variables$reference is NULL
  if (is.null(variables$reference)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Termini processing requires reference database! 
      Please select a reference fasta file or 
      upload your own before continuing",
      type="error"
    )
    return()
  }
  # Prepare the termini data with cleaning and annotation
  df <- prepareInputData(
    data=variables$uploads$termini,
    id_col=input$termini_identifier_col,
    meta_list = variables$datasets$metadata,
    data_type="termini",
    uniprotDB=variables$reference,
    contains_rep=input$termini_whether_replica,
    pro_col=input$termini_proteinAcc_col,
    strSeq_col=input$termini_strippedSeq_col,
    modSeq_col=input$termini_modifiedSeq_col,
    modifType=input$termini_mod_type
  )

  # If df is numeric, means an error occured in prepareInputData
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: Unexpected Error at Termini Data Processing
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="An unexpected error occured while processing termini data! 
        Data passed from preview is not a dataframe or no values are passed",
        type="error"
      )
      return()
    }
    # Error Code 1: Missing annotation column(s)
    else if (df == 1) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="The selected identifier column is not in the data!",
        type="error"
      )
      return()
    }
    # Error Code 2: only annotation columns are passed
    else if (df == 2) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="No quantitative columns are available!",
        type="error"
      )
      return()
    }
    # Error Code 3: no overlap between data and metadata
    else if (df == 3) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="There are no overlapping samples between 
        the metadata and the data! Ensure the metadata's 
        selected identifier column has the name of the 
        quantitative data column names.",
        type="error"
      )
      return()
    }
    # Error Code 4: Metadata has more samples than data
    else if (df == 4) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="Some samples from metadata are not in the data! 
        Make sure the metadata fully matches the data.",
        type="error"
      )
      return()
    }
    # Error Code 5: All features identifiers are missing
    else if (df == 5) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="Proteins identifiers are NA! 
        [If this is an unexpected error, report by GitHub or email]",
        type="error"
      )
      return()
    }
    # Error Code 6: Error at the explode data step
    else if (df == 6) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="An error occured while exploding the data!",
        type="error"
      )
      return()
    }
    # Error Code 7: Data conversion to numeric type failed
    else if (df == 7) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="An error occured while converting quantitative 
        data columns to numeric type! Please ensure the
        contents of the quantitative columns don't contain unique strings.",
        type="error"
      )
      return()
    }
    # Error Code 8: No quantitative data is left after filtering
    else if (df == 8) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="No quantitative data is left after filtering!",
        type="error"
      )
      return()
    }
    # Error Code 9: Error at the expand annotation step
    else if (df == 9) {
      sendSweetAlert(
        session=session,
        title="Termini Data Error",
        text="An error occured while expanding the annotation!",
        type="error"
      )
      return()
    }
  }
  
  # Create dataTableOutput from the opened data
  output$terminiData_prepared <- shiny.preview.data(
    cbind(
      df$annot, 
      df$quant
    ), 
    colIgnore='Fasta.sequence'
  )
  # Save the prepared termini data into reactive variable
  variables$datasets$termini <- df
  # Download handler
  output$downloadTerminiPrepared <- shiny.download.data(
    fname = paste0(
      "prepared_terminiData_", 
      Sys.Date(), 
      ".csv"
    ), 
    data = cbind(
      df$annot, 
      df$quant
    )
  )
})

# PTM Data Preview - Opens the data and previews it
observeEvent(input$show_ptm_preview,{
  # Validate before preview
  if (is.null(input$uploadPTMData)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please upload a PTM data to preview!",
      type="error"
    )
    return()
  }
  if (is.null(input$ptm_file_type)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select how the PTM data file is separated!",
      type="error"
    )
    return()
  }
  if (is.null(variables$datasets$metadata)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please process metadata before processing PTM data!",
      type="error"
    )
    return()
  }

  # Opens the data
  df <- openData(
    input$uploadPTMData$datapath, 
    file_sep=input$ptm_file_type
  )
  # If df is numeric, then an error occured - only error 0
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: 
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="Upload Error",
        text="The uploaded file is not a valid file with 
        given path and file extension! Please ensure the 
        file path and the correct file type is selected.",
        type="error"
      )
      return()
    }else{
      sendSweetAlert(
        session=session,
        title="Unexpected Error",
        text="An unexpected error occured while opening PTM data! 
        Please contact the developer through GitHub or email.",
        type="error"
      )
      return()
    }
  }

  meta_list <- variables$datasets$metadata
  if (
    length(intersect(names(df), meta_list$data[, meta_list$idCol])) == 0
  ){
    if(!is.null(meta_list$uniqCol)){
      if (
        length(intersect(names(df), meta_list$data[, meta_list$uniqCol])) == 0
      ){
        sendSweetAlert(
          session=session,
          title="PTM Data Error",
          text="No sample name overlap between metadata and data!",
          type="error"
        )
        return() 
      }else{
        sampleNames <- meta_list$data[, meta_list$uniqCol]
      }
    }else{
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="No sample name overlap between metadata and data!",
        type="error"
      )
      return()
    }
  }else{
    sampleNames <- variables$datasets$metadata$data[
        , 
        variables$datasets$metadata$idCol
    ]
  }  
  # Find the info columns, columnNames that are not in sampleNames
  infoCols <- names(df)[!names(df) %in% sampleNames]
  output$ptmData_preview <- shiny.preview.data(df, colIgnore=NULL)

  # Create drop-down input selection to select identifier column
  output$ptm_identifier_col <- renderUI({
    selectizeInput(
      "ptm_identifier_col",
      label="Select identifier column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select proteinAcc column
  output$ptm_proteinAcc_col <- renderUI({
    selectizeInput(
      "ptm_proteinAcc_col",
      label="Select protein id column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select strippedSequence column
  output$ptm_strippedSeq_col <- renderUI({
    selectizeInput(
      "ptm_strippedSeq_col",
      label="Select stripped sequence column",
      choices=infoCols
    )
  })
  # Create drop-down input selection to select modified sequence column
  output$ptm_modifiedSeq_col <- renderUI({
    selectizeInput(
      "ptm_modifiedSeq_col",
      label="Select modified sequence column",
      choices=infoCols
    )
  })
  # Save the opened ptm data into reactive variable
  variables$uploads$ptm <- df
})

# Process PTM Data - Processes the ptm data for analysis
observeEvent(input$process_ptm_data,{
  # Validate before processing
  if (is.null(input$ptm_identifier_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select an identifier column!",
      type="error"
    )
    return()
  }
  if (is.null(input$ptm_proteinAcc_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a protein id column!",
      type="error"
    )
    return()
  }
  if (is.null(input$ptm_strippedSeq_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a stripped sequence column!",
      type="error"
    )
    return()
  }
  if (is.null(input$ptm_modifiedSeq_col)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="Please select a modified sequence column!",
      type="error"
    )
    return()
  }
  # Check if the variables$reference is NULL
  if (is.null(variables$reference)) {
    sendSweetAlert(
      session=session,
      title="Configuration Error",
      text="PTM processing requires reference database! 
      Please select a reference fasta file or 
      upload your own before continuing",
      type="error"
    )
    return()
  } 
  # Prepare the ptm data with cleaning and annotation
  df <- prepareInputData(
    data=variables$uploads$ptm,
    id_col=input$ptm_identifier_col,
    meta_list = variables$datasets$metadata,
    data_type="ptm",
    uniprotDB=variables$reference,
    contains_rep=input$ptm_whether_replica,
    pro_col=input$ptm_proteinAcc_col,
    strSeq_col=input$ptm_strippedSeq_col,
    modSeq_col=input$ptm_modifiedSeq_col,
    modifType=input$ptm_mod_type
  )
  # If df is numeric, means an error occured in prepareInputData
  if (length(df)==1 & is.numeric(df)) {
    # Error Code 0: Unexpected Error at PTM Data Processing
    if (df == 0) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="An unexpected error occured while processing ptm data! 
        Data passed from preview is not a dataframe or no values are passed",
        type="error"
      )
      return()
    }
    # Error Code 1: Missing annotation column(s)
    else if (df == 1) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="The selected identifier column is not in the data!",
        type="error"
      )
      return()
    }
    # Error Code 2: only annotation columns are passed
    else if (df == 2) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="No quantitative columns are available!",
        type="error"
      )
      return()
    }
    # Error Code 3: no overlap between data and metadata
    else if (df == 3) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="There are no overlapping samples between 
        the metadata and the data! Ensure the metadata's 
        selected identifier column has the name of the 
        quantitative data column names.",
        type="error"
      )
      return()
    }
    # Error Code 4: Metadata has more samples than data
    else if (df == 4) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="More than 90% of samples from metadata are not in the data! 
        Is this by design or an error?",
        type="error"
      )
      return()
    }
    # Error Code 5: All features identifiers are missing
    else if (df == 5) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="Proteins identifiers are NA! 
        [If this is an unexpected error, report by GitHub or email]",
        type="error"
      )
      return()
    }
    # Error Code 6: Error at the explode data step
    else if (df == 6) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="An error occured while exploding the data!",
        type="error"
      )
      return()
    }
    # Error Code 7: Data conversion to numeric type failed
    else if (df == 7) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="An error occured while converting quantitative 
        data columns to numeric type! Please ensure the
        contents of the quantitative columns don't contain unique strings.",
        type="error"
      )
      return()
    }
    # Error Code 8: No quantitative data is left after filtering
    else if (df == 8) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="No quantitative data is left after filtering!",
        type="error"
      )
      return()
    }
    # Error Code 9: Error at the expand annotation step
    else if (df == 9) {
      sendSweetAlert(
        session=session,
        title="PTM Data Error",
        text="An error occured while expanding the annotation!",
        type="error"
      )
      return()
    }
  }
  
  # Create dataTableOutput from the opened data
  output$ptmData_prepared <- shiny.preview.data(
    cbind(
      df$annot, 
      df$quant
    ), 
    colIgnore='Fasta.sequence'
  )
  # Save the prepared protein data into reactive variable
  variables$datasets$ptm <- df
  # Download handler
  output$downloadPtmPrepared <- shiny.download.data(
    fname = paste0(
      "prepared_ptmData_", 
      Sys.Date(), 
      ".csv"
    ), 
    data = cbind(
      df$annot, 
      df$quant
    )
  )
})