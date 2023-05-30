# require -> UpSetR

# calculate CVs for each sample group
calculate_cvs <- function(
  quant_data, 
  metadata,
  group_factor, 
  id_column
){
  # Error Handling Codes:
  # 0: A logical error has occurred!
  # 1: CV requires at least 2 replicates or groups!
  # 2: No or a single sample has returned!
  # 3: An error at feature-wise cv calculation!
  # 4: No sample-group returned a CV vector!

  # Checks the logic of passed arguments
  if(!is.data.frame(quant_data)){
    return(0)
  }
  if(!is.data.frame(metadata)){
    return(0)
  }
  # If group_factor is not a metadata column, return error
  if(!(group_factor %in% colnames(metadata))){
    return(0)
  }
  # if contents of id_column and group_factor are the same
  if(all(metadata[, id_column] == metadata[, group_factor])){
    return(1)
  }

  # Initialize variables to be populated
  cv_list <- list()
  colname_kept <- c()
  # Loop through unique elements in metadata$group_factor
  for(i in unique(metadata[, group_factor])){
    match_locs <- which(metadata[, group_factor]==i)
    # If only one element has been matched - skip
    if (length(match_locs) == 1){ next }
    # Get sample ids from metadata matched to the group_factor
    match_samples <- metadata[match_locs, id_column]
    # Selecting columns that are consistent with quant data and metadata
    match_samples <- match_samples[
      match_samples %in% colnames(quant_data)
    ]
    # Issues with match samples
    if(length(match_samples) < 1){
      return(2)
    }else if(length(match_samples) == 1){
      return(2)
    }else{
      # Calculate feature-wise cvs for the selected elements
      cur_cv <- try2(
        expr = na.omit(
          apply( # Apply on feature-wise
            quant_data[, match_samples], # Between selected samples 
            1,
            function(x) ( # CV calculation
              sd(x, na.rm=TRUE) / mean(x, na.rm=TRUE)
            ) * 100 # Convert to percentage
          )
        ), 
        silent = TRUE, 
        err_code = 0
      )
      if (length(cur_cv) == 1 & is.numeric(cur_cv)){ return(3) }
      # If there are no values in the current cv, skip
      if (length(cur_cv) < 1){ next }
      # Save the current cv to the list
      cv_list[[i]] <- cur_cv
      # Grouped column names are saved
      colname_kept <- c(colname_kept, i)
    }
  }
  # Check if the cv_list is empty
  if(length(cv_list) < 1){ return(4) }
  # Create CV data from the list
  cv_data <- data.frame(t(bind_rows(cv_list)))
  # Pass the column names saved
  colnames(cv_data) <- colname_kept
  # Return a data frame
  return(cv_data)
}

