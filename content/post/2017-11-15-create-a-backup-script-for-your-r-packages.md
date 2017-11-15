---
title: Create A Backup Script for Your R Packages
author: jemus42
date: '2017-11-15'
slug: create-a-backup-script-for-your-r-packages
categories:
  - rstats
tags:
  - packages
  - maintenance
  - backup
enable_mathjax: no
enable_katex: no
---

So today I was playing around with the `installed.packages()` function, and I thought to myself:  
Boy wouldn't it be a jolly good time to make some kind of backup script from this?

The idea is simple: R has a minor version update, possibly breaking your previously installed packages. 
You could just copy the old packages over, or use a custom library location that's version-indepent (this is what I do), but sooner or later you might find that thinks have crashed so hard it's better to burn it all down than try to pick up the pieces.  
This is where the aptly named [*clean slate protocol*](https://rud.is/b/2017/06/10/engaging-the-tidyverse-clean-slate-protocol/) comes in.  

To do this, you throw away your current R installation or at least your current library and reinstall *all the things again*. You might want to reinstall everything step by step as needed, but that would be silly.  
This is where my idea comes in, and I present to you a simple piece of R code that will generate an R script that will reinstall all your packages.  

```r
pkgs  <- rownames(installed.packages()) # Get packages
scrpt <- glue::glue("if (!('[pkgs]' %in% installed.packages())) ",
                    "install.packages('[pkgs]')",
                    .open = "[", .close = "]") # Assemble script

writeLines(scrpt, con = "package-reimport.R") # Write to file
```

It will look something like this:

```r
if (!('abind' %in% installed.packages())) install.packages('abind')
...
if (!('psych' %in% installed.packages())) install.packages('psych')
if (!('purrr' %in% installed.packages())) install.packages('purrr')
...
if (!('strengejacke' %in% installed.packages())) install.packages('strengejacke')
if (!('stringdist' %in% installed.packages())) install.packages('stringdist')
if (!('stringi' %in% installed.packages())) install.packages('stringi')
if (!('stringr' %in% installed.packages())) install.packages('stringr')
...
```

You get the idea.  

Note how I make use of `installed.packaged()` again to make sure to not repeatedly install and re-install packages that might have already been installed as a dependency of a previous package.  

Sooo… that's what I did this evening.  
Just wanted to share that.
