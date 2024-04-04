## install and load dbplyr and DBI
library(dbplyr)
library(DBI)
library(RPostgreSQL)
library(keyring)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(dplyr)
library(treemapify)
library(shiny)
library(yaml)
library(palmerpenguins)
library(knitr)
library(readr)
library(httr)

## install ruodk
#options(repos = c(ropensci = 'https://ropensci.r-universe.dev',
#                  CRAN = 'https://cloud.r-project.org'))
#install.packages('ruODK')
library(ruODK)

## added security hdm_assessment 
#keyring_create("HDM")
#keyring_unlock("HDM")
## create credentials
#key_set("mimic_user", keyring = "HDM")
#key_set("mimic_pwd", keyring = "HDM")
#key_set("odk_user", keyring = "HDM")
#key_set("odk_pwd", keyring = "HDM")

#connect to ODK central
ru_setup(url = "https://odk-survey.lshtm.ac.uk", 
         un = key_get("odk_user", keyring = "HDM"), 
         pw = key_get("odk_pwd", keyring = "HDM"),
         svc = "https://odk-survey.lshtm.ac.uk/v1/projects/80/forms/HDM_Assessment.svc")
# get data
odk <- odata_submission_get()
#clean subject_id
odk$subject_id <- as.integer(gsub("_", "", odk$subject_id))

## get dataframes for analysis

# connect to MIMIC III
dbcon <-  DBI::dbConnect(
  PostgreSQL (),
  dbname = "mimic",
  host = "healthdatascience.lshtm.ac.uk",
  port = "5432",
  user = key_get("mimic_user", keyring = "HDM"),
  password = key_get("mimic_pwd", keyring = "HDM"))

# (i) demographic of patients by making a table, one row for one distinct subject id
patient_demo <- DBI::dbSendQuery(dbcon,
    "SELECT DISTINCT ON (a.subject_id)
    a.subject_id,a.gender,
    EXTRACT(EPOCH FROM ((b.admittime - a.dob))/(3600*24*365.25)) as age_in_years,
    b.marital_status,
    b.ethnicity
FROM 
    patients a
INNER JOIN 
    admissions b ON a.subject_id = b.subject_id")
patient_demo_table <- dbFetch(patient_demo)

# (ii) total stay times and ICU stay times,characterised in terms of median, 25/75% quantiles, and min-max for both indicators
adm_icu <- DBI::dbSendQuery(dbcon,
    "SELECT 
    a.subject_id, a.hadm_id, b.icustay_id,
    c.gender,
    EXTRACT(EPOCH FROM ((a.admittime - c.dob))/(3600*24*365.25)) as age_in_years,
    EXTRACT(EPOCH FROM ((a.dischtime - a.admittime))/(3600*24)) as total_staytime,
    b.los, EXTRACT(EPOCH from b.outtime - b.intime)/(3600*24) as icu_staytime
FROM 
    admissions a
FULL JOIN 
    icustays b ON a.subject_id = b.subject_id and a.hadm_id = b.hadm_id
FULL JOIN
    patients c on a.subject_id = c.subject_id
")
adm_icu_table <- dbFetch(adm_icu)
View(adm_icu_table)

# (iii) extract table for v450 who stayed in ICU
icu_pt <- DBI::dbSendQuery(dbcon,
    "SELECT 
    b.subject_id, b.hadm_id, b.icustay_id,
    EXTRACT(EPOCH from sum((b.outtime - b.intime)/(3600*24))) as icu_staytime,
    MIN(intime) - interval '6 hour' AS first_icu,
    MAX(outtime) + interval '6 hour' AS last_icu,
    c.gender, d.deathtime
FROM (SELECT hadm_id FROM diagnoses_icd a WHERE icd9_code LIKE 'V450%' GROUP BY hadm_id) cardiacdev
JOIN icustays b USING (hadm_id)
LEFT JOIN
    patients c on b.subject_id = c.subject_id
LEFT JOIN 
    admissions d on b.hadm_id = d.hadm_id
GROUP BY 
    b.subject_id, b.hadm_id, b.icustay_id, c.gender, d.deathtime")
icu_pt_table <- dbFetch(icu_pt)

# (iv) extract table for v450 who stayed in ICU and died in ICU, including icd codes
icu_pt_icd <- DBI::dbSendQuery(dbcon,
   "SELECT 
    b.subject_id, b.hadm_id, b.icustay_id,
    MIN(intime) - interval '6 hour' AS first_icu,
    MAX(outtime) + interval '6 hour' AS last_icu,
    b.first_careunit, c.gender, e.deathtime, 
    e.admittime, c.dob, b.los as icu_days, code_summary, title_summary
FROM (
    SELECT hadm_id 
    FROM diagnoses_icd 
    WHERE icd9_code LIKE 'V450%' 
    GROUP BY hadm_id
) cardiacdev
JOIN icustays b USING (hadm_id)
LEFT JOIN patients c ON b.subject_id = c.subject_id
LEFT JOIN diagnoses_icd d ON b.hadm_id = d.hadm_id
LEFT JOIN admissions e ON b.hadm_id = e.hadm_id
JOIN (
    SELECT 
        hadm_id,
        ARRAY_TO_STRING(ARRAY_AGG(icd9_code), ', ') AS code_summary,
        ARRAY_TO_STRING(ARRAY_AGG(short_title), ', ') AS title_summary
    FROM (
        SELECT * 
        FROM diagnoses_icd 
        ORDER BY hadm_id, icd9_code
    ) sort_icd
    JOIN d_icd_diagnoses USING (icd9_code)
    GROUP BY hadm_id
) diag_summary ON b.hadm_id = diag_summary.hadm_id
GROUP BY
    b.subject_id, b.hadm_id, b.icustay_id, b.first_careunit, c.gender, e.deathtime, e.admittime, c.dob, b.los, code_summary, title_summary;
")
icu_pt_icd_tbl <- dbFetch(icu_pt_icd)
View(icu_pt_icd_tbl)

## close the connections and disconnect
dbClearResult(patient_demo) # i
dbClearResult(adm_icu) # ii
dbClearResult(icu_pt) # iii
dbClearResult(icu_pt_icd) # iv
dbDisconnect(dbcon) # disconnect the postgresever connection

# lock the keyring after getting dbcon and odk to the environment
keyring_lock("HDM") 