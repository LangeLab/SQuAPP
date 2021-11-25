fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title=tagList(icon("tag"), "Data Clustering"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        uiOutput("select_clustering_data"),
        hr(),
        awesomeRadio(
          inputId="select_clustering_method",
          label="Select clustering method",
          choices=c(
            "Hierarchical Clustering"="hierarchical",
            "K-Means Clustering"="kmeans",
            "Fuzzy Clustering"="fuzzy",
            "Hierarchical K-Means Clustering"="hybrid"
          ),
          inline=FALSE, selected="hierarchical"
        ),
        uiOutput("select_clustering_featureSet"),
        numericInput(
          inputId="maxClusters_toTest",
          label="Limit to max number of clusters to test",
          min=2, value=10, max=20
        ),
        actionButton(
          inputId="preview_clustering",
          label="Preview Clustering",
          icon=icon("play"),
          status="primary",
          size="sm"
        ),
        hr(),
        conditionalPanel(
          condition="input.preview_clustering!=0",
          sliderInput(
            "set_cluster_number",
            "Select number of clusters",
            min = 1, value = 2, max = 10, step = 1
          ),
          materialSwitch(
            inputId="ifFurtherConfigure",
            label="Do you want to further configure the clustering method?",
            value=FALSE, status="primary"
          ),
          actionButton(
            inputId="run_clustering",
            label="Run Clustering",
            icon=icon("play"),
            status="primary",
            size="sm"
          )
        )
      ),
      conditionalPanel(
        condition="input.preview_clustering!=0 &&
                   input.ifFurtherConfigure",
        box(
          title=tagList(icon("wrench"), "Further Configuration"),
          status="primary",
          width=NULL,
          inputId="",
          collapsible=FALSE,

          conditionalPanel(
            condition="input.select_clustering_method=='hierarchical'",
            h4("Hierarchical Clustering"),
            awesomeRadio(
              inputId="select_hc_function",
              label="Select function to employed",
              choices=c("hclust", "agnes", "diana"),
              inline=FALSE, selected="hclust"
            ),
            conditionalPanel(
              condition="input.select_hc_function=='hclust' ||
                         input.select_hc_function=='agnes'",
              awesomeRadio(
                inputId="select_hc_agglo_method",
                label="Select agglomeration method",
                choices=c("ward.D", "ward.D2", "single", "complete", "average"),
                inline=FALSE, selected="ward.D2"
              )
            ),
            awesomeRadio(
              inputId="select_hc_disMatCal_method",
              label="Select dissimilarity calculation method",
              choices=c("euclidean", "manhattan", "maximum",
                        "canberra", "binary", "minkowski"),
              inline=FALSE, selected="euclidean"
            )
          ),
          conditionalPanel(
            condition="input.select_clustering_method=='kmeans'",
            h4("K-Means Clustering"),
            awesomeRadio(
              inputId="select_km_algorithm",
              label="Select algorithm for k-means",
              choices=c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
              inline=FALSE, selected="Hartigan-Wong"
            ),
            numericInput(
              inputId="select_kc_maxIteration",
              label="Set maximum number of iteration for k-means",
              min=2, value=10, max=50
            )
          ),
          conditionalPanel(
            condition="input.select_clustering_method=='fuzzy'",
            h4("Fuzzy Clustering"),
            awesomeRadio(
              inputId="select_fc_disMatCal_method",
              label="Select dissimilarity calculation method",
              choices=c("euclidean", "manhattan", "SqEuclidean"),
              inline=FALSE, selected="euclidean"
            ),
            sliderInput(
              "set_fc_memberExponent",
              "Select membership exponent for cluster fit",
              min = 1, value = 2, max = 4, step = 0.25
            )
          ),
          conditionalPanel(
            condition="input.select_clustering_method=='hybrid'",
            h4("Hybrid Hierarchical-Kmeans Clustering"),
            awesomeRadio(
              inputId="select_hkc_disMatCal_method",
              label="Select dissimilarity calculation method",
              choices=c("euclidean", "manhattan", "maximum",
                        "canberra", "binary", "minkowski"),
              inline=FALSE, selected="euclidean"
            ),
            awesomeRadio(
              inputId="select_hkc_agglo_method",
              label="Select agglomeration method",
              choices=c("ward.D", "ward.D2", "single", "complete",
                        "average", "mcquitty", "median", "centroid"),
              inline=FALSE, selected="ward.D2"
            ),
            awesomeRadio(
              inputId="select_hkc_function",
              label="Select algorithm for k-means",
              choices=c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
              inline=FALSE, selected="Hartigan-Wong"
            ),
            numericInput(
              inputId="select_hkc_maxIteration",
              label="Set maximum number of iteration for k-means",
              min=2, value=10, max=50
            )
          )
        )
      )
    ),
    column(
      width=9,
      box(
        title="Testing Cluster Performance",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,

        conditionalPanel(
          condition="input.preview_clustering!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Average Silhouette",
              plotOutput("show_avgSil_test_plot") %>% withSpinner(),
              downloadBttn("download_avgSil_test_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Within Sum of Squares",
              plotOutput("show_wss_test_plot") %>% withSpinner(),
              downloadBttn("download_wss_test_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Gap Statistics",
              plotOutput("show_gapStat_test_plot") %>% withSpinner(),
              downloadBttn("download_gapStat_test_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")

            )
          )
        )
      ),
      box(
        title="Clustering Result",
        status="primary",
        width=NULL,
        inputId="",
        solidHeader=TRUE,
        collapsible=TRUE,

        conditionalPanel(
          condition="input.run_clustering!=0",
          tabBox(
            title="",
            width=NULL,
            collapsible=FALSE,
            tabPanel(
              title="Cluster PCA ",
              plotOutput("show_clusterPCA_plot") %>% withSpinner(),
              downloadBttn("download_clusterPCA_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),
            tabPanel(
              title="Cluster Silhouette",
              plotOutput("show_clusterSilh_plot") %>% withSpinner(),
              downloadBttn("download_clusterSilh_plot",
                           label="Download Plot",
                           style="minimal",
                           color="warning")
            ),

            tabPanel(
              title="Cluster Dendogram",
              conditionalPanel(
                condition="input.select_clustering_method=='hierarchical' ||
                           input.select_clustering_method=='hybrid'",
                plotOutput("show_clusterDendogram_plot") %>% withSpinner(),
                downloadBttn("download_clusterDendogram_plot",
                             label="Download Plot",
                             style="minimal",
                             color="warning")
              )
            ),
            tabPanel(
              title="Cluster Membership Plot",
              conditionalPanel(
                condition="input.select_clustering_method=='fuzzy'",
                plotOutput("show_clusterMembership_plot") %>% withSpinner(),
                downloadBttn("download_clusterMembership_plot",
                             label="Download Plot",
                             style="minimal",
                             color="warning")
              )
            )
            # conditionalPanel(
            #   condition="input.select_clustering_method=='hierarchical'",
            #   tabPanel(
            #     title="Summary Heatmap Plot",
            #     plotOutput("show_clusterHeatmap_plot") %>% withSpinner(),
            #     downloadBttn("download_clusterHeatmap_plot",
            #                  label="Download Plot",
            #                  style="minimal",
            #                  color="warning")
            #   )
            # )
          )
        )
      )
    )
  )
)
