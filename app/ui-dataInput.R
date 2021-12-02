fluidPage(
  fluidRow(
    column(
      width=3,
      box(
        title = tagList(icon("file-export"), "Data Preparation"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,
        # Checks if user wants to use example data
        radioButtons("example_data",
                     "Do you want to use demo datasets?",
                      choices = c("Yes" = "yes",
                                  "Upload your own data" = "no"),
                      selected = "no"),
        # If example data selected
        conditionalPanel(
          condition="input.example_data=='yes'",
          actionButton(
            inputId="submitExampleData",
            label="Prepare example data",
            icon=icon("play"),
            status="warning",
            size="sm"
          )
        ),
        hr(),
        # If user upload selected
        conditionalPanel(
          condition="input.example_data=='no'",
          # Check for user specified or or existed orgnanism based uniprot reference
          radioButtons("custom_reference",
                       "Do you want to use custom reference proteome fasta?",
                       choices=c("Yes"="yes",
                                 "Select from available reference proteomes"="no"),
                       selected="no"),
          # If user selected to upload custom uniprot reference fasta
          conditionalPanel(
            condition="input.custom_reference=='yes'",
            fileInput(
              "uploadReference",
              "Upload your UniProt Fasta Reference",
              multiple=FALSE,
              accept=c("text/fasta",".fasta"))
          ),
          # If user want to use one of the preloaded
          conditionalPanel(
            condition="input.custom_reference=='no'",
            selectInput("select_reference",
                        "Select uniprot reference proteome(s)",
                        choices=reference_organisms,
                        selected=NULL, multiple=TRUE),
            actionButton(
              inputId="load_reference",
              label="Load reference(s)",
              icon=icon("caret-right"),
              status="primary",
              size="xs"
            )
          ),
          hr(),
          # Data Upload Section
          tabBox(
            title="",
            id="dataupload",
            side="right",
            width=NULL,
            selected="Metadata",
            type="pills",
            solidHeader=FALSE,
            collapsible=FALSE,
            # Tab for Uploading Metadata Data
            tabPanel(
              title="Metadata",
              materialSwitch(
                inputId="isExist_metadata",
                label="Upload metadata",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_metadata",
                fileInput(
                  "uploadMetadata",
                  "Upload Metadata",
                  multiple=FALSE,
                  accept=c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv", ".xlsx")
                ),
                radioGroupButtons(
                  inputId="metadata_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected="comma",
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                actionButton(
                  inputId="show_metadata_preview",
                  label="Preview metadata",
                  icon=icon("search"),
                  status="primary",
                  size="sm"
                ),
                conditionalPanel(
                  condition="input.show_metadata_preview!=0",
                  uiOutput("metadata_sampleName_col"),
                  materialSwitch(
                    inputId="metadata_whether_replica",
                    label="Contains replica",
                    value=FALSE,
                    status="primary",
                  ),
                  conditionalPanel(
                    condition="input.metadata_whether_replica",
                    uiOutput("metadata_uniqueSample_col")
                  ),
                  actionButton(
                    inputId="process_metadata",
                    label="Prepare Metadata",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ),
            # Tab for Uploading Protein Level Data
            tabPanel(
              title="Protein",
              materialSwitch(
                inputId="isExist_protein",
                label="Upload protein",
                value=FALSE,
                status="primary",
              ),
              # If protein data needs to be uploaded
              conditionalPanel(
                condition="input.isExist_protein",
                fileInput(
                  "uploadProteinData",
                  "Upload Protein Level Data",
                  accept=c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv", ".xlsx")
                ),
                radioGroupButtons(
                  inputId="protein_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                actionButton(
                  inputId="show_protein_preview",
                  label="Preview Protein Data",
                  icon=icon("search"),
                  status="primary",
                  size="sm"
                ),
                conditionalPanel(
                  condition="input.show_protein_preview!=0",
                  uiOutput("protein_identifier_col"),
                  materialSwitch(
                    inputId="protein_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  actionButton(
                    inputId="process_protein_data",
                    label="Prepare Protein Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ),
            # Tab for Uploading Peptide Level Data
            tabPanel(
              title="Peptide",
              materialSwitch(
                inputId="isExist_peptide",
                label="Upload peptide",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_peptide",
                fileInput(
                  "uploadPeptideData",
                  "Upload Peptide Level Data",
                  accept=c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv", ".xlsx")
                ),
                radioGroupButtons(
                  inputId="peptide_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                actionButton(
                  inputId="show_peptide_preview",
                  label="Preview Peptide Data",
                  icon=icon("search"),
                  status="primary",
                  size="sm"
                ),
                conditionalPanel(
                  condition="input.show_peptide_preview!=0",
                  uiOutput("peptide_identifier_col"),
                  uiOutput("peptide_proteinAcc_col"),
                  uiOutput("peptide_strippedSeq_col"),
                  materialSwitch(
                    inputId="peptide_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  actionButton(
                    inputId="process_peptide_data",
                    label="Prepare Peptide Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ),
            # Tab for Uploading Termini Level Data
            tabPanel(
              title="Termini",
              materialSwitch(
                inputId="isExist_termini",
                label="Upload termini",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_termini",
                fileInput(
                  "uploadTerminiData",
                  "Upload Termini Level Data",
                  accept=c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv", ".xlsx")
                ),
                radioGroupButtons(
                  inputId="termini_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                actionButton(
                  inputId="show_termini_preview",
                  label="Preview Termini Data",
                  icon=icon("search"),
                  status="primary",
                  size="sm"
                ),
                conditionalPanel(
                  condition="input.show_termini_preview!=0",
                  selectInput(
                    "termini_mod_type", "Termini Type:",
                    c("N-Term"="Nterm","C-Term"="Cterm"),
                    multiple=F
                  ),
                  uiOutput("termini_identifier_col"),
                  uiOutput("termini_proteinAcc_col"),
                  uiOutput("termini_strippedSeq_col"),
                  uiOutput("termini_modifiedSeq_col"),
                  materialSwitch(
                    inputId="termini_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  actionButton(
                    inputId="process_termini_data",
                    label="Prepare Termini Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ),
            # Tab for Uploading PTM Level Data
            tabPanel(
              title="PTM",
              materialSwitch(
                inputId="isExist_ptm",
                label="Upload ptm",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_ptm",
                fileInput(
                  "uploadPTMData",
                  "Upload PTM Level Data",
                  accept=c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv", ".xlsx")
                ),
                radioGroupButtons(
                  inputId="ptm_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                actionButton(
                  inputId="show_ptm_preview",
                  label="Preview PTM Data",
                  icon=icon("search"),
                  status="primary",
                  size="sm"
                ),
                conditionalPanel(
                  condition=("input.show_ptm_preview!=0"),
                  selectInput(
                    "ptm_mod_type", "PTM Type:",
                    c("Phosphorylation"="Phospho"),
                    multiple=F
                  ),
                  uiOutput("ptm_identifier_col"),
                  uiOutput("ptm_proteinAcc_col"),
                  uiOutput("ptm_strippedSeq_col"),
                  uiOutput("ptm_modifiedSeq_col"),
                  materialSwitch(
                    inputId="ptm_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  actionButton(
                    inputId="process_ptm_data",
                    label="Prepare PTM Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            )
          )
        )
      )
    ),
    #------------------------ Data Preview on Right Side ----------------------#
    column(
      width=9,
      #-------------- Preview the Data tables uploaded by User ----------------#
      # Preview Metadata if preview button activated
      conditionalPanel(
        condition="input.example_data=='no'",
        conditionalPanel(
          condition="input.show_metadata_preview!=0 && input.process_metadata==0",
          box(
            title=tagList(icon("columns"), "Preview - Metadata"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("metaData_preview") %>% withSpinner()
          )
        ),
        # Preview Protein data if preview button activated
        conditionalPanel(
          condition="input.show_protein_preview!=0 && input.process_protein_data==0",
          box(
            title=tagList(icon("columns"), "Preview - Protein Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("proteinData_preview") %>% withSpinner()
          )
        ),
        # Preview Peptide data if preview button activated
        conditionalPanel(
          condition="input.show_peptide_preview!=0 && input.process_peptide_data==0",
          box(
            title=tagList(icon("columns"), "Preview - Peptide Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("peptideData_preview") %>% withSpinner()
          )
        ),
        # Preview Termini data if preview button activated
        conditionalPanel(
          condition="input.show_termini_preview!=0 && input.process_termini_data==0",
          box(
            title=tagList(icon("columns"), "Preview - Termini Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("terminiData_preview") %>% withSpinner()
          )
        ),
        # Preview Peptide data if preview button activated
        conditionalPanel(
          condition="input.show_ptm_preview!=0 && input.process_ptm_data==0",
          box(
            title=tagList(icon("columns"), "Preview - PTM Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("ptmData_preview") %>% withSpinner()
          )
        ),
        #--------------------- Show prepared data tables ------------------------#
        # Preview Metadata if preview button activated
        conditionalPanel(
          condition="input.process_metadata!=0",
          box(
            title=tagList(icon("table"), "Prepared - Metadata"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("metaData_prepared") %>% withSpinner(),
            downloadBttn("downloadMetadataPrepared",
                         label="Download Prepared Metadata",
                         style="minimal",
                         color="warning")
          )
        ),
        # Preview Protein data if preview button activated
        conditionalPanel(
          condition="input.process_protein_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Protein Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("proteinData_prepared") %>% withSpinner(),
            downloadBttn("downloadProteinPrepared",
                         label="Download Prepared Protein Data",
                         style="minimal",
                         color="warning")
          )
        ),
        # Preview Peptide data if preview button activated
        conditionalPanel(
          condition="input.process_peptide_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Peptide Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("peptideData_prepared") %>% withSpinner(),
            downloadBttn("downloadPeptidePrepared",
                         label="Download Prepared Peptide Data",
                         style="minimal",
                         color="warning")
          )
        ),
        # Preview Termini data if preview button activated
        conditionalPanel(
          condition="input.process_termini_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Termini Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("terminiData_prepared") %>% withSpinner(),
            downloadBttn("downloadTerminiPrepared",
                         label="Download Prepared Termini Data",
                         style="minimal",
                         color="warning")
          )
        ),
        # Preview Peptide data if preview button activated
        conditionalPanel(
          condition="input.process_ptm_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - PTM Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("ptmData_prepared") %>% withSpinner(),
            downloadBttn("downloadPtmPrepared",
                         label="Download Prepared PTM Data",
                         style="minimal",
                         color="warning")
          )
        )
      ),
      #------------- Show prepared data tables for example data ---------------#
      conditionalPanel(
        condition="input.example_data=='yes' && input.submitExampleData!=0",
        # uiOutput("show_exampleData_prepared")
        # Show Metadata from demo data
        box(
          title=tagList(icon("table"), "Prepared - Metadata"),
          solidHeader=TRUE,
          collapsed = TRUE,
          status="warning",
          width=NULL,
          DT::dataTableOutput("example_metaData_prepared") %>% withSpinner()
        ),
        # Show Protein Data from demo data
        box(
          title=tagList(icon("table"), "Prepared - Protein Data"),
          solidHeader=TRUE,
          collapsed = TRUE,
          status="warning",
          width=NULL,
          DT::dataTableOutput("example_proteinData_prepared") %>% withSpinner()
        ),
        # Show Peptide Data from demo data
        box(
          title=tagList(icon("table"), "Prepared - Peptide Data"),
          solidHeader=TRUE,
          collapsed = TRUE,
          status="warning",
          width=NULL,
          DT::dataTableOutput("example_peptideData_prepared") %>% withSpinner()
        ),
        # Show Termini Data from demo data
        box(
          title=tagList(icon("table"), "Prepared - Termini Data"),
          solidHeader=TRUE,
          collapsed = TRUE,
          status="warning",
          width=NULL,
          DT::dataTableOutput("example_terminiData_prepared") %>% withSpinner()
        ),
        # Show PTM Data from demo data
        box(
          title=tagList(icon("table"), "Prepared - PTM Data"),
          solidHeader=TRUE,
          collapsed = TRUE,
          status="warning",
          width=NULL,
          DT::dataTableOutput("example_ptmData_prepared") %>% withSpinner()
        )
      )
    )
  )
)
