# Global things sourced in each blogpost

library(ggplot2)
library(dplyr)
library(knitr)
library(tadaatoolbox)

# Global chunk options
knitr::opts_chunk$set(out.width = "90%",
                      fig.retina = 2,
                      warning = F,
                      message = F)

ggplot2::theme_set(tadaatoolbox::theme_tadaa())

#### Plot output ####

hook <- function(x, options) {
  width <- height <- ''
  if (!is.null(options$out.width))
    width <- sprintf(' width = "%s" ', options$out.width)
  if (!is.null(options$out.height))
    height <- sprintf(' height = "%s" ', options$out.height)

  filename <- paste0("../../../post/", knitr::opts_knit$get('base.url'), paste(x, collapse = '.'))

  if (!is.null(options$fig.cap)) {
    caption <- paste0("<figcaption>", options$fig.cap, "</figcaption>")
  } else {
    caption <- NULL
  }
  plot_id <- paste0(paste0(sample(c(letters, LETTERS),
                                  size = 5, replace = T), collapse = ""),
                    caption)

  img <- paste0("<img src='", filename, "' ", width, height, " alt='' />")
  lightbox <- paste0("<a href='", filename, "' ",
                     "data-lightbox='", plot_id, "' data-title='", plot_id, "'>",
                     img, "</a>")

  figure <- paste0("<figure>", lightbox, caption, "</figure>")

  return(figure)

}

knitr::knit_hooks$set(plot = hook)
