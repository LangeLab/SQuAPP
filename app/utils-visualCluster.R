prepare_clustering_data <- function(dataList, feature_selection="all"){
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
  quant_data <- quant_data[rows2select, ]
  # scale the dataframe for use
  scaled_data <- scale(t(na.omit(quant_data)))
  # Return the scaled data
  return(scaled_data)
}

plot_clustering_performance <- function(data,
                                        clustering_function,
                                        max_k=10, nboot=50,
                                        performance_method="silhouette",
                                        linecolor="steelblue",
                                        custom_title=""
                                        ){
  # plot the data with factoextra function
  p <- suppressWarnings(factoextra::fviz_nbclust(data,
                                                 FUN=clustering_function,
                                                 method=performance_method,
                                                 nboot=nboot, k.max=max_k,
                                                 linecolor=linecolor,
                                                 verbose=FALSE))
  p <- p + theme_pubclean() + ggtitle(custom_title)
  # Return the plot with custom theme
  return(p)
}

plot_clustering_pca <- function(res, data,
                                show_label=FALSE,
                                add_repel=FALSE,
                                customTitle="",
                                add_ellipse=TRUE,
                                ellipse_type="confidence",
                                pointsize=2){
  # Assign which plotting to be used
  if(!show_label){
    add_repel <- FALSE
    geom_c <- "point"
  }else{
    geom_c <- c("point", "text")
  }
  # Plot the fviz_cluster
  p <- suppressWarnings(factoextra::fviz_cluster(res,
                                                 data=data,
                                                 palette="jco",
                                                 geom=geom_c,
                                                 main=customTitle,
                                                 repel=add_repel,
                                                 ellipse=add_ellipse,
                                                 ellipse.type=ellipse_type,
                                                 pointsize=pointsize,
                                                 ggtheme = theme_pubclean()))
  # Return the plot
  return(p)
}

plot_clustering_silhouette <- function(sil_res){
  # Plot with fviz_silhouette
  p <- suppressWarnings(factoextra::fviz_silhouette(sil_res,
                                                    palette="jco",
                                                    ggtheme=theme_pubclean(),
                                                    print.summary=FALSE))
  # Return the plot
  return(p)
}

plot_clustering_dendogram <- function(res,
                           customTitle="",
                           subTitle=""){
  # Plot dendogram with fviz_dend
  p <- suppressWarnings(factoextra::fviz_dend(res,
                                             cex=0.5,
                                             type="rectangle",
                                             palette="jco",
                                             color_labels_by_k=TRUE,
                                             rect=TRUE,
                                             rect_fill=TRUE,
                                             main=customTitle,
                                             sub=subTitle,
                                             ggtheme=theme_pubclean()))
  # Return the plot
  return(p)
}

plot_clustering_membership <- function(res){

  # Create dataframe for plotting
  df <- data.frame(res$membership)
  colnames(df) <- gsub("X", "", colnames(df))
  df$Samples <- rownames(df)
  df.melt <- reshape2::melt(df,
                            id.vars="Samples",
                            variable.name="Clusters",
                            value.name="Membership")
  # Create the ggplot tiles
  p <- ggplot(df.melt, aes(x=Samples, y=Clusters, fill=Membership))+
          geom_tile(color = "black", lwd=.25, linetype=1) +
          scale_fill_gradient(low = "white", high = "blue") +
          guides(fill = guide_colourbar(barwidth = 25, barheight = .75)) +
          theme_pubclean() +
          theme(axis.text.x = element_text(angle = 90, size=7.5))

  # Return the plot
  return(p)
}
