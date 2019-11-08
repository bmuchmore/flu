library(dplyr)
library(tidyr)
library(formr)
library(labelled)
library(purrr)

formr_connect(email = "bmuchmore@gmail.com", password = "dogsdogs" )
results <- formr_results("testflusurvey")

zipfix <- function(x) {
  if (nchar(x) == 5) {
    x
  } else {
    substring(x, 2)
  }
}

filtered_results <- results %>%
  remove_labels() %>%
  remove_attributes("haven_labelled") %>%
  mutate(had_flu_in_past_year = coalesce(child_had_flu_in_past_year, juvenile_had_flu_in_past_year, teenage_had_flu_in_past_year, young_adult_had_flu_in_past_year, older_adult_had_flu_in_past_year, oldest_adult_had_flu_in_past_year)) %>%
  select(-child_had_flu_in_past_year, -juvenile_had_flu_in_past_year, -teenage_had_flu_in_past_year, -young_adult_had_flu_in_past_year, -older_adult_had_flu_in_past_year, -oldest_adult_had_flu_in_past_year) %>%
  mutate(has_flu_currently = coalesce(child_has_flu, juvenile_has_flu, teenage_has_flu, young_adult_has_flu, older_adult_has_flu, oldest_adult_has_flu)) %>%
  select(-child_has_flu, -juvenile_has_flu, -teenage_has_flu, -young_adult_has_flu, -older_adult_has_flu, -oldest_adult_has_flu) %>%
  mutate(received_shot_last_year = coalesce(child_received_shot_last_year, juvenile_received_shot_last_year, teenage_received_shot_last_year, young_adult_received_shot_last_year, older_adult_received_shot_last_year, oldest_adult_received_shot_last_year)) %>%
  select(-child_received_shot_last_year, -juvenile_received_shot_last_year, -teenage_received_shot_last_year, -young_adult_received_shot_last_year, -older_adult_received_shot_last_year, -oldest_adult_received_shot_last_year) %>%
  mutate(already_received_shot = coalesce(child_already_received_shot, juvenile_already_received_shot, teenage_already_received_shot, young_adult_already_received_shot, older_adult_already_received_shot, oldest_adult_already_received_shot)) %>%
  select(-child_already_received_shot, -juvenile_already_received_shot, -teenage_already_received_shot, -young_adult_already_received_shot, -older_adult_already_received_shot, -oldest_adult_already_received_shot) %>%
  mutate(shot_today = coalesce(child_will_get_shot_today, juvenile_will_get_shot_today, teenage_will_get_shot_today, young_adult_will_get_shot_today, older_adult_will_get_shot_today, oldest_adult_will_get_shot_today)) %>%
  select(-child_will_get_shot_today, -juvenile_will_get_shot_today, -teenage_will_get_shot_today, -young_adult_will_get_shot_today, -older_adult_will_get_shot_today, -oldest_adult_will_get_shot_today) %>%
  mutate(no_shot_explanation = coalesce(child_will_not_get_shot_today_explanation, juvenile_will_not_get_shot_today_explanation, teenage_will_not_get_shot_today_explanation, young_adult_will_not_get_shot_today_explanation, older_adult_will_not_get_shot_today_explanation, oldest_adult_will_not_get_shot_today_explanation)) %>%
  select(-child_will_not_get_shot_today_explanation, -juvenile_will_not_get_shot_today_explanation, -teenage_will_not_get_shot_today_explanation, -young_adult_will_not_get_shot_today_explanation, -older_adult_will_not_get_shot_today_explanation, -oldest_adult_will_not_get_shot_today_explanation) %>%
  filter(!is.na(who_is_taking_survey)) %>%
  drop_na(zipcode) %>%
  drop_na(who_is_taking_survey) %>%
  filter(!grepl("Windows", browser)) %>%
  mutate(annul_results = as.character(annul_results)) %>%
  filter(annul_results == "2") %>%
  filter(survey_already_offered == "2") %>%
  select(-session, -annul_results, -survey_already_offered, -browser, -created, -modified, -last_outside_referrer, -expired, -ip_address) 

filtered_results <- filtered_results %>%
  mutate(zipcode = as.character(zipcode))
filtered_results$zipcode <- sub("^", 0, filtered_results$zipcode)
filtered_results <- filtered_results %>%
  mutate(zipcode = map(zipcode, ~zipfix(.x))) %>%
  mutate(zipcode = as.character(zipcode))

