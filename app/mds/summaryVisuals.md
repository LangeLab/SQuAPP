[Add Cover Figure (landscape format)]
The last step in the workflow entails visualizing quantitative differences between samples and conditions, first at the dataset level using dimensionality reduction and clustering approaches and then at the level of individual proteins, PTMs, termini and their relationships.

### 1. Dimensional Reduction
Dimensional reduction is a frequently used data analysis step for high-dimensional data. Dimensional reduction can be done to all features or for a subset to denoise and simplify the high-dimensional data. SQuAPP allows for the subset selection in the dimensional reduction to take all features if no statistical testing is done prior. More subset options will be available depending on the statistical testing if statistical testing has been completed for the selected data level. (e.g. all significant, up, or down-regulated subsets becomes available)


SQuAPP offers three commonly used methods to reduce dimensions in high-dimensional data:

- `PCA`: “principal component analysis” implemented using `stats::prcomp()` function.
- `t-SNE`: “t-distributed stochastic neighbour embedding” is implemented using `Rtsne::Rtsne()` function.
	- Allows additional “perplexity” option to be selected when running the dimensional reduction.
- `UMAP`:  “Uniform manifold approximation and projection” is implemented using `umap::umap()` function.

SQuAPP produces a customizable scatter plot with two dimensions based on the method used. In the main configuration box, you can select if you want to include a colour and/or a shape variable from the metadata. Aside from the colour and shape, further customization of these plots can be done by opening the plot settings menu located on the top left corner of the plot. In the plot settings menu, you can change more aspects of the plot for downloading for reference.

<p align="center">
  <img src="../../png/034_DimensionalReductionMethods.png" width="80%">
</p>

SQuAPP also provides the reduced table in the bottom box. The reduced table results from a dimensional reduction method merged with metadata to create a reference for people who would like to access the dataset used to produce the data above.

<p align="center">
  <img src="../../png/035_DimensionalReductionDone.png" width="80%">
</p>

---

### 2. Clustering


---

### 3. Feature Comparison


---

### 4. Protein Domain


---

### 5. Circular Network Summary
