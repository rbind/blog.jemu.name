# Global things sourced in each blogpost

library(ggplot2)
library(dplyr)
library(knitr)
library(tadaatoolbox)

source(rprojroot::find_rstudio_root_file("helpers.R"))

# Hugo config
# config_toml <- RcppTOML::parseTOML(rprojroot::find_rstudio_root_file("config.toml"))

# Global chunk options
knitr::opts_chunk$set(out.width = "100%",
                      fig.retina = 2,
                      warning = F,
                      message = F,
                      comment = "")

ggplot2::theme_set(tadaatoolbox::theme_tadaa())

#### Plot output ####

# Set hook defined in helpers.R
knitr::knit_hooks$set(plot = hook)


