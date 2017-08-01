---
author: Jemus42
categories:
- rstats
tags:
- r-pkgs
packages:
- tRakt
date: 2015-02-16
title: Introducing tRakt
---

It's been a while since I started working on a set of functions to pull data from [trakt.tv](http://trakt.tv). I documented part of the early process in [an earlier blogpost](http://blog.quantenbrot.de/2014/06/05/i-just-wanted-to-rewatch-stargate/), and since then I started aggregating my work into a proper package.

Since trakt launched their new APIv2, I started to rewrite and ehance the package a little, also solidifying the whole authentication business. I have not implemented any OAuth2 methods, but since the purpose of this package is to pull a bunch of data and not to perform actions like checkins, I don't think it's a big deal.  
My main use for this package remains my [shiny app](https://github.com/jemus42/tRakt-shiny) built around it, so I tend to tailor the package around these specific needs.


## Installation and setup

```r title:'Getting started'
if (!require("devtools")){
  install.packages("devtools")
} 
devtools::install_github("jemus42/tRakt")
library("tRakt")
```

If you have a `key.json` with your client.id and/or username ready, you're already good to go.  
Otherwise, try this:

```r
get_trakt_credentials(client.id = "12fc1de7671c7f2fb4a8ac08ba7c9f45b447f4d5bad5e11e3490823d629afdf2",
username = "yourusername")
```


## Let's pull some data

### Search

There are two ways to search on trakt.tv. The first is via text query (i.e. `Game of Thrones`),
the second is via ID (various types supported).  

At the time of this writing (2015-02-16), the trakt.tv search is a little derpy, so search by ID is recommended.


```r title:'Getting data'
# Search via text query
show1  <- trakt.search("Game of Thrones")

# Search via ID (trakt id is used by default)
show2 <- trakt.search.byid(1390) # trakt id of Game of Thrones

# The returned data is identical
identical(show1, show2)
```

```
## [1] TRUE
```

### Getting more data


```r
# Search a show and receive basic info
show          <- trakt.search("Breaking Bad")
# Save the slug of the show, that's needed for other functions as an ID
slug          <- show$ids$slug
slug
```

```
## [1] "breaking-bad"
```

```r
# Get the season & episode data
show.seasons  <- trakt.getSeasons(slug) # How many seasons are there?
show.episodes <- trakt.getEpisodeData(slug, show.seasons$season, extended = "full")

# Glimpse at data (only some columns each)
rownames(show.seasons) <- NULL # This shouldn't be necessary
show.seasons[c(1, 3, 4)]
```



| season|  rating| votes|
|------:|-------:|-----:|
|      1| 8.44355|   124|
|      2| 9.01961|   102|
|      3| 8.93000|   100|
|      4| 9.21739|    92|
|      5| 9.23913|    92|

```r
show.episodes[c(1:3, 6, 7, 17)] %>% head(10)
```



|season | episode|title                         |  rating| votes|firstaired.string |
|:------|-------:|:-----------------------------|-------:|-----:|:-----------------|
|1      |       1|Pilot                         | 8.67205|  2540|2008-01-21        |
|1      |       2|Cat's in the Bag...           | 8.47242|  1922|2008-01-28        |
|1      |       3|...And the Bag's in the River | 8.36136|  1760|2008-02-11        |
|1      |       4|Cancer Man                    | 8.33920|  1704|2008-02-18        |
|1      |       5|Gray Matter                   | 8.29345|  1663|2008-02-25        |
|1      |       6|Crazy Handful of Nothin'      | 8.90687|  1761|2008-03-03        |
|1      |       7|A No-Rough-Stuff-Type Deal    | 8.69036|  1702|2008-03-10        |
|2      |       1|Seven Thirty-Seven            | 8.48705|  1622|2009-03-09        |
|2      |       2|Grilled                       | 8.71402|  1612|2009-03-16        |
|2      |       3|Bit by a Dead Bee             | 8.27689|  1506|2009-03-23        |

## Some example graphs

Plotting the data is pretty straight forward since I try to return regular `data.frames` without 
unnecessary ambiguity.

Here is some code to plot the episode ratings over time:

```r
show.episodes$episode_abs <- 1:nrow(show.episodes) # I should probably do that for you.
show.episodes %>%
  ggplot(aes(x = episode_abs, y = rating, colour = season)) +
    geom_point(size = 3.5, colour = "black") +
    geom_point(size = 3) + 
    geom_smooth(method = lm, se = F) +
    labs(title = "Trakt.tv Ratings of Breaking Bad", 
         y = "Rating", x = "Episode (absolute)", colour = "Season")
```

And now the votes per episode:

```r
show.episodes %>%
  ggplot(aes(x = episode_abs, y = votes, colour = season)) +
    geom_point(size = 3.5, colour = "black") +
    geom_point(size = 3) + 
    labs(title = "Trakt.tv User Votes of Breaking Bad Episodes", 
         y = "Votes", x = "Episode (absolute)", colour = "Season")
```

And now we go all statistic-y and use `scale`'d ratings:

```r
show.episodes %>%
  ggplot(aes(x = episode_abs, y = scale(rating), fill = season)) +
    geom_bar(stat = "identity", colour = "black", position = "dodge") +
    labs(title = "Trakt.tv User Ratings of Breaking Bad Episodes\n(Scaled using mean and standard deviation)", 
         y = "z-Rating", x = "Episode (absolute)", fill = "Season")
```

## Now some user-specific data

User-specific functions (`trakt.user.*`) default to `user = getOption("trakt.username")`, which
should have been set by `get_trakt_credentials()`, so you get your own data per default.  
However, you can specifiy any publicly available user. Note that OAuth2 is not supported, so 
by "publicly available user", I really mean only non-private users.

```r
myeps    <- trakt.user.watched(user = "jemus42", type = "shows.extended")

# Get a feel for the data
myeps[c(1:4, 6:7)] %>% 
  arrange(desc(lastwatched.posix)) %>% 
  head(5)
```

|title           | season| episode| plays|lastwatched.posix   | lastwatched.year|
|:---------------|------:|-------:|-----:|:-------------------|----------------:|
|Game of Thrones |      2|       5|     2|2015-02-16 07:06:50 |             2015|
|Game of Thrones |      2|       4|     2|2015-02-16 05:53:45 |             2015|
|Game of Thrones |      2|       3|     2|2015-02-16 04:22:19 |             2015|
|Game of Thrones |      2|       2|     2|2015-02-16 02:52:07 |             2015|
|Game of Thrones |      2|       1|     2|2015-02-16 00:55:29 |             2015|

…and the movies in my trakt.tv collection

```r
mymovies <- trakt.user.collection(user = "jemus42", type = "movies")

mymovies %>%
  select(title, year, collected.posix) %>%
  arrange(collected.posix) %>%
  head(5)
```

|title                      | year|collected.posix     |
|:--------------------------|----:|:-------------------|
|Howl's Moving Castle       | 2004|2013-09-24 00:11:02 |
|Stargate: Continuum        | 2008|2013-09-29 07:23:57 |
|Stargate: The Ark of Truth | 2008|2013-09-29 07:24:01 |
|Stargate                   | 1994|2013-09-29 07:24:03 |
|Fight Club                 | 1999|2013-09-29 07:38:59 |


## Yaaay

Feel free to check out the code on
[GitHub](https://github.com/jemus42/tRakt), and if you find any bugs or have requests, [you know the drill](https://github.com/jemus42/tRakt/issues)
