# Oak-Bay-Deer-Density
Data analysis repository for the Oak Bay black-tailed deer density project. The general goals of this project is to estimate population density in response to immunocontraceptive treatment. 

<hr>

### GENERAL INFORMATION
**Project Information**
Details for the Oak Bay urban deer program can be found on the Urban Wildlife Stewardship Society [website](https://uwss.ca/) and on the ACME lab [website](http://www.acmelab.ca/esquimaltdeer.html)

 **Principal Investigator Contact Information**  
 Name: Jason T. Fisher, PhD   
 Institution: University of Victoria  
 Address: 3800 Finnerty Rd, Victoria, BC V8P 5C2  
 Email: [fisherj@uvic.ca](mailto:fisherj@uvic.ca) 

 **Principal Investigator Contact Information**  
 Name: Sandra Frey, MSc   
 Institution: Urban Wildlife Stewardship Society  
 Address: Oak Bay, British Columbia  
 Email: [safrey07@gmail.com ](mailto:safrey07@gmail.com ) 

 **Lead Data Analyst**  
 Name: Andrew Barnas, PhD  
 Institution: University of Victoria  
 Address: 3800 Finnerty Rd, Victoria, BC V8P 5C2  
 Email: [andrewbarnas@uvic.ca](mailto:andrewbarnas@uvic.ca) 

### DATA & FILE OVERVIEW
This repository works on a linear pipeline format, whereby the initial data files are processed in 1.1 Assigning WHIDs and the outputs of that section are then used as the inputs for 1.2 Data Prep, and so on. For each step, the relevant R markdown files are located within main folder. However there is a singular master script at the start which will run all of the relevant project scripts. This was done to avoid having to go into the project and manually run every script if someone wanted to run the project from top to bottom. 
<hr>

**1.1 Assigning WHIDs** 
This folder contains code to assign Wildlife Health IDs to the raw detection data featuring information on deer collar and ear tags. This is primarily being done for the October detection data for 2019 and 2020. The reason this is being done separately is in these two years, deer were being continually marked and added to the population, so we elected to produce density results for the month of October instead of September (as was done for the other study years). The original analyst who processed the other years of data is unavailable for more data processing, so this step is being done separately using his code to the best of my ability (Barnas). The main outputs of this is a single large dataframe with WHIDs that will be used in the next step.  

*File and Folder list*
* <span style = "color: #7B0F17;">**1.1 Assigning WHID.RMD**</span>: Markdown file for assigning Wildlife Health IDs
  
**_inputs_**
* <span style = "color: #7B0F17;">**Control_Markings.csv**</span>: Manually constructed csv of WHIDs for the control group tagged in 2018
* <span style = "color: #7B0F17;">**IC_Markings.csv**</span>: Manually constructed csv of WHIDs for the IC treated deer from 2019-2020.
* <span style = "color: #7B0F17;">**October2019.csv**</span>: Raw camera detection data from October 2019. This was tagged seperately due to logistic constraints on sampling (see main manuscript)
* <span style = "color: #7B0F17;">**October2020.csv**</span>: Raw camera detection data from October 2020. This was tagged seperately due to logistic constraints on sampling (see main manuscript)
* <span style = "color: #7B0F17;">**September18-23_with_whid.csv**</span>: the main large dataframe of raw detection data from 2018-2023 without assigned WHIDs for 2019 and 2020. Note that the detection data from 2019 and 2020 is present in this frame, but we needed a different timeframe so we replace it with the October datasets described above.
* <span style = "color: #7B0F17;">**urban_deer_mortalities.csv**</span>: Manually constructed csv of known moralities of marked deer from 2018-2023. Note this is not used in any of the current analyses but provides good metadata. 

**_outputs_**
* <span style = "color: #7B0F17;">**main_dataframe_with_whid.csv**</span>: The main large dataframe of detection data from 2018-2023 with assigned WHIDs. This is a very large dataframe with many columns, which are described within the code
<hr>

**1.2 Data Prep** 
This folder contains scripts to process raw camera data into summarized detections of marked and unmarked individuals, as well as details on camera operability. Data for each year is processed seperately in scripts named, "1. Data Prep XXXX". Minor differences in data collection each year, along with differences in review, neccesitate seperate processing just to make life easier. The outputs from each year are produced seperately, to be combined in future steps. There are inputs for this step are the outputs of 1.1 Assinging WHIDs, but there are also additional inputs on camera operability that did not make sense to include in the 1.1 folder. One important thing these scripts do is output partially processed detection data to the 1.3 Relative Abundance folder. This data contains information on fawns, which is removed as a part of the continuined processing for density estimation, so we needed a way and place to retain this informaiton.

*File and Folder list*
* <span style = "color: #7B0F17;">**1.2 Data Prep 2018.RMD**</span>: Markdown file for processing 2018 data
* <span style = "color: #7B0F17;">**1.2 Data Prep 2019.RMD**</span>: Markdown file for processing 2019 data
* <span style = "color: #7B0F17;">**1.2 Data Prep 2020.RMD**</span>: Markdown file for processing 2020 data
* <span style = "color: #7B0F17;">**1.2 Data Prep 2021.RMD**</span>: Markdown file for processing 2021 data
* <span style = "color: #7B0F17;">**1.2 Data Prep 2022.RMD**</span>: Markdown file for processing 2022 data
* <span style = "color: #7B0F17;">**1.2 Data Prep 2023.RMD**</span>: Markdown file for processing 2023 data

**_inputs_**
* <span style = "color: #7B0F17;">**UWSS_StationCovariates_updatedMay2023.csv**</span>: Manually constructed csv of camera locations from 2018-2023
* <span style = "color: #7B0F17;">**UWSS_Deployment_Data_updatedMay2024.csv**</span>: Manually constructed csv of camera operability from 2018-2023
* _Archived_ - a folder containing previous versions of detection and camera data, only keeping for records, no longer used in any analyses

**_outputs_**
* <span style = "color: #7B0F17;">**camera_operability_summary_XXXX.csv**</span>: A year specific summary of the number of cameras operating for the sampling window, and descriptive statistics on the number of camera days
* <span style = "color: #7B0F17;">**marked_detections_september/fall_XXXX.csv**</span>: A year specific list of detections of marked individuals at each camera site along with the date. Note differences from september vs fall files, fall indicates the sampling span from October 8th to November 6th.
* <span style = "color: #7B0F17;">**operation_matrix_september/fall_XXXX.csv**</span>: A year specific matrix of camera operability for each of the 30 sampling occassions. Note differences from september vs fall files, fall indicates the sampling span from October 8th to November 6th.
* <span style = "color: #7B0F17;">**unmarked_matrix_fall_XXXX.csv**</span>: A year specific matrix of the counts of unmarked deer for each of the 30 sampling occassions. Note differences from september vs fall files, fall indicates the sampling span from October 8th to November 6th.

**_figures_**
* <span style = "color: #7B0F17;">**camera_operability_matrix_XXXX.jpeg**</span>: A year specific figure visually representing the camera operability for each camera
<hr>

**1.3 Relative Abundance Calculations** 
This folder contains scripts to process detection data to obtain relative abundance of fawns and adults. The inputs for this script are the main detectiond dataframes from each year, prior to the removal of the fawn data (as fawns were removed for further processing for density estimates).

*File and Folder list*
* <span style = "color: #7B0F17;">**1.3 Relative Abundance Calculations.RMD**</span>: Markdown file for combining and processing each years data to estimate the relative abundance of lone adults and adults with fawns.
  
**_inputs_**
* <span style = "color: #7B0F17;">**deer_XXX_with_fanws.csv**</span>: a year specific dataframe of deer detection data which still contains fawns

**_outputs_**
* <span style = "color: #7B0F17;">**mean_detection_summary.csv**</span>: a summarized csv of the proportion of detetctions per camera of just adult deer and then adult deer with fawns for each year
* <span style = "color: #7B0F17;">**proportion_summary.csv**</span>: a summarized csv of the number proportion of detetctions overall of just adult deer and then adult deer with fawns for each year

**_figures_**
* <span style = "color: #7B0F17;">**proportion_detections.jpeg**</span>: The overall proportion of detections containing lone adults and adults with fawns from 2018-2023
* <span style = "color: #7B0F17;">**relative_abundance_no_outliers.jpeg**</span>: Proportion of detections of lone adults with and without fawns for each camera from 2018-2023. Outliers removed.
* <span style = "color: #7B0F17;">**relative_abundance_with_outliers.jpeg**</span>: Proportion of detections of lone adults with and without fawns for each camera from 2018-2023. Outliers retained.
* <span style = "color: #7B0F17;">**stacked_figure.jpeg**</span>: A multipanel plot of proportion_detections and relative_abundance_no_outliers. Figure 3 in the main maunscript.
<hr>

**2. SECR Prep** 
This folder contains script to take the previously processed detection data and further process it into a specialized format for the SECR package in R. This combines the data from each year and produces text files formatted for a multisession model. The inputs for this folder are the outputs from 1.2 Data Prep. 

*File and Folder list*
* <span style = "color: #7B0F17;">**2.1 Multisession Data Prep.RMD**</span>: Markdown file for further processing data into specialized format needed for SECR.

**_outputs_**
* <span style = "color: #7B0F17;">**deer_cameras_XXXX.txt**</span>: a year specific text file showing the operability (1/0) on each sampling occassion
* <span style = "color: #7B0F17;">**deer_multi.txt**</span>: a text file of detections of marked deer at cameras from 2018-2023. Specially formatted for multisession analysis.
* <span style = "color: #7B0F17;">**unmarked_multi.txt**</span>: a text file of counts of unmarked deer detections at cameras from 2018 -2023. Specially formatted for multisession analysis.

**_archvied_scripts_**
This folder contains several old scripts for processing the data during initial development. I have retained these as they may come in handy in the future for different versions of SMR models if needed. 
<hr>

**3. SECR Models** 
This folder contains the script to run the multisession spatial mark resight model that produces density estimates from 2018-2013. The inputs for this section are the outputs from 2.1 SECR Prep, but also uses other manually created inputs for habitat masks. 

*File and Folder list*
* <span style = "color: #7B0F17;">**3.1 Multisession Model.RMD**</span>: Markdown file for running the multisession model.

**_shapefiles_**
Too exhaustive to list everything. Sufficient to say these are the shapefiles exported from ArcMap of the camera locations for each study year (2018-2023)

  **_outputs_**
* <span style = "color: #7B0F17;">**density_estimates.csv**</span>: a csv of density estimates for each study year 2018-2023
* <span style = "color: #7B0F17;">**deer_multisession.RData**</span>: the initial multisession R object calculated prior to adjustments from diagnostics
* <span style = "color: #7B0F17;">**multisession_fit_suggested_buffer**</span>: the subsequent multisession R object calculated based off the initial estimate, adjusted for a better buffer and overdispersion. Density estimates obtained from this object. 

**_figures_**
* <span style = "color: #7B0F17;">**OakbayXXX_tracks.jpeg**</span>: a summary image of detections of marked individuals at each camera
* <span style = "color: #7B0F17;">**esa_plots.jpeg**</span>: a diagnostic plot from the secr package showing the recommended buffer size to use
* <span style = "color: #7B0F17;">**density_figure.jpeg**</span>: Estimated density and confidence intervals for each year 2018-2023. This is Figure 3 in the manuscript.
<hr>

Fin.

**_archvied_scripts_**
This folder contains several old scripts for processing the data during initial development. I have retained these as they may come in handy in the future for different versions of SMR models if needed. 
<hr>



