# require -> openxlsx
# require -> Biostrings

makeUniProtData <- function(
  fasta_path
){
  # Error handling:
  # 0 - Biostrings::readAAStringSet Fails to parse the fasta
  # 1 - Biostrings::readAAStringSet returns a non AAStringSet object

  # Ensure the file doesn't broke the app
  fasta <- try2(
    # Parse the fasta with biostrings
    expr = Biostrings::readAAStringSet(filepath=fasta_path),
    # If it breaks, return an empty string
    err_code = 0
  )
  # Checks if fasta is numeric
  if (length(fasta)==1 & is.numeric(fasta)) return(fasta) 
  # Checks if the fasta is a AAStringSet
  if (class(fasta) != "AAStringSet")return(1)
  # Convert AAStringSet to dataframe
  fasta.df <- data.frame(names(fasta), paste(fasta))
  colnames(fasta.df) <- c('Fasta.name', 'Fasta.sequence')
  # Make parsed uniprot Fasta with more user friendly columns
  sequence.df <- fasta.df %>% # Start the pipe
    mutate(
      Fasta.identifier = sub("^[> ]*(\\S+).*", "\\1", Fasta.name)
    ) %>%
    separate(
      Fasta.identifier, 
      c('db', 'Protein.identifier', 'Entry.name'), 
      sep='\\|'
    ) %>%
    mutate(
      tmp_clean = sub(" OS=.*", "\\1", Fasta.name)
    ) %>%
    mutate(
      Protein.name = sub(".*? ", "", tmp_clean)
    ) %>%
    mutate(
      Gene.name = sub(".* GN=([^ ]+).*", "\\1", Fasta.name)
    ) %>%
    mutate(
      Gene.name = if_else(
        str_detect(
          Gene.name,
          fixed('sp|')), 
          "", 
          Gene.name
      )
    ) %>%
    mutate(
      Organism.identifier = sub(".* OX=([^ ]+).*", "\\1", Fasta.name)
    ) %>%
    mutate(
      Protein.existence = sub(".* PE=([^ ]+).*", "\\1", Fasta.name)
    ) %>%
    mutate(
      Sequence.version = sub(".* SV=([^ ]+).*", "\\1", Fasta.name)
    ) %>%
    select(
      db, 
      Organism.identifier, 
      Entry.name,
      Protein.identifier, 
      Protein.name,
      Gene.name, 
      Fasta.sequence,
      Protein.existence,
      Sequence.version
    ) # End the pipe
  return(sequence.df)
}

# TODO: Add exception catching and error handling parts to the openData
#  This is important due to csv extension can contain different seperation.
openData <- function(
  file_path, 
  file_sep="comma"
){
  # Error handling:
  # 0 - Opening the file fails 
  # TODO: Expand with more specific error codes

  # Open the file with the correct seperation
  if(file_sep=="comma"){
    data <- try2(
      expr = read.csv(
          file_path, 
          header=T, 
          check.names=F, 
          sep=','
        ),
      err_code = 0
    )
  }
  if(file_sep=="tab"){
    data <- try2(
      expr = read.csv(
          file_path, 
          header=T, 
          check.names=F, 
          sep="\t"
        ),
      err_code = 0
    )
  }
  if(file_sep=="excel"){
    data <- try2(
      expr = openxlsx::read.xlsx(
          file_path,
          check.names=F
        ),
      err_code = 0
    )
  }

  # Check if the data is numeric, if so return the data as error code
  if (length(data)==1 & is.numeric(data)) return(data)
  # Return the data as data.frame without any name checking
  return(data.frame(data, check.names=F))
}

# WARNING: Important to provide metadata identifier to be comprehensive.
cleanMetadata <- function(
  meta_data, 
  meta_id_col, 
  is_replicate=FALSE,
  meta_unique_col=NULL,
  NA_replace_str="Unknown"
){
  # Error handling:
  # 0 - ID column has duplicate values
  # 1 - ID column has NA values
  # 3 - Unique column and ID column is the same
  # 4 - Unique column has NA values

  # Check if the ID column has duplicate values - Error Code 0
  if (anyDuplicated(meta_data[, meta_id_col]) > 0) return(0)
  # Check if the ID column has NA values - Error Code 1
  if (anyNA(meta_data[, meta_id_col])) return(1)
  # If is_replicate is true
  if (is_replicate){
    # Unique col and id column is the same - Error Code 3
    if (meta_id_col == meta_unique_col) return(3)
    # Check if the unique column has NA values - Error Code 4
    if (anyNA(meta_data[, meta_unique_col])) return(4)
  }
  # Replace NA values with NA_replace_str
  meta_data[is.na(meta_data)] <- NA_replace_str
  # Return the data as data.frame without any name checking
  return(data.frame(meta_data, check.names=F))
}

