#! /usr/bin/env bash

PATH=$HOME/bin:$PATH
echo $PATH

HUGO_VERSION_HAVE=$(hugo version)
HUGO_VERSION_HAVE=$(echo -e "${HUGO_VERSION_HAVE}")

HUGO_VERSION_WANT=0.66.0

if [ "$HUGO_VERSION_HAVE" -ne "$HUGO_VERSION_HAVE" ]; then
    echo "Hugo versions mismatch";
    echo "Current: $HUGO_VERSION_HAVE"
    echo "Want: $HUGO_VERSION_WANT"
    exit;
fi

echo "##########################"
echo "# Restoring renv library #"
echo "##########################"
Rscript -e 'renv::restore()'

echo "##########################"
echo "# Installing Hugo        #"
echo "##########################"
Rscript -e "blogdown::install_hugo(version = $HUGO_VERSION_WANT, force = FALSE)"

echo "##########################"
echo "# Building site          #"
echo "##########################"
Rscript -e 'blogdown::build_site()'

echo "##########################"
echo "# Done! $(date +'%F %H:%M:%S')"
echo "##########################"
