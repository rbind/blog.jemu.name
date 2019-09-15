# Global things sourced in each blogpost

library(ggplot2)
library(dplyr)
library(knitr)
library(tadaatoolbox)

source(here::here("helpers.R"))

# Hugo config
# config_toml <- RcppTOML::parseTOML(here::here("config.toml"))

# Global chunk options
knitr::opts_chunk$set(
  out.width = "90%",
  fig.retina = 2,
  error = FALSE,
  warning = FALSE,
  message = FALSE,
  comment = "",
  cache = TRUE
)

ggplot2::theme_set(
  firasans::theme_ipsum_fsc() +
    theme(
      panel.spacing.y = unit(2.5, "mm"),
      panel.spacing.x = unit(2, "mm"),
      plot.margin = margin(3, 3, 3, 3),
      legend.position = "bottom"
    )
)

#### Plot output ####

# Set hook defined in helpers.R
knitr::knit_hooks$set(plot = hook)


