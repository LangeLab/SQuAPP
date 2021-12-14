# Main plot to visualize distributions with violin plots
plotviolin <- function(dataList, group_factor=NULL, custom_title=""){
  # Get the quantitative data
  quant_data <- dataList$quant
  # Create long version of the data
  data.long <- na.omit(melt(as.matrix(quant_data)))
  colnames(data.long) <- c("Feature", "Sample", "Intensity")
  rownames(data.long) <- NULL
  data.long <- as.data.frame(data.long)
  # If no group factor is passed
  if(is.null(group_factor)){
    # Plot the Violin Plots of the data to show intensities
    p <- ggplot(data.long, aes(x = Sample, y = log2(Intensity))) +
            geom_violin(draw_quantiles=(.5)) + # Drawing median for each violin
            theme_pubclean() + ggtitle(custom_title) +
            theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
  }else{
    # Get the metadata
    metadata <- dataList$meta
    meta_id_col <- dataList$meta_id
    # Check if the group factor is within the metadata
    if(!group_factor %in% colnames(metadata)){return()}
    # If there are more than 5 unique values for the group_factor
    if(length(unique(metadata[, group_factor])) > 5){
      # stop("More than 5 unique values in group_factor won't be plotted!")
      return(1)
    }
    # Merge the grouping factor to the plot data
    data.long <- merge(data.long,
                       metadata[, c(meta_id_col, group_factor)],
                       by.x="Sample",
                       by.y=meta_id_col)
                       # Standardize column names
    colnames(data.long) <- c("Sample", "Feature", "Intensity", "group")
    # Plot the Violin Plots of the data to show intensities
    p <- ggplot(data.long, aes(x = Sample, y = log2(Intensity), fill=group)) +
            geom_violin(draw_quantiles=(.5)) + # Drawing median for each violin
            facet_grid(. ~group, scales = "free_x", space='free') +
            theme_pubclean() + ggtitle(custom_title) +
            theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7.5))
    p <- set_palette(p, "jco")
  }
  return(p+labs(x="Samples"))
}

geom_flat_violin <- function(mapping = NULL, data = NULL, stat = "ydensity",
                             position = "dodge", trim = TRUE, scale = "area",
                             show.legend = NA, inherit.aes = TRUE, ...) {
    # define flat violin geom
    GeomFlatViolin <- ggplot2::ggproto(
        "Violinist",
        Geom,
        setup_data = function(data, params) {
            data$width <- data$width %||%
                params$width %||% (ggplot2::resolution(data$x, FALSE) * 0.9)

            # ymin, ymax, xmin, and xmax define the bounding rectangle for each group
            data %>%
                dplyr::group_by(group) %>%
                dplyr::mutate(ymin = min(y),
                              ymax = max(y),
                              xmin = x,
                              xmax = x + width / 2)

        },
        draw_group = function(data, panel_scales, coord) {
            # Find the points for the line to go all the way around
            data <- transform(data, xminv = x,
                              xmaxv = x + violinwidth * (xmax - x))

            # Make sure it's sorted properly to draw the outline
            newdata <- rbind(plyr::arrange(transform(data, x = xminv), y),
                             plyr::arrange(transform(data, x = xmaxv), -y))

            # Close the polygon: set first and last point the same
            # Needed for coord_polar and such
            newdata <- rbind(newdata, newdata[1,])

            ggplot2:::ggname("geom_flat_violin",
                             ggplot2::GeomPolygon$draw_panel(newdata, panel_scales, coord))
        },
        draw_key = draw_key_polygon,
        default_aes = aes(weight = 1, colour = "grey20",
                          fill = "white", size = 0.5,
                          alpha = NA, linetype = "solid"),
        required_aes = c("x", "y")
    )

    layer(
        data = data,
        mapping = mapping,
        stat = stat,
        geom = GeomFlatViolin,
        position = position,
        show.legend = show.legend,
        inherit.aes = inherit.aes,
        params = list(
            trim = trim,
            scale = scale,
            ...
        )
    )
}

