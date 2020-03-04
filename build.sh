#! /usr/bin/env bash

echo "##########################"
echo "# Restoring renv library #"
echo "##########################"
Rscript -e 'renv::restore()'

echo "##########################"
echo "# Installing Hugo        #"
echo "##########################"
Rscript -e 'blogdown::install_hugo(version = "0.66.0", force = FALSE)'

echo "##########################"
echo "# Building site          #"
echo "##########################"
Rscript -e 'blogdown::build_site()'

echo "##########################"
echo "# Done! $(date +'%F %H:%M:%S')"
echo "##########################"
