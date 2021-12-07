# require -> ComplexHeatmap

# Utility function that subsets based on data level
subset_data_for_circular <- function(data, d_type="protein"){
  # Subsets the data based on data type
  df <- data %>%
    filter(type==d_type) %>%
    separate_rows(PTM.Protein.Pos) %>%
    select(type, Protein.identifier,
           PTM.Protein.Pos, significance,
           log2FC, change, sectionID) %>%
    distinct() %>% data.frame()
  # Make sure the column is numeric
  df$PTM.Protein.Pos <- as.numeric(df$PTM.Protein.Pos)
  # Return to the subseted dataframe
  return(df)
}
# Function to allow user selection based filtering to be done when creating data
filter_data_based_user_selection <- function(df,
                                             filter_on="log2fc",
                                             filter_condition="all"){

  if(filter_on == "log2fc"){
    if(filter_condition == "all"){
      filtered_data <- df %>% filter(change!="no change")
    }else if(filter_condition == "none"){
      filtered_data <- df
    }else if(filter_condition == "no regulate"){
      filtered_data <- df %>% filter(change=="no change")
    }else{
      filtered_data <- df %>% filter(change==filter_condition)
    }
  }else if(filter_on == "pvalue"){
    if(filter_condition == "all"){
      filtered_data <- df %>% filter(significance!="no significance")
    }else if(filter_condition == "none"){
      filtered_data <- df
    }else{
      filtered_data <- df %>% filter(significance==filter_condition)
    }
  }
  return(as.data.frame(filtered_data))
}

# Creates a quantitative based data from all available data levels
create_circular_quant_data <- function(dataset_lists,
                                       include_levels=c("protein",
                                                        "termini",
                                                        "ptm")){
  # If 1 or less levels passed to include return null
  if(length(include_levels) <=1){
    return()
  }
  else{
    # Initialize a dataframe
    df <- data.frame()
    # Combine the datasets with same - necessary columns
    for(i in include_levels){
      cur_data.list <- dataset_lists[[i]]
      if(i == "protein"){
        cur_data.list$annot$PTM.Protein.Pos <- 1
      }else if(i == "peptide"){
        cur_data.list$annot$PTM.Protein.Pos <- cur_data.list$annot$PEP.Pos.start
      # If termini or PTM's annotation is not extended in the data setup section
      }else{
        if(!('PTM.Protein.Pos' %in%cur_data.list$annot)){
          # use function from utils-annot.R to extend annotation to
          #  have PTM.Protein.Pos column ready for use
          cur_data.list$annot <- getSequenceWindow(
            cur_data.list$annot,
            numExtend=5,
            modificationType=cur_data.list$name
          )
        }
      }
      df <- rbind(df, cbind(type=cur_data.list$name,
                            cur_data.list$annot[, c("Protein.identifier",
                                                    "PTM.Protein.Pos")],
                            cur_data.list$stats))
      df <- df %>% drop_na() %>% data.frame()
    }
    # Create type table to remove if there is only one type data available
    logical_table <- df %>%
      group_by(Protein.identifier) %>%
      count(type) %>% spread(type, n) %>%
      mutate_if(is.numeric, as.logical) %>%
      mutate_if(is.logical, ~replace_na(., FALSE)) %>%
      mutate(distinctTypes = rowSums(across(where(is.logical)))) %>%
      filter(distinctTypes > 1)

    df <- df %>%
      filter(Protein.identifier %in% logical_table$Protein.identifier) %>%
      mutate(change=case_when(log2FC<(-1) ~ "down",
                              log2FC>(-1)&(log2FC<1) ~ "no change",
                              log2FC>1 ~ "up")) %>%
      mutate(sectionID=paste0(type,"_",change)) %>%
      mutate(point_color = case_when(change=="up" ~ "#78000050",
                                     change=="down" ~ "#00304950",
                                     change=="no change" ~ "#b1a7a650"))

    return(data.frame(df))
  }
}

