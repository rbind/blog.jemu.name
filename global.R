# Global things sourced in each blogpost

library(ggplot2)
library(dplyr)
library(knitr)
library(tadaatoolbox)

# Hugo config
config_toml <- RcppTOML::parseTOML("config.toml")

# Global chunk options
knitr::opts_chunk$set(out.width = "100%",
                      fig.retina = 2,
                      warning = F,
                      message = F,
                      comment = "")

ggplot2::theme_set(tadaatoolbox::theme_tadaa())

#### Plot output ####

hook <- function(x, options) {
  width <- height <- ''
  if (!is.null(options$out.width))
    width <- sprintf(' width = "%s" ', options$out.width)
  if (!is.null(options$out.height))
    height <- sprintf(' height = "%s" ', options$out.height)

  filename <- paste0("../../../post/", knitr::opts_knit$get('base.url'), paste(x, collapse = '.'))
  basename <- stringr::str_replace(x, ".*\\/", "")
  id       <- stringr::str_extract(x, "^[^\\/]*")

  if (!is.null(options$fig.cap)) {
    caption <- options$fig.cap
  } else {
    caption <- opts_current$get("label")
  }

  img     <- paste0("<img src='", filename, "'", width, height, "alt='' />")
  imglink <- paste0("<a href='", filename, "' ",
                     "class = 'swipebox fresco' ",
                     "data-lightbox='", id, "' ",
                     "data-title='", caption, "' ",
                     "data-fresco-caption='", caption, "' ",
                     "data-fresco-group='", id, "' ",
                     ">", img, "</a>")

  paste0("<figure>", imglink, "<figcaption>", caption, "</figcaption></figure>")
}

knitr::knit_hooks$set(plot = hook)
