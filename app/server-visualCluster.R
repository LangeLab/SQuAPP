# Create data selection for clustering
output$select_clustering_data <- renderUI({
  if(input$example_data == "yes"){
    cc <- c("protein", "peptide", "termini", "ptm")
  }else{
    cc <- c("protein", "peptide",
            "termini", "ptm")[c(input$isExist_protein, input$isExist_peptide,
                                input$isExist_termini, input$isExist_ptm)]
  }
  selectInput("select_clustering_data",
               label="Select data level for clustering",
               choices=cc,
               selected=NULL)
})

# Create data subsetting element for clustering
output$select_clustering_featureSet <- renderUI({
  if(isTruthy(input$select_clustering_data)){
    # Get the current data list
    dataList <- variables$datasets[[input$select_clustering_data]]
    cc <- c("all")
    if(isTruthy(dataList$stats)){
      cc <- c(cc, "all significant", levels(dataList$stats$significance))
    }
    selectInput("select_clustering_featureSet",
                 label="Select feature subset you want to use",
                 choices=cc,
                 selected=NULL)
  }else{ return() }
})

observeEvent(input$preview_clustering, {
  # TODO: Add validations and checks to prevent crashes
  # Get the current data list
  dataList <- variables$datasets[[input$select_clustering_data]]
  # Get the clustering methods
  method <- input$select_clustering_method
  # Get the feature subset
  feature_selection <- input$select_clustering_featureSet
  # Get the maximum number of clusters to test
  max_k <- input$maxClusters_toTest
  # Prepare the quant data for
  scaled_data <- prepare_clustering_data(dataList, feature_selection)
  # Get the function for running the clustering
  if(method=="hierarchical"){
    clustering_function <- factoextra::hcut
  }else if(method=="kmeans"){
    clustering_function <- kmeans
  }else if(method=="fuzzy"){
    clustering_function <- cluster::fanny
  }else if(method=="hybrid"){
    clustering_function <- factoextra::hkmeans
  }
  custom_title <- paste(method, "clustering performance up to", max_k, "clusters")

  # Create plot for testing with average silhouette
  output$show_avgSil_test_plot <- renderPlot({
    #
    res <- plot_clustering_performance(scaled_data,
                                       clustering_function,
                                       max_k=max_k, nboot=25,
                                       performance_method="silhouette",
                                       custom_title=custom_title
                                      )
    # Create name for the plot
    pname <- paste0("ClusterTest_AverageSilhouette_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_avgSil_test_plot <- shiny.download.plot(pname, res, multi=F,
                                                            fig.width=12,
                                                            fig.height=6)
    return(res)
  })
  # Create plot for testing with within sum of squares
  output$show_wss_test_plot <- renderPlot({
    #
    res <- plot_clustering_performance(scaled_data,
                                       clustering_function,
                                       max_k=max_k, nboot=25,
                                       performance_method="wss",
                                       custom_title=custom_title
                                      )
    # Create name for the plot
    pname <- paste0("ClusterTest_withinSumofSquares_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_wss_test_plot <- shiny.download.plot(pname, res, multi=F,
                                                         fig.width=12,
                                                         fig.height=6)
    return(res)
  })

  # Create plot for testing with within sum of squares
  output$show_gapStat_test_plot <- renderPlot({
    #
    res <- plot_clustering_performance(scaled_data,
                                       clustering_function,
                                       max_k=max_k, nboot=25,
                                       performance_method="gap_stat",
                                       custom_title=custom_title
                                      )
    # Create name for the plot
    pname <- paste0("ClusterTest_gapStats_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_gapStat_test_plot <- shiny.download.plot(pname, res, multi=F,
                                                             fig.width=12,
                                                             fig.height=6)
    return(res)
  })
})

# Create run cluster server handling
observeEvent(input$run_clustering, {
  # TODO: Add validations and checks to prevent crashes
  # Get the current data list
  dataList <- variables$datasets[[input$select_clustering_data]]
  # Get the clustering methods
  method <- input$select_clustering_method
  # Get the feature subset
  feature_selection <- input$select_clustering_featureSet
  # Get cluster numbers to run with
  clusterNumber <- input$set_cluster_number
  # Prepare the quant data for
  scaled_data <- prepare_clustering_data(dataList, feature_selection)
  # Run the functions based on the clustering method passed
  if(method=="hierarchical"){
    clu <- factoextra::hcut(scaled_data,
                            k=clusterNumber,
                            hc_func=input$select_hc_function,
                            hc_method=input$select_hc_agglo_method,
                            hc_metric=input$select_hc_disMatCal_method)
  }else if(method=="kmeans"){
    clu <- stats::kmeans(scaled_data,
                         centers=clusterNumber,
                         algorithm=input$select_km_algorithm,
                         iter.max=input$select_kc_maxIteration)
  }else if(method=="fuzzy"){
    clu <- cluster::fanny(scaled_data,
                          k=clusterNumber,
                          metric=input$select_fc_disMatCal_method,
                          memb.exp=input$set_fc_memberExponent)
  }else if(method=="hybrid"){
    clu <- factoextra::hkmeans(scaled_data,
                               k=clusterNumber,
                               hc.metric=input$select_hkc_disMatCal_method,
                               hc.method=input$select_hkc_agglo_method,
                               km.algorithm=input$select_hkc_function,
                               iter.max=input$select_hkc_maxIteration)
  }

  # Create cluster PCA plot
  output$show_clusterPCA_plot <- renderPlot({
    # Plot the data with figure variables
    res <- plot_clustering_pca(clu, scaled_data,
                               show_label=TRUE,
                               add_repel=TRUE,
                               customTitle=paste(method, "clustering on PCA"),
                               add_ellipse=TRUE,
                               ellipse_type="confidence",
                               pointsize=2)
    # Create name for the plot
    pname <- paste0("Cluster_PCA_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_clusterPCA_plot <- shiny.download.plot(pname, res, multi=F,
                                                           fig.width=12,
                                                           fig.height=6)
    return(res)
  })

  # Create cluster silhouette plot
  output$show_clusterSilh_plot <- renderPlot({
    if(method=="fuzzy"){
      sil_res <- cluster::silhouette(clu$clustering, dist(scaled_data))
    }else{
      sil_res <- cluster::silhouette(clu$cluster, dist(scaled_data))
    }
    # Plot the data with figure variables
    res <- plot_clustering_silhouette(sil_res)
    # Create name for the plot
    pname <- paste0("Cluster_Silhouette_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_clusterSilh_plot <- shiny.download.plot(pname, res, multi=F,
                                                           fig.width=12,
                                                           fig.height=6)
    return(res)
  })

  # Create cluster dendogram plot
  output$show_clusterDendogram_plot <- renderPlot({
    res <- plot_clustering_dendogram(clu)
    # Create name for the plot
    pname <- paste0("Cluster_Dendogram_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_clusterDendogram_plot <- shiny.download.plot(pname, res, multi=F,
                                                                 fig.width=12,
                                                                 fig.height=6)
    return(res)
  })

  # Create cluster dendogram plot
  output$show_clusterMembership_plot <- renderPlot({
    res <- plot_clustering_membership(clu)
    # Create name for the plot
    pname <- paste0("Cluster_MembershipPlot_",
                   input$select_clustering_data,
                   "_", method, "_",
                   Sys.Date(), ".pdf")
    # Download handler for the plot
    output$download_clusterMembership_plot <- shiny.download.plot(pname, res, multi=F,
                                                                 fig.width=12,
                                                                 fig.height=6)
    return(res)
  })

})
