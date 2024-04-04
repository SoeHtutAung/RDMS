

# Check number of vaccines received by each patient according to odk
response_counts <- odk %>%
  group_by(subject_id,vaccinated) %>%
  summarise(count = n())
View(response_counts)
# 1 is most frequent vaccine admission

#Error with discharge and admit time - 98 records
check_minus_adm <- DBI::dbSendQuery(dbcon,
"SELECT subject_id, hadm_id, admittime, dischtime FROM admissions WHERE dischtime < admittime")
dbFetch(check_minus_adm)

icu_pt_vac %>% filter (icu_death == "Died in ICU") %>% summarise(distinct_subjects = n_distinct(subject_id))

table (icu_pt_vac$vaccinated,icu_pt_vac$icu_death)

#Missing 'outtime' in icustays for icustay_id 265303 
# we will not remove the entire information but just use na.rm function to exclude during calculation

# storing credentials in yml and retrieving using config package
library(config)
get("secret")$mimic_user
get("secret")$mimic_pwd
get("secret")$odk_user
get("secret")$odk_pwd