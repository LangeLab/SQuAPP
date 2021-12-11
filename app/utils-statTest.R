# require -> limma

# Function to Add different methods for testing
testingDEmethods <- function(data,
                             methodin,
                             group_factor,
                             metadata,
                             meta_id_col,
                             weight.m,
                             adj.method,
                             pval.thr=0.05,
                             log2FC.thr=1){
  # Make sure the data columns are present in the metadata
  metadata <- metadata[which(metadata[, meta_id_col] %in% colnames(data)), ]
  # Based on the method passed
  if(methodin=="limma"){
    # Create design matrix to use in limma
    design <- model.matrix(~metadata[, group_factor])
    # Fit a linear model with weights
    fit <- limma::lmFit(data, design, weights=weight.m)
    # Run the model based on the fit
    fit.eb <- limma::eBayes(fit)
    # Get log2FC for the model
    log2FC <- fit.eb$coefficients[, 2]
    # Get the average intensity
    average <- fit.eb$Amean
    # Get pvalues for the model
    pvalues <- fit.eb$p.value[, 2]
    # Adjust the p-values with FDR
    adj.pvalues <- p.adjust(pvalues, method=adj.method)
  }
  # OPINION: I believe limma is flexible and robust enough that
  #  we can include that only and not include t-test
  # TODO: Add more methods that out app can use. (proDA, etc.)

  # Create a dataframe from the results
  df <- data.frame(name=rownames(data),
                   average=average,
                   log2FC=log2FC,
                   adj.pvalue=adj.pvalues,
                   pvalue=pvalues)
  # Initialize significance column with no significance
  df$significance <- "no significance"
  # Find columns with significance significance
  df$significance[(df$adj.pvalue<pval.thr) & (df$log2FC >= log2FC.thr)] <- "Up regulated"
  df$significance[(df$adj.pvalue<pval.thr) & (df$log2FC <= -log2FC.thr)] <- "Down regulated"
  # Make the significance column a factor column
  df$significance <- as.factor(df$significance)
  # Return the data
  return(df)
}

testBlockGroup <- function(data,
                           methodin,
                           group_factor,
                           metadata,
                           meta_id_col,
                           blockfactor,
                           blockgroup,
                           weight.m,
                           adj.method,
                           pval.thr,
                           log2FC.thr){
  # Select samples
  samples_grp <- metadata[which(metadata[, blockfactor]==blockgroup), meta_id_col]
  # Run the test for specific samples
  df <- testingDEmethods(data[, samples_grp],
                         methodin,
                         group_factor,
                         metadata,
                         meta_id_col,
                         weight.m[,samples_grp],
                         adj.method,
                         pval.thr,
                         log2FC.thr)
  # Return the result
  return(df %>% drop_na() %>% data.frame())
}

createBlockResultData <- function(df1, df2, pval.thr, log2FC.thr){
  # TODO: This section can be improved
  # Filter for proteins that are identified and tested in both
  df <- df1 %>% filter(name %in% df2$name) %>% select(name)
  # Find logFCs and pvalues
  df$log2FC1 <- df1$log2FC[match(df$name,df1$name)]
  df$log2FC2 <- df2$log2FC[match(df$name,df2$name)]
  df$adj.pvalue1 <- df1$adj.pvalue[match(df$name,df1$name)]
  df$adj.pvalue2 <- df2$adj.pvalue[match(df$name,df2$name)]
  # Calculate the signficance with conditions
  df <- df %>%
    mutate(significance=case_when((adj.pvalue1 < pval.thr) & (abs(log2FC1)>log2FC.thr) & (!((adj.pvalue2 < pval.thr) & (abs(log2FC2)>log2FC.thr))) ~ "in block 1",
                                  (adj.pvalue2 < pval.thr) & (abs(log2FC2)>log2FC.thr) & (!((adj.pvalue1 < pval.thr) & (abs(log2FC1)>log2FC.thr))) ~ "in block 2",
                                  (adj.pvalue1 < pval.thr) & (abs(log2FC1)>log2FC.thr) & (adj.pvalue2 < pval.thr) & (abs(log2FC2)>log2FC.thr) ~ "in both blocks"))
  # If there are na values they are not signifcant ones
  df$significance[is.na(df$significance)] <- "no significance"
  # Create a factor out of significane column
  df$significance <-factor(df$significance,
                           levels=(c("in block 1",
                                     "in block 2",
                                     "in both blocks",
                                     "no significance")))
  # Return dataframe
  return(df %>% data.frame())
}

