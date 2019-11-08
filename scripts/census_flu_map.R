library(leaflet)
library(stringr)
library(sf)
library(tidyverse)
library(tidycensus)
library(crosstalk)
library(zipcode)
library(magrittr)
library(leafsync)
library(leaflet.minicharts)

census_api_key(
  key = "ff2744c9f1b4604267fdd12c1f0371d90a7d3df5", 
  overwrite = FALSE, 
  install = FALSE
)

acs_variables <- load_variables(2017, "acs5", cache = TRUE)
View(acs_variables)

data(zipcode)
zip_list <- zipcode %>%
  filter(state == "VT") %>%
  select(zip) %>%
  .[[1]]

zip_edu_data <- get_acs(
  geography = "zcta", 
  variables = c("B06009_003", "B06009_004", "B06009_005", "B06009_006"),
  table = NULL,
  cache_table = FALSE, 
  year = 2017, 
  endyear = NULL,
  output = "tidy", 
  state = NULL, 
  county = NULL, 
  geometry = TRUE,
  keep_geo_vars = FALSE, 
  shift_geo = FALSE, 
  summary_var = "B06009_001",
  key = NULL, 
  moe_level = 90, 
  survey = "acs5"
) %>%
  as_tibble()

zip_other_data <- get_acs(
  geography = "zcta", 
  variables = c("B01003_001", "B19013_001", "B01002_001", "B06009_003"), 
  table = NULL,
  cache_table = FALSE, 
  year = 2017, 
  endyear = NULL,
  output = "tidy", 
  state = NULL, 
  county = NULL, 
  geometry = TRUE,
  keep_geo_vars = FALSE, 
  shift_geo = FALSE, 
  summary_var = "B06009_001",
  key = NULL, 
  moe_level = 90, 
  survey = "acs5"
) %>%
  as_tibble()

vermont_zip_other_rawdata <- zip_other_data %>%
  filter(GEOID %in% zip_list) %>%
  rename(zip = GEOID) %>%
  inner_join(zipcode) 
vermont_zip_rawdata <- zip_edu_data %>%
  filter(GEOID %in% zip_list) %>%
  rename(zip = GEOID) %>%
  inner_join(zipcode) %>%
  group_by(zip) %>%
  summarize(grad_hs = sum(estimate, na.rm = TRUE)) %>%
  inner_join(vermont_zip_other_rawdata)

vermont_zip_geo <- vermont_zip_rawdata %>%
  filter(variable == "B19013_001") %>%
  select(zip, city, geometry, latitude, longitude)
vermont_zip_income <- vermont_zip_rawdata %>%
  filter(variable == "B19013_001") %>%
  drop_na(estimate) %>%
  rename(income = estimate) %>%
  select(zip, income)
vermont_zip_pop <- vermont_zip_rawdata %>%
  filter(variable == "B01003_001") %>%
  drop_na(estimate) %>%
  rename(pop = estimate) %>%
  select(zip, pop)
vermont_zip_age <- vermont_zip_rawdata %>%
  filter(variable == "B01002_001") %>%
  drop_na(estimate) %>%
  rename(age = estimate) %>%
  select(zip, age)
vermont_zip_edu <- vermont_zip_rawdata %>%
  filter(variable == "B06009_003") %>%
  drop_na(estimate) %>%
  select(zip, grad_hs, summary_est) %>%
  mutate(edu = grad_hs/summary_est) %>%
  select(zip, edu)

vermont_zip_data <- vermont_zip_income %>%
  inner_join(vermont_zip_pop) %>%
  inner_join(vermont_zip_age) %>%
  inner_join(vermont_zip_edu) %>%
  inner_join(vermont_zip_geo) %>%
  st_sf()

# library(readr)
# write_rds(vermont_zip_data, "/home/brian/Desktop/flu/data/vermont_zip_data")
# write_rds(vermont_zip_geo, "/home/brian/Desktop/flu/data/vermont_zip_geo")

edu_palette <- colorNumeric(
  palette = "magma", 
  domain = vermont_zip_data$edu
)
vt_edu <- vermont_zip_data %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%", height = "600px") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    popup = ~zip,
    stroke = FALSE,
    smoothFactor = 0,
    fillOpacity = 0.7,
    color = ~edu_palette(edu)
  ) %>%
  addLegend(
    "bottomright", 
    pal = edu_palette, 
    values = ~edu,
    title = "Education by Zip",
    opacity = 1
  )


