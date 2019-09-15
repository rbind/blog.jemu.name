# Global things sourced in each blogpost

# First up: dependency checking ----
if (!("devtools" %in% installed.packages())) install.packages("devtools")
devtools::install_deps(".")

# Global stuff ----
library(ggplot2)
library(dplyr)
library(knitr)
library(tadaatoolbox)

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

# Set hook defined in helpers.R
knitr::knit_hooks$set(plot = hook)

# Plot output ----

# ggplot2 theme
ggplot2::theme_set(
  firasans::theme_ipsum_fsc() +
    theme(
      panel.spacing.y = unit(2.5, "mm"),
      panel.spacing.x = unit(2, "mm"),
      plot.margin = margin(t = 7, r = 5, b = 7, l = 5),
      legend.position = "bottom",
      plot.background = element_rect(fill = "#FCFCFC", color = "#FCFCFC"),
      panel.background = element_rect(fill = "#FCFCFC", color = "#FCFCFC")
    )
)

# Caching datasets ----

# Set post-specific cache directiory, create if needed
# Use at beginning of post
# Might take rmarkdown::metadata$slug as input dynamically
make_cache_path <- function(post_slug = "misc") {

  cache_path <- here::here(file.path("datasets", post_slug))

  if (!file.exists(cache_path)) dir.create(cache_path)

  return(cache_path)
}

# Check if file is not cached
# if (file_note_cache(cache_path, bigdata)) {
#   { do expensive stuff }
# }
file_not_cached <- function(cache_path, cache_file) {
  !(file.exists(file.path(cache_path, cache_file)))
}

# Cache a file, just a wrapper for saveRDS
cache_file <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  saveRDS(cache_data, file.path(cache_path, filename))
}

# Read a cached file, just a wrapper for readRDS
read_cache_file <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")

  readRDS(file.path(cache_path, filename))
}

# Get date from cached file
cache_date <- function(cached_file, cache_path) {
  format(file.mtime(file.path(cache_path, cached_file)), "%F")
}
