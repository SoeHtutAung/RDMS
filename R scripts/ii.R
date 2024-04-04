################( task ii)##################
## data preparation
# join with adm_icu with odk
adm_icu_vac <- left_join(adm_icu_table, odk %>% select(subject_id, vaccinated), by = "subject_id")

# age group for analysis
adm_icu_vac$age_gp <- cut(adm_icu_vac$age_in_years,
                          breaks = c(0, 59, Inf), labels = c("<60 yrs", "60+ yrs"))
# change name of gender
adm_icu_vac <- adm_icu_vac %>% 
  mutate (gender = case_when(
    gender == "M" ~ "Male",
    gender == "F" ~ "Female",
    TRUE ~ gender))
# change vaccine status
adm_icu_vac <- adm_icu_vac %>% 
  mutate (vaccinated = case_when(
    vaccinated == "NO" ~ "0",
    vaccinated == "YES" ~ "1+ doses",
    TRUE ~ vaccinated))

## creating data tables to include in report

# create a seperate dataframe to summarize admission stays by measuring each admission
ii_adm <- adm_icu_vac %>% filter(total_staytime > 0) %>%
  group_by(hadm_id) %>%
  summarize(across(everything(), list(first = ~first(.))), .groups = "drop")

# Calculate and create a summary table for admissions
ii_adm_sum <- bind_rows(
  ii_adm %>% group_by(Group = gender_first) %>% summarize(
      Median = round(median(total_staytime_first),1),
      "25 Q" = round(quantile(total_staytime_first, 0.25),1),
      "75 Q" = round(quantile(total_staytime_first, 0.75),1),
      Minimum = round(min(total_staytime_first),3),
      Maximum = round(max(total_staytime_first),1)
    ),
  ii_adm %>% filter(!is.na(age_gp_first)) %>% 
    group_by(Group = age_gp_first) %>% summarize(
      Median = round(median(total_staytime_first),1),
      "25 Q" = round(quantile(total_staytime_first, 0.25),1),
      "75 Q" = round(quantile(total_staytime_first, 0.75),1),
      Minimum = round(min(total_staytime_first),3),
      Maximum = round(max(total_staytime_first),1)
    ),
  ii_adm %>% filter(!is.na(vaccinated_first)) %>% 
    group_by(Group = vaccinated_first) %>% summarize(
      Median = round(median(total_staytime_first),1),
      "25 Q" = round(quantile(total_staytime_first, 0.25),1),
      "75 Q" = round(quantile(total_staytime_first, 0.75),1),
      Minimum = round(min(total_staytime_first),3),
      Maximum = round(max(total_staytime_first),1)
    ),
  ii_adm %>% summarize(
      Group = "Overall",
      Median = round(median(total_staytime_first), 1),
      "25 Q" = round(quantile(total_staytime_first, 0.25), 1),
      "75 Q" = round(quantile(total_staytime_first, 0.75), 1),
      Minimum = round(min(total_staytime_first), 3),
      Maximum = round(max(total_staytime_first), 1)
    )
) %>%
  ungroup()

# Calculate and create a summary table for icu stays
ii_icu_sum <- bind_rows(
  adm_icu_vac %>% filter(!is.na(icu_staytime)) %>% 
    group_by(Group = gender) %>% summarize(
    Median = round(median(icu_staytime),1),
    "25 Q" = round(quantile(icu_staytime, 0.25),1),
    "75 Q" = round(quantile(icu_staytime, 0.75),1),
    Minimum = round(min(icu_staytime),3),
    Maximum = round(max(icu_staytime),1)
  ),
  adm_icu_vac %>% filter(!is.na(icu_staytime)) %>% filter(!is.na(age_gp)) %>% 
    group_by(Group = age_gp) %>% summarize(
      Median = round(median(icu_staytime),1),
      "25 Q" = round(quantile(icu_staytime, 0.25),1),
      "75 Q" = round(quantile(icu_staytime, 0.75),1),
      Minimum = round(min(icu_staytime),3),
      Maximum = round(max(icu_staytime),1)
    ),
  adm_icu_vac %>% filter(!is.na(icu_staytime)) %>% filter(!is.na(vaccinated)) %>% 
    group_by(Group = vaccinated) %>% summarize(
      Median = round(median(icu_staytime),1),
      "25 Q" = round(quantile(icu_staytime, 0.25),1),
      "75 Q" = round(quantile(icu_staytime, 0.75),1),
      Minimum = round(min(icu_staytime),3),
      Maximum = round(max(icu_staytime),1)
    ),
  adm_icu_vac %>% filter(!is.na(icu_staytime)) %>% summarize(
    Group = "Overall",
    Median = round(median(icu_staytime),1),
    "25 Q" = round(quantile(icu_staytime, 0.25),1),
    "75 Q" = round(quantile(icu_staytime, 0.75),1),
    Minimum = round(min(icu_staytime),3),
    Maximum = round(max(icu_staytime),1)
  )
) %>%
  ungroup()
View(ii_icu_sum)

