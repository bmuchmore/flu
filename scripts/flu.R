library(zipcode)
library(dplyr)
library(plotly)
data("zipcode")
vt_zips <- zipcode %>%
  filter(state == "VT")

library(cdcfluview)
library(dplyr)
data <- ili_weekly_activity_indicators(2018) %>%
  filter(statename == "Vermont") %>%
  arrange(weeknumber)

more_data <- hospitalizations(
  surveillance_area = c("flusurv", "eip", "ihsp"),
  region = "all", 
  years = 2018
)

gs <- geographic_spread()

library(crosstalk)
data(trails, package = 'mapview')

tsd <- SharedData$new(trails)

bscols(
  plot_geo(tsd, text = ~FKN, hoverinfo = "text"),
  DT::datatable(tsd)
)




library(leaflet)
library(crosstalk)
library(DT)
library(zipcode)
library(dplyr)

chc_icon <- makeAwesomeIcon(icon = "first-aid", library = "fa", markerColor = "white", iconColor = "#FF0000")
popup <- paste(sep = "<br/>", "<b><a href=https://www.chcb.org/locations-providers/south-end-health-center/', target='_blank'>South End Health Center</a></b>", "789 Pine Street", "Burlington, VT 05401", "(802) 864-6309")

zip_data <- (function(...)get(data(...,envir = new.env())))("zipcode") %>%
  filter(state == "VT")
sd <- SharedData$new(zip_data)


bscols(
  leaflet(sd) %>%
    addProviderTiles("Stamen.Watercolor") %>%
    addMarkers(popup = ~city) %>%
    setView(lng =  -73.21501, lat = 44.45748, zoom = 12) %>%
    addAwesomeMarkers(lng = -73.21501, lat = 44.45748, popup = popup, icon = chc_icon),
  datatable(
    sd,
    extensions = "Scroller",
    style = "bootstrap",
    class = "compact",
    width = "100%",
    options = list(deferRender = TRUE, scrollY = 300, scroller = TRUE)
  )
)
library(leaflet)
chc_icon <- makeAwesomeIcon(icon = "microscope", library = "fa")
chc_icon <- makeAwesomeIcon(icon = "first-aid", library = "fa", markerColor = "white", iconColor = "#FF0000")

chc_icon <- makeAwesomeIcon(
  icon = "user-md",
  library = "fa",
  markerColor = "white",
  iconColor = "blue",
  spin = FALSE,
  extraClasses = NULL,
  squareMarker = FALSE,
  iconRotate = 0,
  fontFamily = "monospace",
  text = NULL
  )
popup <- paste(sep = "<br/>", "<b><a href=https://www.chcb.org/locations-providers/south-end-health-center/', target='_blank'>South End Health Center</a></b>", "789 Pine Street", "Burlington, VT 05401", "(802) 864-6309")
leaflet() %>%
  addProviderTiles("Stamen.Watercolor") %>%
  setView(lng =  -73.21501, lat = 44.45748, zoom = 12) %>%
  addAwesomeMarkers(lng = -73.21501, lat = 44.45748, popup = popup, icon = chc_icon)
