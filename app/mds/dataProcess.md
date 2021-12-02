[Add Cover Figure (landscape format)]

Going over the quality check step you might have an idea of what you would like to do in terms of pre-processing. SQuAPP offers multiple methods for each category of data preprocessing: average, filter, impute and normalize your data.

SQuAPP offers flexible methods and options when it comes to changing your data. Each category of data preprocessing follows a similar structure of showing the original state of the data on the top result box and the changed state of the data on the bottom result box. Both of the boxes contain visualizations and a changing table as well as a summary statistics table. The plots and data tables can be downloaded individually for reference.

> SQuAPP doesn’t automatically update your dataset when you apply a change but offers a button. Whenever you are done with configuration and checked with the provided visuals for each preprocessing category you can click on that button to save the data as the original.

### 1. Data Averaging
Data averaging simply collapses the replicas into the same sample by averaging the replicas.

When the data level is selected and the “Average Replica” button is clicked, SQuAPP provides a simple violin plot and a quantitative data preview for both original and averaged states for you to compare. After you want to go with the averaged state of a selected data level, you can switch on the “Want to replace it with original data” and click the “Record as Original” button to save the averaged state.

<p align="center">
  <img src="../../png/019_DataAveragingVisual.png" width="80%">
</p>

### 2. Data Filtering

Using SQuAPP you can remove one or more than one sample and/or can remove features that have low data completeness.

> SQuAPP provides two major versions to look at the data completeness and apply filtering on the data; global and grouped. If you want to look at the data completeness by adding grouping variables, you can switch on the “Do you want to preview plots with grouping” and “Do you want to filter by metadata groups?” options to access variable selection input.

<p align="center">
  <img src="../../png/020_DataFilteringInitial.png" width="80%">
</p>

To provide a friendly interface SQuAPP offers a data quality preview specifically for data completeness to decide if you want to filter by data completeness and if by what percentage you want your features to be complete to keep them. There are two plots and two tables available for both “Original State of Data” and “Filtered State of Data”:

- `Data Completeness - Count Plot`:  Bar plot showing the number of complete samples over the number of features.
- `Data Completeness - Percentage Plot`: Stacked bar plot showing the number of features belonging to each percentage group for visualizing data completeness.
- `Data Table`: Selected data level
- `Summary Statistics`: Summary statistics of the selected data level
When you click the “Preview Data Quality” button after you select data level and if you want grouped preview’s select grouping variable, the “Original State of Data” box will be available.

<p align="center">
  <img src="../../png/021_DataFilteringPreview.png" width="80%">
</p>

When the “Preview Data Quality” button is clicked and the “Original State of Data” box is populated, the options to configure filtering will appear. Two switches indicate two simple filtering functions available in SQuAPP; the ability to remove samples from the selected data level and filter features by data completeness. If you chose to switch on the removing samples option, you can select one or more sample names from the drop-down menu to be removed from the data. If you chose to filter features by data completeness, you can use the slider to indicate the percentage of data completeness to allow in your data. When the filter features by data completeness switch are on, another switch opens up to filter by grouping variables based on the metadata column. The grouping variable makes the percentage of data completeness to be applied to each of the groups instead of global.

<p align="center">
  <img src="../../png/022_DataFilteringDone.png" width="80%">
</p>

After you have decided to go with the filtered state you can click on the “Record as Original” button replaces the original data with the updated state of the data.

---

### 3. Data Imputation



---

### 4. Data Normalization
