########## (iii) ################
## data preparation
# join with adm_icu with odk for (ii)
icu_pt_vac <- merge(icu_pt_table, odk[c("subject_id", "vaccinated")], by = "subject_id", all.x = TRUE)

# change name of gender
icu_pt_vac <- icu_pt_vac %>% 
  mutate (gender = case_when(
    gender == "M" ~ "Male",
    gender == "F" ~ "Female",
    TRUE ~ gender))
# change vaccine status
icu_pt_vac <- icu_pt_vac %>% 
  mutate (vaccinated = case_when(
    vaccinated == "NO" ~ "0",
    vaccinated == "YES" ~ "1+ doses",
    TRUE ~ vaccinated))
# a new column for icu death
icu_pt_vac <- icu_pt_vac %>% 
  mutate(icu_death = case_when(
    first_icu < deathtime & deathtime < last_icu ~ "Died in ICU",
    TRUE ~ "Did not die in ICU"
  ))
View(icu_pt_vac)