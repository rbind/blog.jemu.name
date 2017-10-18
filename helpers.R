#### Helper functions ####

# Convert a plot to multiple formats

convert_plots <- function(filename) {
  library(magick)
  library(stringr)

  plot_orig <- image_read(filename)
  plot_webp <- image_convert(plot_orig, "webp")
  #plot_png  <- image_convert(plot_orig,  "png")

  file_noext <- str_replace(filename, "[a-z]{2,3}$", "")

  #
  image_write(plot_webp, path = paste0(file_noext, ".webp"))
  #image_write(plot_png,  path = paste0(file_noext, ".png"), flatten = F)

}

# A modified plot hook

hook <- function(x, options) {
  require(glue)

  width <- height <- ''
  if (!is.null(options$out.width))
    width <- sprintf(' width = "%s" ', options$out.width)
  if (!is.null(options$out.height))
    height <- sprintf(' height = "%s" ', options$out.height)

  basename <- paste0(knitr::opts_knit$get('base.url'), paste(x, collapse = '.'))
  filename <- paste0("../../../post/", basename)
  filename_webp <- stringr::str_replace(filename, "\\.png$", "\\.webp")
  id       <- stringr::str_extract(x, "^[^\\/]*")

  if (!is.null(options$fig.cap)) {
    caption <- options$fig.cap
  } else {
    caption <- opts_current$get("label")
  }

  #convert_plots(basename)

  #paste0("<figure>", imglink, "<figcaption>", caption, "</figcaption></figure>")

  glue("<figure><picture>",
       "<source type='image/webp' srcset='{filename_webp}'>",
       "<a href='{filename}' class='fresco' data-fresco-caption='{caption}'
       data-fresco-group='{id}' data-lightbox='{id}' data-title='{caption}'>",
       "<img src='{filename}' {width} {height} alt='{caption}' />",
       "</a></picture>",
       "<figcaption>{caption}</figcaption>",
       "</figure>")

}
