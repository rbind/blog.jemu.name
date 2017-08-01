---
author: jemus42
categories:
- rstats
tags:
- r-pkgs
packages:
- tRakt
date: 2015-02-23
title: Yay! tRakt is now on CRAN
---

As of today, I have my [first package published on CRAN](http://cran.r-project.org/web/packages/tRakt/index.html).  

In the grand scheme of things, that's not really a big deal, since CRAN doesn't have any quality standards regarding the content of a package, they just verify that the package can be installed and run without breaking horribly.

Still, I'm quite happy about this minor achievement. Not because I'm particularly proud of my package, but rather since I consider it as a small verification of my ongoing path to become an R developer that doesn't embarrass himself more than necessary.

As far as the functionality of my package is concerned, well. Consider the following:  

Most of the functions follow this basic template:

```r
trakt.show.related <- function(target){
  if (is.null(getOption("trakt.headers"))){
    stop("HTTP headers not set, see ?get_trakt_credentials")
  }
  ids <- NULL

  baseURL <- "https://api-v2launch.trakt.tv/shows"
  url     <- paste0(baseURL, "/", target, "/related")

  # Actual API call
  response <- trakt.api.call(url = url)

  # Flattening
  response <- cbind(subset(response, select = -ids), response$ids)

  return(response)
}
```

That's about 80% of the package, with minor variations here and there. The most complex functions is probably `trakt.user.watched`, clocking in at about 100 lines of code, including `roxygen2` documentation.  
That's still not really a big one, but oh well.

I guess it just illustrates the nature of my package:  
I did it for

* Convenience
* Curiosity
* The lulz

And now I've got the CRAN link to prove it.  

And that's about it.  
So please, if you are interested in TV shows, movies, [trakt.tv](https://trakt.tv) and R, you're welcome to check it out and [leave an issue or two](https://github.com/jemus42/tRakt/issues).
