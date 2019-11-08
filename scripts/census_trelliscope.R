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
library(purrr)
library(magrittr)
library(foreach)
library(microbenchmark)
library(trelliscopejs)

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
  as_tibble() %>%
  filter(GEOID %in% zip_list) %>%
  rename(zip = GEOID) %>%
  inner_join(zipcode) 

census_func <- function(i) {
  output <- filter(zip_edu_data, variable == i) %>%
    drop_na(estimate) %>%
    select(zip, estimate, geometry)
  color_palette <- colorNumeric(
    palette = "viridis",
    domain = output$estimate
  )
  output %>%
    st_sf() %>%
    st_transform(crs = "+init=epsg:4326") %>%
    leaflet(width = "100%", height = "600px") %>%
    addProviderTiles(provider = "CartoDB.Positron") %>%
    addPolygons(
      popup = ~zip,
      stroke = FALSE,
      smoothFactor = 0,
      fillOpacity = 0.7,
      color = ~color_palette(estimate)
    ) %>%
    addLegend(
      "bottomright",
      pal = color_palette,
      values = ~estimate,
      title = i,
      opacity = 1
    )
}

variables <- c("B06009_003", "B06009_004", "B06009_005", "B06009_006")
foreach_output <- foreach(
  i = 1:length(variables),
  .errorhandling = "pass",
  .verbose = FALSE,
  .inorder = TRUE
) %dopar% {
  census_func(variables[[i]])
}

trellis_input <- foreach_output %$%
  tibble(panel = .) %>%
  mutate(variable = map(panel, ~.x[[1]][["calls"]][[3]][["args"]][[1]][["title"]])) %>%
  mutate(variable = as.character(variable)) %>%
  mutate(panel = map_plt(panel, ~panel(.x)))

trellis_input[4, 1][[1]]

trellis_input %>%
  trelliscope(
    "testing"
  )
trelliscope(
  x = trellis_input,
  name = "temp",
  group = "common",
  panel_col = "panel",
  desc = "",
  md_desc = "",
  path = "/home/brian/Desktop/flu/data/census_trelliscope",
  height = 500,
  width = 500,
  auto_cog = FALSE,
  state = NULL,
  nrow = 1,
  ncol = 1,
  jsonp = TRUE,
  self_contained = FALSE,
  thumb = FALSE
)

census_output
