run_testing <- function(dataList,
                        methodin,
                        group_factor,
                        test_variables,
                        flag.block,
                        blockfactor,
                        blockLevels,
                        flag.weight,
                        NAweight,
                        NAind,
                        adj.method,
                        pval.thr=0.05,
                        log2FC.thr=1) {

  # Get the quant data
  quant_data <- dataList$quant
  # Get the metadata
  metadata <- dataList$meta
  # Get the id column for metadata
  meta_id_col <- dataList$meta_id
  # Log2 scale the data
  quant_data <- log2(quant_data)
  # Initialize weight matrix
  weight.m <- matrix(1,
                     nrow=nrow(quant_data),
                     ncol=ncol(quant_data))
  # Setup the column names to weigh matrix
  colnames(weight.m) <- colnames(quant_data)
  # If weighting option is selected in the options
  if (flag.weight==TRUE){
    # Place 1 to the missing values in the data
    quant_data[is.na(quant_data)] <- 1
    # Weight matrix data is updated with the imputation index
    weight.m[NAind] <- NAweight
  }
  # Subset the metadata with test_variable matching rows
  metadata <- metadata[which(metadata[, group_factor] %in% test_variables), ]
  # Create vector of samples to subset quant data
  samples2subset <- metadata[, meta_id_col]
  # Create factor out of grouping column
  metadata[, group_factor] <- as.factor(metadata[, group_factor])
  # Subsets the quant data
  quant_data <- quant_data[, samples2subset]
  # Subsets the weight matrix
  weight.m <- weight.m[, samples2subset]
  # If blocking is not passed do a traditionally testing and plotting
  if(flag.block==FALSE){
    # Run DE test for selected method
    df <- testingDEmethods(quant_data,
                           methodin,
                           group_factor,
                           metadata,
                           meta_id_col,
                           weight.m,
                           adj.method,
                           pval.thr,
                           log2FC.thr)
    # If blocking is selected in the app
  }else{
    # If the blocking factor is same as the FoI passed
    if(blockfactor==group_factor){return()}
    ## Prepare and Run the method selected with the first group
    df1 <- testBlockGroup(quant_data,
                          methodin,
                          group_factor,
                          metadata,
                          meta_id_col,
                          blockfactor,
                          blockLevels[1],
                          weight.m,
                          adj.method,
                          pval.thr,
                          log2FC.thr)

    ## Prepare and Run the method selected with the first group
    df2 <- testBlockGroup(quant_data,
                          methodin,
                          group_factor,
                          metadata,
                          meta_id_col,
                          blockfactor,
                          blockLevels[2],
                          weight.m,
                          adj.method,
                          pval.thr,
                          log2FC.thr)

    # Create blocked result dataframe
    df <- createBlockResultData(df1, df2, pval.thr, log2FC.thr)
  }
  # Save the result dataframe into the datalist
  dataList$stats <- df
  dataList$blocked <- flag.block

  # Return the data list
  return(dataList)
}

plot_volcano <- function(dataList, pval.thr, log2FC.thr, i_size=2){
  # Get the stats data
  data <- dataList$stats
  # Get if blocking is used in testing
  flag.block <- dataList$blocked
  # If blocking is used in testing apply different
  if(flag.block){
    p <- ggplot(data, aes(x=log2FC1, y=log2FC2,
                          color=significance, alpha=significance))+
    geom_point(size=i_size)+
    geom_vline(xintercept=log2FC.thr, linetype="dashed", color="darkgrey")+
    geom_vline(xintercept=-log2FC.thr, linetype="dashed", color="darkgrey")+
    geom_hline(yintercept=log2FC.thr, linetype="dashed", color="darkgrey")+
    geom_hline(yintercept=-log2FC.thr, linetype="dashed", color="darkgrey")+
    scale_color_manual(values=c("in block 1"="#b7094c",
                                "in block 2"="#0091ad",
                                "in both blocks"="#5c4d7d",
                                "no significance"="#b1a7a6")) +
    scale_alpha_manual(values=c("in block 1"=1.0,
                                "in block 2"=1.0,
                                "in both blocks"=1.0,
                                "no significance"=0.2)) +
    ggtitle("") + theme_pubclean() +
    labs(x="log2 fold change on block 1", y="log2 fold change on block 2")
  }else{
    p <- ggplot(data, aes(x=log2FC, y=-log10(adj.pvalue),
                          color=significance, alpha=significance)) +
          geom_point(size=i_size) +
          geom_vline(xintercept=log2FC.thr, linetype="dashed", color="darkgrey") +
          geom_vline(xintercept=-log2FC.thr, linetype="dashed", color="darkgrey") +
          geom_hline(yintercept=-log10(pval.thr), linetype="dashed", color="darkgrey") +
          scale_color_manual(values=c("Up regulated"="#e63946",
                                      "Down regulated"="#1d3557",
                                      "no significance"="#b1a7a6")) +
          scale_alpha_manual(values=c("Up regulated"=1.0,
                                      "Down regulated"=1.0,
                                      "no significance"=0.2)) +
          ggtitle("") + theme_pubclean() +
          labs(x="log2(Fold-Change)", y="-log10(adjusted p-value)")
  }
  return(p)
}

plot_ma <- function(dataList, i_size=2){
  # Get stats data
  data <- dataList$stats
  # Get if blocking is used in testing
  flag.block <- dataList$blocked
  if(flag.block){
    return()
  }else{
    p <- ggplot(data, aes(y=log2FC, x=average, color=significance, alpha=significance)) +
            geom_point(size=i_size) +
            scale_color_manual(values=c("Up regulated"="#e63946",
                                        "Down regulated"="#1d3557",
                                        "no significance"="#b1a7a6")) +
            scale_alpha_manual(values=c("Up regulated"=1.0,
                                        "Down regulated"=1.0,
                                        "no significance"=0.2)) +
            ggtitle("") + theme_pubclean() +
            labs(y="M=log2(Fold-Change)", x="A=log2(Average Intensity)")
    return(p)
  }
}
