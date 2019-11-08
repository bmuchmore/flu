  library(ggalt) 
  library(magick)
  library(cdcfluview)
  library(hrbrthemes)
  library(statebins)
  library(tidyverse)
  
  flu <- ili_weekly_activity_indicators(2018)
  frames <- image_graph(width = 1800, height = 1200, res = 144)
  arrange(flu, weekend) %>%
    pull(weekend) %>%
    unique() %>%
    map(~{
      filter(flu, weekend == .x) %>%
        statebins(
          state_col = "statename", 
          value_col = "activity_level", 
          round = TRUE,
          ggplot2_scale_function = viridis::scale_fill_viridis, 
          limits = c(0, 10),
          name = "Flu Activity Level  ") +
        labs(title = sprintf("Flu Weekly Activity : Week Ending %s / 2018-19", .x)) +
        theme_statebins(base_family = "Roboto Condensed") -> gg
      print(gg)
    }) -> y
  gif <- image_animate(frames, 1)
  image_write(gif, "/home/brian/Desktop/flu/scripts/fluview.gif")