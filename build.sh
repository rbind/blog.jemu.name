#! /usr/bin/env bash

# rm -r public

Rscript -e 'renv::restore()'
Rscript -e 'blogdown::install_hugo(version = "0.65.3")'
Rscript -e 'blogdown::build_site()'

#echo "----------------"
#echo "Syncing public/ to server..."
#find . -name '.DS_Store' -delete
#rsync -rltvz --delete public/ mercy:/srv/blog.jemu.name/public/

echo "----------------"
echo "Done with things"
date +"%F %H:%M:%S"