getPeptidePosition <- function(data){
  # WARNING: The data column names are fixed coming from UniprotDB data
  #  Column names needs to be updated here if they changed in UniprotDB file.
  # Finds peptide start and end position as well as returning to important AA
  data <- data %>% # Start the pipe
    mutate(
      PEP.AA.length = str_length(Peptide.sequence)
    ) %>%
    mutate(
      PEP.Pos.start = str_locate(
        Fasta.sequence,
        Peptide.sequence
      )[, 1]
    ) %>%
    mutate(
      PEP.AA.start = str_sub(
        Fasta.sequence,
        start = .data$PEP.Pos.start,
        end   = .data$PEP.Pos.start
      )
    ) %>%
    mutate(
      PEP.Pos.end = str_locate(
        Fasta.sequence,
        Peptide.sequence
      )[, 2]
    ) %>%
    mutate(
      PEP.AA.end = str_sub(
        Fasta.sequence,
        start = .data$PEP.Pos.end,
        end   = .data$PEP.Pos.end
      )
    ) %>%
    mutate(
      PEP.AA.before = str_sub(
        Fasta.sequence,
        start = .data$PEP.Pos.start - 1,
        end   = .data$PEP.Pos.start - 1
      )
    ) %>%
    mutate(
      PEP.AA.last = str_sub(
        Fasta.sequence,
        start = .data$PEP.Pos.end,
        end   = .data$PEP.Pos.end
      )
    ) %>%
    mutate(
      PEP.AA.after = str_sub(
        Fasta.sequence,
        start = .data$PEP.Pos.end + 1,
        end   = .data$PEP.Pos.end + 1
      )
    ) # End the pipe
  return(data)
}

expandAnnotation <- function(
  proteinIdentifier,
  strippedSeq,
  modifiedSeq,
  uniprotDB,
  data_type
){
  # Make the subset of uniprotDB based on passed protein identifiers
  res <- uniprotDB[
    match(
      proteinIdentifier, 
      uniprotDB$Protein.identifier
    ),
    c("Entry.name", "Gene.name", "Protein.name", "Fasta.sequence")
  ]
  # Create a new dataframe with passed data columns
  if(data_type=="protein"){
    df <- data.frame(
      Protein.identifier=proteinIdentifier
    )
  }
  if(data_type=="peptide"){
    df <- data.frame(
      Protein.identifier=proteinIdentifier,
      Peptide.sequence=strippedSeq
    )
  }
  if((data_type=="termini") || (data_type=="ptm")){
    df <- data.frame(
      Protein.identifier=proteinIdentifier,
      Peptide.sequence=strippedSeq,
      Peptide.modified=modifiedSeq
    )
  }
  # Add uniprot data to the new dataframe for annotation
  df <- cbind(df, res)
  # Create protein length variable
  df$Protein.length <- str_length(df$Fasta.sequence)
  # If protein data is passed
  if(data_type=="protein"){
      # Skip other steps since no peptide data will be there
      return(df)
  }
  # Get peptide position information and save to data frame
  df <- getPeptidePosition(df)
  # Returnd the data
  return(df)
}