age_palette <- colorNumeric(
  palette = "inferno", 
  domain = vermont_zip_data$age
)
vt_age <- vermont_zip_data %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%", height = "600px") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    popup = ~zip,
    stroke = FALSE,
    smoothFactor = 0,
    fillOpacity = 0.7,
    color = ~age_palette(age)
  ) %>%
  addLegend(
    "bottomright", 
    pal = age_palette, 
    values = ~age,
    title = "Median Age by Zip",
    opacity = 1
  )



pop_palette <- colorNumeric(
  palette = "plasma", 
  domain = vermont_zip_data$pop
)
vt_pop <- vermont_zip_data %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%", height = "600px") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    popup = ~zip,
    stroke = FALSE,
    smoothFactor = 0,
    fillOpacity = 0.7,
    color = ~pop_palette(pop)
  ) %>%
  addLegend(
    "bottomright", 
    pal = pop_palette, 
    values = ~pop,
    title = "Population by Zip",
    opacity = 1
  ) 



income_palette <- colorNumeric(
  palette = "viridis", 
  domain = vermont_zip_data$income
)
vt_income <- vermont_zip_data %>%
  st_transform(crs = "+init=epsg:4326") %>%
  leaflet(width = "100%", height = "600px") %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolygons(
    popup = ~zip,
    stroke = FALSE,
    smoothFactor = 0,
    fillOpacity = 0.7,
    color = ~income_palette(income)) %>%
  addLegend(
    "bottomright", 
    pal = income_palette, 
    values = ~income,
    title = "Median Income by Zip",
    labFormat = labelFormat(prefix = "$"),
    opacity = 1
  ) 


  # addMinicharts(
  #   test$longitude, 
  #   test$latitude,
  #   type = "bar",
  #   chartdata = select(test2, -sum),
  #   colorPalette = d3.schemeCategory10,
  #   width = 30 * sqrt(test2$sum) / sqrt(max(test2$sum)), 
  #   height = 30 * sqrt(test2$sum) / sqrt(max(test2$sum))
  # ) 

library(htmltools)
library(widgetframe)
save_tags <- function (tags, file, selfcontained = F, libdir = "./lib") 
{
  if (is.null(libdir)) {
    libdir <- paste(tools::file_path_sans_ext(basename(file)), 
                    "_files", sep = "")
  }
  htmltools::save_html(tags, file = file, libdir = libdir)
  if (selfcontained) {
    if (!htmlwidgets:::pandoc_available()) {
      stop("Saving a widget with selfcontained = TRUE requires pandoc. For details see:\n", 
           "https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md")
    }
    htmlwidgets:::pandoc_self_contained_html(file, file)
    unlink(libdir, recursive = TRUE)
  }
  return(file)
}
zip_sync <- leafsync::sync(
  vt_age,
  vt_income,
  vt_pop,
  vt_edu
)
save_tags(zip_sync, "zip_sync.html", selfcontained = TRUE)

library(htmlwidgets)
saveWidget(zip_sync, "/home/brian/Desktop/flu/data/zip_sync")

library(manipulateWidget)
combineWidgets(vt_age, vt_pop, ncol = 2)


survey_data_fixed <- survey_data
survey_data_fixed$zip <- sub("^", 0, survey_data$zip )
test <- survey_data_fixed %>%
  as_tibble() %>%
  group_by(zip) %>%
  count(education) %>%
  inner_join(vermont_zip_geo) %>%
  select(-geometry, -city) %>%
  spread(education,  n) %>%
  mutate_all(~replace(., is.na(.), 0)) %>%
  select(-zip) %>%
  ungroup()
test2 <- test %>%
  select(-zip, -latitude, -longitude) %>%
  mutate(sum = rowSums(.[1:ncol(.)]))
vt_age %>%
  addMinicharts(
    test$longitude, 
    test$latitude,
    type = "bar",
    chartdata = select(test2, -sum),
    colorPalette = d3.schemeCategory10,
    width = 30 * sqrt(test2$sum) / sqrt(max(test2$sum)), 
    height = 30 * sqrt(test2$sum) / sqrt(max(test2$sum))
  )


library(DT)
datatable(
  survey_data,
  extensions = 'Buttons', 
  options = list(
    dom = 'Bfrtip',
    buttons = 
      list('copy', list(
        extend = 'collection',
        buttons = c('csv', 'excel', 'pdf'),
        text = 'Download'
      )
      )
  )
)