# Custom function to plot CVs
plot_cv <- function(
  dataList, 
  group_factor=NULL
){
  # Error Handling Codes:
  # 0: A logical error has occurred!
  # 1: CV requires at least 2 replicates or groups!
  # 2: No or a single sample has returned!
  # 3: An error at feature-wise cv calculation!
  # 4: No sample-group returned a CV vector!


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
      cv_data <- calculate_cvs(
        quant_data, 
        metadata,
        group_factor=meta_uniq_col,
        id_column=meta_id_col
      )
      # If there are errors, return the error code (0-4)
      if(!is.data.frame(cv_data)){ return(cv_data) }
      # Calculate row averages for CV calculate for each unique sample
      cvs <- (rowMeans(cv_data, na.rm=TRUE))

      # Create stacked bar data
      stacked_bar_data <- data.frame(
        feature="Global", 
        CV=cvs, 
        number=1, 
        check.names = FALSE
      ) %>%
      mutate(
        range=case_when(
          (CV < 10) ~ "<10%",
          (CV > 10) & (CV < 20) ~ "10%~20%",
          (CV > 20) & (CV < 50) ~ "20%~50%",
          (CV > 50) & (CV < 100 ) ~ "50%~100%",
          (CV > 100) ~ ">100%"
        )
      )
      # Create the column for the CV groups created
      stacked_bar_data$range <- ordered(
        stacked_bar_data$range,
        levels = c(
          ">100%",
          "50%~100%",
          "20%~50%",
          "10%~20%",
          "<10%")
        )

      # Create a stacked bar chart with CV groups
      g1 <- ggplot( # Main Layer
        stacked_bar_data, 
        aes(
          y=feature, 
          x=number, 
          fill=range
        )
      ) + 
      geom_bar(
        position = "stack", 
        stat = "identity", 
        width = 0.5
      ) +
      scale_fill_manual(
        values = c(
          "<10%"="#011627",
          "10%~20%"="#023047",
          "20%~50%"="#126782",
          "50%~100%"="#219ebc",
          ">100%"="#8ecae6"
        )
      ) +
      labs( 
        x = "# of features",
        y = "", 
        fill = "%CV"
      ) + 
      theme_pubclean()

      # Create a violin plot with CVs
      g2 <- ggplot(
        data.frame(
          name = "CV", 
          CV = cvs
        ), 
        aes(
          y = CV, 
          x = name
        )
      ) +
      geom_violin() +
      geom_hline(
        yintercept = median(cvs,na.rm=TRUE),
        color = "red",
        linetype = "dashed"
      ) +
      geom_text(
        data = data.frame(y = median(cvs),x = 0), 
        aes(x, y),
        label = round(median(cvs), digits = 1),
        vjust = -0.8, 
        hjust = -0.2, 
        color = "red", 
        size = 3.5
      ) +
      labs(
        x = "", 
        y = "%CV"
      ) + 
      coord_flip() + 
      theme_pubclean()

      return(g1/g2)
    }else{ # If the data does not have replica
      return(1)
    }
  }else{ # If user selected group quality check.
    
    # Calculates the cvs using custom function
    cv_data <- calculate_cvs(
      quant_data, 
      metadata,
      group_factor=group_factor,
      id_column=meta_id_col
    )
    # If there are errors, return the error code (0-4)
    if(!is.data.frame(cv_data)){ return(cv_data) }
    # Create long version of the data for ease of plotting
    cv_data.long <- melt(
      data = cv_data, 
      variable.name = "Group", 
      value.name = "CV", 
      id.vars = NULL
    )
    # Create CV counts based on percentages
    cv_data.long <- cv_data.long %>%
        mutate(
          range = case_when(
            (is.na(CV)) ~ "Missing",
            (CV < 10) ~ "<10%",
            (CV > 10) & (CV < 20) ~ "10%~20%",
            (CV > 20) & (CV < 50) ~ "20%~50%",
            (CV > 50) & (CV < 100 ) ~ "50%~100%",
            (CV > 100) ~ ">100%"
          )
        )
    # Have fixed order for CV counts
    cv_data.long$range <- ordered(
      cv_data.long$range,
      levels = c(
        "Missing",
        ">100%",
        "50%~100%",
        "20%~50%",
        "10%~20%",
        "<10%"
      )
    )
    # Plot the Stacked Bar Chart
    g1 <- ggplot(
      data=cv_data.long, 
      aes(
        y=Group, 
        fill=range
      )
    ) +
    geom_bar(color = "grey") +
    scale_fill_manual(
      values = c(
        "<10%"="#011627",
        "10%~20%"="#023047",
        "20%~50%"="#126782",
        "50%~100%"="#219ebc",
        ">100%"="#8ecae6",
        "Missing"="#540b0e"
      )
    ) +
    labs(
      x="# of Features", 
      y="", 
      fill="%CV"
    ) + theme_pubclean()
    # Plot the violin chart
    g2 <- ggplot(
      data=na.omit(cv_data.long), 
      aes(x=Group, y=CV)
    ) +
    geom_violin(
      draw_quantiles = c(0.25, 0.75), 
      linetype = "dashed", 
      adjust=1.5
    ) +
    geom_violin(
      fill="transparent", 
      draw_quantiles = 0.5, 
      adjust=1.5
    ) +
    stat_summary(
      fun=mean,na.rm=TRUE,
      geom="point", shape=20, size=5,
      color="red", fill="red"
    ) +
    labs(
      x = "", 
      y = "%CV"
    ) + 
    coord_flip() + 
    theme_pubclean() +
    rremove("y.ticks") + 
    rremove("y.text")
    # Return the plots 
    return(g1+g2)
  }
}

