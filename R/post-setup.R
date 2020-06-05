knitr::opts_chunk$set(
  fig.path = "plots/", # for leaf bundles to work nicely
  cache = TRUE,
  cache.path = "blogdown_cache/", # (for leaf bundles, cache in post directory)
  fig.retina = 2,
  fig.width = 8.5,
  echo = TRUE,
  message = FALSE, warning = FALSE, error = FALSE,
  fig.align = "center",
  out.width = "95%"
)

# knitr hook to use Hugo highlighting options ----
knitr::knit_hooks$set(
  source = function(x, options) {
    hlopts <- options$hlopts
    paste0(
      "```", "r ",
      if (!is.null(hlopts)) {
        paste0("{",
               glue::glue_collapse(
                 glue::glue('{names(hlopts)}={hlopts}'),
                 sep = ","
               ), "}"
        )
      },
      "\n", glue::glue_collapse(x, sep = "\n"), "\n```\n"
    )
  }
)

# Plot to hugo figure shortcode ----
# in .Rmarkdown only
# see https://ropensci.org/technotes/2020/04/23/rmd-learnings/
knitr::knit_hooks$set(
  plot = function(x, options) {
    hugoopts <- options$hugoopts
    # Link image to itself if there's no explicit link set
    if (!hasName(hugoopts, "link")) hugoopts$link <- x
    paste0(
      "\n{", "{<figure src=", '"', x, '" ',
      if (!is.null(hugoopts)) {
        glue::glue_collapse(
          glue::glue('{names(hugoopts)}="{hugoopts}"'),
          sep = " "
        )
      },
      ">}}\n"
    )
  }
)

# Fold entire chunk incl output ----
# https://github.com/cpsievert/plotly_book/blob/a95fb991fdbfdab209f5f86ce1e1c181e78f801e/index.Rmd#L52-L60
knitr::knit_hooks$set(
  chunk_fold = function(before, options, envir) {
  if (length(options$chunk_fold)) {
    if (before) {
      return(sprintf("<details><summary>Click to expand: %s</summary>\n\n", options$summary))
    } else {
      return("\n</details>")
    }
  }
}
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
