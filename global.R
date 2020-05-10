# Global things sourced in each blogpost

# Global stuff ----
library(ggplot2)
library(dplyr)
library(knitr)
library(extrafont)

source(here::here("helpers.R"))

# Hugo config
# config_toml <- RcppTOML::parseTOML(here::here("config.toml"))

# knitr: Global chunk options
knitr::opts_chunk$set(
  out.width = "90%",
  fig.retina = 2,
  error = FALSE,
  warning = FALSE,
  message = FALSE,
  comment = "",
  cache = TRUE
)

# Code highlighting via prims.js requires manually set class
knitr::opts_chunk$set(
  class.source = c("language-r")
)

# Set hooks defined in helpers.R
knitr::knit_hooks$set(
  plot = plot_hook,
  summary = summary_hook
)

# Plot output ----

# ggplot2 theme
ggplot2::theme_set(
  firasans::theme_ipsum_fsc() +
    theme(
      plot.title.position = "plot",
      panel.spacing.y = unit(2.5, "mm"),
      panel.spacing.x = unit(2, "mm"),
      plot.margin = margin(t = 7, r = 5, b = 7, l = 5),
      legend.position = "top",
      plot.background = element_rect(fill = "#FCFCFC", color = "#FCFCFC"),
      panel.background = element_rect(fill = "#FCFCFC", color = "#FCFCFC")
    )
)