explodeData <- function(
  data, 
  data_type, 
  id_col, 
  pro_col, 
  strSeq_col, 
  modSeq_col
){
  # TODO: Add error handling codes and try catch blocks

  # Conditionally explode multi element column values into their own rows
  if(data_type == "protein"){
    # Explode the protein accessions
    data <- data %>%
      separate_rows(
        all_of(id_col), 
        sep=";"
      ) %>%
      distinct() %>% 
      data.frame(check.names=F)
    # Put the protein names into rownames
    rownames(data) <- data[, id_col]
  }else if(data_type == "peptide"){
    data <- data %>% # Start the pipe
      separate_rows(
        all_of(id_col), 
        sep=";"
      )  %>%
      separate_rows(
        all_of(pro_col), 
        sep=";"
      ) %>%
      separate_rows(
        all_of(strSeq_col), 
        sep=";"
      ) %>%
      distinct() %>% 
      data.frame(check.names=F) # End the pipe
    # Create unique rownames and add as index
    rownames(data) <- paste(
      data[,pro_col], 
      data[,id_col], 
      sep="|"
    )
  }else if((data_type == "termini") || (data_type == "ptm")){
    data <- data %>% # Start the pipe
      separate_rows(
        all_of(id_col), 
        sep=";"
      )  %>%
      separate_rows(
        all_of(pro_col), 
        sep=";"
      ) %>%
      separate_rows(
        all_of(strSeq_col), 
        sep=";"
      ) %>%
      separate_rows(
        all_of(modSeq_col), 
        sep=";"
      ) %>%
      distinct() %>% 
      data.frame(check.names=F) # End the pipe

    # TODO: This is not robust where the modified sequence 
    #   contains less than that.
    data[, modSeq_col] <- sapply(
      strsplit(data[, modSeq_col], "_"), 
      "[", 
      2
    )
    # Remove duplicate columns
    data <- data[
      !duplicated(
        data[, c(id_col, pro_col, modSeq_col)]
      ), 
    ]
    # Create unique rownames and add as index
    rownames(data) <- paste(
      data[,id_col], 
      data[,pro_col], 
      data[,modSeq_col],
      sep="|"
    )
  }
  return(data.frame(data, check.names = FALSE))
}

