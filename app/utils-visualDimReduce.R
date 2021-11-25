reduce_dimensions <- function(dataList,
                              feature_selection,
                              method,
                              tsne_perp=NULL){
  # Get quantitative data
  quant_data <- dataList$quant
  # Get statistics data
  stat_data <- dataList$stats
  # Get metadata
  metadata <- dataList$meta
  # Based on feature selection apply clustering and visualization
  if(feature_selection == "all"){
    rows2select <- rownames(quant_data)
  # If all significant is selected
  }else if(feature_selection == "all significant"){
    rows2select <- rownames(stat_data[which(stat_data$significance != "no significance"), ])
  # If single significant features is selected
  }else{
    rows2select <- rownames(stat_data[which(stat_data$significance == feature_selection), ])
  }
  # Subset the quantitative data based on the selected rows
  quant_data <- quant_data[rows2select, ]
  # Prepare the data
  m <- log2(t(na.omit(quant_data)))
  # Check the data size if there are enough data to work on
  if(ncol(m) < 1){stop("No complete data to reduce dimension after na.omit")}
  # PCA
  if(method=="PCA"){
    # Create PCA
    res.pca <- prcomp(m, scale.=TRUE)
    # Select only first two PC
    res <- res.pca[["x"]][, c(1,2)]
  }
  # t-SNE
  if(method=="t-SNE"){
    # If perplexity value for tSNE is 0 or left alone
    if((tsne_perp==0) || (is.null(tsne_perp))){
      # Initial tSNE
      tsne_perp <- round((nrow(m) - 1) / 3) - 1
    }
    # Run the tsne function from Rtsne with default variables + tsne_perp
    res.tsne <- Rtsne::Rtsne(m, dims=2, theta=0,
                             perplexity=tsne_perp,
                             max_iter=1500,
                             verbose=FALSE,
                             normalize=FALSE)
    # Select relevant info
    res <- res.tsne$Y
    # Make sure the rownames are carried over
    rownames(res) <- rownames(m)
  }
  # UMAP
  if(method=="UMAP"){
    # Run umap function
    res.umap <- umap::umap(m)
    # Select relevant info
    res <- res.umap[["layout"]]
  }
  # Create dataframe from the resulting matrix
  df <- data.frame(res)
  # Create columnnames
  colnames(df) <- c("Dim 1", "Dim 2")
  # Create samples columns
  df$samples <- rownames(df)
  # Combine metadata to the dim reduced table
  df <- merge(df, metadata, by.x="samples", by.y=dataList$meta_id)
  # Return to the dataframe
  return(df)
}

plot_dimensions <- function(df,
                            customTitle="",
                            show_labels=FALSE,
                            add_repel=FALSE,
                            add_ellipse=FALSE,
                            show_mean_point=FALSE,
                            color_group="black",
                            shape_group=19,
                            point_size=2){
  # Further plot configurations
  if(show_labels){label="samples"}else{label=NULL}
  # if(color_group=="black" && shape_group==19){
  #   add_ellipse=FALSE
  #   show_mean_point=FALSE
  # }
  # Conditional statement to not use palette for more than 10
  if(color_group != "black"){
    if(length(unique(df[, color_group])) > 10){use_pal <- "grey"}else{use_pal <- "jco"}
  }else{
    use_pal <- "black"
  }
  if(shape_group != 19){
    if(length(unique(df[, shape_group])) > 5){
      stop("Selected group have more than more unique values than R's number of shapes. Select another group for shapes")
    }
  }
  # Create a specialized scatter plot for dim.red methods
  g <- ggscatter(df, x="Dim 1", y="Dim 2",
                 color=color_group,
                 shape=shape_group,
                 size=point_size,
                 palette=use_pal,
                 label=label,
                 repel=add_repel,
                 ellipse=add_ellipse,
                 mean.point=show_mean_point,
                 star.plot=FALSE) +
    ggtitle(customTitle) +
    theme_pubclean()
  # Return the plot object
  return(g)
}
