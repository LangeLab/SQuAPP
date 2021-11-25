# require -> openxlsx
# require -> Biostrings

makeUniProtData <- function(fasta_path){
    # Parse the fasta with biostrings
    fasta <- Biostrings::readAAStringSet(filepath=fasta_path)
    fasta.df <- data.frame(names(fasta), paste(fasta))
    colnames(fasta.df) <- c('Fasta.name', 'Fasta.sequence')
    # Make parsed uniprot Fasta with more user friendly columns
    sequence.df <- fasta.df %>%
        mutate(Fasta.identifier = sub("^[> ]*(\\S+).*", "\\1", Fasta.name)) %>%
        separate(Fasta.identifier, c('db', 'Protein.identifier', 'Entry.name'), sep='\\|') %>%
        mutate(tmp_clean = sub(" OS=.*", "\\1", Fasta.name)) %>%
        mutate(Protein.name = sub(".*? ", "", tmp_clean)) %>%
        mutate(Gene.name = sub(".* GN=([^ ]+).*", "\\1", Fasta.name)) %>%
        mutate(Gene.name = if_else(str_detect(Gene.name,fixed('sp|')), "", Gene.name)) %>%
        mutate(Organism.identifier = sub(".* OX=([^ ]+).*", "\\1", Fasta.name)) %>%
        mutate(Protein.existence = sub(".* PE=([^ ]+).*", "\\1", Fasta.name)) %>%
        mutate(Sequence.version = sub(".* SV=([^ ]+).*", "\\1", Fasta.name)) %>%
        select(db, Organism.identifier, Entry.name,
               Protein.identifier, Protein.name,
               Gene.name, Fasta.sequence,
               Protein.existence,Sequence.version)

    return(sequence.df)
}

# TODO: Add exception catching and error handling parts to the openData
#  This is important due to csv extension can contain different seperation.
openData <- function(file_path, file_sep="comma"){
    # Conditional open data
    if(file_sep=="comma"){
        return(data.frame(read.csv(file_path, header=T, check.names=F, sep=',')))
    }
    if(file_sep=="tab"){
        return(data.frame(read.csv(file_path, header=T, check.names=F, sep="\t")))
    }
    if(file_sep=="excel"){
        return(data.frame(openxlsx::read.xlsx(file_path)))
    }
}

# WARNING: Important to provide metadata identifier to be comprehensive.
cleanMetadata <- function(meta_data, meta_id_col){
    # Remove rows if the metadata id is na
    return(data.frame(meta_data[!is.na(meta_data[, meta_id_col]), ]))
}

getPeptidePosition <- function(data) {
    # WARNING: The data column names are fixed coming from UniprotDB data
    #  Column names needs to be updated here if they changed in UniprotDB file.
    # Finds peptide start and end position as well as returning to important AA
    data <- data %>%
        dplyr::mutate(PEP.AA.length = stringr::str_length(Peptide.sequence)) %>%
        dplyr::mutate(PEP.Pos.start = stringr::str_locate(Fasta.sequence,
                                                          Peptide.sequence)[, 1]) %>%
        dplyr::mutate(PEP.AA.start = stringr::str_sub(Fasta.sequence,
                                                      start = .data$PEP.Pos.start,
                                                      end   = .data$PEP.Pos.start)) %>%

        dplyr::mutate(PEP.Pos.end   = stringr::str_locate(Fasta.sequence,
                                                          Peptide.sequence)[, 2]) %>%
        dplyr::mutate(PEP.AA.end = stringr::str_sub(Fasta.sequence,
                                                    start = .data$PEP.Pos.end,
                                                    end   = .data$PEP.Pos.end)) %>%

        dplyr::mutate(PEP.AA.before = stringr::str_sub(Fasta.sequence,
                                                       start = .data$PEP.Pos.start - 1,
                                                       end   = .data$PEP.Pos.start - 1)) %>%
        dplyr::mutate(PEP.AA.last   = stringr::str_sub(Fasta.sequence,
                                                       start = .data$PEP.Pos.end,
                                                       end   = .data$PEP.Pos.end)) %>%
        dplyr::mutate(PEP.AA.after  = stringr::str_sub(Fasta.sequence,
                                                       start = .data$PEP.Pos.end + 1,
                                                       end   = .data$PEP.Pos.end + 1))
    # Return the data
    return(data)
}