recoded_data <- filtered_results %>%
  select(-ended) %>%
  mutate_all(as.integer) %>%
  mutate(flu_shot_available = recode(.[["flu_shot_available"]], `1` = "Yes", `2` = "No")) %>%
  mutate(had_flu_in_past_year = recode(.[["had_flu_in_past_year"]], `1` = "Yes", `2` = "No")) %>%
  mutate(has_flu_currently = recode(.[["has_flu_currently"]], `1` = "Yes", `2` = "No")) %>%
  mutate(received_shot_last_year = recode(.[["received_shot_last_year"]], `1` = "Yes", `2` = "No")) %>%
  mutate(already_received_shot = recode(.[["already_received_shot"]], `1` = "Yes", `2` = "No")) %>%
  mutate(shot_today = recode(.[["shot_today"]], `0` = "Not Answered", `1` = "Yes", `2` = "No")) %>%
  mutate(vaccine_given_in_clinic = recode(.[["vaccine_given_in_clinic"]], `1` = "Yes", `2` = "No")) %>%
  mutate(
    no_shot_explanation = 
      recode(
        .[["no_shot_explanation"]],
        `0` = "Not Answered",
        `1` = "Not the season", 
        `2` = "Not available", 
        `3` = "I think the flu shot can give you the flu", 
        `4` = "Healthy and not needed", 
        `5` = "It is not necessary to get one every year", 
        `6` = "Other"
      )
  ) %>%
  mutate(
    who_is_taking_survey = 
      recode(
        .[["who_is_taking_survey"]],
        `1` = "0-4", 
        `2` = "5-17", 
        `3` = "5-17", 
        `4` = "18-49", 
        `5` = "50-64", 
        `6` = "65+"
      )
  )
recoded_data <- recoded_data %>%
  mutate(zipcode = as.character(zipcode))
recoded_data$zipcode <- sub("^", 0, recoded_data$zipcode)
recoded_data <- recoded_data %>%
  mutate(zipcode = map(zipcode, ~zipfix(.x))) %>%
  mutate_all(as.character) %>%
  rename(
    "Was the flu shot available?" = "flu_shot_available",
    "Age of participant" = "who_is_taking_survey",
    "Zipcode" = "zipcode",
    "Prediction of next flu season severity" = "flu_season_prediction",
    "Was the vaccine given in clinic?" = "vaccine_given_in_clinic",
    "Did they have flu symptoms last year?" = "had_flu_in_past_year",
    "Do they currently have flu symptoms?" = "has_flu_currently",
    "Did they receive the flu vaccine last year?" = "received_shot_last_year",
    "Have they already receive the flu vaccine?" = "already_received_shot",
    "Do they plan on getting the flu vaccine today?" = "shot_today",
    "Why will they not get the flu vaccine?" = "no_shot_explanation"
  )



date1 <- as.POSIXct(Sys.Date() - 7)
date2 <- as.POSIXct(Sys.Date() + 1)
time_interval <- interval(date1, date2)
time_filtered <- filtered_results[filtered_results$ended %within% time_interval, ]
current_cases <- time_filtered %>%
  select(-ended) %>%
  as_tibble() %>%
  group_by(zipcode) %>%
  count(has_flu_currently) %>%
  filter(has_flu_currently == 1) %>%
  inner_join(vermont_zip_geo, by = c("zipcode" = "zip")) %>%
  select(-geometry, -city) %>%
  spread(has_flu_currently, n) %>%
  ungroup() %>%
  rename("Current cases" = "1") 

# 
# Column {.tabset}
# -----------------------------------------------------------------------
#   
#   ### Chart A
#   
# ```{r}
# recoded_data %>%
#   mutate_all(as.factor) %>%
#   datatable(
#     filter = list(position = "top", clear = FALSE),
#     rownames = FALSE,
#     extensions = "Buttons", 
#     options = list(
#       bPaginate = FALSE,
#       dom = "Brtip",
#       buttons = 
#         list("copy", list(
#           extend = "collection",
#           buttons = c("csv", "excel", "pdf"),
#           text = "Download"
#         )
#         )
#     )
#   )
# ```
# 
# ### Chart B
# 
# ```{r}
# rpivotTable(
#   data = recoded_data, 
#   rows = "Age of participant", 
#   cols = "Was the vaccine given in clinic?", 
#   aggregatorName = "Count",
#   vals = NULL, 
#   rendererName = "Horizontal Bar Chart",
#   sorter = NULL, 
#   exclusions = NULL,
#   inclusions = NULL, 
#   locale = "en", 
#   subtotals = FALSE,
#   width = 800,
#   height = 600, 
#   elementId = NULL
# )
# ```
# 
# 
# 
# 
# rpivotTable(
#   data = recoded_data, 
#   rows = "Age of participant", 
#   cols = "Was the vaccine given in clinic?", 
#   aggregatorName = "Count",
#   vals = NULL, 
#   rendererName = "Horizontal Bar Chart",
#   sorter = NULL, 
#   exclusions = NULL,
#   inclusions = NULL, 
#   locale = "en", 
#   subtotals = FALSE,
#   width = 800,
#   height = 600, 
#   elementId = NULL
# ) 




