# Creates a Start to End connections dataframe for plotting
create_connections_data <- function(df,
                                    dataset_lists,
                                    include_levels,
                                    filter_on_vector,
                                    filter_condition_vector,
                                    windowSize=10
                                    ){
  # Get subset from circular quant_data and apply filtering parameters
  if("protein" %in% include_levels){
    pro_sub <- subset_data_for_circular(df, dataset_lists$protein$name)
    pro_sub <- filter_data_based_user_selection(pro_sub,
                                                filter_on_vector["protein"],
                                                filter_condition_vector["protein"]
                                                )
  }
  if("peptide" %in% include_levels){
    pep_sub <- subset_data_for_circular(df, dataset_lists$peptide$name)
    pep_sub <- filter_data_based_user_selection(pep_sub,
                                                filter_on_vector["peptide"],
                                                filter_condition_vector["peptide"]
                                                )
  }
  if("termini" %in% include_levels){
    ter_sub <- subset_data_for_circular(df, dataset_lists$termini$name)
    ter_sub <- filter_data_based_user_selection(ter_sub,
                                                filter_on_vector["termini"],
                                                filter_condition_vector["termini"]
                                                )
  }
  if("ptm" %in% include_levels){
    ptm_sub <- subset_data_for_circular(df, dataset_lists$ptm$name)
    ptm_sub <- filter_data_based_user_selection(ptm_sub,
                                                filter_on_vector["ptm"],
                                                filter_condition_vector["ptm"]
                                                )
  }
  # Initialize a connections data to populate
  connection_df <- data.frame()

  # If protein level is passed
  if("protein" %in% include_levels){
    # Go through other available levels to combine a connection with protein
    for(i in (include_levels[include_levels!="protein"])){
      if(i=="peptide"){sub_data <- merge(pro_sub, pep_sub, by="Protein.identifier")}
      if(i=="termini"){sub_data <- merge(pro_sub, ter_sub, by="Protein.identifier")}
      if(i=="ptm"){sub_data <- merge(pro_sub, ptm_sub, by="Protein.identifier")}
      connection_df <- rbind(connection_df, sub_data)
    }
  }
  # If peptide level is passed make sure to capture peptide to termini-ptm
  if("peptide" %in% include_levels){
    if("termini" %in% include_levels){
      sub_data <- merge(pep_sub, ter_sub, by="Protein.identifier")
      sub_data <- sub_data %>%
        filter((PTM.Protein.Pos.x <= PTM.Protein.Pos.y + windowSize) &
               (PTM.Protein.Pos.x >= PTM.Protein.Pos.y - windowSize)) %>%
        data.frame()
      connection_df <- rbind(connection_df, sub_data)
    }
    if("ptm" %in% include_levels){
      sub_data <- merge(pep_sub, ptm_sub, by="Protein.identifier")
      sub_data <- sub_data %>%
      filter((PTM.Protein.Pos.x <= PTM.Protein.Pos.y + windowSize) &
             (PTM.Protein.Pos.x >= PTM.Protein.Pos.y - windowSize)) %>%
        data.frame()
      connection_df <- rbind(connection_df, sub_data)
    }
  }
  if(("termini" %in% include_levels) && ("ptm" %in% include_levels)){
    sub_data <- merge(ter_sub, ptm_sub, by="Protein.identifier")
    sub_data <- sub_data %>%
      filter((PTM.Protein.Pos.x <= PTM.Protein.Pos.y + windowSize) &
             (PTM.Protein.Pos.x >= PTM.Protein.Pos.y - windowSize))  %>%
      data.frame()
    connection_df <- rbind(connection_df, sub_data)
  }

  # connection_df <- connection_df %>%
  #   # Remove entities with non-significant in both ends of the connection to boost performance in plotting
  #   filter((change.x != "no change") & (change.y != "no change")) %>%
  #   data.frame()

  # Return the prepare connection dataframe
  return(connection_df)
}