bar_plot_identified_features <- function(
  dataList, 
  group_factor=NULL
){
  # Error Codes:
  # 0: Group factor not matched to metadata

  # Get quantitative data
  quant_data <- dataList$quant
  # If group_factor is not passed
  if(is.null(group_factor)){
    # Create dataframe to plots
    plot_data <- data.frame(
      number.features=colSums(!is.na(quant_data)),
      sample=colnames(quant_data)
    )
    # Create a bar plot from ggpubr
    p <- ggbarplot(
      plot_data,
      x="sample",
      y="number.features",
      color = "steelblue",
      sort.val = "asc",
      sort.by.groups = TRUE,
      x.text.angle = 90,
      ggtheme = theme_pubclean()
    ) +
    labs(y="# of feature", x="Samples") +
    font("x.text", size = 8, vjust = 0.5) +
    ggtitle(
      paste(
        "Number of identified",  
        dataList$name,
        "per sample"
      )
    )
  }else{ # If group_factor is passed
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return(0)}
    # Create dataframe for plotting with grouping
    plot_data <- data.frame(
      number.features=colSums(!is.na(quant_data)),
      sample=colnames(quant_data),
      condition=metadata[
        match(
          colnames(quant_data),
          metadata[, meta_id_col]
        ),
        group_factor
      ]
    )
    # Conditional statement to not use palette for more than 10
    if(length(unique(plot_data$condition)) > 10){
        use_pal <- "grey"
    }else{
        use_pal <- "jco"
    }
    # Create a bar plot from ggpubr
    p <- ggbarplot(
      plot_data,
      x="sample",
      y="number.features",
      fill = "condition",
      color = "white",
      palette = use_pal,
      sort.val = "asc",
      sort.by.groups = TRUE,
      x.text.angle = 90,
      ggtheme = theme_pubclean()
    ) +
    labs(y="# of features", x="Samples") +
    font("x.text", size = 8, vjust = 0.5) +
    ggtitle(
      paste(
        paste(
          "Number of identified",  
          dataList$name,
          "per sample grouped by"
        ), 
        paste0('"', group_factor, '"')
      )
    )
  }
  return(p)
}

upsetplot <- function(
  dataList, 
  group_factor=NULL, 
  selection=NULL
){
  
  # Error Codes:
  # 0: Unexpected error
  # 1: WIP - Selection not implemented

  # Get the quantitative data
  quant_data <- dataList$quant
  # Create a protein identified mask data
  flag.df <- 1*(!is.na(quant_data))
  # Save the protein names
  protein <- rownames(flag.df)
  # Initialize a list for upset input
  group.flag.df <- list()
  if (is.null(selection)){
    # If group_factor is not passed
    if(is.null(group_factor)){
      # Get first 5 elements for default visualization
      loop_vector <- colnames(flag.df[, c(1:5)])
       # Loop to create list input for upset function
      for(i in loop_vector){
        group.flag.df[[i]] <- unique(protein[which(flag.df[, i] == 1)])
      }
    }else{
      # Get the metadata
      metadata <- dataList$meta
      meta_id_col <- dataList$meta_id
      # Check if the group factor is within the metadata
      if(!group_factor %in% colnames(metadata)){return(0)}
      # Convert the sample type to factor
      metadata[, group_factor] <- as.factor(metadata[, group_factor])
      # Get the unique levels for group_factor
      loop_vector <- levels(metadata[, group_factor])
      # Loop through each group
      for (i in loop_vector){   
        # Get the subset of the flag.df with tryCatch to avoid hard errors
        sub.flag.df <- try2(
          expr=flag.df[
            ,
            metadata[ 
              which(metadata[, group_factor]==i), 
              meta_id_col
            ]
          ],
          err_code=0
        )
        # If an error is caught, return 0
        if (length(sub.flag.df)==1 & is.numeric(sub.flag.df)){ return(0) }
        # Flexible finding of proteins by one or multi-matches
        if(!is.null(ncol(sub.flag.df))){
          cur_protein_n <- protein[rowSums(sub.flag.df)>0]
        } else {
          cur_protein_n <- protein[sub.flag.df>0]
        }
        # Get the proteins that are matching
        group.flag.df[[i]] <- cur_protein_n
      }
    }
  }else{
    # TODO: Add selection functionality
    return(1)
  } 
  # Plot the intersections found from the list created
  p <- UpSetR::upset(
    UpSetR::fromList(group.flag.df),
    nsets=length(names(group.flag.df)),
    order.by="freq",
    decreasing=T,
    cutoff=0,
    text.scale = 1.25
  )
  return(p)
}

