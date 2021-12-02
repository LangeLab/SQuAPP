[Add Cover Figure (landscape format)]

### 1. Data Upload

#### Using Example Data
You can bypass the detailed data upload options by selecting using demo dataset option in the “Data Upload” page and clicking the “prepare example data” button. Using example data will set up all data levels to allow you to explore SQuAPP’s functionalities. You can view the uploaded data on the app or check the [raw](https://github.com/LangeLab/SQuAPP/tree/main/data/raw/) and [prepared](https://github.com/LangeLab/SQuAPP/tree/main/data/prepared/) files on the Github page.

<p align="center">
  <img src="../../png/001_UseExampleData.png" width="80%">
</p>

#### Using Your Data
For utilizing SQuAPP with your data, you can provide comma and tab-separated text files as well as excel files as input. The abundance data for protein, peptide, termini and PTM level information must be uploaded as separate files on the data upload page. The centrepiece of a SQuAPP analysis is the metadata file which captures the experimental design details.

**UniProt Reference Proteome Fasta:**

Because SQuAPP expands all levels of data by basic annotations, mapping the protein ids to reference proteome fasta is a crucial requirement. You can select from pre-loaded reference fasta datasets or upload a custom reference fasta if your experiments specifically use a modified fasta or your experiment organism is not in the list of pre-loaded references. After selecting or uploading the fasta through file input, click the "Load reference(s)" button to complete the reference proteome fasta configuration.

> Here are the ten reference fasta files available and can be accessed from [github](https://github.com/LangeLab/SQuAPP/tree/main/data/uniprot/fasta) at the moment:

- Arabidopsis thaliana
- Bos taurus
- Drosophila melanogaster
- Escherichia coli
- Homo sapiens
- Mus musculus
- Rattus norvegicus
- Saccharomyces cerevisiae

<p align="center">
  <img src="../../png/002_LoadingReferenceProteome.png" width="80%">
</p>

After the reference proteome is loaded in the app, the next step is to upload experiment files. Except for the metadata describing the experiment design and at least one quantitative data file, all files are optional. However, some functionality will only be available if certain data is available. For instance, peptide level data must be uploaded if you want to use the protein re-calculation feature.


##### Metadata

> **Metadata is required for SQuAPP**

The metadata specifies unique sample IDs, common ID for a replica sample, and experiment grouping variables. The sample IDs must match the column names containing the abundance data in the individual data files (protein, termini, peptide and other PTMs). One or several grouping variables are defined by providing a grouping variable name as a column header (e.g. ‘timepoint’) and the association of each sample with one or more groups (e.g. "0hr" or "1hr" or "6hr"). In the analysis, a replica is used to evaluate the data quality and can be averaged to obtain one robust datapoint per condition. PTMs).

To upload the metadata, first switch on the “Upload metadata” option, which will open the metadata upload options. After selecting a file from your computer over the “Browse…” option, select a method in which the data is separated. (If the extension of the file is `.xlsx` select excel, if `.tsv` or `.txt` select  tab, and finally if `.csv` select comma option) You can preview the uploaded data by clicking “Preview metadata” to see if the data is uploaded without any mistake.  

<p align="center">
  <img src="../../png/003_PreviewUploadedMetadata.png" width="80%">
</p>

After data preview for metadata is created now you can select column names that allow the app to assign required unique ids. The first option is to select which column in the uploaded metadata is the unique identifier that matches with quantitative sample names in your quantitative file(s).

If at least one of the quantitative data levels contains a replica, you can switch on the “Contains replica” option, requiring you to select a column containing a unique sample name column. This column will be the sample names used in non-replica datasets, or if you average replica further down in your analysis, this column will become the unique identifier for the metadata.  When you select the required columns for the app to parse it, you can click the “Prepare Metadata” button to finish loading the metadata to the app.

<p align="center">
  <img src="../../png/004_PreparedMetadata.png" width="80%">
</p>

When “Prepare Metadata” is clicked the “Prepared- Metadata” table will replace the “Preview - Metadata”, and this version of the metadata will be used for other data files. Here is the [example metadata](../../data/raw/meta_data.csv) that is used in the images and provided for users to use. Here are the column descriptions of this example metadata:

- ID (a unique identifier that matches with samples names in quantitative files -> **Required**)
- SampleName (**Required if at least one of the quantitative data has replicas**)
- SampleType (*grouping variable*)
- Disease (*grouping variable*)
- Stage (*grouping variable*)
- Replica (*Optional variable to indicate replica number*)

##### Protein Level
The protein-data file needs to contain at least a unique protein identifier as UniProt accession id format and abundance data in columns matching the subset of or all of the sample names defined in the metadata file.

To upload your protein-data file you can open the Protein tab and switch on the “Upload protein” to see the options. After selecting the file and selecting the file separated by option as done in the metadata tab you can click on the “Preview Protein Data” button to see the uploaded file. This will upload the data and preview it for you to check if the data is uploaded as expected.

<p align="center">
  <img src="../../png/005_PreviewUploadedProtein.png" width="80%">
</p>

When the protein level data preview is created options to select protein identifier column and replica indicator switch will be available for configuration according to your data. As done in metadata when you select the protein identifier column and switch on the replica indicator if protein data contains replica, you can click “Prepare Protein Data” to finalize the loading process.

<p align="center">
  <img src="../../png/006_PreparedProteindata.png" width="80%">
</p>

As can be seen from the “Prepared - Protein Data” table in the figure above, more protein-related information is created and added to the table using the proteome fasta. This is an initial annotation expansion done when loading the protein data to the app so the many features of the app can benefit from expanded annotation. In this stage, the loaded data can be downloaded as a comma-separate file to view on your computer from the bottom-left corner of the visualized table. Here is the [example protein data](./data/raw/protein_data.csv) that is used in the images and provided for users to use in the app. Here are the column descriptions of this **raw example protein data**:

- PG.ProteinAccessions (unique protein identifier -> **Required**)
- NP01_1 … NP044_2 (*Quantitative sampl es matching to unique id in metadata*)

##### Peptide Level
The peptide-data file needs to contain at least a unique peptide identifier (best to have the stripped sequence), the corresponding protein identifier, and abundance data in columns matching the sample names defined in the metadata file.

To upload your peptide quantitative data file you need to switch on the “Upload peptide” to access the upload options and configurations. The first step is to file upload the same way you did earlier for metadata or protein level data to access the uploaded file preview table. Because peptide data is commonly larger than other levels the speed of data upload and preview can be slower than other levels. You can wait until the “Preview - Peptide Data” table is created and shown.

<p align="center">
  <img src="../../png/007_PreviewUploadedPeptide.png" width="80%">
</p>

As it is done for metadata or protein level preview of the uploaded data allows you to check the uploaded data and get column names for reference to configure important column selection to be used to properly load the data to the app to be used. For peptide level, the app asks three columns to fully load the peptide data, identifier column, protein id column and stripped sequence column. If your data contains stripped sequence column and identifier column three distinct columns can be accommodated. If you have two columns as example data has you can put the `PEP.StrippedSequence` column for identifier column and stripped sequence column. Another step is similar to protein level data is to indicate if the data contains replicas. Switch on the indicator asking if the samples contain replicas. When done selecting relevant columns and selecting whether or not data contains replica click the “Prepare Peptide Data” button to load the data to the app.

<p align="center">
  <img src="../../png/008_PreparedPeptidedata.png" width="80%">
</p>

As an initial data cleaning and handling for the peptide data SQuAPP implements a simple annotation to match gene, protein names, peptide start and end positions relative to its host protein, and some quick match of Amino-acids if you want to use this expanded data for another use. SQuAPP also expands multiple protein matches to their own rows to make the data consistent for further analysis. This data can be downloaded with the button located on the bottom left of the “Prepared-Peptide Data” table created in the app. Here is the [example peptide data](./data/raw/peptide_data.csv) that is used in the images and provided for users to use in the app. Here are the column descriptions of this **raw example peptide data**:

- PEP.StrippedSequence (unique peptide identifier -> **Required**)
- PG.ProteinAccessions (corresponding protein identifier -> **Required**)
- NP01_01 … NP044_2 (*Quantitative samples matching to unique id in metadata*)
- PEP.isProteotypic (*Optional - Not used*)

##### Termini Level
The termini-data file needs to contain the following annotation elements for SQuAPP to properly load the data; a unique termini identifier, corresponding protein identifier, stripped sequence, modified sequence, and quantitative sample columns.

> To aid interpretation of the data “*ProteinAccession-position*” or “*GeneName-position*” can be used as unique termini identifier. However, using a modified sequence as a unique identifier can also be an option for unique termini identifier.

> For termini data depending on a tool, you used to search and analyze the data you might have artifacts or mislabeling in the data we highly recommended you do a pre-filtering for only correctly labelled termini to get the most healthy results in the downstream analysis. For example, SQuAPP’s example data contains two files for N-termini data one is [non-filtered](./data/raw/termini_data.csv) and the other is [filtered](./data/raw/termini_data_cleaned.csv) for only correctly-labelled N-terms. *The pre-loaded demo data is based on the filtered N-termini data*.

Similar to other data levels to upload your termini data you need to switch on the “Upload termini”. After selecting the file to upload and correct the file separator you can click “Preview Termini Data” to preview the uploaded data for checking if there are any errors in the upload process. After the data is uploaded the column selection and configuration will be enabled.

<p align="center">
  <img src="../../png/009_PreviewUploadedTermini.png" width="80%">
</p>

Configuration for loading the termini data requires selecting if the data is N-term or C-term based termini data. The “Preview - Termini Data” table can be used to select relevant columns as done in previous data levels. Finally, the replica switch needs to be turned on if the data contains replicas. When the configuration is done, you can click on “Prepare Termini Data” to load the data onto SQuAPP.

<p align="center">
  <img src="../../png/010_PreparedTerminidata.png" width="80%">
</p>

When loading the data, SQuAPP applies data cleaning steps to make the data extend its annotation and standardizes the names of the columns to be compatible with other levels if they are provided. The simple annotation includes gene, protein names, peptide start and end positions relative to its host protein, and some quick matches of Amino-acids. SQuAPP also expands multiple protein matches to their own rows to make the data consistent for further analysis. This data can be downloaded with the button located on the bottom left of the “Prepared-Termini Data” table created in the app. Here is the [example termini data](./data/raw/termini_data_cleaned.csv) that is used in the images and provided for users to use in the app. Here are the column descriptions of this **raw example termini data**:

- EG.PrecursorID (unique termini identifier & modified sequence -> **Required**)
- PEP.StrippedSequence (stripped sequence -> **Required**)
- PG.ProteinAccession (protein accession ids - > **Required** )
- NP01_01 … NP044_2 (*Quantitative samples matching to unique id in metadata*)

##### PTM Level
The PTM-data file needs to contain the following annotation elements for SQuAPP to properly load the data; a unique ptm identifier, corresponding protein identifier, stripped sequence, modified sequence, and quantitative sample columns.

> To aid interpretation of the data we recommend the use of “ProteinAccession-PTMtype-position” or “GeneName-PTMtype-position” as a unique identifier.

Similar to other data levels to upload the ptm data you need to switch on the “Upload ptm”. After selecting the file to upload and correct the file separator you can click “Preview PTM Data” to preview the uploaded data for checking if there are any errors in the upload process. After the data is uploaded the column selection and configuration will be enabled.

<p align="center">
  <img src="../../png/011_PreviewUploadedPtm.png" width="80%">
</p>

Configuration for loading the ptm data requires selecting the PTM type. (As the version 0.25 we only have Phosphorylation for PTM type, however, SQuAPP is in active development to add more PTM types and features to expand its capabilities.) The “Preview - PTM Data” table can be used to select relevant columns as done in previous data levels. Finally, the replica switch needs to be turned on if the data contains replicas. (In our example data phospho data doesn’t contain replicas so we leave it off)  When the configuration is done, you can click on “Prepare PTM Data” to load the data onto SQuAPP.

<p align="center">
  <img src="../../png/012_PreparedPtmdata.png" width="80%">
</p>

PTM data is cleaned and prepared the same way as the termini data level. SQuAPP extends its annotation with gene, protein names, peptide start and end positions relative to its host protein, and some quick matches of Amino-acids. SQuAPP also expands multiple protein matches to their own rows to make the data consistent for further analysis. This data can be downloaded with the button located on the bottom left of the “Prepared-PTM Data” table created in the app. Here is the [example ptm data](./data/raw/phospho_data.csv) that is used in the images and provided for users to use in the app. Here are the column descriptions of this raw example ptm data:

- PTM_collapse_key (unique ptm identifier -> **Required**)
- PG.ProteinGroups (protein accession ids - > **Required**)
- PTM_group (modified sequence -> **Required** )
- PEP.StrippedSequence (stripped sequence -> **Required**)
- PEP.PeptidePosition (ptm position -> not required and used)
- PTM_type (ptm type -> not required as column and not used)


---

### 2. Data Annotation

> **Requires at least termini or PTM data to be loaded to the app!**

Termini or PTM data can be further annotated to derive the sequence context of the modification site. In the current version, the annotation tool expands the initial annotation applied when preparing the uploaded data by including, specific modification sites and modification-specific sequence windows. The annotation is used for protein domain and circular network summary plots. The expanded annotated version of termini or ptm data can also be downloaded for use in external applications, such as in RoLiM.

<p align="center">
  <img src="../../png/013_DataAnnotation.png" width="80%">
</p>

Apart from the initial annotation, the data annotation section, as shown above, adds the following columns:
- `Window.size`: (user-selected residue expand * 2) + 1
- `PEP.End.window`: Window created from ending amino-acid of the peptide centred in the middle
- `PEP.Start.window`: Window created from starting amino-acid of the peptide centred in the middle
- `PTM.Protein.Pos`: Modification’s relative position on the protein
- `PTM.PEP.Pos`: Modification’s relative position on the peptide
- `PTM.AA`: Modified amino-acid
- `PTM.Window`: Sequence window created from the modified amino-acid centred in the middle

---

### 3. Protein Re-calculation
If a peptide-dataset has been uploaded, one can choose to calculate protein intensities from peptides with multiple different options provided by SQuAPP. Here are the methods provided by SQuAPP:

- `Sum of All`: Method summing all the intensities of peptides matching to the same protein
- `Average All`: Method takes the average of all the intensities of peptides matching to the same protein
- `Sum of top 3`: Method summing top intensity 3 peptides for the matching protein
- `Average of top 3`: Method averaging top intensity 3 peptides for the matching protein

When a method is selected and the “Re-calculate Proteins” button is clicked, SQuAPP calculates protein intensities and the show’s calculated protein level data as a table on the top and a visualization showing the distribution of the calculated protein intensities as a violin plot.

> If protein-level data is provided in the data-upload section the visualization becomes a split violin to show a sample-wise comparison of the original and calculated protein intensities.

<p align="center">
  <img src="../../png/014_ProteinCalculation.png" width="80%">
</p>

When the data is calculated the “Keep as protein data” switch becomes available. If you want to keep this data as the protein data or want to replace it with the original protein data then switch on “Keep as protein data” and click the “Record Proteins”.
