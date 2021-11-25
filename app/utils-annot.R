getSequenceWindow <- function(df, numExtend, modificationType){
  if("Fasta.sequence" %in% colnames(df)){
    df["Window.size"] <- ((numExtend)*2) + 1
    # Create peptide end and start windows
    df <- df %>%
        dplyr::mutate(PEP.End.window = stringr::str_sub(Fasta.sequence,
                                                        start = .data$PEP.Pos.end - numExtend,
                                                        end   = .data$PEP.Pos.end + numExtend)) %>%
        dplyr::mutate(PEP.Start.window = stringr::str_sub(Fasta.sequence,
                                                          start = .data$PEP.Pos.start - numExtend,
                                                          end   = .data$PEP.Pos.start + numExtend))

    # Modification Specific Columns
    if(modificationType == "Nterm"){
        df["PTM.Protein.Pos"] <- df["PEP.Pos.start"]
        df["PTM.PEP.Pos"] <- 1
        df["PTM.AA"] <- df["PEP.AA.start"]
        df["PTM.Window"] <- df["PEP.Start.window"]
    }else if(modificationType=="Cterm"){
        df["PTM.Protein.Pos"] <- df["PEP.Pos.end"]
        df["PTM.PEP.Pos"] <- nchar(df$Peptide.sequence)
        df["PTM.AA"] <- df["PEP.AA.end"]
        df["PTM.Window"] <- df["PEP.End.window"]
    }else if(modificationType=="ptm" || modificationType=="Phospho"){
        # Get the PTM Annotations to the column
        df["PTM.annotated"] <- sapply(str_extract_all(df[["Peptide.modified"]],
                                                      "(?<=\\[).+?(?=\\])"), toString)
        # Prepare PTM.Tmp for looping.
        df["PTM.Tmp"] <- str_replace_all(df[["Peptide.modified"]], "(?<=\\[).+?(?=\\])", "")
        df["PTM.Tmp"] <- str_replace_all(df[["PTM.Tmp"]], fixed("[]"), "<")
        df["PTM.Tmp"] <- sapply(str_locate_all(df[["PTM.Tmp"]], "<"), toString)

        # Initialize a vectors
        mod_pos_vector <- c()
        mod_aas_vector <- c()
        mod_seq_vector <- c()
        mod_rel_pos_vector <- c()
        # Loop through each row
        for(i in 1:nrow(df)){
            # Split the current PTM position
            X <- strsplit(df[i, "PTM.Tmp"], split=", ")[[1]]
            # strsplit results start-end, that's why get first half of the vector
            cur_pos <- X[1:(length(X)/2)]
            # Initialize a decrement since position is effected by annot character
            #  after the first annotation character
            decr <- 1
            # Initialize a current vectors
            new_pos <- c()
            new_aas <- c()
            new_seq <- c()
            new_rel_pos <- c()
            # Loop through the multiple PTMs if they are more then one.
            for(j in cur_pos){
                cur_aa_pos <- (as.numeric(j) - decr)
                cur_rel_pos <- df[i, "PEP.Pos.start"] + (cur_aa_pos - 1)
                cur_aa <- substr(df[i, "Fasta.sequence"], cur_rel_pos, cur_rel_pos)
                cur_seq <- substr(df[i, "Fasta.sequence"],
                                  (cur_rel_pos-numExtend),
                                  (cur_rel_pos+numExtend))
                new_pos <- c(new_pos, cur_aa_pos)
                new_aas <- c(new_aas, cur_aa)
                new_seq <- c(new_seq, cur_seq)
                new_rel_pos <- c(new_rel_pos, cur_rel_pos)
                decr <- decr + 1
            }
            # Append the results to the main vectors for saving
            mod_pos_vector <- c(mod_pos_vector, paste(as.character(new_pos), collapse=", "))
            mod_aas_vector <- c(mod_aas_vector, paste(as.character(new_aas), collapse=", "))
            mod_seq_vector <- c(mod_seq_vector, paste(as.character(new_seq), collapse=", "))
            mod_rel_pos_vector <- c(mod_rel_pos_vector, paste(as.character(new_rel_pos), collapse=", "))
        }

        # Save the PTM related vectors
        df["PTM.Protein.Pos"] <- mod_rel_pos_vector
        df["PTM.PEP.Pos"] <- mod_pos_vector
        df["PTM.AA"] <- mod_aas_vector
        df["PTM.Window"] <- mod_seq_vector
        df["PTM.Tmp"] <- NULL

    }
    df$Fasta.sequence <- NULL
  }
  return(df)
}