# Main Data to Preapare Data to be used in the app
prepareInputData <- function(
  data,                # Data being prepared for further use
  id_col,              # Column name uniquely identifying the data
  meta_list,           # Metadata as a list object
  data_type,           # String identifying which data it is being prepared
  uniprotDB,           # Fasta reference database for expanding annotation
  pro_col=NULL,        # column name of the protein identifier
  strSeq_col=NULL,     # column name of peptide stripped sequence
  modSeq_col=NULL,     # column name of peptide modified sequence
  contains_rep=TRUE,   # Logical variable to check if sample has replicas
  modifType=""         # User defined text to identify the data
){
  # Error handling: 
  # 0 - Data type based errors
  # 1 - missing annotation columns
  # 2 - only annotation columns are passed
  # 3 - no overlap between data and metadata
  # 4 - Metadata has more samples than data
  # 5 - All features identifiers are missing
  # 6 - Error at the explode data step
  # 7 - Data conversion to numeric type failed
  # 8 - No quantitative data is left after filtering
  # 9 - Error at the expand annotation step

  # Ensure the data is a data frame
  if(!is.data.frame(data)) return(0)
  # Ensure the data is not empty
  if(nrow(data)==0) return(0)
  # Pass the data name if motifType is not passed
  if(modifType==""){modifType <- data_type}
  # Get the most used meta info
  meta_data <- meta_list$data
  meta_id_col <- meta_list$idCol

  # Adjust the metadata based on the data's replicate status
  if(!contains_rep){ # If data does not have replicates
    if(meta_list$isRep){ # If metadata has replicates
      # If metadata has replicates
      # Remove the replica column
      meta_data[, meta_id_col] <- meta_data[, meta_list$uniqCol]
      # Remove the replica column if it exists
      if(!is.null(meta_list$replCol)){
          if (meta_list$replCol %in% colnames(meta_data)){
          meta_data[, meta_list$replCol] <- NULL
        }
      }
      # Remove the original unique column
      meta_data[, meta_list$uniqCol] <- NULL
      # Select only unique values in df
      meta_data <- unique(meta_data)
      # Reset the row ids
      rownames(meta_data) <- 1:nrow(meta_data)
    }
  }

  # Annotation Columns
  col4annot <- unique(c(id_col, pro_col, strSeq_col, modSeq_col))
  # if any of the crucial annotation columns are missing - error 1
  if(!all(col4annot %in% colnames(data))) return(1) 
  # Find columns that are not part of col4annot
  otherCols <- setdiff(colnames(data), col4annot)
  # If no other columns are present - error 2
  if (length(otherCols)==0) return(2)
  # Find the intersection between Sample (meta$id) and Column (data) names
  colOverlap <- intersect(otherCols, meta_data[, meta_id_col])
  # If no overlap - error 3
  if (length(colOverlap)==0) return(3)
  # if colOverlap < len(metadata sample ids) - error 4
  if (length(colOverlap) < nrow(meta_data)){
    # Check the percentage of overlap
    if (length(colOverlap)/nrow(meta_data) < 0.1) return(4)
    # Subset the metadata to only the overlapping samples
    meta_data <- meta_data[ meta_data[, meta_id_col] %in% colOverlap, ]
  }
  
  # Remove rows where ID column has missing values
  data <- data[!is.na(data[, id_col]), ]
  # If no rows are left - error 5
  if (nrow(data)==0) return(5)
  # Replace many interpreation of missing values with NA
  data[data==""] <- NA
  data[data==" "] <- NA
  data[data=="NA"] <- NA
  data[data=="N/A"] <- NA
  data[data=="NaN"] <- NA
  data[data=="Filtered"] <- NA
  data[data=="Filtered out"] <- NA
  data[data=="Filtered Out"] <- NA
  # Subset the identifyable (Annotation + Quantitative) Columns
  data <- data[, unique(c(col4annot, colOverlap))]
  # Set numeric data index
  rownames(data) <- 1:nrow(data)
  # Explode the multi elements and create unique rownames
  # TODO: Not very valid since multiple proteins mean 
  #  search wasn't sure if one or other protein, find a better way
  data <- explodeData(
    data, 
    data_type, 
    id_col, 
    pro_col, 
    strSeq_col, 
    modSeq_col
  )
  # If an error occurred at the explodeData - error 6
  if (length(data)==1 & is.numeric(data)) return(6)
  # Convert elements to numeric in the quantitative part of the data
  quant.data <- try2(
    sapply(data[, colOverlap], as.numeric),
    err_code = 0 
  )
  # If an error occurred at the numeric conversion - error 7
  if (length(quant.data)==1 & is.numeric(quant.data)) return(7)
  # Add rownames to quant.data
  rownames(quant.data) <- rownames(data)
  # Remove completely missing row + columns
  # Remove rows where all values are NA
  quant.data <- data.frame(
    quant.data[
      rowSums(is.na(quant.data)) != ncol(quant.data),
    ], 
    check.names = FALSE
  )
  # if no quantitative data is left return 8
  if (nrow(quant.data)==0) return(8)
  # Remove columns where all values are NA
  quant.data <- quant.data[, colSums(is.na(quant.data)) != nrow(quant.data)]
  # If no quantitative data is left return 8
  if (ncol(quant.data)==0) return(8)
  # I filtering out the data, the ensure rownames consistency
  data <- data[rownames(quant.data), ]

  # Get data content from passed column names
  if(data_type=="protein"){
    pro_id <- rownames(data)
  }else if(data_type=="peptide"){
    pro_id <- data[, pro_col]
    pep_str_seq <- data[, strSeq_col]
  }else if((data_type=="termini") || (data_type=="ptm")){
    pro_id <- data[, pro_col]
    pep_str_seq <- data[, strSeq_col]
    pep_mod_seq <- data[, modSeq_col]
  }

  # Expand the annotation
  annotate.data <- expandAnnotation(
    proteinIdentifier=pro_id,
    strippedSeq=pep_str_seq,
    modifiedSeq=pep_mod_seq,
    uniprotDB=uniprotDB,
    data_type=data_type
  )
  # If an error occurred at the expandAnnotation - error 9
  if (length(annotate.data)==1 & is.numeric(annotate.data)) return(9)

  # Add rownames to annotate.data
  rownames(annotate.data) <- rownames(data)
  # Ensure meta_data, quant.data, and annotate.data are data.frame
  meta_data <- as.data.frame(meta_data, check.names=FALSE)
  quant.data <- as.data.frame(quant.data, check.names=FALSE)
  annotate.data <- as.data.frame(annotate.data, check.names=FALSE)

  # Build the data.list 
  data.list <- list(
    name=modifType,
    repl=contains_rep,
    avrg=FALSE,
    filt=FALSE,
    impt=FALSE,
    norm=FALSE,
    meta_id=meta_id_col,
    meta_uniq=meta_list$uniqCol,
    meta=meta_data,
    quant=quant.data,
    annot=annotate.data
  )
  return(data.list)
}
