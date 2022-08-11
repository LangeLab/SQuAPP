placeholder_message <- function(title, message){
  tagList(
    tags$b(title),
    tags$br(),
    tags$span(style="color:grey", tags$em(message))
  )
}

report.preview.data <- function(data, colIgnore=NULL, rowN=3){
  if(!is.null(colIgnore)){data[, colIgnore] <- NULL}
  return (psych::headTail(data, top=rowN, bottom=rowN, ellipsis=FALSE))
}
