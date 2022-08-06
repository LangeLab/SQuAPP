placeholder_message <- function(title, message){
  tagList(
    tags$b(title),
    tags$br(),
    tags$span(style="color:grey", tags$em(message))
  )
}
