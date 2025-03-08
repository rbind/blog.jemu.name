---
title: Create A Backup Script for Your R Packages
description: "Having to re-install a lot of packages is annoying, and this is at least one possibility to help you along the way"
author: jemus42
date: '2017-11-15'
slug: create-a-backup-script-for-your-r-packages
toc: false
categories: 
  - R
tags:
  - Packages
  - Maintenance
  - Backup
packages:
  - glue
---

{{< addendum title="Note" >}}
This is overly convoluted and you might as well do [what Patrick does](https://twitter.com/pjs_228/status/1398553952526950403)
{{< /addendum >}}

So today I was playing around with the `installed.packages()` function, and I thought to myself:  
Boy wouldn't it be a jolly good time to make some kind of backup script from this?

The idea is simple: R has a major/minor version update, possibly breaking your previously installed packages. 
You could just copy the old packages over (risking more breakage), or use a custom library location that's version-independent (this is what I used to do), but sooner or later you might find that things have crashed so hard it's better to burn it all down than try to pick up the pieces.  
This is where the aptly named [*clean slate protocol*](https://rud.is/b/2017/06/10/engaging-the-tidyverse-clean-slate-protocol/) comes in.  

To do this, you throw away your current R installation, or at least your current library, and reinstall *all the things again*. You might want to reinstall everything step by step as needed, but that would be silly.  
This is where my (presumably wholly unoriginal) idea comes in, and I present to you a simple piece of R code that will generate an R script that will reinstall all your packages.  

```r
# Get packages, sort alphabetically for minor convenience later
pkgs  <- sort(rownames(installed.packages()))

# Assemble script
scrpt <- glue::glue(
  "if (!('{pkgs}' %in% installed.packages())) ",
  "install.packages('{pkgs}')"
)

# Write to file
writeLines(scrpt, con = glue::glue("R-{R.version$major}.{R.version$minor}-package-reinstall.R"))
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

Note how I make use of `installed.packages()` again to make sure to not repeatedly install and re-install packages that might have already been installed as a dependency of a previous package.  

And yes, this will only work for CRAN packages or packages available in one of the repositories you set via `options("repos")`. If you rely on GitHub or local packages in production, I'll just assume you're aware of that and act accordingly, but that's out of the scope of this little thing. If you want *proper* package reproducibility and whatnot, you're probably better of using a *proper package management thing* like… ~~`packrat`~~ `renv`? Microsoft's MRAN and snapshot stuff? I don't know.  
I just did this little thing.  
Don't @ me.

Sooo… that's what I did this evening.  
Just wanted to share that.

**EDIT** 2020-04-25: With R 4.0 released the other day and this post being aptly relevant, I updated it mildly. Nothing major.
