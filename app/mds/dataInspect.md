[Add Cover Figure (landscape format)]

The data inspection section provides typical sample-based quality check (QC) visualizations for evaluating each of the study datasets uploaded in step 1.

There are two major ways to inspect your data – (i) review global data quality, (ii) apply and use a grouping variable from the metadata to arrange samples for quality checks. Turn on the "Plot data with a grouping factor" switch to select a metadata column for grouping.

Configure all selections, and click the “Create Plots” button to make plots. If an update of the previous configuration is required, for instance, changing the data level or changing the grouping condition, effect the change and click the "Create Plots" again to re-do the plots.

<p align="center">
  <img src="../../png/015_ConfigureQC.png" width="25%">
</p>

Plots are contained in their tabs, allowing a clean visualization and a wide variety of screen resolutions.

<p align="center">
  <img src="../../png/016_QCVisualizationBox.png" width="80%">
</p>

Here are the QC visualizations to explore your data in detail:

- `Violin plot`: Distribution of the samples, visualized in log2 of intensity
- `CV Plot`: Visualizes the coefficient of variation (CV) percentage of features by grouping them in CV percent groups (<10%, 10%-20%, 20%-50%, 50%-100%, >100%) and a global violin plot of the percent CVs.
	- **Coefficient of variation is calculated as the ratio of the standard deviation of samples to the mean of samples for a given feature.**
- `Identified Features Comparison`: Visualizes the number of unique features a sample contains as a bar plot
- `Comparing Shared Features`: Visualizes the number of features shared between different samples as an upset plot.
	- **This plot is most useful when used with a grouping factor**
	- **Using without grouping factor defaults to first four samples in your data to show only, you can bypass this by selecting the unique sample identifier in the grouping factor variable, however upset plots are not most useful with too many samples**
- `Data Completeness`: Visualizes the data completeness percentage over several unique features.
- `Missing Values`: Visualizes the number of missing values per sample with a stacked bar chart.

All plots that have been displayed and inspected will later be included in the report or can be directly downloaded individually on their tabs.

<p align="center">
  <img src="../../png/017_QCVisualizationPanel_withoutGroup.png" width="65%">
</p>

---

<p align="center">
  <img src="../../png/018_QCVisualizationPanel_withGroup.png" width="65%">
</p>
