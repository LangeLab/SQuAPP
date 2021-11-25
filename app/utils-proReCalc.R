# Calculate intensities from peptides
proteinRecalculate <- function(pepList, calc.method){
  # Get quantitative data
  data <- pepList$quant
  # Save protein identifier from the annotation for group_by
  data$Protein.identifier <- pepList$annot$Protein.identifier
  # Sum all the quantified peptides into that protein
  if (calc.method=="sum_all"){
    protein_data <- data %>%
      group_by(Protein.identifier) %>%
      summarize_if(is.numeric, sum, na.rm=TRUE) %>%
      data.frame()
  }
  if(calc.method=="mean_all"){
    protein_data <- data %>%
      group_by(Protein.identifier) %>%
      summarize_if(is.numeric, mean, na.rm=TRUE) %>%
      data.frame()
  }
  if(calc.method=="sum_top3"){
    protein_data <- data %>%
      group_by(Protein.identifier) %>%
      top_n(n=3) %>%
      summarize_if(is.numeric, sum, na.rm=TRUE) %>%
      data.frame()
  }
  if(calc.method=="mean_top3"){
    protein_data <- data %>%
      group_by(Protein.identifier) %>%
      top_n(n=3) %>%
      summarize_if(is.numeric, mean, na.rm=TRUE) %>%
      data.frame()
  }
  # Replace 0 with NAs
  protein_data[protein_data==0] <- NA
  # Put the protein identifier into rownames
  rownames(protein_data) <- protein_data$Protein.identifier
  # Remove the protein identifier from the columns
  protein_data$Protein.identifier <- NULL
  # Return the dataframe
  return(protein_data)
}

compare_protein_recalc_split_violin_plot <- function(df1, df2){
  # Get the melted version of the original data
  df1.long <- na.omit(melt(as.matrix(df1)))
  colnames(df1.long) <- c("Feature", "Sample", "Intensity")
  rownames(df1.long) <- NULL
  df1.long$state <- "Original"
  # Get the melted version of the recalculated data
  df2.long <- na.omit(melt(as.matrix(df2)))
  colnames(df2.long) <- c("Feature", "Sample", "Intensity")
  rownames(df2.long) <- NULL
  df2.long$state <- "Recalculated"
  # Concatanate the long datasets
  plot_data <- data.frame(rbind(df1.long, df2.long))
  # Plot the split violin
  p <- ggplot(plot_data, aes(x=Sample, y=log10(Intensity), fill=state)) +
              geom_split_violin(alpha = .4, trim = T) +
              geom_boxplot(width = .175, alpha = .6,
                           show.legend = FALSE, outlier.shape = NA) +
              scale_fill_manual(values = c("Original"="#fca311",
                                           "Recalculated"="#457b9d")) +
              theme_pubclean() +
              theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  return(p)
}
