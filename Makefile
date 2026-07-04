server:
	Rscript -e "blogdown::hugo_server('localhost', '1314')"

stop-server:
	Rscript -e "blogdown::stop_server()"

build:
	Rscript -e "blogdown::build_site()"

# Create a new post as a page bundle. Usage:
#   make post title="My Post Title"       -> content/posts/DATE-slug/index.md
#   make post-rmd title="My Post Title"   -> ...index.Rmarkdown (knitr scaffold)
post:
	./newpost "$(title)"

post-rmd:
	./newpost --rmd "$(title)"

# Provision a fresh yolobox/Linux box: blogdown + pinned extended Hugo.
# Run once per new sandbox (see R/setup-sandbox.R). Idempotent.
sandbox-setup:
	Rscript R/setup-sandbox.R
