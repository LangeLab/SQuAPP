remove_samples <- function(dataList, samples2remove){
  # get the quantitative data
  quant_data <- dataList$quant
  # get the metadata
  meta_data <- dataList$meta
  # Remove the column names based on user selection
  qcols <- colnames(quant_data)[!(colnames(quant_data) %in% samples2remove)]
  # Subset the quantitative data with remove sample column names
  dataList$quant <- dataList$quant[, qcols]
  # Update the metadata by removing the samples selected to be removed
  dataList$meta <- meta_data[meta_data[, dataList$meta_id] %in% qcols, ]
  # Return update dataList
  return(dataList)
}

filter_features <- function(dataList, filterLevel, group_factor=NULL){
  # get the quantitative data
  quant_data <- dataList$quant

  # If filtering is done on global - consider all samples in one group
  if(is.null(group_factor)){
    # Applying the filtering by passed filtered level
    new_quant_data <- data.frame(quant_data[apply(quant_data, 1,
                                                  function(x) sum(!is.na(x)) > filterLevel/100*length(x)
                                                  ), ])
  # If filtering is gonna be done by a grouping variable based on metadata
  }else{
    # get the metadata
    meta_data <- dataList$meta
    # Get all features
    feature_intersection <- rownames(quant_data)
    # Loop through unique grouping values
    for(i in unique(meta_data[, group_factor])){
      # Find the matching indices
      match_locs <- which(meta_data[, group_factor] == i)
      # If only one element has been matched - skip it
      if (length(match_locs) == 1){ next }
      # Get the subset data
      sub_data <- quant_data[, meta_data[match_locs, dataList$meta_id]]
      # Apply the filtering based on filter level
      sub_data <- data.frame(sub_data[apply(sub_data, 1,
                                            function(x) sum(!is.na(x)) > filterLevel/100*length(x)
                                            ),])
      # Append the data to new_quant_data
      feature_intersection <- intersect(feature_intersection, rownames(sub_data))
    }
    # Subset the data based on the filtering
    new_quant_data <- quant_data[feature_intersection, ]
  }

  # Update the dataList dataframe and variables after filteration
  dataList$quant <- new_quant_data
  dataList$annot <- dataList$annot[rownames(new_quant_data), ]

  return(dataList)
}

plot_completeness_counts <- function(dataList, group_factor=NULL){
    # Get quantitative data
  quant_data <- dataList$quant
  # If no group_factor is passed
  if(is.null(group_factor)){
    # Get the completeness df
    complete.df <- as.data.frame(table(rowSums(!is.na(quant_data))))
    # Convert factor to numeric
    complete.df$Var1 <- as.numeric(levels(complete.df$Var1))[complete.df$Var1]
    # Plot single
    p <- ggplot(complete.df, aes(x=Var1, y=Freq)) +
            geom_bar(stat="identity", width=1, color = "steelblue", fill="white") +
            theme_pubclean() + labs(y="# of Features", x="# of Complete Samples") +
            theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  }else{
    # Get the metadata
    metadata <- dataList$meta
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}

    # Initialize the dataframe to collected completenes
    complete.df <- data.frame()
    # Loop through each group in group_factor
    for(i in unique(metadata[, group_factor])){
      # get the current columns to subset
      col2subset <- metadata[which(metadata[, group_factor]==i), dataList$meta_id]
      # Subset the data
      subset_data <- quant_data[, col2subset]
      # Get completeness df
      if(is.null(nrow(subset_data))){
        df <- as.data.frame(table(as.numeric(!is.na(subset_data))))
      }else{
        df <- as.data.frame(table(rowSums(!is.na(subset_data))))
      }
      # Assign group
      df$group <- i
      # Concat the dataframe to complete.df
      if(nrow(complete.df) < 1){
        complete.df <- df
      }else{
        complete.df <- rbind(complete.df, df)
      }
    }
    p <- ggplot(complete.df, aes(x=Var1, y=Freq)) +
          geom_bar(stat="identity", width=1, color = "steelblue", fill="white") +
          facet_wrap(~group, scales = "free_x", ncol=10) + theme_pubclean() +
          theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5)) +
          labs(y="# of Features", x="# of Complete Samples")
  }
  return(p)
}

