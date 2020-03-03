#! /usr/bin/env bash

# rm -r public

# Debugging
echo which pandoc
which pandoc
echo where pandoc
where pandoc
echo pandoc version
pandoc --version

echo "##########################"
echo "# Restoring renv library #"
echo "##########################"
Rscript -e 'renv::restore()'

echo "##########################"
echo "# Installing Hugo        #"
echo "##########################"
Rscript -e 'blogdown::install_hugo(version = "0.65.3")'

echo "##########################"
echo "# Building site          #"
echo "##########################"
Rscript -e 'blogdown::build_site()'

echo "##########################"
echo "# Done! $(date +'%F %H:%M:%S')"
echo "##########################"
