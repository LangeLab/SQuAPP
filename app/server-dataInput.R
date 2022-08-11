# If preparing example data button is clicked
observeEvent(input$submitExampleData, {
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
  variables$reference <- feather::read_feather(path=references_vector["Homo sapiens"])

  ## Create dataframe to show
  # Protein
  protein <- cbind(protein.list$annot, protein.list$quant)
  # Peptide
  peptide <- cbind(peptide.list$annot, peptide.list$quant)
  # Termini
  termini <- cbind(termini.list$annot, termini.list$quant)
  # PTM
  ptm <- cbind(ptm.list$annot, ptm.list$quant)

  # Create datatable renders to show in the UI
  output$example_metaData_prepared <- shiny.preview.data(metadata, colIgnore="Fasta.sequence")
  output$example_proteinData_prepared <- shiny.preview.data(protein, colIgnore="Fasta.sequence")
  output$example_peptideData_prepared <- shiny.preview.data(peptide, colIgnore="Fasta.sequence")
  output$example_terminiData_prepared <- shiny.preview.data(termini, colIgnore="Fasta.sequence")
  output$example_ptmData_prepared <- shiny.preview.data(ptm, colIgnore="Fasta.sequence")

  ## Create and Save Report Variables
  # Update isRun variables
  variables$reportParam$protein$dataSetup$isRun <- TRUE
  # variables$reportParam$peptide$dataSetup$isRun <- TRUE
  # variables$reportParam$termini$dataSetup$isRun <- TRUE
  # variables$reportParam$ptm$dataSetup$isRun <- TRUE
  # Create report preview tables and save them in reportParam-level-dataSetup variables
  variables$reportParam$shared$reference$table <- report.preview.data(
    variables$reference, colIgnore=c("Fasta.sequence", "Gene.name"), rowN=3
  )
  variables$reportParam$shared$metadata$table <- report.preview.data(
    metadata, colIgnore="Fasta.sequence", rowN=3
  )
  variables$reportParam$protein$dataSetup$table <- report.preview.data(
    protein, colIgnore="Fasta.sequence", rowN=3
  )
  variables$reportParam$peptide$dataSetup$table <- report.preview.data(
    peptide, colIgnore="Fasta.sequence", rowN=3
  )
  variables$reportParam$termini$dataSetup$table <- report.preview.data(
    termini, colIgnore="Fasta.sequence", rowN=3
  )
  variables$reportParam$ptm$dataSetup$table <- report.preview.data(
    ptm, colIgnore="Fasta.sequence", rowN=3
  )
  # Update the param variables
  variables$reportParam$shared$reference$param <- data.frame(
    "parameters" = c("organism", "source", "isCustom", "date"),
    "values" = c(
      "Homo Sapiens",
      "Reviewed (Swiss-Prot) + Unreviewed (TrEMBL)",
      "non-customized",
      "2022-08-07")
  )
  variables$reportParam$shared$metadata$param <- data.frame(
    "parameters" = c("file name","file format", "id column", "contain replica?", "unique column"),
    "values" = c("meta_data.csv", "comma-separated", "ID", "Yes", "SampleName")
  )
  variables$reportParam$protein$dataSetup$param <- data.frame(
    "parameters" = c("file name","file format", "id column", "contain replica?"),
    "values" = c("protein_data.csv", "comma-separated", "PG.ProteinAccessions", "Yes")
  )
  variables$reportParam$peptide$dataSetup$param <- data.frame(
    "parameters" = c("file name", "file format", "id column",
                     "protein id column", "stripped seq column",
                     "contain replica?"),
    "values" = c("peptide_data.csv", "comma-separated", "PEP.StrippedSequence",
                 "PG.ProteinAccessions","PEP.StrippedSequence", "Yes"))
  variables$reportParam$termini$dataSetup$param <- data.frame(
    "parameters" = c("file name", "file format", "Termini Type", "id column",
                     "protein id column", "stripped seq column",
                     "modified seq column", "contain replica?"),
    "values" = c("termini_data_cleaned.csv","comma-separated", "N-Term",
                 "EG.PrecursorId","PG.ProteinAccessions", "PEP.StrippedSequence",
                 "EG.PrecursorId", "Yes"))
  variables$reportParam$ptm$dataSetup$param <- data.frame(
    "parameters" = c("file name", "file format", "PTM Type", "id column",
                     "protein id column", "stripped seq column",
                     "modified seq column", "contain replica?"),
    "values" = c("peptide_data.csv", "comma-separated", "Phosphorylation",
                 "PTM_collapse_key", "PG.ProteinGroups", "PEP.StrippedSequence",
                 "PTM_group", "No"))
})

