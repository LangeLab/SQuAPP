prepare_subset_preview_data <- function(dataList, feature_selection="all"){
  # Get quantitative data
  quant_data <- dataList$quant
  # Get stats data
  stat_data <- dataList$stats
  # Based on feature selection apply clustering and visualization
  if(feature_selection == "all"){
    rows2select <- rownames(quant_data)
  # If all significant is selected
  }else if(feature_selection == "all significant"){
    rows2select <- rownames(stat_data[which(stat_data$significance !=
                                            "no significance"), ])
  # Select specific sub-group of significant
  }else{
    rows2select <- rownames(stat_data[which(stat_data$significance ==
                                            feature_selection), ])
  }
  # Subset the quantitative data based on the selected rows
  return(rows2select)
}

create_protein_domain_data <- function(selected_protein,
                                       dataset_lists){

  # Check if any level of data has inconsistency in replica
  reps <- c()
  for(i in names(dataset_lists)){
    reps <- c(reps, dataset_lists[[i]]$repl)
  }
  comb_colnames <- c()
  # Make sure all levels are averaged to give consistency
  if(length(unique(reps)) > 1){
    for(i in names(dataset_lists)){
      if(dataset_lists[[i]]$repl){
        dataset_lists[[i]] <- average_data(dataset_lists[[i]])
      }
      if(length(comb_colnames) < 1){
        comb_colnames<-colnames(dataset_lists[[i]]$quant)
      }else{
        # Get intersected column names for consistency
        comb_colnames <- intersect(comb_colnames, colnames(dataset_lists[[i]]$quant))
      }
    }
  }
  # Loop through available data levels to gather their data
  comb_data <- data.frame()
  for(i in names(dataset_lists)){
    # Don't loop protein level data if they exist
    if(i == "protein") { next }
    cur_list <- dataset_lists[[i]]
    # If current list is null skip
    if(is.null(cur_list)){ next }
    # Find indices where it matches to the protein
    cur_ind <- which(cur_list$annot[, "Protein.identifier"] == selected_protein)
    # If no indices returned emtpy skip
    if(length(cur_ind) == 0){ next }
    # Subset quantitative and annotation datasets
    sub_quant <- cur_list$quant[cur_ind, ]
    # peptide and (termini / ptm) have differences
    if(i == "peptide"){
      sub_annot <- cur_list$annot[cur_ind, c("Protein.identifier",
                                             "Peptide.sequence",
                                             "PEP.Pos.start",
                                             "PEP.AA.length")]
      colnames(sub_annot) <- c("Protein.identifier", "Peptide.modified",
                               "PEP.Pos.start", "PEP.AA.length")

    }else{
      sub_annot <- cur_list$annot[cur_ind, c("Protein.identifier",
                                           "Peptide.modified",
                                           "PEP.Pos.start",
                                           "PEP.AA.length")]
    }
    # Save name as modification type
    sub_annot[, "Modification.type"] <- cur_list$name
    # Combine annot and quant
    sub_comb <- cbind(sub_quant[, comb_colnames], sub_annot)
    # Combine the data
    if(nrow(comb_data) < 1){
      comb_data <- sub_comb
    }else{ comb_data <- rbind(comb_data, sub_comb) }
  }

  # If given protein nothing matches return NULL
  if(nrow(comb_data) < 1){return( NULL )}

  df <- comb_data %>%
    pivot_longer(cols=all_of(comb_colnames),
                 values_drop_na=TRUE,
                 names_to="Samples",
                 values_to="Intensity") %>%
    separate_rows(Peptide.modified, sep=";") %>%
    distinct(Protein.identifier, Peptide.modified, Samples, .keep_all= TRUE) %>%
    data.frame()
  # Create temporary column to extract PTM position from modified sequence
  df["PTM.Tmp"] <- str_replace_all(df[["Peptide.modified"]], "(?<=\\[).+?(?=\\])", "")
  df["PTM.Tmp"] <- str_replace_all(df[["PTM.Tmp"]], fixed("[]"), "<")
  df["PTM.Tmp"] <- str_sub(df[["PTM.Tmp"]], start=2, end=-4)
  df["PTM.Tmp"] <- sapply(str_locate_all(df[["PTM.Tmp"]], "<"), toString)

  # Loop through each values to robustly extract PTM position
  mod_pos_vector <- c()
  for(i in 1:nrow(df)){
    mod_type <- df[i, "Modification.type"]
    if(mod_type == "Nterm" || mod_type == "peptide"){
      mod_pos_vector <- c(mod_pos_vector, df[i, "PEP.Pos.start"])
    }else{
      X <- strsplit(df[i, "PTM.Tmp"], split=", ")[[1]]
      # strsplit results start-end, that's why get first half of the vector
      cur_pos <- as.numeric(X[1:(length(X)/2)][1]) - 1

      mod_pos_vector <- c(mod_pos_vector, (df[i, "PEP.Pos.start"] + cur_pos))
    }
  }
  # Save the position in the data
  df["PTM.Pos"] <- mod_pos_vector
  df["PTM.Tmp"] <- NULL
  # Create position end variable
  df$PEP.Pos.End <- df$PTM.Pos + df$PEP.AA.length
  # Drop missing values if any
  df <- df %>% drop_na() %>% data.frame()
  # Merge with the metadata variables to be used later
  df <- merge(df, cur_list$meta,
              by.x="Samples", by.y=cur_list$meta_id,
              all.x=TRUE)

  # Return the data
  return(df)
}