# Create custom data-level color map to be used in circular plot with
#  user assigned names for better readibility in legends
create_data_level_color_map <- function(dataset_lists, include_levels){

  # Custom colors for the data levels
  data_level_colors <- c("protein"="#403d39",
                         "peptide"="#005f73",
                         "termini"="#ae2012",
                         "ptm"="#ee9b00")
  # Subset main color palette and make sure the names are consistent with user provided names
  color_map <- c()
  user_names <- c()
  for(i in include_levels){
    user_names <- c(user_names, dataset_lists[[i]]$name)
    color_map <- c(color_map, data_level_colors[i])
  }
  names(color_map) <- user_names
  return(color_map)
}

# Main function to plot the circular network plot
plot_circular_network_summary <- function(df,
                                          connection_df,
                                          color_map
                                          ){

  # Makes sure the highligted connections are plotted last
  #  order not changed if no highlight selected
  connection_df <- connection_df %>% arrange(width) %>% data.frame()

  # First create legend objects to include in the plot
  lgd_data <- ComplexHeatmap::Legend(title="Data Level", ncol=1,
                                   at=names(color_map),
                                   legend_gp=grid::gpar(fill=color_map))

  lgd_points <- ComplexHeatmap::Legend(title="Log2FC Regulation",
                                       ncol=1, type = "points",
                                       at=c("up", "no change", "down"),
                                       legend_gp=grid::gpar(col=c("#780000",
                                                                  "#b1a7a6",
                                                                  "#003049")))

  lgd_list = ComplexHeatmap::packLegend(lgd_data, lgd_points)

  # Initialize the circos plot with sectors
  circos.initialize(sectors=df$sectionID, x = df$log2FC)
  # Create color label track
  circos.trackPlotRegion(track.index=1,
                         sectors=df$sectionID,
                         y=df$adj.pvalue,
                         track.height = 0.05,
                         track.margin=c(0.075, 0.01))
  uniq_sectors <- unique(df$sectionID)
  # Add colors to the color label track
  lapply(names(color_map),
         function(x){highlight.sector(uniq_sectors[grep(x, uniq_sectors)],
                                      track.index=1,
                                      col=color_map[x],
                                      text="",
                                      lwd=1.25,
                                      cex=0.8,
                                      text.col='white',
                                      niceFacing=TRUE)})
  # Create volcano track
  circos.trackPlotRegion(track.index=2,
                         sectors=df$sectionID,
                         y=df$adj.pvalue,
                         panel.fun = function(x, y){
    circos.axis(h='top',
                labels=TRUE,
                major.tick=TRUE,
                labels.cex=.5,
                labels.font=1,
                direction='outside',
                minor.ticks=5,
                lwd=1)
  })
  # Add limma test result points to the volcano track
  circos.trackPoints(df$sectionID,
                     df$log2FC,
                     df$adj.pvalue,
                     track.index=2,
                     pch = 16,
                     cex = 0.45,
                     col=df$point_color)
  # Adding each individual connections
  for (row in 1:nrow(connection_df)){
      circos.link(as.character(connection_df[row, 'sectionID.x']),
                  as.double(connection_df[row, 'log2FC.x']),
                  as.character(connection_df[row, 'sectionID.y']),
                  as.double(connection_df[row, 'log2FC.y']),
                  h=0.95, h2=0.95,
                  w=as.numeric(connection_df[row, "width"]),
                  col=as.character(connection_df[row, 'color']))
  }
  # Drawing the legend prepared
  ComplexHeatmap::draw(lgd_list,
                       x=grid::unit(8, "mm"),
                       y=grid::unit(4, "mm"),
                       just=c("left", "bottom"))
  # Assign generic title
  title("Circular plots")
  # Record base R graphics to object to return without an issue
  p <- recordPlot()

  circos.clear()

  return(p)
}
