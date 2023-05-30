add_TabPanel_homeTab <- function(title, icon, mds_path){
    tabPanel(
        title = title,
        icon = icon,
        fluidRow(
            column(
                width = 10, 
                offset = 1, 
                includeMarkdown(mds_path)
            )
        )
    )
}