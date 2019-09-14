#! /usr/local/bin/bash

rm -r public

Rscript -e 'blogdown::build_site()'

echo "----------------"
echo "Syncing public/ to server..."
find . -name '.DS_Store' -delete
# rsync -avz --delete public/ mercy:/srv/blog.jemu.name/public/

echo "----------------"
echo "Done with things"
date +"%F %H:%M:%S"

