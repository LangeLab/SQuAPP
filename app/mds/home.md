## `SQuAPP` *Version 0.26*
**S**imple **Qu**antitative **A**nalysis of **P**eptides and **P**roteins (`SQuAPP`) is a workflow-based web application built on R-Shiny to enable a rapid high-level analysis of quantitative proteomics data. `SQuAPP` provides streamlined and straightforward access to many aspects of typical downstream analysis done with quantitative proteomics data. `SQuAPP` facilitates combined statistical analysis of multiple levels of proteomics data, including peptide, protein, post-translational modifications and termini modification, and allows for visual comparisons using a variety of plots and table formats.

Mandatory quality control and conscious pre-processing early in the workflow ensure that only robust data are quantitatively evaluated and visualized. The processed datasets can be downloaded for further custom analysis, and the comprehensive report supports record keeping and allows for easy sharing with colleagues and collaborators.

---

#### Functionality

`SQuAPP` is a flexible application, and its functions can be applied in a non-sequential order as long as the requirements for a specific function are met. `SQuAPP` also can be used to follow a sequential workflow-driven approach with the following steps:

1. **Data Setup**
2. **Data Inspection**
3. **Data Pre-processing**
4. **Statistical inference**
5. **Summary Visualization**
6. **Report generation**

[Add the main workflow figure here!]

---

#### Quick Start
You can start exploring the `SQuAPP` right now using our pre-loaded example data containing protein, phosphorylation and N termini level data comparing primary leukemic cells with matched patient-derived xenografts.[**(Uzozie et al. 2021)**](https://jeccr.biomedcentral.com/articles/10.1186/s13046-021-01835-8)

---

#### Help
A detailed tutorial on how to use `SQuAPP` can be accessed in the respective tabs for section - Data Setup, Data Inspection, Data Preprocessing, Statistical Inference, Summary Visualizations, and Generate a Report.

---

#### About `SQuAPP`
`SQuAPP` has been developed by **Enes Kemal Ergin** & **Siyuan Chen** with contributions from **Anuli Uzozie**, **Ye Su**, and **Philipp Lange** at BC Children’s Hospital & the University of British Columbia.

The source code for `SQuAPP` is available at [SQuAPP Github Page](https://github.com/LangeLab/SQuAPP/).

For any feedback, comments, and questions please contact:

- Enes Kemal Ergin
	- [Email](mailto:eneskemalergin@gmail.com)
	- [Twitter](https://twitter.com/eneskemalergin)
	- [GitHub](https://github.com/eneskemalergin)
- Philipp Lange
	- [Email](mailto:philipp.lange@ubc.ca)
	- [Twitter](https://twitter.com/Lange_Lab)
	- [GitHub](https://github.com/phegnal)

Or you can directly submit an issue on the [GitHub page](https://github.com/LangeLab/SQuAPP/issues/new).

---

#### Change Log
- **Version 0.26 - December 8th 2021**:
	- Various bug fixes
	- Various UI updates
	- More compact protein domain
	- More filteration options for circular network plot
	- Additional combinations to select in circular network plot
	- Customizable coloring for circular network plot
- **Version 0.25 - December 1st 2021**:
	- Working version made public
