######### (i) ###########
## data preparation
# change age to age group
patient_demo_table$age_gp <- cut(
  patient_demo_table$age_in_years,
  breaks = c(0, 18, 30, 50, 60, Inf),
  labels = c("0-18", "19-30", "31-50", "51-60", "61+"))
# change name of gender
patient_demo_table <- patient_demo_table %>% 
  mutate (gender = case_when(
    gender == "M" ~ "Male",
    gender == "F" ~ "Female",
    TRUE ~ gender))
# grouping ethnic groups
patient_demo_table <- patient_demo_table %>% 
  mutate(ethnic_gp = case_when(
    grepl("ASIA", ethnicity, ignore.case = TRUE) ~ "Asian",
    grepl("BLACK", ethnicity, ignore.case = TRUE) ~ "Black",
    grepl("HISPANIC", ethnicity, ignore.case = TRUE) ~ "Hispanic",
    grepl("WHITE", ethnicity, ignore.case = TRUE) ~ "White",
    grepl("UNKNOWN", ethnicity, ignore.case = TRUE) ~ "Unknown",
    TRUE ~ "Other"))
#  Add vaccination status from ODK
pt_demo <- merge(patient_demo_table, odk[c("subject_id", "admitage_yrs","vaccinated")], by = "subject_id", all.x = TRUE)
View(pt_demo)
# summarize the demographic characteristics 
age_sex <- pt_demo %>% filter(!is.na(age_gp)) %>% count(age_gp, gender) %>% arrange(age_gp)
ethnicity <- pt_demo %>% count(ethnic_gp) %>% arrange(desc(n))