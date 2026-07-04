# https://bookdown.org/yihui/blogdown/more-global-options.html
# https://bookdown.org/yihui/blogdown/global-options.html

options(
    servr.port = 4321L,
    blogdown.author = "jemus42",
    blogdown.ext = ".Rmarkdown",
    blogdown.subdir = "posts",
    blogdown.hugo.version = "0.163.3",
    blogdown.hugo.server = c("-D", "-F", "--navigateToChanged"),
    blogdown.knit.on_save = FALSE,
    blogdown.serve_site.startup = FALSE,
    #blogdown.files_filter = blogdown:::md5sum_filter,
    # other nice to haves!
    blogdown.title_case = TRUE,
    blogdown.initial_files = FALSE,
    # nice defaults!
    blogdown.new_bundle = TRUE,
    blogdown.warn.future = TRUE,
    blogdown.draft.output = FALSE
)

rprofile <- Sys.getenv("R_PROFILE_USER", "~/.Rprofile")

if (file.exists(rprofile)) {
  source(file = rprofile)
}
rm(rprofile)
