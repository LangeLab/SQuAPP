prepare_subset_preview_data <- function(dataList, feature_selection="all"){
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
  return(rows2select)
}

plot_protein_subsets <- function(dataList,
                                 feature_subset,
                                 x_var,
                                 color_var="black",
                                 shape_var=19,
                                 size_var=2){

  # Get the quantitative data
  quant_data <- dataList$quant
  # Get the metadata
  metadata <- dataList$meta
  # Get only the selected features
  quant_data <- quant_data[feature_subset, ]
  # Create the plot data
  quant_data <- quant_data %>%
      tibble::rownames_to_column(var="name") %>%
      pivot_longer(cols=-c(name),
                   names_to="samples",
                   values_to="intensity") %>%
      mutate(log2intensity=log2(intensity)) %>%
      drop_na() %>% as.data.frame()

  # Merge the metadata with the
  quant_data <- merge(quant_data, metadata,
                      by.x="samples",
                      by.y=dataList$meta_id)

  # Create protein intensity based plot
  p <- ggstripchart(quant_data,
                    palette="jco",
                    x=x_var,
                    y="log2intensity",
                    color=color_var,
                    shape=shape_var,
                    size=size_var,
                    jitter=.35,
                    x.text.angle=90,
                    facet.by="name", ncol=6,
                    add="mean_sd",
                    add.params=list(color="#3d405b75", size=.5),
                    ggtheme=theme_pubclean())
  # Return the plot
  return(p)
}

cor.mtest <- function(mat, ...) {
    mat <- as.matrix(mat)
    n <- ncol(mat)
    p.mat<- matrix(NA, n, n)
    diag(p.mat) <- 0
    for (i in 1:(n - 1)) {
        for (j in (i + 1):n) {
            tmp <- cor.test(mat[, i], mat[, j], ...)
            p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
        }
    }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  return(p.mat)
}

# require -> corrplot
plot_correlogram_fast <- function(dataList,
                                  feature_subset,
                                  corr_method="pearson",
                                  cov_with_na="pairwise.complete.obs"){
  # Create correlation matrix from the subset data
  M <- cor(t(dataList$quant[feature_subset, ]),
          use=cov_with_na,
          method=corr_method)
  # Loop through rows (original columns of data)
  for(i in rownames(M)){
    if(sum(!is.na(M[,i]))<2){
      M <- M[-which(rownames(M)==i), -which(rownames(M)==i)]
    }
  }

  # Create statistical test for the correaltion matrix
  p.mat <- cor.mtest(M, conf.level = .95)
  # Create corrplot from the package
  corrplot::corrplot.mixed(M,
                           lower="number",
                           upper="circle",
                           tl.col="black",
                           tl.pos = 'lt',
                           p.mat = p.mat,
                           sig.level=c(.001, .01, .05),
                           insig="label_sig",
                           pch.cex=1., pch.col = "white")
  p <- recordPlot()
  # Return the plot
  return(p)
}

# require -> ggstatsplot
# require -> ggcorrplot
plot_correlogram_detailed <- function(dataList,
                                      feature_subset,
                                      padjust="none",
                                      sig_level=0.05,
                                      stat_type="nonparametric",
                                      colors=c("#1d3557", "white", "#e63946"),
                                      title="Correlalogram for selected features",
                                      subtitle="", caption=""){

  data <- data.frame(t(dataList$quant[feature_subset, ]))
  # Create plot from ggstatsplot
  p <- ggstatsplot::ggcorrmat(data=data,
                              output="plot",
                              type=stat_type,
                              matrix.type="lower",
                              sig.level=sig_level,
                              p.adjust.method=padjust,
                              colors = colors,
                              title=title,
                              subtitle=subtitle,
                              caption=caption,
                              ggcorrplot.args=list(outline.color="black",
                                                   hc.order=TRUE)
                              )
  # Return the plot
  return(p)
}
