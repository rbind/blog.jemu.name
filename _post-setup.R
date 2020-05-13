knitr::opts_chunk$set(
  fig.path = "", # for leaf bundles to work
  fig.retina = 2,
  echo = TRUE,
  message = FALSE, warning = FALSE, error = FALSE,
  fig.align = "center",
  out.width = "95%"
)

# knitr hook to use Hugo highlighting options
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

# plot output in .Rmarkdown
# see https://ropensci.org/technotes/2020/04/23/rmd-learnings/
knitr::knit_hooks$set(
  plot = function(x, options) {
    hugoopts <- options$hugoopts
    # Link image to itself if there's no explicit link set
    if (!hasName(hugoopts, "link")) hugoopts$link <- x
    paste0(
      "{", "{<figure src=", '"', x, '" ',
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

# cat(plot("my-image.png", list()))
# cat(plot("my-image.png", list()))

# hugoopts <- list(link = "mylink.png")

# Enable the code-hiding-via-summary-tags thing
# Shamelessly stolen from
# https://github.com/cpsievert/plotly_book/blob/a95fb991fdbfdab209f5f86ce1e1c181e78f801e/index.Rmd#L52-L60
knitr::hooks$set(
  summary = function(before, options, envir) {
  if (length(options$summary)) {
    if (before) {
      return(sprintf("<details><summary>Code: %s</summary>\n", options$summary))
    } else {
      return("\n</details>")
    }
  }
}
)

# Make chroma style

# chroma_gen <- function(style = "monokai") {
#   cmd <- glue::glue("hugo gen chromastyles --style={style} > static/css/syntax-{style}.css")
#   system(cmd)
# }

# chroma_gen("api")
# chroma_gen("fruity")
# chroma_gen("monokailight")
