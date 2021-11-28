# require -> MsCoreUtils
# require -> psych

normalize_with_MsCore <- function(data, normalize.method="div.median"){
  # Get the data as matrix
  data_matrix <- as.matrix(data)
  # Normalize the data with the MsCoreUtils normalize_matrix function
  data_normalized <- MsCoreUtils::normalize_matrix(data_matrix,
                                                   method=normalize.method)
  # Get global factors based on median of global
  global_factor <- median(as.vector(data_matrix), na.rm=T)
  global_factor_norm <- median(as.vector(data_normalized), na.rm=T)
  if((normalize.method=="div.median") || (normalize.method=="div.mean")){
    scale_factor <- global_factor - global_factor_norm
  }else{
    scale_factor <- 10**(log10(global_factor) - log10(global_factor_norm))
  }
  # Return the normalized matrix as dataframe
  return(as.data.frame(data_normalized*scale_factor))
}
normalize_data <- function(dataList,
                           normalize.method="div.median",
                           group_factor=NULL){
  # Get the quantitative data
  quant_data <- dataList$quant
  # Check if the normalization method is based on global or grouped
  if(is.null(group_factor)){
    normalized_data <- normalize_with_MsCore(quant_data, normalize.method)
  }else{
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){
      stop("Passed grouping factor is not in metadata!")
    }
    grp_col <- metadata[, group_factor]
    # Get unique groups
    uniq_grps <- unique(grp_col)
    # Initialize normalized data
    normalized_data <- data.frame()
    # Loop through unique groups
    for(grp in uniq_grps){
      # Find indices to subset
      col2subset <- metadata[which(grp_col %in% grp), meta_id_col]
      # Subset the data
      subset_data <- quant_data[, col2subset]
      # Apply normalization to selected group
      normalized_subset <- normalize_with_MsCore(subset_data, normalize.method)
      # Concatanate the imputed data
      if(nrow(normalized_data)==0){
        normalized_data <- normalized_subset
      }else{
        normalized_data <- cbind(normalized_data, normalized_subset)
      }
    }
  }
  # Save the normalized data into quant data
  dataList$quant <- normalized_data[, colnames(quant_data)]
  # Return the dataList
  return(dataList)
}

global_and_sample_distribution_plot <- function(dataList, group_factor=NULL){
  # Get quant data
  quant_data <- dataList$quant
  # Create long version of the data
  data.long <- na.omit(melt(as.matrix(quant_data)))
  colnames(data.long) <- c("Feature", "Sample", "Intensity")
  rownames(data.long) <- NULL
  data.long <- as.data.frame(data.long)
  # If no group factor is passed
  if(is.null(group_factor)){
    p1 <- ggplot(data.long, aes(x=log10(Intensity))) +
            geom_density(show.legend = FALSE) + theme_pubclean() +
            rremove("xlab") + rremove("x.text") + rremove("x.ticks")
    p2 <- ggplot(data.long, aes(x=log10(Intensity), color=Sample)) +
            geom_density(show.legend = FALSE) + theme_pubclean()
    return(p1/p2)
  }else{
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # If there are more than 5 unique values for the group_factor
    if(length(unique(metadata[, group_factor])) > 5){
      stop("More than 5 unique values in group_factor won't be plotted!")
    }
    # Add group factor to the count data
    data.long <- cbind(data.long,
                       group=metadata[, group_factor][match(data.long$Sample,
                                                            metadata[, meta_id_col])])

    # Create Plots with group
    p1 <- ggplot(data.long, aes(x=log10(Intensity))) +
            geom_density(show.legend = FALSE) +
            facet_wrap(~group) + theme_pubclean() +
            rremove("xlab") + rremove("x.text") + rremove("x.ticks")
    p2 <- ggplot(data.long, aes(x=log10(Intensity), color=Sample)) +
            geom_density(show.legend = FALSE) +
            facet_wrap(~group) + theme_pubclean()
    return(p1/p2)
  }
}

plot_pair_panels <- function(data, col2subset=NULL, cor.method="spearman"){
  if(is.null(col2subset)){
    subset <- data[, c(1:4)]
  }else{
    subset <- data[, col2subset]
  }
  if(ncol(subset) > 15){stop("Comparing more than 15 samples not informative!")}

  psych::pairs.panels(log10(subset),
                       density = TRUE,
                       ellipses = TRUE,
                       method = cor.method,
                       pch = 20,
                       lm = TRUE,
                       cor = TRUE,
                       hist.col = 4,
                       cex.cor=.5,
                       stars = TRUE,
                       gap=0,
                       alpha=.5)
}
