#! /usr/bin/env bash

# Hugo will be installed to ~/bin, translating to /etc/git-auto-deploy/bin
PATH=$HOME/bin:$PATH

HUGO_VERSION_WANT="0.66.0"
HUGO_VERSION_HAVE=$(hugo version)
HUGO_VERSION_HAVE=$(echo -e "${HUGO_VERSION_HAVE:28:6}")

echo "Current PATH: $PATH"
echo ""
echo "##########################"
echo "# Restoring renv library #"
echo "##########################"
Rscript -e "renv::restore()"

echo ""
echo "##########################"
echo "# Checking Hugo          #"
echo "##########################"

if [ "$HUGO_VERSION_HAVE" != "$HUGO_VERSION_HAVE" ]; then
    echo "Hugo versions mismatch";
    echo "Current: $HUGO_VERSION_HAVE"
    echo "Want: $HUGO_VERSION_WANT"
    echo "Installing hugo"
    Rscript -e "blogdown::install_hugo(version = \"$HUGO_VERSION_WANT\", force = FALSE)"
else
    echo "Hugo $HUGO_VERSION_WANT is already installed";
fi

echo ""
echo "##########################"
echo "# Building site          #"
echo "##########################"
Rscript -e "blogdown::build_site()"

echo ""
echo "##########################"
echo "# Done! $(date +'%F %H:%M:%S')"
echo "##########################"
