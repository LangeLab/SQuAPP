# require -> MsCoreUtils

# Imputation by all using MsCoreUtils
impute_with_MsCore <- function(data, impute.method="MinProb", val=NULL){
  if(is.null(val)){
    # Calculate the imputed data based on given imputation method
    tmp_matrix <- MsCoreUtils::impute_matrix(as.matrix(log10(data)),
                                             method=impute.method)
  }else{
    tmp_matrix <- MsCoreUtils::impute_matrix(as.matrix(log10(data)),
                                             method=impute.method,
                                             val=val)
  }
  # Return the value as dataframe with scaled up version
  return(data.frame(10**(tmp_matrix)))
}

impute_with_downshifted_normal <- function(data, downshift_mag){
  # Create log10 version of the data
  data <- log10(data)
  # Get aggregated distribution of the data by flattening it
  flatten_data <- as.vector(as.matrix(data))
  # Get complete values
  complete_dist <- flatten_data[!is.na(flatten_data)]
  # Initialize imputed dataframe
  imputed_data <- data.frame(matrix(ncol=ncol(data), nrow=nrow(data)))
  # Create imputed distribution
  for(i in 1:ncol(data)){
    # Create column in the imputed data
    imputed_data[, i] <- data[, i]
    # Find missing value index of the current column
    missing_ind <- is.na(imputed_data[, i])
    # Create downshifted normal distribution from the data distribution
    impute_dist <- rnorm(
      sum(missing_ind),
      sd=sd(complete_dist),
      mean=(mean(complete_dist)-(downshift_mag*sd(complete_dist)))
    )
    # Replace missing values with the downshifted normal distribution values
    imputed_data[missing_ind, i] <- impute_dist
  }
  imputed_data <- data.frame(10**(imputed_data))
  colnames(imputed_data) <- colnames(data)
  rownames(imputed_data) <- rownames(data)
  # Return the imputed data
  return(imputed_data)
}

impute_data <- function(dataList,
                        impute_method="MinProb",
                        group_factor=NULL,
                        downshift_mag=3.5,
                        impute_value=NULL){
  # Get quantitative data
  quant_data <- dataList$quant

  # Check if the imputation method is based on global or grouped
  if(is.null(group_factor)){
    if(impute_method == "Down-shifted Normal"){
      imputed_data <- impute_with_downshifted_normal(quant_data, downshift_mag)
    }else{
      if(impute_method == "with" && is.null(impute_value)){
        stop("A value must be passed when using impute_with method!")
      }
      imputed_data <- impute_with_MsCore(quant_data,
                                         impute.method=impute_method,
                                         val=impute_value)
    }
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
    # Initialize imputed data
    imputed_data <- data.frame()
    if(impute_method == "Down-shifted Normal"){
      for(grp in uniq_grps){
        # Find indices to subset
        col2subset <- metadata[which(grp_col %in% grp), meta_id_col]
        # Subset the data
        subset_data <- quant_data[, col2subset]
        # Apply the imputation for selected group
        subset_imputed <- impute_with_downshifted_normal(subset_data, downshift_mag)
        # Concatanate the imputed data
        if(nrow(imputed_data)==0){
          imputed_data <- subset_imputed
        }else{
          imputed_data <- cbind(imputed_data, subset_imputed)
        }
      }
    }else{
      if(impute_method == "with" && is.null(impute_value)){
        stop("A value must be passed when using impute_with method!")
      }
      for(grp in uniq_grps){
        # Find indices to subset
        col2subset <- metadata[which(grp_col %in% grp), meta_id_col]
        # Subset the data
        subset_data <- quant_data[, col2subset]
        # Apply the imputation for selected group
        subset_imputed <- impute_with_MsCore(subset_data,
                                             impute.method=impute_method,
                                             val=impute_value)
        # Concatanate the imputed data
        if(nrow(imputed_data)==0){
          imputed_data <- subset_imputed
        }else{
          imputed_data <- cbind(imputed_data, subset_imputed)
        }
      }
    }
  }
  # Save the imputed data into quant data
  dataList$quant <- imputed_data[, colnames(quant_data)]
  # Save the imputed data
  dataList$impute_index <- which(is.na(quant_data))
  # Return the dataList
  return(dataList)
}