plot_completeness_percentage <- function(dataList, group_factor=NULL){
  # Get quantitative data
  quant_data <- dataList$quant
  # If no group_factor is passed
  if(is.null(group_factor)){
    # Get the completeness df
    complete.df <- as.data.frame(table(rowSums(!is.na(quant_data))))
    # Convert factor to numeric
    complete.df$Var1 <- as.numeric(levels(complete.df$Var1))[complete.df$Var1]
    # Find the percentages
    complete.df$pctg <- (complete.df$Var1 / ncol(quant_data)) * 100
    # Assign group
    complete.df$group <- "All Samples"

  }else{
    # Get the metadata
    metadata <- dataList$meta
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}

    # Initialize the dataframe to collected completenes
    complete.df <- data.frame()
    # Loop through each group in group_factor
    for(i in unique(metadata[, group_factor])){
      # get the current columns to subset
      col2subset <- metadata[which(metadata[, group_factor]==i), dataList$meta_id]
      # Subset the data
      subset_data <- quant_data[, col2subset]
      # Get completeness df
      if(is.null(nrow(subset_data))){
        df <- as.data.frame(table(as.numeric(!is.na(subset_data))))
        tmp <- as.numeric(levels(df$Var1))[df$Var1]
        tmp[tmp == 1] <- 100
        df$pctg <- tmp
      }else{
        df <- as.data.frame(table(rowSums(!is.na(subset_data))))
        # Find the percentages
        df$pctg <- (as.numeric(levels(df$Var1))[df$Var1] / ncol(subset_data)) * 100
      }
      # Assign group
      df$group <- i
      # Concat the dataframe to complete.df
      if(nrow(complete.df) < 1){
        complete.df <- df
      }else{
        complete.df <- rbind(complete.df, df)
      }
    }
  }
  # convert to factor - Make sure numeric value won't break it
  complete.df$group <- as.factor(complete.df$group)
  # Create percentage grouping
  complete.df <- complete.df %>%
    mutate(completeness=case_when((pctg < 1)~"0%",
                                  (pctg >=1) & (pctg < 25)~"1~25%",
                                  (pctg >=25) & (pctg < 50)~"25~50%",
                                  (pctg >=50) & (pctg < 90)~"50~90%",
                                  (pctg >=90) & (pctg < 95)~"90~95%",
                                  (pctg >=95) & (pctg < 99)~"95~99%",
                                  (pctg == 100)~"100%"))
  # Make factor out of percentage grouping
  complete.df$completeness <- as.factor(complete.df$completeness)
  # Order them before plotting
  complete.df$completeness <- ordered(complete.df$completeness,
                                      levels = c("0%", "1~25%", "25~50%", "50~90%",
                                                 "90~95%", "95~99%", "100%"))

  p <- complete.df %>%
        group_by(group, completeness) %>%
        summarise(number.features=sum(Freq)) %>%
        ggplot(aes(y=group, x=number.features,  fill=completeness, label=number.features)) +
          geom_bar(stat="identity", position="stack", width=1) +
          geom_text(size = 3.5, position = position_stack(vjust=0.5), color="white", fontface = "bold") +
          scale_fill_manual(values = c("100%"="#1b4332", "95~99%"="#2d6a4f",
                                     "90~95%"="#40916c", "50~90%"="#52b788",
                                     "25~50%"="#74c69d", "1~25%"="#95d5b2",
                                     "0%"="#495057")) +
          labs(x="# of Features", y=group_factor, fill="%Complete") + theme_pubclean()
  return(p)
}
