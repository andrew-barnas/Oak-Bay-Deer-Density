# Oak-Bay-Deer-Density
Data analysis repository for the Oak Bay black-tailed deer density project. The general goals of this project is to estimate population density in response to immunocontraceptive treatment. 

<hr>

### GENERAL INFORMATION
**Project Information**
Details for the Oak Bay urban deer program can be found on the Urban Wildlife Stewardship Society [website](https://uwss.ca/)

**Author Information**

 Principal Investigator Contact Information  
 Name: Jason T. Fisher, PhD   
 Institution: University of Victoria  
 Address: 3800 Finnerty Rd, Victoria, BC V8P 5C2  
 Email: [fisherj@uvic.ca](mailto:fisherj@uvic.ca) 

 Principal Investigator Contact Information  
 Name: Sandra Frey, MSc   
 Institution: Urban Wildlife Stewardship Society  
 Address: Oak Bay, British Columbia  
 Email: [safrey07@gmail.com ](mailto:safrey07@gmail.com ) 

 Lead Data Analyst  
 Name: Andrew Barnas, PhD  
 Institution: University of Victoria  
 Address: 3800 Finnerty Rd, Victoria, BC V8P 5C2  
 Email: [andrew.f.barnas@gmail.com](mailto:andrew.f.barnas@gmail.com) 

### DATA & FILE OVERVIEW

**1. Data Prep** 
This folder contains scripts to process raw camera data into summarized detections of marked and unmarked individuals, as well as details on camera operability. Data for each year is processed seperately in scripts named, "1. Data Prep XXXX". Minor differences in data collection each year, along with differences in review, neccesitate seperate processing just to make life easier. The outputs from each year are produced seperately, to be combined in future steps


*File and Folder list*
* <span style = "color: #7B0F17;">**1. Data Prep 2018.RMD**</span>: Markdown file for processing 2018 data
* <span style = "color: #7B0F17;">**1. Data Prep 2019.RMD**</span>: Markdown file for processing 2019 data
* <span style = "color: #7B0F17;">**1. Data Prep 2020.RMD**</span>: Markdown file for processing 2020 data
* <span style = "color: #7B0F17;">**1. Data Prep 2021.RMD**</span>: Markdown file for processing 2021 data
* <span style = "color: #7B0F17;">**1. Data Prep 2022.RMD**</span>: Markdown file for processing 2022 data
* <span style = "color: #7B0F17;">**1. Data Prep 2023.RMD**</span>: Markdown file for processing 2023 data

**inputs**
* <span style = "color: #7B0F17;">**September18-23_with_whid.csv**</span>: Large file of raw camera data from 2018 to 2023 (to be updated with october data for 2019 and 2020- May 1/24)
* <span style = "color: #7B0F17;">**metada**</span>: Folder of ncillary data relevant to the project and data organization, but not used directly within R code
  * *ActiveCameras_Sep2018-2022_updated_July26-2023* - List of active cameras within each month. This is a summarized list based off field notes and knowledge of the system. Note the different months (September vs October) for each year
  * *UWSS_StudyDeer-Markings-Mortalities_updatedMay2023* - Folder of information on captures and known mortalities of individuals. May be used in future versions of models to inform known removals from population. 

* <span style = "color: #7B0F17;">**archived**</span>: Older versions of data that are no longer used. May have contained errors that needed manual adjustments.
  * Not listing the individual files here as they are plentiful and not to be used. 

<hr>
**2. SECR Prep** 
Description goes here
*File list*
Details etc
*????


NEED PROJECT DESCRIPTION AND CONTACT INFORMATION HERE
JAKE
SANDRA
ANDREW
MACG?


WHAT IS GOING ON IN EACH FOLDER
1. DATA PREP - preparing data seperately for each year

FILE STRUCTURE/INVENTORY

1. DATA PREP 
