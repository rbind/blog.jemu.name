---
layout: post
title: "Quickly Compare your TV show ratings to trakt.tv"
date: 2015-04-18 21:48
comments: true
categories: [rstats, tvshows, trakt]
published: true
   
---

```r Me vs. trakt.tv
library(tRakt) # install via devtools::install_github("jemus42/tRakt")
library(dplyr)
library(tidyr)
library(ggplot2)

get_trakt_credentials(username = "Your Username")

slug <- "dig" # Slug from trakt.tv show url

trakt.user.ratings(type = "episodes") %>%
  filter(show.slug == slug) %>%
  arrange(season, episode) %>%
  select(rating, season, episode, title) %>%
  mutate(season = factor(season, ordered = T)) %>%
  rename(user.rating = rating) %>%
  left_join((trakt.get_all_episodes(slug) %>% select(rating, title, epnum))) %>%
  gather("type", value = "rating", user.rating, rating) %>%
  ggplot(data = ., aes(x = epnum, y = rating, colour = type)) +
  geom_point(size = 6, colour = "black") +
  geom_point(size = 5) +
  ylim(c(5, 10)) +
  scale_colour_discrete(labels = c("My Rating", "Trakt.tv Rating")) +
  labs(title = "Dig: Trakt.tv Ratings vs. My Own",
       x = "Absolute Episode Number", y = "Rating (0-10)", colour = "Source")

```

The result looks like this:

![](http://stats.jemu.name/tvshows/me_vs_trakt_dig.png)

Make sure to change the `labs` title for the plot title, and if necessary also the `ylim` settings.