# Upload a custom uniprot reference proteome by user
observeEvent(input$uploadReference, {
  # Save the uniprot reference data to main list
  variables$reference <- makeUniProtData(input$uploadReference$datapath)
  # Update the report list with created reference table
  variables$reportParam$shared$reference$table <- report.preview.data(
    variables$reference, colIgnore=c("Fasta.sequence", "Gene.name"), rowN=3
  )
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
      dfs, colIgnore=c("Fasta.sequence", "Gene.name"), rowN=3
    )
    # Update the param variables
    variables$reportParam$shared$reference$param <- data.frame(
      "parameters" = c("organism", "source", "isCustom", "date"),
      "values" = c(
        paste(refs, collapse=" + "),
        "Reviewed (Swiss-Prot) + Unreviewed (TrEMBL)",
        "non-customized",
        "2022-08-07")
    )
  }
})

# Metadata Preview - Opens the data and previews the opened data
observeEvent(input$show_metadata_preview,{
  # checks if the required logic is there, if not provide helpful message
  validate(need(input$uploadMetadata,
                message="Upload file to preview"),
           need(input$metadata_file_type,
                message="Select how file upload is separated"))
  # Opens the metadata
  df <- openData(input$uploadMetadata$datapath, file_sep=input$metadata_file_type)
  # Create dataTableOutput from the opened data
  output$metaData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to get sampleNames
  output$metadata_sampleName_col <- renderUI({
    selectizeInput("metadata_sampleName_col",
                   "Select sample name column",
                   choices=colnames(df) )
  })
  # Create drop-down input selection if metadata contains replica samples
  output$metadata_uniqueSample_col <- renderUI({
    req(input$metadata_whether_replica)
    selectizeInput("metadata_uniqueSample_col",
                   "Select unique sample name column",
                   choices=colnames(df) )
  })
  # Save the opened metadata into reactive variable
  variables$uploads$metadata <- df

})

# Metadata Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_metadata,{
  # Check if the opened data is available
  validate(need(variables$uploads$metadata,
                message="Error occured in opening metadata!"))
  # Run the clean metadata to be prepared for the data
  df <- cleanMetadata(variables$uploads$metadata, input$metadata_sampleName_col)
  # Create dataTableOutput from the opened data
  output$metaData_prepared <- shiny.preview.data(df, colIgnore=NULL)
  # Save the prepared metadata alongside with user provided parameters into a list
  variables$datasets$metadata <- list(
    name="metadata",
    isRep=input$metadata_whether_replica,
    idCol=input$metadata_sampleName_col,
    uniqCol=input$metadata_uniqueSample_col,
    data=df
  )
  # Create unique file name
  fname <- paste0("prepared_metadata_", Sys.Date(), ".csv")
  # Download handler
  output$downloadMetadataPrepared <- shiny.download.data(fname, df)
})

# Protein Data Preview - Opens the data and previews it
observeEvent(input$show_protein_preview,{
  # Check if the fileInput is provided and protein file is provided
  validate(need(input$uploadProteinData,
                message="Upload file to preview"),
           need(input$protein_file_type,
                message="Select how file upload is separated"))
  # Opens the data
  df <- openData(input$uploadProteinData$datapath, file_sep=input$protein_file_type)
  # Get non-numeric columns to look for identifier column
  nonNumeric_cols <- names(df)[!sapply(df, is.numeric)]
  # Create a dataTableOutput to preview opened data
  output$proteinData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$protein_identifier_col <- renderUI({
    selectizeInput("protein_identifier_col",
                   "Select identifier column",
                   choices=nonNumeric_cols)
  })
  # Save the opened protein data into reactive variable
  variables$uploads$protein <- df
})

# Protein Data Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_protein_data,{
  # Check if the opened data is available
  validate(need(variables$uploads$protein,
                message="Error occured in opening protein data!"),
           need(variables$datasets$metadata,
                message="Metadata is needed to prepare protein data"))
  # Prepare the protein data with cleaning and annotation
  df <- prepareInputData(data=variables$uploads$protein,
                         id_col=input$protein_identifier_col,
                         meta_data=variables$datasets$metadata$data,
                         meta_id_col=variables$datasets$metadata$idCol,
                         meta_uniq_col=variables$datasets$metadata$uniqCol,
                         data_type="protein",
                         uniprotDB=variables$reference,
                         contains_rep=input$protein_whether_replica,
                         pro_col=NULL,
                         strSeq_col=NULL,
                         modSeq_col=NULL)
  # Create dataTableOutput from the opened data
  output$proteinData_prepared <- shiny.preview.data(cbind(df$annot, df$quant), colIgnore='Fasta.sequence')
  # Save the prepared protein data alongside with user provided parameters into a list
  variables$datasets$protein <- df
  # Create unique file name
  fname <- paste0("prepared_proteinData_", Sys.Date(), ".csv")
  # Download handler
  output$downloadProteinPrepared <- shiny.download.data(fname, df)
})

