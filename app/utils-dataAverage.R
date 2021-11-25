average_data <- function(dataList){
  # Check if the quantitative data presented is empty return null
  if(is.null(dataList$quant)){return()}
  # If data passed for averaging doesn't have replicas return null
  if(!dataList$repl){return()}
  # If data passed for averaging is already averaged
  if(dataList$avrg){return()}
  # Initialize variables to be used
  uniq_col <- dataList$meta_uniq
  id_col <- dataList$meta_id
  quant_data <- dataList$quant
  meta_data <- dataList$meta
  sample.names <- unique(meta_data[, uniq_col])

  # Initialize averages data to populate in a loop
  averages.data <- matrix(ncol=length(sample.names), nrow=nrow(quant_data))
  colnames(averages.data) <- sample.names
  rownames(averages.data) <- rownames(quant_data)
  # TODO: This is a simple solution, but might be a bottleneck.
  # Loop over sample names given
  for(cur_sample_name in sample.names){
    col2subset <- meta_data[which(meta_data[, uniq_col] == cur_sample_name), id_col]
    subset_data <- quant_data[, col2subset]

    if(is.null(ncol(subset_data))){averages_vect <- subset_data
    } else {averages_vect <- rowMeans(subset_data, na.rm=TRUE)}
    averages_vect[is.nan(averages_vect)] <- NA
    averages.data[, cur_sample_name] <- averages_vect
  }
  # Remove empty columns since metadata samples might not be available for all
  averages.data <- averages.data[, colSums(is.na(averages.data)) != nrow(averages.data)]
  # Adjust the dataList element with meta and quant parts changed based on the averaging
  dataList$quant <- as.data.frame(averages.data)
  dataList$avrg <- TRUE
  dataList$meta[, id_col] <- dataList$meta[, uniq_col]
  dataList$meta[, uniq_col] <- NULL
  dataList$meta$Replica <- NULL
  # dataList$meta_id <- uniq_col
  dataList$meta <- unique(dataList$meta)
  rownames(dataList$meta) <- 1:nrow(dataList$meta)

  # Return newly created dataList
  return(dataList)
}
