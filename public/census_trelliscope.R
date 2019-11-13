library(readr)
library(trelliscopejs)
library(magrittr)

read_rds("/home/brian/Desktop/flu/fludata/census_trelliscope_input.rds") %>%
  trelliscope(
    name = "Vermont Census Data",
    group = "common",
    panel_col = "panel",
    desc = "",
    md_desc = "",
    path = "/home/brian/Desktop/flu/static/census_trelliscope",
    height = 500,
    width = 500,
    auto_cog = FALSE,
    state = NULL,
    nrow = 1,
    ncol = 1,
    jsonp = TRUE,
    self_contained = TRUE,
    thumb = FALSE
  )