# Stacked Bar plot from ggplot to present missing value counts in the data
missing_values.stacked_bar_plot <- function(dataList, group_factor=NULL){
  # Get quantiative data
  data <- dataList$quant
  # Get missing counts
  missing_counts <- colSums(is.na(data))
  # Get complete counts
  complete_counts <- (nrow(data) - missing_counts)
  # Put them in data format
  count_data <- data.frame(t(rbind(complete_counts, missing_counts)))
  # Pass column names for better reading
  colnames(count_data) <- c("complete", "imputed")
  # Get rownames as samples
  count_data$samples <- rownames(count_data)
  # If a grouping factor is passed
  if(!is.null(group_factor)){
    # Open the metadata into a variable
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # If there are more than 5 unique values for the group_factor
    if(length(unique(metadata[, group_factor])) > 5){
      stop("More than 5 unique values in group_factor won't be plotted!")
    }
    # Add group factor to the count data
    count_data <- cbind(count_data,
                        group=metadata[, group_factor][match(count_data$samples,
                                                             metadata[, meta_id_col])])

    # Convert the data into long format
    count_data <- melt(count_data, id.vars=c("samples", "group"),
                      value.name="count", variable.name="state")
    # Create average count table for horizontal indicators
    avg_counts <- count_data %>%
        group_by(group, state) %>%
        summarize(avg_count = mean(count)) %>%
        filter(state=="imputed") %>%
        select(group, avg_count)
    # Create the plot
    p <- ggplot(count_data, aes(fill=state, y=count, x=samples)) +
      geom_bar(position="stack", stat="identity", width=1) +
      facet_grid(. ~group, scales = "free_x", space='free') +
      theme_pubclean() +
      scale_fill_manual(values=c("complete"="#00AFBB", "imputed"="#E7B800")) +
      theme(panel.spacing = unit(.5, "lines"),
            axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5)) +
      geom_hline(data=avg_counts,
                 aes(yintercept=avg_count),
                 colour = "#e63946",
                 linetype='dotted',
                 show.legend = NA)
    # Return the plot
    return(p)

  # If grouping factor is not passed plot the whole data without facet
  }else{
    # Convert the data into long format
    count_data <- melt(count_data, id.vars=c("samples"),
                      value.name="count", variable.name="state")
    # Create the plot
    p <- ggplot(count_data, aes(fill=state, y=count, x=samples)) +
      geom_bar(position="stack", stat="identity", width=1) +
      theme_pubclean() +
      scale_fill_manual(values=c("complete"="#00AFBB", "imputed"="#E7B800")) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
    return(p)
  }
}

imputed_value_distribution.density_plots <- function(dataList,
                                                     impute.method="MinProb",
                                                     group_factor=NULL,
                                                     downshift_mag=3.5){
  # Get the quant data
  quant_data <- dataList$quant

  # If a grouping factor is passed
  if(!is.null(group_factor)){
    # Open the metadata into a variable
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    grp_col <- metadata[, group_factor]
    # Get unique groups
    uniq_grps <- unique(grp_col)
    # If there are more than 5 unique values for the group_factor
    if(length(uniq_grps)  > 5){
      stop("More than 5 unique values in group_factor won't be plotted!")
    }
    plot_data <- data.frame()
    for(grp in uniq_grps){
      # Find indices to subset
      col2subset <- metadata[which(grp_col %in% grp), meta_id_col]
      # Subset the data
      subset_data <- quant_data[, col2subset]
      # Create flatten version of the data
      flatten_data <- as.vector(as.matrix(subset_data))
      # Find the missing values from the flatten version
      missing_ind <- is.na(flatten_data)
      # Get complete values
      complete_dist <- flatten_data[!is.na(flatten_data)]
      # If imputation methods is selected
      if(impute.method != "No imputation"){
        if(impute.method != "Down-shifted Normal"){
          subset_data <- impute_with_MsCore(subset_data,
                                            impute.method=impute.method)

          imputed_dist <- as.vector(as.matrix(subset_data))[missing_ind]
        }else{
          if(is.null(downshift_mag)){
            stop("donwshift_mag argument needs to be passed id Down-shifted normal method is selected")
          }
          imputed_dist <- rnorm(sum(missing_ind),
                                sd=sd(log10(complete_dist)),
                                mean=(mean(log10(complete_dist))-(downshift_mag*sd(log10(complete_dist)))))
          imputed_dist <- 10 ** imputed_dist
        }
      }
      # Create plot_df subset for given grouping
      sub_plot_df <- data.frame(rbind(cbind(intensity=complete_dist, state="complete"),
                                      cbind(intensity=imputed_dist, state="imputed")))
      # Add grouping variable
      sub_plot_df$group <- grp
      # Concatenate the data
      plot_data <- rbind(plot_data, sub_plot_df)
    }
    # Take to log 10 scale
    plot_data$intensity <- log10(as.numeric(plot_data$intensity))

    p1 <- ggdensity(plot_data, x="intensity", y=c("..count.."), facet.by="group",
                   add="median", color="state", fill="state",
                   palette = c("#457b9d", "#fca311"),
                   size=.25, ggtheme=theme_pubclean()) +
      rremove("xlab") + rremove("x.text") + rremove("x.ticks")
    p2 <- ggdensity(plot_data, x="intensity", y=c("..density.."), facet.by="group",
                   add="median", color="state", fill="state",
                   palette = c("#457b9d", "#fca311"),
                   xlab="log10(intensity)",# ylab="Number of Features",
                   size=.25, ggtheme=theme_pubclean()) + rremove("legend")

    return(p1/p2)

  # If grouping factor is not passed
  }else{
    # Create flatten version of the data
    flatten_data <- as.vector(as.matrix(quant_data))
    # Find the missing values from the flatten version
    missing_ind <- is.na(flatten_data)
    # Get complete values
    complete_dist <- flatten_data[!is.na(flatten_data)]
    # If imputation methods is selected
    if(impute.method != "No imputation"){
      if(impute.method != "Down-shifted Normal"){
        quant_data <- impute_with_MsCore(quant_data,
                                         impute.method=impute.method)

        imputed_dist <- as.vector(as.matrix(quant_data))[missing_ind]
      }else{
        if(is.null(downshift_mag)){
          stop("donwshift_mag argument needs to be passed id Down-shifted normal method is selected")
        }
        imputed_dist <- rnorm(sum(missing_ind),
                              sd=sd(log10(complete_dist)),
                              mean=(mean(log10(complete_dist))-(downshift_mag*sd(log10(complete_dist)))))
        imputed_dist <- 10 ** imputed_dist
      }
    }
    # Put them into a dataframe
    plot_data <- data.frame(rbind(cbind(intensity=complete_dist, state="complete"),
                                  cbind(intensity=imputed_dist, state="imputed")))
    # Take to log 10 scale
    plot_data$intensity <- log10(as.numeric(plot_data$intensity))

    p1 <- ggdensity(plot_data, x="intensity", y=c("..count.."),
                   add="median", color="state", fill="state",
                   palette = c("#457b9d", "#fca311"),
                   size=.25, ggtheme=theme_pubclean()) +
      rremove("xlab") + rremove("x.text") + rremove("x.ticks")
    p2 <- ggdensity(plot_data, x="intensity", y=c("..density.."),
                   add="median", color="state", fill="state",
                   palette = c("#457b9d", "#fca311"),
                   xlab="log10(intensity)",# ylab="Number of Features",
                   size=.25, ggtheme=theme_pubclean()) + rremove("legend")

    return(p1/p2)
  }
}

