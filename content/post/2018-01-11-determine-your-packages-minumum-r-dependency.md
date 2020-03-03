---
title: Determine Your Packages Minumum R Dependency
author: jemus42
date: '2018-01-11'
slug: determine-your-packages-minumum-r-dependency
tags:
  - rstats
  - packages
draft: no
---

So the other day I was wondering how I could determine the minimum R version I *technically* need to depend on in my R package, `tadaatoolbox`. Naturally, I asked `#rstats`, and I got [a neat suggestion](https://twitter.com/kevin_ushey/status/951132312002899968) which I implemented hastily like this:

```r
library(stringr)
library(purrr)
library(desc)
library(dplyr)

# Get vector of package dependencies
deps <- tools::package_dependencies("tadaatoolbox")[[1]]
# Remove base packages
deps <- deps[!(deps %in% getOption("defaultPackages"))]

deptbl <- map_df(deps, ~{
  # Parse package DESCRIPTION file
  descr   <- system.file("DESCRIPTION", package = .x)
  # Get the "Depends" field
  depends <- desc_get("Depends", descr)[[1]]

  # Pack together
  tibble(package = .x, depends = depends)
})

# Extract R version number, sort, print
deptbl %>%
  mutate(depends = str_extract(depends, "(\\d+\\.)?(\\d+\\.)?(\\*|\\d+)")) %>%
  arrange(desc(depends)) %>%
  knitr::kable()
```

|package   |depends |
|:---------|:-------|
|DescTools |3.3.1   |
|car       |3.2.0   |
|pixiedust |3.1.2   |
|ggplot2   |3.1     |
|viridis   |2.10    |
|broom     |NA      |
|magrittr  |NA      |
|pwr       |NA      |
|nortest   |NA      |


So, now I have a neat little table.  
Couple things to note:

Current R-devel doesn't like you to depend on an R version with a non-zero patch-level, i.e. you should depend on `R (>= 3.2.0)` rather than `R (>= 3.2.1)`.  
So even if I want to be safe and depend on the highest dependency in the list (`DescTools` with `R (>= 3.3.1)`), I can only really depend on `R (>= 3.3.0)` and wait for `DescTools` to comply with the new rules.  
The next thing that irks me is that `DescTools` has such a high dependency, and I couldn't find out why that has to be or if the devs were just taking the easy route on that one. Since I can't find the package on GitHub, I guess I won't be able to easily find that out since I can't file an issue anywhere.  

Lastly, I was surprised that packages like `broom` or `nortest` don't even explicitly depend on any specific R version, I did not know that's an option. Or if it was an option, I would have assumed it's discouraged.

So maybe my desire do "depend properly" is totally meaningless anyway and I just should let it go.  
So that's what I'll do for now.

EDIT: 

You might also be interested in [this discussion](https://community.rstudio.com/t/determining-which-version-of-r-to-depend-on/4396/13) on <community.rstduio.com> about whether or not this is a good approach, and what else you might want to do to ensure you depend meaningfully.