expandAnnotation <- function(proteinIdentifier,
                             strippedSeq,
                             modifiedSeq,
                             uniprotDB,
                             data_type
                            ){
    # Make the subset of uniprotDB based on passed protein identifiers
    res <- uniprotDB[match(proteinIdentifier, uniprotDB$Protein.identifier),
                     c("Entry.name", "Gene.name", "Protein.name", "Fasta.sequence")]
    # Create a new dataframe with passed data columns
    if(data_type=="protein"){
        df <- data.frame(Protein.identifier=proteinIdentifier)
    }
    if(data_type=="peptide"){
        df <- data.frame(Protein.identifier=proteinIdentifier,
                         Peptide.sequence=strippedSeq)
    }
    if((data_type=="termini") || (data_type=="ptm")){
        df <- data.frame(Protein.identifier=proteinIdentifier,
                         Peptide.sequence=strippedSeq,
                         Peptide.modified=modifiedSeq)
    }
    # Add uniprot data to the new dataframe for annotation
    df <- cbind(df, res)
    # Create protein length variable
    df$Protein.length <- stringr::str_length(df$Fasta.sequence)
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

explodeData <- function(data, data_type, id_col, pro_col, strSeq_col, modSeq_col){
  # Conditionally explode multi element column values into their own rows
  if(data_type == "protein"){
    # Explode the protein accessions
    data <- data %>%
      separate_rows(all_of(id_col), sep=";") %>%
      distinct() %>% data.frame()
    # Put the protein names into rownames
    rownames(data) <- data[, id_col]
  }else if(data_type == "peptide"){
    data <- data %>%
      separate_rows(all_of(id_col), sep=";")  %>%
      separate_rows(all_of(pro_col), sep=";") %>%
      separate_rows(all_of(strSeq_col), sep=";") %>%
      distinct() %>% data.frame()
    # Create unique rownames and add as index
    rownames(data) <- paste(data[,pro_col], data[,id_col], sep="|")
  }else if((data_type == "termini") || (data_type == "ptm")){
    data <- data %>%
      separate_rows(all_of(id_col), sep=";")  %>%
      separate_rows(all_of(pro_col), sep=";") %>%
      separate_rows(all_of(strSeq_col), sep=";") %>%
      separate_rows(all_of(modSeq_col), sep=";") %>%
      distinct() %>% data.frame()
    # TODO: This is not robust where the modified sequence contains less than that.
    data[, modSeq_col] <- sapply(strsplit(data[, modSeq_col], "_"), "[", 2)
    # Remove duplicate columns
    data <- data[!duplicated(data[, c(id_col, pro_col, modSeq_col)]), ]
    # Create unique rownames and add as index
    rownames(data) <- paste(data[,id_col], data[,pro_col], data[,modSeq_col],sep="|")
  }
  return(data.frame(data))
}

# Main Data to Preapare Data to be used in the app
prepareInputData <- function(data,                # Data being prepared for further use
                             id_col,              # Column name uniquely identifying the data
                             meta_data,           # Metadata describing the data
                             meta_id_col,         # Column name identifying samples from metadata
                             meta_uniq_col,       # Column name for unique samples stripped of replica from metadata
                             data_type,           # String identifying which data it is being prepared
                             uniprotDB,           # Fasta reference database for expanding annotation
                             pro_col=NULL,        # column name of the protein identifier
                             strSeq_col=NULL,     # column name of peptide stripped sequence
                             modSeq_col=NULL,     # column name of peptide modified sequence
                             contains_rep=TRUE,   # Logical variable to check if sample has replicas
                             modifType=""         # User defined text to identify the data
                             ){

  # If data returned is null return nothing
  if(is.null(data)){return()}
  # Create custom data name if it is not passed
  if(modifType==""){modifType <- data_type}
  # Re-create metadata if data doesn't contain replica
  if(!contains_rep){
    # WARNING: Replica column name is not robust and needs to be passed
    # Remove replica column
    meta_data$Replica <- NULL
    # Save unique column into the original id column
    meta_data[, meta_id_col] <- meta_data[, meta_uniq_col]
    # Remove the original unique column
    meta_data[, meta_uniq_col] <- NULL
    # Select only unique values in df
    meta_data <- unique(meta_data)
    # Reset the row ids
    rownames(meta_data) <- 1:nrow(meta_data)
  }
  # Annotate Columns
  col4annot <- unique(c(id_col, pro_col, strSeq_col, modSeq_col))
  # Remove rows where ID column has missing values
  data <- data[!is.na(data[, id_col]), ]
  # Replace Filtered or string NaN with NA
  data[data=="NaN"] <- NA
  data[data=="Filtered"] <- NA
  # Find column ids present in both metadata and data
  col2select <- intersect(meta_data[, meta_id_col], colnames(data))
  # Subset based on all columns
  data <- data[, unique(c(col4annot, col2select))]
  # Set numeric data index
  rownames(data) <- 1:nrow(data)
  # Explode the multi elements and create unique rownames
  data <- explodeData(data, data_type, id_col, pro_col, strSeq_col, modSeq_col)

  # Convert elements to numeric in the quantitative part of the data
  quant.data <- sapply(data[, col2select], as.numeric)
  # Add rownames to quant.data
  rownames(quant.data) <- rownames(data)
  # Remove columns where quantitative data is completely missing
  quant.data <- data.frame(quant.data[rowSums(is.na(quant.data)) != ncol(quant.data), ])
  # Make sure the rownames are consistent with annotation and quantitative data
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
  annotate.data <- expandAnnotation(proteinIdentifier=pro_id,
                                    strippedSeq=pep_str_seq,
                                    modifiedSeq=pep_mod_seq,
                                    uniprotDB=uniprotDB,
                                    data_type=data_type)
  # Add rownames to annotate.data
  rownames(annotate.data) <- rownames(data)
  # Create a list for the data
  data.list <- list(name=modifType,
                    repl=contains_rep,
                    avrg=FALSE,
                    filt=FALSE,
                    impt=FALSE,
                    norm=FALSE,
                    meta_id=meta_id_col,
                    meta_uniq=meta_uniq_col,
                    meta=data.frame(meta_data),
                    quant=data.frame(quant.data),
                    annot=data.frame(annotate.data))
  return(data.list)
}
