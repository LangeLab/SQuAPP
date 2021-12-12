# require -> UpSetR

# Custom cv calculation function
calculate_cvs <- function(quant_data, metadata,
                          group_factor, id_column){
  # Initialize cv list and columnname vector variables
  cv_list <- list()
  colname_kept <- c()
  # Loop through the unique samples to collect CV of replicas for each samples
  for(i in unique(metadata[, group_factor])){
    # Find the elements matching the current group in the metadata
    match_locs <- which(metadata[, group_factor]==i)
    # If only one element has been matched - skip it
    if (length(match_locs) == 1){
        next
    }
    # Get sample ids from metadata matched to the group_factor
    match_samples <- metadata[match_locs, id_column]
    # Selecting columns that are consistent with quant data and metadata
    match_samples <- match_samples[match_samples %in% colnames(quant_data)]
    # Checks and error messages if there are issues with sample name consistency
    if(length(match_samples) < 1){
      stop("No samples are returned!\n
            Make sure the sample names are consistent
            between metadata id and quantitative data's column names!")
    }else if(length(match_samples) == 1){
      stop("Only single sample has returned!\n
            Make sure the sample names are consistent between metadata id
            and quantitative data's column names!")
    }else{
      # Calculate feature-wise cvs for the selected elements from the quantitative data
      cur_cv <- na.omit(apply(quant_data[, match_samples], 1,
                    function(x) (sd(x, na.rm=TRUE) / mean(x, na.rm=TRUE))* 100))
      if(length(cur_cv) < 1){
        next
      }
      cv_list[[i]] <- cur_cv
      # Get the column names that are used to have consistencies
      colname_kept <- c(colname_kept, i)
    }
  }
  # Create CV data from the list
  cv_data <- data.frame(t(bind_rows(cv_list)))
  # Pass the column names saved
  colnames(cv_data) <- colname_kept

  return(cv_data)
}

# plot_cv function for the version 0.27
plot_cv <- function(dataList, group_factor=NULL){
  ## Gather variables from the dataList
  # Get replica info
  if_repl <- dataList$repl
  # Get quantitative data
  quant_data <- dataList$quant
  # Get the metadata
  metadata <- dataList$meta
  meta_id_col <- dataList$meta_id

  # If user selected global quality check.
  if(is.null(group_factor)){
    # If the data has replica
    if(if_repl){
      # Get the unique sample name column from the list
      meta_uniq_col <- dataList$meta_uniq
      # Calculates the cvs using custom function
      cv_data <- calculate_cvs(quant_data, metadata,
                               group_factor=meta_uniq_col,
                               id_column=meta_id_col)
      # Calculate row averages for CV calculate for each unique sample
      cvs <- (rowMeans(cv_data, na.rm=TRUE))

      # Create stacked bar data
      stacked_bar_data <- data.frame(feature="Global", CV=cvs, number=1) %>%
          mutate(range=case_when((CV < 10) ~ "<10%",
                                 (CV > 10) & (CV < 20) ~ "10%~20%",
                                 (CV > 20) & (CV < 50) ~ "20%~50%",
                                 (CV > 50) & (CV < 100 ) ~ "50%~100%",
                                 (CV > 100) ~ ">100%"))
      # Create the column for the CV groups created
      stacked_bar_data$range <- ordered(stacked_bar_data$range,
                                        levels = c(">100%",
                                                   "50%~100%",
                                                   "20%~50%",
                                                   "10%~20%",
                                                   "<10%"))

      # Create a stacked bar chart with CV groups
      g1 <- ggplot(stacked_bar_data, aes(y=feature, x=number, fill=range)) +
            geom_bar(position = "stack", stat = "identity", width = 0.5) +
            scale_fill_manual(values = c("<10%"="#011627",
                                         "10%~20%"="#023047",
                                         "20%~50%"="#126782",
                                         "50%~100%"="#219ebc",
                                         ">100%"="#8ecae6")) +
            labs(x = "# of features",y = "", fill = "%CV") + theme_pubclean()
      # Create a violin plot with CVs
      g2 <- ggplot(data.frame(name = "CV", CV = cvs), aes(y = CV, x = name)) +
            geom_violin() +
            geom_hline(yintercept = median(cvs,na.rm=TRUE),
                       color = "red",
                       linetype = "dashed") +
            geom_text(data = data.frame(y = median(cvs),x = 0), aes(x, y),
                      label = round(median(cvs), digits = 1),
                      vjust = -0.8, hjust = -0.2, color = "red", size = 3.5) +
            labs(x = "", y = "%CV") + coord_flip() + theme_pubclean()

      return(g1/g2)
    }else{
      stop("Data needs to have replicas to create CV plot!")
    }
  }else{
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # Calculates the cvs using custom function
    cv_data <- calculate_cvs(quant_data, metadata,
                             group_factor=group_factor,
                             id_column=meta_id_col)
    # Create long version of the data for ease of plotting
    cv_data.long <- melt(data = cv_data, variable.name = "Group", value.name = "CV", id.vars = NULL)
    # Create CV counts based on percentages
    cv_data.long <- cv_data.long %>%
        mutate(range = case_when((is.na(CV)) ~ "Missing",
                                 (CV < 10) ~ "<10%",
                                 (CV > 10) & (CV < 20) ~ "10%~20%",
                                 (CV > 20) & (CV < 50) ~ "20%~50%",
                                 (CV > 50) & (CV < 100 ) ~ "50%~100%",
                                 (CV > 100) ~ ">100%"))
    # Have fixed order for CV counts
    cv_data.long$range <- ordered(cv_data.long$range,
                                  levels = c("Missing",
                                             ">100%",
                                             "50%~100%",
                                             "20%~50%",
                                             "10%~20%",
                                             "<10%"))
    # Plot the Stacked Bar Chart
    g1 <- ggplot(data=cv_data.long, aes(y=Group, fill=range,)) +
            geom_bar(color = "grey") +
            scale_fill_manual(values = c("<10%"="#011627",
                                         "10%~20%"="#023047",
                                         "20%~50%"="#126782",
                                         "50%~100%"="#219ebc",
                                         ">100%"="#8ecae6",
                                         "Missing"="#540b0e")) +
            labs(x="# of Features", y="", fill="%CV") + theme_pubclean()
    # Plot the violin chart
    g2 <- ggplot(data=na.omit(cv_data.long), aes(x=Group, y=CV)) +
          geom_violin(draw_quantiles = c(0.25, 0.75), linetype = "dashed", adjust=1.5) +
          geom_violin(fill="transparent", draw_quantiles = 0.5, adjust=1.5) +
          stat_summary(fun=mean,na.rm=TRUE,
                       geom="point", shape=20, size=5,
                       color="red", fill="red") +
          labs(x = "", y = "%CV") + coord_flip() + theme_pubclean() +
          rremove("y.ticks") + rremove("y.text")
    return(g1+g2)
  }
}

bar_plot_identified_features <- function(dataList, group_factor=NULL){
  # Get quantitative data
  quant_data <- dataList$quant
  # If group_factor is not passed
  if(is.null(group_factor)){
    # Create dataframe to plots
    plot_data <- data.frame(number.features=colSums(!is.na(quant_data)),
                            sample=colnames(quant_data))
    # Create a bar plot from ggpubr
    p <- ggbarplot(plot_data,
                   x="sample",
                   y="number.features",
                   color = "steelblue",
                   sort.val = "asc",
                   sort.by.groups = TRUE,
                   x.text.angle = 90,
                   ggtheme = theme_pubclean()) +
        labs(y="# of feature", x="Samples") +
        font("x.text", size = 8, vjust = 0.5) +
        ggtitle("Number of identified features per sample")

  }else{
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # Create dataframe for plotting with grouping
    plot_data <- data.frame(number.features=colSums(!is.na(quant_data)),
                            sample=colnames(quant_data),
                            condition=metadata[match(colnames(quant_data),
                                                     metadata[, meta_id_col]),
                                               group_factor])
    # Conditional statement to not use palette for more than 10
    if(length(unique(plot_data$condition)) > 10){
        use_pal <- "grey"
    }else{
        use_pal <- "jco"
    }
    # Create a bar plot from ggpubr
    p <- ggbarplot(plot_data,
                   x="sample",
                   y="number.features",
                   fill = "condition",
                   color = "white",
                   palette = use_pal,
                   sort.val = "asc",
                   sort.by.groups = TRUE,
                   x.text.angle = 90,
                   ggtheme = theme_pubclean()) +
        labs(y="# of features", x="Samples") +
        font("x.text", size = 8, vjust = 0.5) +
        ggtitle(paste("Number of identified features per sample, grouped by", paste0('"', group_factor, '"')))
  }
  return(p)
}

upsetplot <- function(dataList, group_factor=NULL, selection=NULL){
  # Get the quantitative data
  quant_data <- dataList$quant
  # Create a protein identified mask data
  flag.df <- data.frame(1*(!is.na(data.frame(quant_data))))
  # Save the protein names
  protein <- rownames(flag.df)
  # Initialize a list for upset input
  group.flag.df <- list()
  # If group_factor is not passed
  if(is.null(group_factor)){
    # Get first 4 elements for default visualization
    loop_vector <- colnames(flag.df[, c(1:4)])
    # Loop to create list input for upset function
    for(i in loop_vector){
      group.flag.df[[i]] <- unique(protein[which(flag.df[, i] == 1)])
    }
  }else{
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # Convert the sample type to factor
    metadata[, group_factor] <- as.factor(metadata[, group_factor])
    if(is.null(selection)){
      # Get the unique levels for group_factor
      loop_vector <- levels(metadata[, group_factor])
    }else{
      loop_vector <- selection
    }
    # Loop through each group
    for (i in loop_vector){
      sub.flag.df <- flag.df[, metadata[which(metadata[,group_factor]==i), meta_id_col]]
      # Flexible finding of proteins by one or multi-matches
      if(!is.null(ncol(sub.flag.df))){
        cur_protein_n <- protein[rowSums(sub.flag.df)>0]
      } else {
        cur_protein_n <- protein[sub.flag.df>0]
      }
      # Get the proteins that are matching
      group.flag.df[[i]]<- cur_protein_n
    }

  }
  # Plot the intersections found from the list created
  p <- UpSetR::upset(UpSetR::fromList(group.flag.df),
                     nsets=length(names(group.flag.df)),
                     order.by="freq",
                     decreasing=T,
                     cutoff=0,
                     text.scale = 1.25)
  return(p)
}

datacompleteness <- function(dataList, group_factor=NULL){
  # Get quantitative data
  quant_data <- dataList$quant
  # Calculate protein-wise completeness of the data
  percent.samples <- apply(quant_data, 1, function(x) sum(!is.na(x))/ncol(quant_data))
  # Order them by completeness
  percent.samples <- percent.samples[order(percent.samples,
                                           decreasing=TRUE)]
  # Create a dataframe from the protein-wise completeness percentage calculated
  temp.df <- data.frame(protein=1:nrow(quant_data),
                        datacompleteness=percent.samples)
  # Plotting data completeness plot
  p <- ggplot(temp.df, aes(x=protein , y=datacompleteness))+
        geom_point() +
        labs(y="Data Completeness", x="# of unique feature")+
        # Annotatating 99, 90, and 50 percentile areas
        geom_vline(xintercept=max(which(temp.df$datacompleteness>=0.99)),
                   linetype="dashed", color = "red")+
        annotate("text",
                 max(which(temp.df$datacompleteness>=0.99)),
                 1.05,
                 vjust = 0, hjust=-.1,
                 label = "99%", color="red")+
        geom_vline(xintercept=max(which(temp.df$datacompleteness>=0.9)),
                   linetype="dashed", color = "red")+
        annotate("text",
                 max(which(temp.df$datacompleteness>=0.9)),
                 1.05,
                 vjust = 0, hjust=-.1,
                 label = "90%", color="red")+
        geom_vline(xintercept=max(which(temp.df$datacompleteness>=0.5)),
                   linetype="dashed", color = "red")+
        annotate("text",
                 max(which(temp.df$datacompleteness>=0.5)),
                 1.05,
                 vjust = 0, hjust=-.1,
                 label = "50%", color="red")+
        theme_pubclean()
  return(p)
}

# Stacked Bar plot from ggplot to present missing value counts in the data
plot_missing_values <- function(dataList, group_factor=NULL){
  # Get quantiative data
  data <- dataList$quant
  # Get missing counts
  missing_counts <- colSums(is.na(data))
  # Get complete counts
  complete_counts <- (nrow(data) - missing_counts)
  # Put them in data format
  count_data <- data.frame(t(rbind(complete_counts, missing_counts)))
  # Pass column names for better reading
  colnames(count_data) <- c("complete", "missing")
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
        filter(state=="missing") %>%
        select(group, avg_count)
    # Create the plot
    p <- ggplot(count_data, aes(fill=state, y=count, x=samples)) +
      geom_bar(position="stack", stat="identity", width=1) +
      facet_grid(. ~group, scales = "free_x", space='free') +
      theme_pubclean() +
      scale_fill_manual(values=c("complete"="#00AFBB", "missing"="#E7B800")) +
      theme(panel.spacing = unit(.5, "lines"),
            axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5)) +
      geom_hline(data=avg_counts,
                 aes(yintercept=avg_count),
                 colour = "#e63946",
                 linetype='dotted',
                 show.legend = NA)

  # If grouping factor is not passed plot the whole data without facet
  }else{
    # Convert the data into long format
    count_data <- melt(count_data, id.vars=c("samples"),
                      value.name="count", variable.name="state")
    # Create the plot
    p <- ggplot(count_data, aes(fill=state, y=count, x=samples)) +
      geom_bar(position="stack", stat="identity", width=1) +
      theme_pubclean() +
      scale_fill_manual(values=c("complete"="#00AFBB", "missing"="#E7B800")) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  }
  # Return the plot
  return(p+labs(x="Samples"))
}
