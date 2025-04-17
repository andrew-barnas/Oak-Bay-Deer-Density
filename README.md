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
* <span style = "color: #7B0F17;">**Control_Markings.csv**</span>: Large file of raw camera data from 2018 to 2023 (to be updated with october data for 2019 and 2020- May 1/24

**_outputs_**
* <span style = "color: #7B0F17;">**main_dataframe_with_whid.csv**</span>: Descriptive statistics on the number of cameras and days of operability from 2018
<hr>

**2. SECR Prep** 
This folder contains scripts to process the data from the previous step (1. Data Prep) into the specialized formats needed for SECR models. Again, data is processed seperately and this is done to produce outputs for each year seperately. UPDATE LATER - HOW DEAL WITH MULTISESSION DATA

*File and Folder list*
* <span style = "color: #7B0F17;">**2. SECR Prep.RMD**</span>: Markdown file for processing 2018 data

**_outputs_**

NEED PROJECT DESCRIPTION AND CONTACT INFORMATION HERE
JAKE
SANDRA
ANDREW
MACG?
This folder contains scripts to process raw camera data into summarized detections of marked and unmarked individuals, as well as details on camera operability. Data for each year is processed seperately in scripts named, "1. Data Prep XXXX". Minor differences in data collection each year, along with differences in review, neccesitate seperate processing just to make life easier. The outputs from each year are produced seperately, to be combined in future steps

WHAT IS GOING ON IN EACH FOLDER
1. DATA PREP - preparing data seperately for each year

FILE STRUCTURE/INVENTORY

1. DATA PREP 