geom_split_violin <- function (mapping = NULL,
                               data = NULL,
                               stat = "ydensity",
                               position = "identity", ...,
                               draw_quantiles = NULL,
                               trim = TRUE,
                               scale = "area",
                               na.rm = FALSE,
                               show.legend = NA,
                               inherit.aes = TRUE) {
    GeomSplitViolin <- ggplot2::ggproto(
        "GeomSplitViolin",
        GeomViolin,
        draw_group = function(self, data, ..., draw_quantiles = NULL) {
            data <- transform(data,
                              xminv = x - violinwidth * (x - xmin),
                              xmaxv = x + violinwidth * (xmax - x))
            grp <- data[1,'group']
            newdata <- plyr::arrange(
                transform(data, x = if(grp%%2==1) xminv else xmaxv),
                if(grp%%2==1) y else -y
            )
            newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
            newdata[c(1,nrow(newdata)-1,nrow(newdata)), 'x'] <- round(newdata[1, 'x'])
            if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
                stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <= 1))
                quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
                aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
                aesthetics$alpha <- rep(1, nrow(quantiles))
                both <- cbind(quantiles, aesthetics)
                quantile_grob <- ggplot2::GeomPath$draw_panel(both, ...)
                ggplot2:::ggname("geom_split_violin",
                                 grid::grobTree(ggplot2::GeomPolygon$draw_panel(newdata, ...), quantile_grob))
            } else {
                ggplot2:::ggname("geom_split_violin", ggplot2::GeomPolygon$draw_panel(newdata, ...))
            }
        }
    )


    layer(data = data,
          mapping = mapping,
          stat = stat,
          geom = GeomSplitViolin,
          position = position,
          show.legend = show.legend,
          inherit.aes = inherit.aes,
          params = list(trim = trim,
                        scale = scale,
                        draw_quantiles = draw_quantiles,
                        na.rm = na.rm, ...)
    )
}

# Implements splitviolin from plotly
# plotly.splitViolin <- function(df1, df2, df1_name, df2_name, color1, color2){
#   # Melt the first dataframe
#   df1 <- melt(df1, id.vars=NULL, variable.name="Samples", value.name="Intensity")
#   df1$DataStatus <- df1_name # Assign value to Data Status
#   df1 <- na.omit(df1) # Remove NA value rows
#   # Melt the second dataframe
#   df2 <- melt(df2, id.vars=NULL, variable.name="Samples", value.name="Intensity")
#   df2$DataStatus <- df2_name # Assign value to Data Status
#   df2 <- na.omit(df2) # Remove NA value rows
#   # Concat datasets
#   combined_df <- rbind(df1, df2)
#
#   # Plot a split violin
#   fig <- combined_df %>%
#     plot_ly(type="violin", points = F, showlegend = T) %>%
#     add_trace(
#       x = combined_df[combined_df$DataStatus==df1_name, "Samples"],
#       y = log10(combined_df[combined_df$DataStatus==df1_name, "Intensity"]),
#       legendgroup = df1_name,
#       scalegroup = df1_name,
#       name = df1_name,
#       side = "negative",
#       box = list(visible = T),
#       meanline = list(visible = T),
#       color = I(color1)
#     ) %>%
#     add_trace(
#       x = combined_df[combined_df$DataStatus==df2_name, "Samples"],
#       y = log10(combined_df[combined_df$DataStatus==df2_name, "Intensity"]),
#       legendgroup = df2_name,
#       scalegroup = df2_name,
#       name = df2_name,
#       side = "positive",
#       box = list(visible = T),
#       meanline = list(visible = T),
#       color = I(color2)
#     ) %>%
#     layout(
#       xaxis = list(title=""),
#       yaxis = list(title="log10(Intensity)", zeroline=F)
#     )
#
#   return(fig)
# }
