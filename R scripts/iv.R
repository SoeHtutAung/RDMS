########## (task iv) ################
## data preparation
# join with adm_icu with odk for (iv)
icu_pt_vac_icd <- left_join(icu_pt_icd_tbl, odk %>% select (subject_id, vaccinated, admitage_yrs), by = "subject_id")

# change vaccine status
icu_pt_vac_icd <- icu_pt_vac_icd %>% 
  mutate (vaccinated = case_when(
    vaccinated == "NO" ~ "N",
    vaccinated == "YES" ~ "Y",
    TRUE ~ vaccinated))
# a new column for icu death
icu_pt_vac_icd <- icu_pt_vac_icd %>% 
  mutate(icu_death = case_when(
    first_icu < deathtime & deathtime < last_icu ~ "Died in ICU",
    TRUE ~ "Did not die in ICU"))

# Exclude those who are not icu death from the dataset
icu_icd <- subset(icu_pt_vac_icd,icu_pt_vac_icd$icu_death == 'Died in ICU')
# round number of days in ICU for clear vision
icu_icd <- icu_icd %>% mutate (icu_days = round (icu_days,2))

# Describe summary for each patient
summary_iv <- icu_icd %>% filter (!is.na(vaccinated)) %>%
  select(subject_id, first_careunit, gender, admitage_yrs, icu_days, title_summary, code_summary,vaccinated)

# combine columns
summary_iv$idsum <- paste(summary_iv$subject_id,'',summary_iv$gender,summary_iv$admitage_yrs,'',summary_iv$vaccinated) #id
summary_iv$icusum <- paste(summary_iv$first_careunit,'',summary_iv$icu_days) #icu

# arrange and rename
summary_iv <- summary_iv %>%
  select(idsum, icusum, code_summary, title_summary) %>%  # Rearrange columns
  rename("Patient (Sex, age, vaccinated)" = idsum, "First care unit (days in ICU)" = icusum, "ICD9 codes" = code_summary, 'Diagnosis' = title_summary)  # Rename columns

# cut the length of two ICD9 columns and replace with ellipsis to save space
summary_iv$`ICD9 codes` <- str_trunc(summary_iv$`ICD9 codes`,30)
summary_iv$Diagnosis <- str_trunc(summary_iv$Diagnosis,75)
