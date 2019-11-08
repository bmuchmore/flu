    library(ggplot2)
    library(tidyr)
    library(hrbrthemes)
    library(plotly)
    library(htmlwidgets)
    p1 <- pi_mortality("national") %>%
      select(wk_end, percent_pni) %>% 
      gather(measure, value, -wk_end) %>% 
      ggplot(aes(wk_end, value)) + 
      geom_line(aes(group = measure, color = measure), color = "red") + 
      scale_y_percent() +
      scale_color_ipsum(name = NULL, labels = c("Percent P&I")) +
      labs(x = NULL, y = NULL, title = NULL) +
      theme_ipsum_rc(grid = "XY") +
      theme(legend.position = "bottom")
    p1 <- ggplotly(p1) %>%
      add_annotations(
        text = "Percentage of deaths due to pneumonia and influenza nationally",
        x = 0.5,
        y = 1,
        yref = "paper",
        xref = "paper",
        xanchor = "middle",
        yshift = 30,
        showarrow = FALSE,
        font = list(size = 15)
      ) %>%
      config(
        collaborate = FALSE,
        displaylogo = FALSE,
        modeBarButtonsToRemove = list(
          "sendDataToCloud",
          "toImage",
          "autoScale2d",
          "resetScale2d",
          "hoverClosestCartesian",
          "hoverCompareCartesian",
          "zoomIn2d", 
          "zoomOut2d",
          "editInChartStudio",
          "zoom2d",
          "pan2d",
          "select2d",
          "lasso2d",
          "toggleSpikelines"
        )
      )
    p2 <- pi_mortality("state") %>%
        filter(region_name == "Vermont") %>%
        select(wk_end, percent_pni) %>% 
        gather(measure, value, -wk_end) %>% 
        ggplot(aes(wk_end, value)) + 
        geom_line(aes(group = measure, color = measure), color = "red") + 
        scale_y_percent() +
        scale_color_ipsum(name = NULL, labels = c("Percent P&I")) +
        labs(x = NULL, y = NULL, title = NULL) +
        theme_ipsum_rc(grid = "XY") +
        theme(legend.position = "bottom")
    p2 <- ggplotly(p2) %>%
      add_annotations(
        text = "Percentage of deaths due to pneumonia and influenza in Vermont",
        x = 0.5,
        y = 1,
        yref = "paper",
        xref = "paper",
        xanchor = "middle",
        yshift = 15,
        showarrow = FALSE,
        font = list(size = 15)
      ) %>%
      config(
        collaborate = FALSE,
        displaylogo = FALSE,
        modeBarButtonsToRemove = list(
          "sendDataToCloud",
          "toImage",
          "autoScale2d",
          "resetScale2d",
          "hoverClosestCartesian",
          "hoverCompareCartesian",
          "zoomIn2d", 
          "zoomOut2d",
          "editInChartStudio",
          "zoom2d",
          "pan2d",
          "select2d",
          "lasso2d",
          "toggleSpikelines"
        )
      )
    p3 <- subplot(
      style(p1, showlegend = FALSE),
      style(p2, showlegend = FALSE),
      nrows = 2, 
      widths = NULL, 
      heights = NULL,
      margin = 0.02, 
      shareX = TRUE, 
      shareY = TRUE, 
      titleX = TRUE,
      titleY = TRUE, 
      which_layout = "merge"
    )
    dir.create("/home/brian/Desktop/flu_deaths", showWarnings = TRUE, recursive = FALSE, mode = "0777")
    saveWidget(p3, file = "/home/brian/Desktop/flu_deaths/index.html")
    
    
    
