---
title: Importing your Trakt.tv Movies to Letterboxd
author: jemus42
date: '2020-12-27'
slug: importing-your-trakt-tv-movies-to-letterboxd
categories: []
tags: 
  - trakt.tv
  - letterboxd
featured_image: ~
description: 'A quick overview on how to get your movie watch history and ratings out of trakt.tv and into letterboxd with R'
externalLink: ''
series:
  - R
packages: ''
toc: no
math: no
---



Every once in a while I'm reminded that [letterboxd](https://letterboxd.com/) exists, and it's more popular for movies than my beloved [trakt.tv](https://trakt.tv).
While my Plex-based setup can auto-scrobble movies to trakt, it can't do the same for letterboxd, so unless I manually check in and rate movies over there, it's not going to happen.  
Unless I can automate it, which is at least in some sense possible thanks to letterboxd's [import options](https://letterboxd.com/import/) where you can just chuck in a CSV file of your watched movies including your rating. 
Looking at [its documentation](https://letterboxd.com/about/importing-data/), I realized that shouldn't be too hard to reproduce using my {{< pkg "tRakt" >}} package to get my data out of trakt and into letterboxd, so here goes.

```r 
library(tRakt)
library(dplyr)

rated_movies <- user_ratings(user = "jemus42", type = "movies")

# whittle down for the importer
rated_movies <- rated_movies %>%
  select(
    Title = title,
    imdbID = imdb,
    rating10 = rating
  )
```

Now I have my ratings, but to fill out the diary entries with corresponding dates I need the  `WatchedDate` column --- I don't particularly care about having a complete / accurate movie watching history on both trakt _and_ letterboxd, but it's easy enough to get via the trakt API:

```r 
watched_movies <- user_watched(
  user = "jemus42",
  type = "movies"
)
```

Now just join the two datasets and here we go.

```r 
watched_movies %>%
  select(
    WatchedDate = last_watched_at,
    Title = title,
    imdbID = imdb
  ) %>%
  mutate(WatchedDate = as.Date(WatchedDate)) %>%
  left_join(rated_movies, by = c("imdbID", "Title")) %>%
  readr::write_csv(
    file = "trakt-movies-letterboxd.csv",
    quote_escape = "backslash"
  )
```

{{< figure src="https://dump.jemu.name/20201227151138-7zl8det8ymgaaov.png" alt="" caption="Seems to work fine as well." >}}


<details><summary>Click to expand: Session Info</summary>

```r 
sess <- sessioninfo::session_info()

sess$platform %>%
  unclass() %>%
  tibble::as_tibble() %>%
  t() %>%
  knitr::kable() %>%
  kableExtra::kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
<tbody>
  <tr>
   <td style="text-align:left;"> version </td>
   <td style="text-align:left;"> R version 4.0.3 Patched (2020-10-13 r79346) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> os </td>
   <td style="text-align:left;"> macOS Catalina 10.15.7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> system </td>
   <td style="text-align:left;"> x86_64, darwin17.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ui </td>
   <td style="text-align:left;"> X11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> language </td>
   <td style="text-align:left;"> (EN) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> collate </td>
   <td style="text-align:left;"> en_US.UTF-8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ctype </td>
   <td style="text-align:left;"> en_US.UTF-8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tz </td>
   <td style="text-align:left;"> Europe/Berlin </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 2020-12-27 </td>
  </tr>
</tbody>
</table>

```r 
sess$packages %>%
  tibble::as_tibble() %>%
  dplyr::select(package, version = ondiskversion, source) %>%
  knitr::kable() %>%
  kableExtra::kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> package </th>
   <th style="text-align:left;"> version </th>
   <th style="text-align:left;"> source </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> assertthat </td>
   <td style="text-align:left;"> 0.2.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> blogdown </td>
   <td style="text-align:left;"> 0.21 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bookdown </td>
   <td style="text-align:left;"> 0.21 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cli </td>
   <td style="text-align:left;"> 2.2.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> codetools </td>
   <td style="text-align:left;"> 0.2.18 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crayon </td>
   <td style="text-align:left;"> 1.3.4 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> curl </td>
   <td style="text-align:left;"> 4.3 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> digest </td>
   <td style="text-align:left;"> 0.6.27 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dplyr </td>
   <td style="text-align:left;"> 1.0.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ellipsis </td>
   <td style="text-align:left;"> 0.3.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> evaluate </td>
   <td style="text-align:left;"> 0.14 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fansi </td>
   <td style="text-align:left;"> 0.4.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> generics </td>
   <td style="text-align:left;"> 0.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> glue </td>
   <td style="text-align:left;"> 1.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> here </td>
   <td style="text-align:left;"> 1.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hms </td>
   <td style="text-align:left;"> 0.5.3 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> htmltools </td>
   <td style="text-align:left;"> 0.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> httr </td>
   <td style="text-align:left;"> 1.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> jsonlite </td>
   <td style="text-align:left;"> 1.7.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.3) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> knitr </td>
   <td style="text-align:left;"> 1.30 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lifecycle </td>
   <td style="text-align:left;"> 0.2.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lubridate </td>
   <td style="text-align:left;"> 1.7.9.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> magrittr </td>
   <td style="text-align:left;"> 2.0.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pillar </td>
   <td style="text-align:left;"> 1.4.7 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pkgconfig </td>
   <td style="text-align:left;"> 2.0.3 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> purrr </td>
   <td style="text-align:left;"> 0.3.4 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> R6 </td>
   <td style="text-align:left;"> 2.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rcpp </td>
   <td style="text-align:left;"> 1.0.5 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> readr </td>
   <td style="text-align:left;"> 1.4.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> renv </td>
   <td style="text-align:left;"> 0.12.3 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rlang </td>
   <td style="text-align:left;"> 0.4.9 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rmarkdown </td>
   <td style="text-align:left;"> 2.5 </td>
   <td style="text-align:left;"> CRAN (R 4.0.3) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rprojroot </td>
   <td style="text-align:left;"> 2.0.2 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstudioapi </td>
   <td style="text-align:left;"> 0.13 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sessioninfo </td>
   <td style="text-align:left;"> 1.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stringi </td>
   <td style="text-align:left;"> 1.5.3 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stringr </td>
   <td style="text-align:left;"> 1.4.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tibble </td>
   <td style="text-align:left;"> 3.0.4 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tidyselect </td>
   <td style="text-align:left;"> 1.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tRakt </td>
   <td style="text-align:left;"> 0.15.0.9000 </td>
   <td style="text-align:left;"> Github (jemus42/tRakt@786ba4d) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vctrs </td>
   <td style="text-align:left;"> 0.3.5 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> withr </td>
   <td style="text-align:left;"> 2.3.0 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xfun </td>
   <td style="text-align:left;"> 0.19 </td>
   <td style="text-align:left;"> CRAN (R 4.0.2) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> yaml </td>
   <td style="text-align:left;"> 2.2.1 </td>
   <td style="text-align:left;"> CRAN (R 4.0.0) </td>
  </tr>
</tbody>
</table>


</details>
