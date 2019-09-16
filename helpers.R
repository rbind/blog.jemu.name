#### Helper functions ####

# A modified plot hook ----
# Needed to wrap knitr plot output in semantic html tags
# which in turn is required for photoswipe.js in beautifulhugo

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

  glue(
    "<figure>
      <picture>
        <source type='image/webp' srcset='{filename_webp}'>
        <a href='{filename}' data-title='{caption}'>
          <img src='{filename}' {width} {height} alt='{caption}' />
        </a></picture>
      <figcaption>{caption}</figcaption>
    </figure>"
  )

}

# Caching datasets ----

# Set post-specific cache directiory, create if needed
# Use at beginning of post
# Might take rmarkdown::metadata$slug as input dynamically
make_cache_path <- function(post_slug = "misc") {

  cache_path <- here::here(file.path("datasets", post_slug))

  if (!file.exists(cache_path)) dir.create(cache_path)

  return(cache_path)
}

#' Check if file is not cached
#' @param cache_path As returned by make_cache_path
#' @param cache_data Bare name of data to cache
#' @example
#' if (file_note_cache(cache_path, bigdata)) {
#'   { do expensive stuff }
#' }
file_not_cached <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  !(file.exists(file.path(cache_path, filename)))
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
