#! /usr/bin/env bash

# Hugo will be installed to ~/bin, translating to /etc/git-auto-deploy/bin
# Adding it to $PATH is kind of optional here, might as well call $HOME/bin/hugo in step 2
PATH=$HOME/bin:$PATH

# Desired hugo version in local setup
HUGO_VERSION_WANT="0.67.0"
# Getting current hugo version from itself and extracting the version string
HUGO_VERSION_HAVE=$(hugo version)
HUGO_VERSION_HAVE=$(echo -e "${HUGO_VERSION_HAVE:28:6}")

echo "Current PATH: $PATH"

echo ""
echo "##########################"
echo "# Restoring renv library #"
echo "##########################"
echo "Restoring renv itself (renv::restore(packages = 'renv'))"
echo ""
Rscript -e "renv::restore(packages = 'renv')"
echo "Restoring everything else (renv::restore())"
Rscript -e "renv::restore()"

echo ""
echo "##########################"
echo "# Checking Hugo          #"
echo "##########################"
echo ""
echo "Current hugo version is $HUGO_VERSION_HAVE"
echo "Desired hugo version is $HUGO_VERSION_WANT"

if [[ "$HUGO_VERSION_HAVE" == "$HUGO_VERSION_WANT" ]]; then
    echo "Hugo $HUGO_VERSION_WANT is already installed"
else
    echo "Hugo versions mismatch: Have: $HUGO_VERSION_HAVE - want: $HUGO_VERSION_WANT"
    echo "Installing hugo"
    echo Rscript -e "blogdown::install_hugo(version = \"$HUGO_VERSION_WANT\", force = TRUE)"
fi

# echo "Nuking /public"
# rm -rf public

echo ""
echo "##########################"
echo "# Building site          #"
echo "##########################"
Rscript -e "blogdown::build_site(run_hugo = FALSE)"
hugo --minify

echo ""
echo "##########################"
echo "# Done! $(date +'%F %H:%M:%S')"
echo "##########################"
