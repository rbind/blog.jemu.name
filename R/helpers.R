#### Helper functions ####

# knitr hooks ----

# Wrap source code in hugo highlight shortcode
hook_source <- function(x, options) {
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


# Hugo plot hook ----
# see https://ropensci.org/technotes/2020/04/23/rmd-learnings/
hook_plot <- function(x, options) {
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

# Enable the code-hiding-via-summary-tags thing
# https://github.com/cpsievert/plotly_book/blob/a95fb991fdbfdab209f5f86ce1e1c181e78f801e/index.Rmd#L52-L60
hook_chunk_fold <- function(before, options, envir) {
  if (length(options$chunk_fold)) {
    if (before) {
      return(sprintf("<details><summary>Click to expand: %s</summary>\n\n", options$chunk_fold))
    } else {
      return("\n</details>")
    }
  }
}

# Caching datasets ----

is_cached <- function(x) {
  file.exists(x)
}

not_cached <- function(x) {
  !file.exists(x)
}

# Rendering singular posts -----

render_latest <- function(post_dir = "posts", clean = FALSE) {
  post_files <- fs::dir_ls(
    here::here("content", post_dir),
    recurse = TRUE,
    glob = "*.Rmarkdown"
  )
  post_mtime <- fs::file_info(post_files)$change_time
  latest_post <- post_files[which.max(post_mtime)]

  if (clean) {
    fs::dir_delete(here::here(fs::path_dir(latest_post), "plots"))
    fs::dir_delete(here::here(fs::path_dir(latest_post), "post_cache"))
    fs::file_delete(here::here(fs::path_dir(latest_post), "index.en.markdown"))
  }

  blogdown:::render_page(latest_post)
}
