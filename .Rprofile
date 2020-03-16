if (file.exists('~/.Rprofile')) sys.source('~/.Rprofile', envir = environment())

# Init renv _after_ user Rprofile to avoid problems. Like renv not working.
source("renv/activate.R")

options(
    servr.port = 4321L,
    blogdown.author = "jemus42",
    blogdown.generator.server = TRUE,
    blogdown.hugo.server = c("-D", "-F", "--navigateToChanged")
)
