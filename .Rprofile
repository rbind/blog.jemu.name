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
    blogdown.generator.server = TRUE,
    blogdown.hugo.server = c("-D", "-F", "--navigateToChanged")
)