# Peptide Data Preview - Opens the data and previews it
observeEvent(input$show_peptide_preview,{
  # Check if the fileInput is provided and peptide file is provided
  validate(need(input$uploadPeptideData,
                message="Upload file to preview"),
           need(input$peptide_file_type,
                message="Select how file upload is separated"))
  # Opens the data
  df <- openData(input$uploadPeptideData$datapath, file_sep=input$peptide_file_type)
  # Get non-numeric columns to look for identifier column
  nonNumeric_cols <- names(df)[!sapply(df, is.numeric)]
  # Create a dataTableOutput to preview opened data
  output$peptideData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$peptide_identifier_col <- renderUI({
    selectizeInput("peptide_identifier_col",
                   "Select identifier column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select proteinAcc column
  output$peptide_proteinAcc_col <- renderUI({
    selectizeInput("peptide_proteinAcc_col",
                   "Select protein id column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select proteinAcc column
  output$peptide_strippedSeq_col <- renderUI({
    selectizeInput("peptide_strippedSeq_col",
                   "Select stripped sequence column",
                   choices=nonNumeric_cols)
  })
  # Save the opened protein data into reactive variable
  variables$uploads$peptide <- df
})

# Peptide Data Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_peptide_data,{
  # Check if the opened data is available
  validate(need(variables$uploads$peptide,
                message="Error occured in opening peptide data!"),
           need(variables$datasets$metadata,
                message="Metadata is needed to prepare peptide data"))
  # Prepare the peptide data with cleaning and annotation
  df <- prepareInputData(data=variables$uploads$peptide,
                         id_col=input$peptide_identifier_col,
                         meta_data=variables$datasets$metadata$data,
                         meta_id_col=variables$datasets$metadata$idCol,
                         meta_uniq_col=variables$datasets$metadata$uniqCol,
                         data_type="peptide",
                         uniprotDB=variables$reference,
                         contains_rep=input$peptide_whether_replica,
                         pro_col=input$peptide_proteinAcc_col,
                         strSeq_col=input$peptide_strippedSeq_col,
                         modSeq_col=NULL)
  # Create dataTableOutput from the opened data
  output$peptideData_prepared <- shiny.preview.data(cbind(df$annot, df$quant), colIgnore='Fasta.sequence')
  # Save the prepared peptide data alongside with user provided parameters into a list
  variables$datasets$peptide <- df
  # Create unique file name
  fname <- paste0("prepared_peptideData_", Sys.Date(), ".csv")
  # Download handler
  output$downloadPeptidePrepared <- shiny.download.data(fname, df)
})

# Termini Data Preview - Opens the data and previews it
observeEvent(input$show_termini_preview,{
  # Check if the fileInput is provided and termini file is provided
  validate(need(input$uploadTerminiData,
                message="Upload file to preview"),
           need(input$termini_file_type,
                message="Select how file upload is separated"))
  # Opens the data
  df <- openData(input$uploadTerminiData$datapath, file_sep=input$termini_file_type)
  # Get non-numeric columns to look for identifier column
  nonNumeric_cols <- names(df)[!sapply(df, is.numeric)]
  # Create a dataTableOutput to preview opened data
  output$terminiData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$termini_identifier_col <- renderUI({
    selectizeInput("termini_identifier_col",
                   "Select identifier column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select proteinAcc column
  output$termini_proteinAcc_col <- renderUI({
    selectizeInput("termini_proteinAcc_col",
                   "Select protein id column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select strippedSequence column
  output$termini_strippedSeq_col <- renderUI({
    selectizeInput("termini_strippedSeq_col",
                   "Select stripped sequence column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select modified sequence column
  output$termini_modifiedSeq_col <- renderUI({
    selectizeInput("termini_modifiedSeq_col",
                   "Select modified sequence column",
                   choices=nonNumeric_cols)
  })
  # Save the opened termini data into reactive variable
  variables$uploads$termini <- df
})

# Termini Data Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_termini_data,{
  # Check if the opened data is available
  validate(need(variables$uploads$termini,
                message="Error occured in opening termini data!"),
           need(variables$datasets$metadata,
                message="Metadata is needed to prepare termini data"))
  # Prepare the termini data with cleaning and annotation
  df <- prepareInputData(data=variables$uploads$termini,
                         id_col=input$termini_identifier_col,
                         meta_data=variables$datasets$metadata$data,
                         meta_id_col=variables$datasets$metadata$idCol,
                         meta_uniq_col=variables$datasets$metadata$uniqCol,
                         data_type="termini",
                         uniprotDB=variables$reference,
                         contains_rep=input$termini_whether_replica,
                         pro_col=input$termini_proteinAcc_col,
                         strSeq_col=input$termini_strippedSeq_col,
                         modSeq_col=input$termini_modifiedSeq_col,
                         modifType=input$termini_mod_type
                        )
  # Create dataTableOutput from the opened data
  output$terminiData_prepared <- shiny.preview.data(cbind(df$annot, df$quant), colIgnore='Fasta.sequence')
  # Save the prepared termini data alongside with user provided parameters into a list
  variables$datasets$termini <- df
  # Create unique file name
  fname <- paste0("prepared_terminiData_", Sys.Date(), ".csv")
  # Download handler
  output$downloadTerminiPrepared <- shiny.download.data(fname, df)
})

# PTM Data Preview - Opens the data and previews it
observeEvent(input$show_ptm_preview,{
  # Check if the fileInput is provided and termini file is provided
  validate(need(input$uploadPTMData,
                message="Upload file to preview"),
           need(input$ptm_file_type,
                message="Select how file upload is separated"))
  # Opens the data
  df <- openData(input$uploadPTMData$datapath, file_sep=input$ptm_file_type)
  # Get non-numeric columns to look for identifier column
  nonNumeric_cols <- names(df)[!sapply(df, is.numeric)]
  # Create a dataTableOutput to preview opened data
  output$ptmData_preview <- shiny.preview.data(df, colIgnore=NULL)
  # Create drop-down input selection to select identifier column
  output$ptm_identifier_col <- renderUI({
    selectizeInput("ptm_identifier_col",
                   "Select identifier column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select proteinAcc column
  output$ptm_proteinAcc_col <- renderUI({
    selectizeInput("ptm_proteinAcc_col",
                   "Select protein id column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select strippedSequence column
  output$ptm_strippedSeq_col <- renderUI({
    selectizeInput("ptm_strippedSeq_col",
                   "Select stripped sequence column",
                   choices=nonNumeric_cols)
  })
  # Create drop-down input selection to select modified sequence column
  output$ptm_modifiedSeq_col <- renderUI({
    selectizeInput("ptm_modifiedSeq_col",
                   "Select modified sequence column",
                   choices=nonNumeric_cols)
  })
  # Save the opened ptm data into reactive variable
  variables$uploads$ptm <- df
})

# PTM Data Prepared - Prepares the data to be used based user defined selections
observeEvent(input$process_ptm_data,{
  # Check if the opened data is available
  validate(need(variables$uploads$ptm,
                message="Error occured in opening ptm data!"),
           need(variables$datasets$metadata,
                message="Metadata is needed to prepare ptm data"))
  # Prepare the ptm data with cleaning and annotation
  df <- prepareInputData(data=variables$uploads$ptm,
                         id_col=input$ptm_identifier_col,
                         meta_data=variables$datasets$metadata$data,
                         meta_id_col=variables$datasets$metadata$idCol,
                         meta_uniq_col=variables$datasets$metadata$uniqCol,
                         data_type="ptm",
                         uniprotDB=variables$reference,
                         contains_rep=input$ptm_whether_replica,
                         pro_col=input$ptm_proteinAcc_col,
                         strSeq_col=input$ptm_strippedSeq_col,
                         modSeq_col=input$ptm_modifiedSeq_col,
                         modifType=input$ptm_mod_type)
  # Create dataTableOutput from the opened data
  output$ptmData_prepared <- shiny.preview.data(cbind(df$annot, df$quant), colIgnore='Fasta.sequence')
  # Save the prepared ptm data alongside with user provided parameters into a list
  variables$datasets$ptm <- df
  # Create unique file name
  fname <- paste0("prepared_ptmData_", Sys.Date(), ".csv")
  # Download handler
  output$downloadPtmPrepared <- shiny.download.data(fname, df)
})
