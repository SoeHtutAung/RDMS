# README for executive report generation

## 1. Description

This is about processing an executive report for the hospital management, by synthesizing patient data, survey data and national statistics.
With the help of this readme file, codes, markdown file, folder and prototype setup, our data analyst department will be able to routinely generate similar reports.
This readme file will work through steps in the pipeline of analysis to enhance ***reproducibility and audibility.***

In a nutshell, only 4 simple steps as listed under [section 5](#sec-5.-creating-a-routine-report) are needed to produce a routine report.

## 2. Installation instructions {#sec-2.-installation-instructions}

This analysis was done using following software.
-   RStudio 2023.09.1+494
-   R version 4.3.2

Following packages in R were used to extract, transform, load, analyze, visualize and publish the report.
-   dbplyr 2.4.0
-   DBI 1.1.3
-   RPostgreSQL 0.7-5
-   config 0.3.2
-   ruODK 1.4.0
-   tidyverse 2.0.0
-   dplyr 1.1.4
-   stringr 1.5.1
-   ggplot2 3.4.4
-   gridExtra 2.3
-   treemapify 2.5.6
-   shiny 1.8.0
-   yaml 2.3.8
-   palmerpenguins 0.1.1
-   knitr 1.45
-   readr 2.1.4
-   httr 1.4.7
-   tinytex 0.49
-   kableExtra 1.3.4

To generate report from Quarto and LaTex compilation following programs were installed

-   Quarto 1.3.450 (available at <https://quarto.org/docs/download/>)
-   TinyTex was installed using **command prompt** by entering the comment '**quarto install tinytex**'.

## 3. Folder structure

### 3.1 First level
At first level of folder, there are 2 folders and 1 file as seen in below [figure](#fig-1).

**R scripts folder:**  
-   A reference folder that R scripts for specific tasks are kept
-   Details in [3.3](#sec-3.3-second-level---r-scripts-folder)

**Report folder:** 
-   Main folder that you can generate the report from
-   Details in [3.2](#sec-3.2-second-level---r-scripts-folder)

**executive- report.pdf:**   
-   A prototype of two-page executive report
   
**README_report generation guideline.html:**
-   Pipeline of analysis and readme for executive report generation to guide audit and reproduction
-   **This is the current file you are viewing**

**Note.pdf:**
-   A one-page feedback note to reflect challenges, solutions and suggestions during the workflow

(You may find a folder named 'images', but it is just for storage of screenshots used in this readme file)

### 3.2 Second level - Report folder {#2ndlevel}
This is the main folder that you need to use during report generation.

**executive report.qmd:**
-   This is Quarto Markdown file, containing a mix of codes, text, and output, to render the report
-   This file is the main file to set up R Studio, connect to servers, extract, load, transform, manipulate, analyze and generate the report

**config.yml:**
-   This YAML file is part of the credential management system
-   This file must be kept within the same folder as 'executive report.qmd' file at all time
-   Being a public folder, this file is excluded in this repository
(You may find a folder named 'media', but it is just for storage of pictures used in report)

### 3.3 Second level - R scripts folder {#sec-3.3-second-level---r-scripts-folder}

There is another second level folder **'R scripts'**, which is for reference purpose only.
The syntax for each task of the pipeline were kept as seperate R files as in below [screenshot](#fig-2).

**setup.R**
-   Install and load necessary R packages.
-   Credential management using keyring package.
-   Connect to PostgreSQL server (MIMIC III database) and ODK central server
-   Extract, transfer and load minimally required information
-   Create data frame from MIMIC III database for specific analysis task
-   Create and clean data frame from ODK central to integrate vaccine information 
-   Save the data frames into environment 

**i.R to v.R**
-   Using 'patient_demo_table' data frame created using 'setup.R', manipulate and prepare the data for anlaysis 
-   Create a data fame to summarise the information for specific task, using both the ODK and MIMIC III database information
-   Save the data frames into environment 

**scratch.R**
-   This is just a place to test run syntax and check data consistency 
(You may find a R file named 'README_report generation pipeline.md', but it is just a markdown file during development of readme file.)

## 4. Pipeline of analysis {#sec-4.-pipeline-of-analysis}

This session is to explain about pipeline of analysis.
The syntax for whole pipeline is included within Quarto Markdown file 'executive report.qmd'.
However, as a reference, 'R scripts' folder is also developed to see R codes for each step and task.
(Detail syntax for can be observed in the Quarto Markdown file as in [figure 3](#fig-3) or and R script files as in the [figure 2](#fig-2).)

### 4.1 Setting up RStudio

-   Required packages as listed in [**section 2**](#sec-2.-installation-instructions) are installed

### 4.2 Credentials management

-   A YAML file called 'config.yml' is created to store required credentials, and it is put in the same directory as Quarto Markdown file.

-   Using 'config' package, the stored credentials from YAML file are retrieved in Quarto Markdown file using 'get()' function of config package.

-   *Note: If users are using the same pc or the a same network, 'Keyring' would be a preferable package. Because we can use password to secure the keyring, so that the credentials can't be exposed without the password for keyring.*

### 4.3 Establishing connection to servers

-   'DBI', 'dbplyr' and 'RPostgre' packages are used to connect PostgreSQL server from RStudio and connection is established as 'dbcon'

-   'ruODK' package is used to connect ODK central server from RStudio to extract dataset

-   In above connections, 'config' package is used to manage credentials

-   'httr' and 'readr' packages are used to connect API of COVID-19 dataset as available on the website to extract dataset

### 4.4 Extracting, transferring and loading {#sec-4.4-extracting-transfering-and-loading}

In this step, data from various sources are extracted, cleaned and loaded into RStudio as below.

*Note: If you try to use individual R files from 'RScripts folder', the extracted information are kept as objects (e.g., data frames, lists, plots) inside RStudio environment. But if you use Quarto Markdown file form 'Report folder', they will be kept temporarily and you will not see them inside global environment of RStudio.*

#### (a) MIMIC III database form PostgreSQL server

-   After connecting PostgreSQL server using 'dbConnect' function, minimally required information for each task is extracted from MIMIC III database

-   SQL syntax is used inside RStudio to extract, transfer and load the data into R environment

-   Patients' demographic information is retrieved from 'admissions' and 'patients' tables.
    Admission information, including ICU stays, ICD9 codes are extracted from joining between 'diagnoses_icd', 'icd9_code' tables

-   'subject_id', 'hadm_id' and 'icustay_id' are often served as keys for data joins

-   Calculation were made from timestamp variables (e.g., admission and discharge time) to get 'age' or 'duration' information

-   The extracted data is kept as data frames inside RStudio environment

#### (b) Vaccination data from ODK Central server

-   Functions inside 'ruODK' package is used to get survey data collected using ODK

-   The extracted data is kept as a data frame inside RStudio environment

#### (c) Community COVID-19 data from website

-   API url path is generated from <https://coronavirus.data.gov.uk/details/download> by specifying required information about new cases and new admissions in the England

-   Using the url, csv file is extracted and saved as data frame inside the RStudio environment using 'httr' and 'readr' packages

-   Please be noted that the link: *"<https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newAdmissions&metric=newCasesByPublishDate&release=2021-03-31&format=csv>"* is used as we are analyzing at the end of March 2021.
    '**release=2021-03-31&**' can be removed if we would like to use up-to-date information.

#### (d) Close connection (and secure the credentials, if 'Keyring' package is used)

-   After extracting data from server, 'dbDisconnect' function is used to disconnect from PostgreSQL server

-   *Note: If we are using Keyring package, keyring is supposed to be locked after extracting required information from server, if the Markdown file is to be shared with outsiders.*

### 4.5 Data manipulation and preparation {#sec-4.5-data-manipulation-and-preparation}

-   Data cleaning for data object 'ODK' was done inside 'setup.R' file to remove '\_*'* in front of subject ID.
    Because 'subject_ID' will serve as key to join between data frame in later step

-   Other data cleaning and data manipulation are done inside respective R Scripts (r chunks of Quarto Markdown file).
    Because grouping, renaming and sorting are to be done specific to analysis task

-   There were some cases observed with discharge date earlier than admission date, with unrealistic ages and one without out time for ICU.
    Those cases were handled by case by case approach within each analysis task

-   The syntax for above steps are already embedded inside Quarto Markdown file, and you can run only one file, i.e., 'executive report.qmd', for report generation.
    However, you can also see those steps inside individual R files inside 'R Script folder'.

### 4.6 Data analysis and visualization

-   The analysis was done inside Quarto Markdown file 'executive report.qmd' as shown in 2nd level [folder](#fig-3)

### 4.7 Publishing report

-   A Quarto Markdown file was created using RStudio

-   First of all, YAML code is modified to setup the page and parameters

-   Code chunks in R are used to analyse and visualize the data frames.

-   At the start of code chunks, parameters are set to customize the layout, figures and tables

-   'kableExtra' package is used to organize the table, where list of 36 patients is developed as an annex

-   Click on ['Render'](#fig-4) inside the menu bar in RStudio is used to generate PDF report

    ![Click on 'Render'](images/Screenshot%202023-12-23%20114621.png){#fig-4 width="217"}

## 5. Creating a routine report {#sec-5.-creating-a-routine-report}

To preview the prototype report, **'One-click'** report generation can be achieved with **4 simple steps**:

-   **Step 1:** Make sure that 'executive report.qmd' and 'config.yml' files are inside the same folder

-   **Step 2:** Make sure that necessary software and packages as listed under [section 2](#sec-2.-installation-instructions) are installed in the computer

-   **Step 3:** Open 'executive report.qmd' (Quarto Markdown file) with RStudio

-   **Step 4:** Click on 'Render'

## 
_This is the copy of my submitted assignment for Health Data Management module duirng MSc Health Data Science Course_
