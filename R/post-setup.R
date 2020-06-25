source(here::here("R/helpers.R"))

knitr::opts_chunk$set(
  fig.path = "plots/", # for leaf bundles to work nicely
  cache = TRUE,
  cache.path = "blogdown_cache/", # (for leaf bundles, cache in post directory)
  fig.retina = 2,
  fig.width = 8.5,
  echo = TRUE,
  message = FALSE, warning = FALSE, error = FALSE,
  fig.align = "center",
  out.width = "95%",
  comment = "#>",
  collapse = FALSE
)

# knitr hook to use Hugo highlighting options ----
knitr::knit_hooks$set(
  source = hook_source
)

# Plot to hugo figure shortcode ----
# in .Rmarkdown only
knitr::knit_hooks$set(
  plot = hook_plot
)

# Fold entire chunk incl output ----
knitr::knit_hooks$set(
  chunk_fold = hook_chunk_fold
)

# Fold source code only ----
# in .Rmarkdown only
# knitr::knit_hooks$set(source = function(x, options) {
#
#   # The original source in a fenced code block
#   source_orig <- paste(c("```r", x, "```\n"), collapse = "\n")
#   fold_option <- options[["code_fold"]]
#
#   # If option not set or explicitly FALSE, return regular code chunk
#   if (is.null(fold_option) | isFALSE(fold_option)) {
#    return(source_orig)
#   }
#
#   summary_text <- ifelse(
#     is.character(fold_option), # If the option is text,
#     fold_option,               # use it as <summary>Label</summary>,
#     "Click to expand"          # otherwise here's a default
#   )
#
#   # Output details tag
#   glue::glue(
#     "<details>
#       <summary>{summary_text}</summary>
#       {source_orig}
#     </details>"
#   )
# })
