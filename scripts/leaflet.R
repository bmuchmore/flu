library(htmlwidgets)
library(leaflet)
library(cdcfluview)
library(dplyr)

data <- ili_weekly_activity_indicators(2019) %>%
  filter(statename == "Vermont") %>%
  arrange(weeknumber)

data <- cdc_basemap(basemap = "states") %>% 
  plot()



