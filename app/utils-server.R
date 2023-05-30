# Description: Contains utility functions that are used in the server.R file.

# An expanded tryCatch function that returns an error code
try2 <- function(
    expr,
    err_code=NULL,
    silent=TRUE
){
    tryCatch(
        expr, 
        error = function(c) {
            msg <- conditionMessage(c)
            if (!silent) message(c)
            invisible(
                structure(
                    msg, 
                    class = "try-error"
                )
            )
            return(err_code)
        }
    )
}

# Function to create a reactive dataframe from a passed data object
shiny.preview.data <- function(
    data,
    colIgnore=NULL,
    row.names=FALSE,
    pageLength=5,
    selection="multiple"
){
    # If the data passed is a matrix, convert it to a dataframe.
    if(is.matrix(data)){
        data <- as.data.frame(data, check.names=FALSE)
    }
    # If the data passed is not a dataframe, display an error message.
    if(!is.data.frame(data)){
        return(
            tags$div(
                class = "alert alert-danger",
                "There has been an error happened 
                while trying to display the data.\n 
                Please ensure your data is formatted correctly."
            )
        )
    }
    # Remove the columns that are to be ignored.
    if(!is.null(colIgnore)){data[, colIgnore] <- NULL}
    DT::renderDataTable({
        # Create a HTML widget for the resulting dataframe.
        DT::datatable(data,
            class = 'cell-border stripe',
            rownames = row.names,
            extensions = 'Buttons',
            options = list(
            scrollX = TRUE,
            lengthMenu = list(
                c(5, 10, 25), 
                c('5','10','25')
            ),
            pageLength = pageLength
            ),
            selection=selection
        )
    })
}

# Function to create a download handler for a data object
shiny.download.data <- function(
    fname,
    data,
    row.names=FALSE,
    colIgnore=NULL
){
    # If the data passed is a matrix, convert it to a dataframe.
    if(is.matrix(data)){
        data <- as.data.frame(data, check.names=FALSE)
    }
    # If the data passed is not a dataframe, display an error message.
    if(!is.data.frame(data)){
        return(
            tags$div(
                class = "alert alert-danger",
                "There has been an error happened 
                while trying to download the data.\n 
                Please ensure your data is formatted correctly."
            )
        )
    }
    # Remove the columns that are to be ignored.
    if(!is.null(colIgnore)){data[, colIgnore] <- NULL}
    # Download handler for the data object.
    downloadHandler(
        filename=function() {fname},
        content = function(file){
            write.csv(
                data, 
                file, 
                row.names=row.names
            )
        }
    )
}

# Function to create download handler for a plot object saved as a pdf
shiny.download.plot <- function(
    f, 
    p, 
    multi=F,
    fig.width=5, 
    fig.height=3
){
    downloadHandler(
        filename = function() {f},
        content = function(file){
            # Open a pdf device.
            pdf( 
                file, 
                paper="special", 
                width=fig.width, 
                height=fig.height 
            )
            # If the plot is a list of plots, print each plot.
            if(multi){ for(i in p){ print(i) } } else { print(p) }
            # Close the pdf device.
            dev.off()
        }
    )
}

# Ensure the Rownames match when cbind-ing two dataframes
robust_cbind <- function(
    df1, 
    df2
){
    df1 <- df1[!is.na(match(rownames(df1), rownames(df2))), ]
    df <- cbind(df1, df2)
    return(df)
}

# Function taken from fBasics package
# Source: https://cran.r-project.org/web/packages/fBasics/index.html
# Expanded Descriptive Statistics about the data  
shiny.basicStats <- function(x, ci=.95){    
    # Univariate/Multivariate:
    y = as.matrix(x)
    # Handle Column Names:
    if (is.null(colnames(y))) {
        Dim <- dim(y)[2]
        if (Dim == 1) {
            colnames(y) <- paste(
                substitute(x), 
                collapse = "."
            )
        } else if (Dim > 1) {
            colnames(y) <- paste(
                paste(
                    substitute(x), 
                    collapse = ""
                ), 
                1:Dim, 
                sep = ""
            )
        }
    }
    # Internal Function - CL Levels:
    cl.vals <- function(x, ci) {
        x <- x[!is.na(x)]
        n <- length(x)
        if(n <= 1) return(c(NA, NA))
        se.mean <- sqrt(var(x)/n)
        t.val <- qt((1 - ci)/2, n - 1)
        mn <- mean(x)
        lcl <- mn + se.mean * t.val
        ucl <- mn - se.mean * t.val
        return(c(lcl, ucl))
    }
    # Internal function - skewness (from moments package)
    skewness <- function (x, na.rm = FALSE) {
        if (is.matrix(x)){
            apply(x, 2, skewness, na.rm = na.rm)
        } else if (is.vector(x)) {
            if (na.rm){
                x <- x[!is.na(x)]
            }
            n <- length(x)
            (sum((x-mean(x))^3)/n)/(sum((x-mean(x))^2)/n)^(3/2)
        } else if (is.data.frame(x)){
            sapply(x, skewness, na.rm = na.rm)
        }else {
            skewness(as.vector(x), na.rm = na.rm)
        }
    }
    # Internal function - kurtois (from moments package)
    kurtosis <-function (x, na.rm = FALSE) {
        if (is.matrix(x)){
            apply(x, 2, kurtosis, na.rm = na.rm)
        } else if (is.vector(x)) {
            if (na.rm) {
                x <- x[!is.na(x)]}
            n <- length(x)
            n*sum( (x-mean(x))^4 )/(sum( (x-mean(x))^2 )^2)
        } else if (is.data.frame(x)){
            sapply(x, kurtosis, na.rm = na.rm)
        } else {
            kurtosis(as.vector(x), na.rm = na.rm)
        }
    }

    # Basic Statistics:
    nColumns <- dim(y)[2]
    ans <- NULL
    for (i in 1:nColumns) {
        X <- y[, i]
        # Observations:
        X.length <- length(X)
        X <- X[!is.na(X)]
        X.na <- X.length - length(X)
        # Basic Statistics:
        z <- c(X.length,
               X.na,
               min(X),
               max(X),
               as.numeric(quantile(X, prob = 0.25, na.rm = TRUE)),
               as.numeric(quantile(X, prob = 0.75, na.rm = TRUE)),
               mean(X),
               median(X),
               sum(X),
               sqrt(var(X)/length(X)),
               cl.vals(X, ci)[1],
               cl.vals(X, ci)[2],
               var(X),
               sqrt(var(X)),
               skewness(X),
               kurtosis(X))
        # Row Names:
        znames <- c("nobs",
                    "NAs",
                    "Minimum",
                    "Maximum",
                    "1. Quartile",
                    "3. Quartile",
                    "Mean",
                    "Median",
                    "Sum",
                    "SE Mean",
                    "LCL Mean",
                    "UCL Mean",
                    "Variance",
                    "Stdev",
                    "Skewness",
                    "Kurtosis")
        # Output as data.frame
        result <- matrix(z, ncol = 1)
        row.names(result) <- znames
        ans <- cbind(ans, result)
    }

    # Column Names:
    colnames(ans) <- colnames(y)

    # Return Value:
    return(data.frame(round(ans, digits = 6)))
}