compare.imputation_split_violin_plot <- function(dataList,
                                                 dataList_new,
                                                 group_factor=NULL){
  # Get the metadata
  metadata <- dataList$meta
  # Get the melted version of the original data
  quant_data_long <- na.omit(melt(as.matrix(dataList$quant)))
  colnames(quant_data_long) <- c("Feature", "Sample", "Intensity")
  rownames(quant_data_long) <- NULL
  quant_data_long$state <- "Original"
  # Get the melted version of the imputed data
  imputed_data_long <- na.omit(melt(as.matrix(dataList_new$quant)))
  colnames(imputed_data_long) <- c("Feature", "Sample", "Intensity")
  rownames(imputed_data_long) <- NULL
  imputed_data_long$state <- "Imputed"
  # Concatanate the long datasets
  plot_data <- data.frame(rbind(quant_data_long, imputed_data_long))

  # If grouping variable is passed
  if(!is.null(group_factor)){
    # Check if necessary variables passed with group variable
    if(!(group_factor %in% colnames(metadata))){
      stop("group_factor passed is not in the metadata!")
    }
    # If there are more than 5 unique values for the group_factor
    if(length(unique(metadata[, group_factor]))  > 5){
      stop("More than 5 unique values in group_factor won't be plotted!")
    }
    # Merge the grouping factor to the plot data
    plot_data <- merge(plot_data,
                       metadata[, c(dataList$meta_id, group_factor)],
                       by.x="Sample",
                       by.y=dataList$meta_id)
    # Standardize column names
    colnames(plot_data) <- c("Sample", "Feature", "Intensity", "state", "group")
    # Make custom title to show
    p <- ggplot(plot_data, aes(x=Sample, y=log10(Intensity), fill=state)) +
                geom_split_violin(alpha = .4, trim = T) +
                geom_boxplot(width = .175, alpha = .6,
                             show.legend = FALSE, outlier.shape = NA) +
                facet_grid(. ~group, scales = "free_x", space='free') +
                scale_fill_manual(values = c("Imputed"="#457b9d",
                                             "Original"="#fca311")) +
                theme_pubclean() +
                theme(panel.spacing = unit(.5, "lines"),
                          axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  }else{
    # Plot the split violin
    p <- ggplot(plot_data, aes(x=Sample, y=log10(Intensity), fill=state)) +
                geom_split_violin(alpha = .4, trim = T) +
                geom_boxplot(width = .175, alpha = .6,
                             show.legend = FALSE, outlier.shape = NA) +
                scale_fill_manual(values = c("Imputed"="#457b9d",
                                             "Original"="#fca311")) +
                theme_pubclean() +
                theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  }

  return(p)
}
