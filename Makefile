server:
	Rscript -e "blogdown::hugo_server('localhost', '1314')"

stop-server:
	Rscript -e "blogdown::stop_server()"

build:
	Rscript -e "blogdown::build_site()"
