# Global things sourced in each blogpost

# First up: dependency checking ----
if (!("devtools" %in% installed.packages())) install.packages("devtools")
devtools::install_deps(".")

# GLobal stuff ----
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
      plot.margin = margin(t = 5, r = 3, b = 5, l = 3),
      legend.position = "bottom",
      plot.background = element_rect(fill = "#FCFCFC"),
      panel.background = element_rect(fill = "#FCFCFC")
    )
)

#### Plot output ####

# Set hook defined in helpers.R
knitr::knit_hooks$set(plot = hook)


