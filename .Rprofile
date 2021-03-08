# if (file.exists('~/.Rprofile')) sys.source('~/.Rprofile', envir = environment())

# Init renv _after_ user Rprofile to avoid problems. Like renv not working.
source("renv/activate.R")

# See
# https://bookdown.org/yihui/blogdown/more-global-options.html
# https://bookdown.org/yihui/blogdown/global-options.html

options(
    servr.port = 4321L,
    blogdown.author = "jemus42",
    blogdown.ext = ".Rmarkdown",
    blogdown.subdir = "posts",
    blogdown.hugo.version = "0.79.0",
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

# Unset client secret so tRakt won't try authorization
Sys.setenv("trakt_client_secret" = "")

rprofile <- Sys.getenv("R_PROFILE_USER", "~/.Rprofile")

if (file.exists(rprofile)) {
  source(file = rprofile)
}
rm(rprofile)