# Data Completeness Plot
datacompleteness <- function(
  dataList, 
  group_factor=NULL
){
  # TODO: Develop a group_factor compatible version
  # Error Code: 
  # 0: Unexpected error

  # Get quantitative data
  quant_data <- dataList$quant
  # Calculate protein-wise completeness of the data
  percent.samples <- apply(
    quant_data, 
    1, 
    function(x) sum(!is.na(x)) / ncol(quant_data)
  )
  # Order them by completeness
  percent.samples <- percent.samples[order(
      percent.samples,
      decreasing=TRUE
  )]
  # Create a dataframe from the protein-wise completeness percentage calculated
  temp.df <- data.frame(
    protein=1:nrow(quant_data),
    datacompleteness=percent.samples
  )
  # Plotting data completeness plot
  p <- ggplot(
    temp.df, 
    aes(x=protein , y=datacompleteness)
  ) +
  geom_point() +
  labs(
    y="Data Completeness", 
    x="# of unique feature"
  ) +
  # Annotate 99% Completeness
  geom_vline(
    xintercept=max(which(temp.df$datacompleteness>=0.99)),
    linetype="dashed", 
    color = "red"
  ) +
  annotate(
    "text",
    max(which(temp.df$datacompleteness>=0.99)),
    1.05,
    vjust = 0, 
    hjust=-.1,
    label = "99%", 
    color="red"
  ) +
  # Annotate 90% Completeness
  geom_vline(
    xintercept=max(which(temp.df$datacompleteness>=0.9)),
    linetype="dashed", 
    color = "red"
  ) +
  annotate(
    "text",
    max(which(temp.df$datacompleteness>=0.9)),
    1.05,
    vjust = 0, 
    hjust=-.1,
    label = "90%", 
    color="red"
  ) +
  # Annotate 50% Completeness
  geom_vline(
    xintercept=max(which(temp.df$datacompleteness>=0.5)),
    linetype="dashed", 
    color = "red"
  ) +
  annotate(
    "text",
    max(which(temp.df$datacompleteness>=0.5)),
    1.05,
    vjust = 0, 
    hjust=-.1,
    label = "50%", 
    color="red"
  ) +
  theme_pubclean()
  return(p)
}

# Stacked Bar plot from ggplot to present missing value counts in the data
plot_missing_values <- function(
  dataList, 
  group_factor=NULL
){
  # Error Code:
  # 0: Unexpected error


  # Get quantiative data
  data <- dataList$quant
  # Get missing counts for each sample
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
      # stop("More than 5 unique values in group_factor won't be plotted!")
      return(1)
    }

    # Add group factor to the count data
    count_data <- cbind(
      count_data,
      group=metadata[
        , 
        group_factor
      ][match(
        count_data$samples,
        metadata[, meta_id_col]
      )]
    )

    # Convert the data into long format
    count_data <- melt(
      count_data, 
      id.vars=c("samples", "group"),
      value.name="count", 
      variable.name="state"
    )
    # Create average count table for horizontal indicators
    avg_counts <- count_data %>%
      group_by(group, state) %>%
      summarize(avg_count = mean(count)) %>%
      filter(state=="missing") %>%
      select(group, avg_count)
    # Create the plot
    p <- ggplot(
      count_data, 
      aes(fill=state, y=count, x=samples)
    ) +
    geom_bar(
      position="stack", 
      stat="identity", 
      width=1
    ) +
    facet_grid(
      . ~group, 
      scales = "free_x", 
      space='free'
    ) +
    theme_pubclean() + 
    labs(x="Samples") +
    scale_fill_manual(
      values=c(
        "complete"="#00AFBB", 
        "missing"="#E7B800"
      )
    ) +
    theme(
      panel.spacing = unit(.5, "lines"),
      axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5)
    ) +
    geom_hline(
      data=avg_counts,
      aes(yintercept=avg_count),
      colour = "#e63946",
      linetype='dotted',
      show.legend = NA
    )
  # If grouping factor is not passed plot the whole data without facet
  }else{
    # Convert the data into long format
    count_data <- melt(
      count_data, 
      id.vars=c("samples"),
      value.name="count", 
      variable.name="state"
    )
    # Create the plot
    p <- ggplot(
      count_data, 
      aes(
        fill=state, 
        y=count, 
        x=samples
      )
    ) +
    geom_bar(
      position="stack", 
      stat="identity", 
      width=1
    ) +
    theme_pubclean() + 
    labs(x="Samples") +
    scale_fill_manual(
      values=c(
        "complete"="#00AFBB", 
        "missing"="#E7B800"
      )
    ) +
    theme(
      axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5)
    )
  }
  # Return the plot
  return(p)
}