# Create user selected intensity calculation method for protein domain plot
custom_protein_domain_intensities <- function(df,
                                              intensity_method="Ratio",
                                              group_variable=NULL,
                                              group_values=NULL){
  # If intensity method is Ratio
  if(intensity_method=="Ratio"){
    # Check if any of the necessary variables is missing
    if(is.null(group_variable) || (is.null(group_values))){
      stop("Ratio intensity method requires grouping variable and values to be selected")
    }else{
      # if full apply the ratio calculation based on the group variable and values
      df <- df %>%
        filter(.data[[group_variable]] %in% group_values) %>%
        group_by(Peptide.modified, PEP.AA.length,
                 PTM.Pos, Modification.type,
                 .data[[group_variable]]) %>%
        summarise(tmp=mean(Intensity)) %>%
        group_by(Peptide.modified, PEP.AA.length,
                 PTM.Pos, Modification.type) %>%
        summarise(Calc.Intensity = (log2(tmp[SampleType==group_values[1]]) -
                                    log2(tmp[SampleType==group_values[2]]))) %>%
        data.frame()
    }
  }else if(intensity_method=="Sum"){
    df <- df %>%
      group_by(Peptide.modified, PEP.AA.length,
               PTM.Pos, Modification.type) %>%
      summarise(Calc.Intensity=sum(Intensity)) %>%
      data.frame()
  }else if(intensity_method=="Mean"){
    df <- df %>%
      group_by(Peptide.modified, PEP.AA.length,
               PTM.Pos, Modification.type) %>%
      summarise(Calc.Intensity=mean(Intensity)) %>%
      data.frame()
  }else if(intensity_method=="Median"){
    df <- df %>%
      group_by(Peptide.modified, PEP.AA.length,
               PTM.Pos, Modification.type) %>%
      summarise(Calc.Intensity=median(Intensity)) %>%
      data.frame()
  }else{
    stop('Select valid intensity method: c("Ratio", "Sum", "Mean", "Median)')
  }
  return(df)
}

# requires -> drawProteins
# requires -> cowplot
plot_protein_domain <- function(current_data,
                                uniprot_data,
                                intensity_method="Ratio"){

  # Create a uniprot based domain plot
  uniProt_plot <- drawProteins::draw_canvas(uniprot_data)
  uniProt_plot <- drawProteins::draw_chains(uniProt_plot, uniprot_data)
  uniProt_plot <- drawProteins::draw_domains(uniProt_plot, uniprot_data)
  uniProt_plot <- drawProteins::draw_repeat(uniProt_plot, uniprot_data)
  uniProt_plot <- drawProteins::draw_motif(uniProt_plot, uniprot_data)
  uniProt_plot <- drawProteins::draw_phospho(uniProt_plot, uniprot_data,
                                             size = 5, fill = "#ee9b00")
  # Stylize the plot a bit for cowplot
  uniProt_plot <- uniProt_plot + theme_pubclean() +
    theme(axis.line.y=element_blank(), axis.ticks.y=element_blank(),
          axis.text.y=element_blank(), legend.position='bottom',
          legend.key.size=unit(15, "pt")) +  ggtitle("Uniprot Reference")

  if(intensity_method=="Ratio"){
    # Create a current data based lolipop data establishing the intensity
    current_plot <- ggplot(current_data, aes(x=PTM.Pos, y=Calc.Intensity)) +
        geom_point(aes(fill=Modification.type), colour="black", pch=21, size=5)+
        geom_segment(alpha=0.5, aes(x=PTM.Pos, xend=PTM.Pos, y=0, yend=Calc.Intensity)) +
        # ylim(0,max((current_data$Calc.Intensity))+.25) +
        xlim(-max(uniprot_data$end, na.rm=TRUE)*0.2,
              max(uniprot_data$end, na.rm=TRUE) +
              max(uniprot_data$end, na.rm=TRUE)*0.1) +
        facet_wrap(~Modification.type, strip.position="left", ncol=1)+
        scale_fill_manual(values=c("peptide"="#005f73",
                                   "Phospho"="#ee9b00",
                                   "Nterm"="#ae2012")) +
        theme_pubclean() + labs(title="Current Data", fill="Data Level") +
        xlab("") + ylab("log2FC")

  }else{
    # Create a current data based lolipop data establishing the intensity
    current_plot <- ggplot(current_data, aes(x=PTM.Pos, y=log2(Calc.Intensity))) +
        geom_point(aes(fill=Modification.type), colour="black", pch=21, size=5)+
        geom_segment(alpha=0.5, aes(x=PTM.Pos, xend=PTM.Pos, y=0, yend=log2(Calc.Intensity))) +
        # ylim(0,max(log2(current_data$Calc.Intensity))+1) +
        xlim(-max(uniprot_data$end, na.rm=TRUE)*0.2,
              max(uniprot_data$end, na.rm=TRUE) +
              max(uniprot_data$end, na.rm=TRUE)*0.1) +
        facet_wrap(~Modification.type, strip.position="left", ncol=1)+
        scale_fill_manual(values=c("peptide"="#005f73",
                                   "Phospho"="#ee9b00",
                                   "Nterm"="#ae2012")) +
        theme_pubclean() + labs(title="Current Data", fill="Data Level") +
        xlab("") + ylab(paste0("log2(",intensity_method,")"))

  }

  # Put the plot together and align them
  res <- cowplot::plot_grid(current_plot, uniProt_plot, ncol=1, align='v', axis='lr')
  # Return the plot
  return(res)
}
