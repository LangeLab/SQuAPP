fluidPage(
  fluidRow(
    column( # Left column
      width=3,
      # Thin box for user selected parameters
      box(
        title = tagList(icon("file-export"), "Data Preparation"),
        status="primary",
        width=NULL,
        inputId="",
        collapsible=FALSE,

        # Checks if user wants to use example data
        radioButtons(
          "example_data",
          "Do you want to use demo datasets?",
          choices = c(
            "Yes" = "yes",
            "Upload your own data" = "no"
          ),
          selected = "no"
        ),

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
        hr(), # Horizontal line

        # If user upload selected
        conditionalPanel(
          condition="input.example_data=='no'",
          # Checkbox if user wants to use custom reference fasta
          radioButtons(
            "custom_reference",
            "Do you want to use custom reference proteome fasta?",
            choices=c(
              "Yes"="yes",
              "Select from available reference proteomes"="no"
            ),
            selected="no"
          ),
          # Upload custom reference fasta
          conditionalPanel(
            condition="input.custom_reference=='yes'",
            fileInput(
              "uploadReference",
              "Upload your UniProt Fasta Reference",
              multiple=FALSE,
              accept=c("text/fasta",".fasta")
            )
          ),
          # Select pre-loaded reference fasta
          conditionalPanel(
            condition="input.custom_reference=='no'",
            selectInput(
              "select_reference",
              "Select uniprot reference proteome(s)",
              choices=reference_organisms,
              selected=NULL, 
              multiple=TRUE
            ),
            # Button and Confirmation Text
            fluidRow(
              # Load reference button
              column(
                width=6,
                actionButton(
                  inputId="load_reference",
                  label="Load reference(s)",
                  icon=icon("caret-right"),
                  status="primary",
                  size="xs"
                )
              ),
              # Confirmation text
              column(
                width=6,
                align='right',
                span(
                  textOutput("reference_loaded"), 
                  style="color:red"
                )
              )
            )
          ),
          hr(), # Horizontal line

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
            ## Create Tab Items for Different Data Uploads

            # Tab for Uploading Metadata Data
            tabPanel(
              title="Metadata",
              # Switch to make it visible
              materialSwitch(
                inputId="isExist_metadata",
                label="Upload metadata",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_metadata",
                # File Upload 
                fileInput(
                  "uploadMetadata",
                  "Upload Metadata",
                  multiple=FALSE,
                  accept=c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv", ".xlsx"
                  )
                ),
                # File Type Selection
                radioGroupButtons(
                  inputId="metadata_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected="comma",
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                # Button to trigger preview
                actionButton(
                  inputId="show_metadata_preview",
                  label="Preview metadata",
                  icon=icon("magnifying-glass"),
                  status="primary",
                  size="sm"
                ),
                hr(), # Horizontal line
                # When metadata preview is done
                conditionalPanel(
                  condition="input.show_metadata_preview!=0",
                  # Server-side selector for a column indicating sample name
                  uiOutput("metadata_sampleName_col"),
                  # Check if metadata contains replica
                  materialSwitch(
                    inputId="metadata_whether_replica",
                    label="Contains replica",
                    value=FALSE,
                    status="primary",
                  ),
                  # If metadata contains replica
                  conditionalPanel(
                    condition="input.metadata_whether_replica",
                    # Server-side selector for a column indicating non-replica sample name
                    uiOutput("metadata_uniqueSample_col"), 
                    # Replicate column
                    # Add a checkbox if there is a specific replica column
                    materialSwitch(
                      inputId="metadata_replica_col_checkbox",
                      label="Column for replica? (1,2,e.g.)",
                      value=FALSE, 
                      status="primary",
                    ),
                    conditionalPanel(
                      condition="input.metadata_replica_col_checkbox",
                      # Server-side selector for a column indicating replica sample name
                      uiOutput("metadata_replica_col")
                    )
                  ),
                  # Button to trigger metadata processing
                  actionButton(
                    inputId="process_metadata",
                    label="Prepare Metadata",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ), # End of Metadata Tab

            # Tab for Uploading Protein Level Data
            tabPanel(
              title="Protein",
              # Switch to make it visible
              materialSwitch(
                inputId="isExist_protein",
                label="Upload protein",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_protein",
                # File Upload
                fileInput(
                  "uploadProteinData",
                  "Upload Protein Level Data",
                  accept=c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv", ".xlsx"
                  )
                ),
                # File Type Selection
                radioGroupButtons(
                  inputId="protein_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                # Button to trigger preview
                actionButton(
                  inputId="show_protein_preview",
                  label="Preview Protein Data",
                  icon=icon("magnifying-glass"),
                  status="primary",
                  size="sm"
                ),
                hr(), # Horizontal line
                # When protein preview is done
                conditionalPanel(
                  condition="input.show_protein_preview!=0",
                  # Server-side selector for a column indicating protein identifier
                  uiOutput("protein_identifier_col"),
                  # Check if protein data contains replica
                  materialSwitch(
                    inputId="protein_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  # Button to trigger protein data processing
                  actionButton(
                    inputId="process_protein_data",
                    label="Prepare Protein Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ), # End of Protein Tab

            # Tab for Uploading Peptide Level Data
            tabPanel(
              title="Peptide",
              # Switch to make it visible
              materialSwitch(
                inputId="isExist_peptide",
                label="Upload peptide",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_peptide",
                # File Upload
                fileInput(
                  "uploadPeptideData",
                  "Upload Peptide Level Data",
                  accept=c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv", ".xlsx"
                  )
                ),
                # File Type Selection
                radioGroupButtons(
                  inputId="peptide_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                # Button to trigger preview
                actionButton(
                  inputId="show_peptide_preview",
                  label="Preview Peptide Data",
                  icon=icon("magnifying-glass"),
                  status="primary",
                  size="sm"
                ),
                hr(), # Horizontal line
                # When peptide preview is done
                conditionalPanel(
                  condition="input.show_peptide_preview!=0",
                  # Server-side selector for a column indicating peptide identifier
                  uiOutput("peptide_identifier_col"),
                  # Server-side selector for a column indicating protein accession
                  uiOutput("peptide_proteinAcc_col"),
                  # Server-side selector for a column indicating peptide sequence (stripped)
                  uiOutput("peptide_strippedSeq_col"),
                  # Check if peptide data contains replica
                  materialSwitch(
                    inputId="peptide_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  # Button to trigger peptide data processing
                  actionButton(
                    inputId="process_peptide_data",
                    label="Prepare Peptide Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ), # End of Peptide Tab

            # Tab for Uploading Termini Level Data
            tabPanel(
              title="Termini",
              # Switch to make it visible
              materialSwitch(
                inputId="isExist_termini",
                label="Upload termini",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_termini",
                # File Upload
                fileInput(
                  "uploadTerminiData",
                  "Upload Termini Level Data",
                  accept=c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv", ".xlsx"
                  )
                ),
                # File Type Selection
                radioGroupButtons(
                  inputId="termini_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                # Button to trigger preview
                actionButton(
                  inputId="show_termini_preview",
                  label="Preview Termini Data",
                  icon=icon("magnifying-glass"),
                  status="primary",
                  size="sm"
                ),
                hr(), # Horizontal line
                # When termini preview is done
                conditionalPanel(
                  condition="input.show_termini_preview!=0",
                  # Select termini type (N-term or C-term)
                  selectInput(
                    "termini_mod_type", 
                    "Termini Type:",
                    c(
                      "N-Term"="Nterm",
                      "C-Term"="Cterm"
                    ),
                    multiple=F
                  ),
                  # Server-side selector for a column indicating termini identifier
                  uiOutput("termini_identifier_col"),
                  # Server-side selector for a column indicating protein accession
                  uiOutput("termini_proteinAcc_col"),
                  # Server-side selector for a column indicating peptide sequence (stripped)
                  uiOutput("termini_strippedSeq_col"),
                  # Server-side selector for a column indicating peptide sequence (modified)
                  uiOutput("termini_modifiedSeq_col"),
                  # Check if termini data contains replica
                  materialSwitch(
                    inputId="termini_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  # Button to trigger termini data processing
                  actionButton(
                    inputId="process_termini_data",
                    label="Prepare Termini Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                )
              )
            ), # End of Termini Tab

            # Tab for Uploading PTM Level Data
            tabPanel(
              title="PTM",
              # Switch to make it visible
              materialSwitch(
                inputId="isExist_ptm",
                label="Upload ptm",
                value=FALSE,
                status="primary",
              ),
              conditionalPanel(
                condition="input.isExist_ptm",
                # File Upload
                fileInput(
                  "uploadPTMData",
                  "Upload PTM Level Data",
                  accept=c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv", ".xlsx"
                  )
                ),
                # File Type Selection
                radioGroupButtons(
                  inputId="ptm_file_type",
                  label="Uploaded file separated by",
                  choices=c("comma","tab","excel"),
                  selected=NULL,
                  size="normal",
                  direction="horizontal",
                  status="secondary"
                ),
                # Button to trigger preview
                actionButton(
                  inputId="show_ptm_preview",
                  label="Preview PTM Data",
                  icon=icon("magnifying-glass"),
                  status="primary",
                  size="sm"
                ),
                hr(), # Horizontal line
                # When PTM preview is done
                conditionalPanel(
                  condition=("input.show_ptm_preview!=0"),
                  # Select PTM type
                  selectInput(
                    "ptm_mod_type", 
                    label="PTM Type:",
                    # TODO: Add more PTM types (FUTURE WORK)
                    choices=c(
                      "Phosphorylation"="Phospho",
                      "Acetylation"="Acetyl"
                    ),
                    selected=NULL,
                    multiple=F
                  ),
                  # Server-side selector for a column indicating PTM identifier
                  uiOutput("ptm_identifier_col"),
                  # Server-side selector for a column indicating protein accession
                  uiOutput("ptm_proteinAcc_col"),
                  # Server-side selector for a column indicating peptide sequence (stripped)
                  uiOutput("ptm_strippedSeq_col"),
                  # Server-side selector for a column indicating peptide sequence (modified)
                  uiOutput("ptm_modifiedSeq_col"),
                  # Check if PTM data contains replica
                  materialSwitch(
                    inputId="ptm_whether_replica",
                    label="Data contains replica samples",
                    value=FALSE,
                    status="primary",
                  ),
                  # Button to trigger PTM data processing
                  actionButton(
                    inputId="process_ptm_data",
                    label="Prepare PTM Data",
                    icon=icon("play"),
                    status="warning",
                    size="sm"
                  )
                ) 
              )
            ) # End of PTM Tab
          ) # End of Tabset
        ) # End of Box
      ) # End of Column
    ), # End of Row

    #------------------------ Show Data Tables on Right Side ----------------------#
    column(
      width=9,

      #-------------- Preview the Data tables uploaded by User ----------------#
      # Preview Metadata if preview button activated
      conditionalPanel(
        condition="input.example_data=='no'",
        conditionalPanel(
          condition="input.show_metadata_preview!=0 && input.process_metadata==0",
          box(
            title=tagList(icon("table-columns"), "Preview - Metadata"),
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
            title=tagList(icon("table-columns"), "Preview - Protein Data"),
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
            title=tagList(icon("table-columns"), "Preview - Peptide Data"),
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
            title=tagList(icon("table-columns"), "Preview - Termini Data"),
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
            title=tagList(icon("table-columns"), "Preview - PTM Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="primary",
            width=NULL,
            DT::dataTableOutput("ptmData_preview") %>% withSpinner()
          )
        ),

        #--------------------- Show prepared data tables ------------------------#
        # Preview Prepared Metadata - if process button activated
        conditionalPanel(
          condition="input.process_metadata!=0",
          box(
            title=tagList(icon("table"), "Prepared - Metadata"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("metaData_prepared") %>% withSpinner(),
            downloadBttn(
              "downloadMetadataPrepared",
              label="Download Prepared Metadata",
              style="minimal",
              color="warning"
            )
          )
        ),
        # Preview Prepared Protein data - if process button activated
        conditionalPanel(
          condition="input.process_protein_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Protein Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("proteinData_prepared") %>% withSpinner(),
            downloadBttn(
              "downloadProteinPrepared",
              label="Download Prepared Protein Data",
              style="minimal",
              color="warning"
            )
          )
        ),
        # Preview Prepared Peptide data - if process button activated
        conditionalPanel(
          condition="input.process_peptide_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Peptide Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("peptideData_prepared") %>% withSpinner(),
            downloadBttn(
              "downloadPeptidePrepared",
              label="Download Prepared Peptide Data",
              style="minimal",
              color="warning"
            )
          )
        ),
        # Preview Prepared Termini data - if process button activated
        conditionalPanel(
          condition="input.process_termini_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - Termini Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("terminiData_prepared") %>% withSpinner(),
            downloadBttn(
              "downloadTerminiPrepared",
              label="Download Prepared Termini Data",
              style="minimal",
              color="warning"
            )
          )
        ),
        # Preview Prepared PTM data - if process button activated
        conditionalPanel(
          condition="input.process_ptm_data!=0",
          box(
            title=tagList(icon("table"), "Prepared - PTM Data"),
            solidHeader=TRUE,
            collapsed = FALSE,
            status="warning",
            width=NULL,
            DT::dataTableOutput("ptmData_prepared") %>% withSpinner(),
            downloadBttn(
              "downloadPtmPrepared",
              label="Download Prepared PTM Data",
              style="minimal",
              color="warning"
            )
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
