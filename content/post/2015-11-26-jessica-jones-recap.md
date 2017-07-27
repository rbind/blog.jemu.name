---
title: Jessica Jones recap
author: jemus42
date: '2015-11-26'
categories:
  - rstats
  - tvshows
tags: ~
---

So I've been watching Marvel's Jessica Jones over the past couple days, as one does, and I have opinions and stuff about it. However, since I believe that a plot is worth more than word stuff, I present to you my viewing expierence in data.

<!--more-->

``` r
library(tRakt)  # devtools::install_github("jemus42/tRakt")
library(ggplot2)
library(scales)
library(tidyr)
library(dplyr)
library(rvest)

seriesinfo <- trakt.search("jessica jones")
```

Watch Progress
--------------

``` r
mywatches <- trakt.user.watched(type = "shows.extended")

mywatches %>% 
  filter(title == seriesinfo$title) %>%
  mutate(date  = as.POSIXct(format(last_watched_at, "%F")),
         total = seq_along(title)) %>%
  ggplot(aes(x = last_watched_at, y = total)) +
  geom_area(alpha = 0.7) +
  geom_point() +
  geom_smooth(method = lm, se = F) +
  scale_x_datetime(breaks = date_breaks("days"), minor_breaks = date_breaks("hours")) +
  labs(title = paste0(seriesinfo$title, " Watch Progress"), 
       x = "Time Watched (hourly grid)", 
       y = "Total Number of Episodes Watched")
```

![](/images/jessicajones_watchprog-1.png)

trakt.tv vs IMDb
----------------

``` r
seriesinfo$ids$imdb %>%
  paste0("http://www.imdb.com/title/", . , "/epdate") %>%
  read_html %>% 
  html_table %>% 
  magrittr::extract2(1) %>%
  cbind(trakt.get_all_episodes(seriesinfo$ids$slug)) %>%
  rename(rating.trakt = rating, rating.imdb = UserRating) %>%
  gather(source, rating, rating.trakt, rating.imdb) %>%
  ggplot(data = ., aes(x = episode, y = rating, colour = source)) +
  geom_point(size = 6, colour = "black") +
  geom_point(size = 5) +
  facet_grid(. ~ season, scales = "free_x", labeller = label_both) +
  scale_colour_manual(labels = c("trakt.tv", "IMDb"), values = c("red", "yellow")) +
  labs(title = paste0(seriesinfo$title, "\nRatings on trakt.tv vs. IMDb"), x = "Episode", y = "Rating",
       colour = "Source")
```

![](/images/jessicajones_traktvsme-1.png)

My Ratings vs. trakt.tv Ratings
-------------------------------

``` r
slug <- seriesinfo$ids$slug

trakt.user.ratings(type = "episodes") %>%
  filter(show.slug == slug) %>%
  arrange(season, episode) %>%
  select(rating, season, episode, title) %>% 
  mutate(season = factor(season, ordered = T)) %>%
  rename(user.rating = rating) %>%
  left_join((trakt.get_all_episodes(slug) %>% select(rating, title, epnum))) %>%
  gather("type", value = "rating", user.rating, rating) %>%
  ggplot(aes(x = episode, y = rating, colour = type)) +
  geom_point(size = 6, colour = "black") +
  geom_point(size = 5) +
  ylim(c(5, 10)) +
  scale_colour_discrete(labels = c("My Rating", "Trakt.tv Rating")) +
  scale_x_discrete(breaks = scales::pretty_breaks()) +
  labs(title = paste0(seriesinfo$title, ": Trakt.tv Ratings vs. My Own"),
       x = "Absolute Episode Number", y = "Rating (0-10)", shape = "Source", colour = "Source")
```

![](/images/jessicajones_mevstrakt-1.png)
