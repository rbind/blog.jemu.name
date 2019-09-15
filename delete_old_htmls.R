#! /usr/bin/env Rscript

library(tibble)
library(dplyr)

# Delete HTMLs of posts that have no source Rmd anymore (i.e. are deleted on purpose)
Rmds <- tibble(
  rmd = fs::dir_ls("content/post/", type = "file", glob = "*.Rmd*"),
  basename = stringr::str_remove(rmd, "\\.Rmd.*")
)

htmls <- tibble(
  html = fs::dir_ls("content/post/", type = "file", glob = "*html"),
  basename = stringr::str_remove(html, "\\.html$")
)

dplyr::full_join(Rmds, htmls, by = "basename") %>%
  dplyr::filter(is.na(rmd)) %>%
  dplyr::pull(html) %>%
  fs::file_delete()
