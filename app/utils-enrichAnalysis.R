# require -> gprofiler2

run_gprofiler <- function(dataList,
                          organism,
                          run_multiple=FALSE,
                          user_threshold=0.05,
                          correction_method="g_SCS",
                          custom_background=FALSE,
                          sources=NULL ){

  # Get annotation data
  annot_data <- dataList$annot[, c("Gene.name", "Protein.identifier", "Protein.name")]
  # Get stats data
  stats_data <- dataList$stats
  # Combine annot and stats data
  data <- robust_cbind(annot_data, stats_data)
  # Subset only significant entries
  data <- data[(data$significance != "no significance") , ]
  # Initialize query list to populate
  go_list <- list()
  # If multi-query is enabled
  if(run_multiple){
    # Loop through the unique significant variables in the data
    for(i in unique(data$significance)){
      # Get the gene names for given variable
      go_list[[i]] <- data[data$significance == i, "Gene.name"]
    }
  # If multi-query is not passed
  }else{
    # Assign gene-name to all significance
    go_list[["All Significant"]] <- data$Gene.name
  }
  # If custom bacground want to be used
  if(custom_background){
    # Use all identified gene names
    custom_bg <- unique(annot_data$Gene.name)
    domain_scope <- "custom_annotated"
  }else{
    custom_bg <- NULL
    domain_scope <- "annotated"
  }
  # Run the gprofiler2 with configured variables
  gostres <- gprofiler2::gost(query=go_list,
                              organism=organism,
                              user_threshold=user_threshold,
                              correction_method=correction_method,
                              custom_bg=custom_bg,
                              domain_scope=domain_scope,
                              sources=sources,
                              multi_query=F,
                             )
  # Calculate Gene Ratio
  gostres$result$GeneRatio <- gostres$result$intersection_size / gostres$result$term_size
  # Return gprofiler2 dataframe
  return(gostres)
}

enrichment_individual_plot <- function(data,
                                       pval.thr=1,
                                       group="GO:BP",
                                       x_var="GeneRatio",
                                       y_var="term_name",
                                       size_var="intersection_size",
                                       size_scales=c(3, 8),
                                       decreasing=TRUE){
  # Subset the data based on the group it is passed
  plot_data <- data %>%
              filter(source == group) %>%
              filter(p_value < 10 ** -pval.thr) %>%
              as.data.frame()
  # Order the variables for the plot to look good
  idx <- order(plot_data[, x_var], decreasing = decreasing)
  plot_data[, y_var] <- factor(plot_data[, y_var],
                            levels=rev(unique(plot_data[, y_var][idx])))

  # Create custom title based on the variables
  custom_title = paste("Enrichment in:", group, "group")
  # Create the plot
  p <- ggplot(plot_data, aes_string(x=x_var,
                                    y=y_var,
                                    size=size_var,
                                    color="p_value")) +
        geom_point() +
        scale_color_continuous(low="#5a189a", high="#ff8500",
                               name="adj.pvalue",
                               guide=guide_colorbar(reverse=TRUE)) +
        scale_size(range=size_scales) +
        guides(size  = guide_legend(order = 1),
               color = guide_colorbar(order = 2)) +
        ylab(NULL) + ggtitle(custom_title) +
        theme_minimal()
  # Return the plot
  return(p)
}
