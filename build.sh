#! /usr/local/bin/bash

# rm -r public

Rscript -e 'blogdown::build_site()'

rsync -avz --delete public/ mercy:/srv/blog.jemu.name/public/
