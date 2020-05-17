---
title: A confused look at Nicolas Cage movies
author: jemus42
date: '2020-05-10'
slug: a-confused-look-at-nicolas-cage-movies
categories:
  - movies
tags:
  - trakt.tv
  - movies
  - Nicolas Cage
packages:
  - tRakt
  - tadaathemes
  - ggrepel
  - ggplot2
  - dplyr
  - kableExtra
draft: no
subtitle: 'Because I just watched Mandy and I need to work through it.'
description: ''
image: 'movies-ratings-1.png'
editor_options:
  chunk_output_type: console
---



The other day I watched [Mandy (2018)](https://trakt.tv/movies/mandy-2018), a confusing Nicolas Cage movie that feels like an odd fever dream.  
A few weeks ago, I watched [Color Out of Space (2020)](https://trakt.tv/movies/color-out-of-space-2020), a confusing Nicolas Cage movie that feels like an odd fever dream, based on the [Lovecraft story of the same name](https://www.hplovecraft.com/writings/texts/fiction/cs.aspx) which I read a couple weeks prior.  
So... yeah. That's why Nic Cage has been on my mind a little lately.

Additionally, I've been trying to fiddle around with {ggplot2} themes a little more, because relying on [{hrbrthemes}](https://hrbrmstr.github.io/hrbrthemes/index.html) alone felt a little unsatisfying, and I thought it was time to make a theme that fits trakt.tv reasonably well.  
And, while we're at it, I saw these great [{ggrepel} examples](https://ggrepel.slowkow.com/articles/examples.html#aesthetics-1) which is why I wanted to play around with {ggrepel} a little more.  

And that's where this post comes from, so here goes nothing.  

I'll start by loading all the things:

```r
library(tRakt) # jemus42/tRakt
library(tadaathemes) # tadaadata/tadaathemes for theme_trakt()
library(ggplot2)
library(ggrepel) # >= 0.9.0
library(dplyr)
library(kableExtra)

plot_caption <- "Data from trakt.tv // @jemus42"
```

To take a look at Cage's movies, I'll first need to find him on trakt.tv – which is easy enough through the search. Once I have his identifiers (I'll be using the `slug` because it's nice and human-readable), I can use `people_movies` to get, well, the *movies* of this particular ~~*people*~~ person.  

```r
search_query("Nicolas Cage", type = "person")
```

```
## # A tibble: 1 x 7
##   type   score name         trakt slug         imdb      tmdb 
##   <chr>  <dbl> <chr>        <chr> <chr>        <chr>     <chr>
## 1 person  159. Nicolas Cage 15197 nicolas-cage nm0000115 2963
```

```r
if (file.exists("cage_credits.rds")) {
  cage_credits <- people_movies("nicolas-cage", extended = "full")
  
  saveRDS(cage_credits, "cage_credits.rds")
} else {
  cage_credits <- readRDS("cage_credits.rds")
}

cage_movies <- cage_credits$cast %>% 
  filter(
    runtime >= 80, votes >= 10,
    !stringr::str_detect(character, "(uncredited)|(voice)|(Himself)")
  )
```

The returned objects is a `list` of two `tibble`s, named `cast` and `crew`. I'm only interested in the `cast` bit, and I'll filter out items where the character description indictaes Cage's role was uncredited, it's a voice role or he's playing himself [^himself]. I'll also exclude movies shorter than 80 minutes and those with less than 10 votes on trakt.tv, because I have to draw the line *somewhere*.

[^himself]: to which extent one might argue he's always kind of playing himself is a different story

```r
cage_movies %>%
  arrange(desc(released)) %>%
  head(10) %>%
  select(year, title, character, runtime, rating, votes) %>%
  kable(
    caption = "The 10 latest Nic Cage movies",
    col.names = c("Year", "Movie", "Role", "Runtime (mins)", "Rating", "Votes"),
    digits = 1
  ) %>%
  kable_styling(
    position = "center"
  )
```
<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Table 1: The 10 latest Nic Cage movies</caption>
 <thead>
  <tr>
   <th style="text-align:right;"> Year </th>
   <th style="text-align:left;"> Movie </th>
   <th style="text-align:left;"> Role </th>
   <th style="text-align:right;"> Runtime (mins) </th>
   <th style="text-align:right;"> Rating </th>
   <th style="text-align:right;"> Votes </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2020 </td>
   <td style="text-align:left;"> Kill Chain </td>
   <td style="text-align:left;"> Araña </td>
   <td style="text-align:right;"> 92 </td>
   <td style="text-align:right;"> 6.4 </td>
   <td style="text-align:right;"> 375 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2020 </td>
   <td style="text-align:left;"> Color Out of Space </td>
   <td style="text-align:left;"> Nathan Gardner </td>
   <td style="text-align:right;"> 111 </td>
   <td style="text-align:right;"> 6.4 </td>
   <td style="text-align:right;"> 1557 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019 </td>
   <td style="text-align:left;"> Primal </td>
   <td style="text-align:left;"> Frank Walsh </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 6.5 </td>
   <td style="text-align:right;"> 688 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019 </td>
   <td style="text-align:left;"> Grand Isle </td>
   <td style="text-align:left;"> Walter </td>
   <td style="text-align:right;"> 97 </td>
   <td style="text-align:right;"> 6.3 </td>
   <td style="text-align:right;"> 238 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019 </td>
   <td style="text-align:left;"> Running with the Devil </td>
   <td style="text-align:left;"> The Cook </td>
   <td style="text-align:right;"> 100 </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> 1036 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019 </td>
   <td style="text-align:left;"> A Score to Settle </td>
   <td style="text-align:left;"> Frank </td>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 6.5 </td>
   <td style="text-align:right;"> 985 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2018 </td>
   <td style="text-align:left;"> Between Worlds </td>
   <td style="text-align:left;"> Joe </td>
   <td style="text-align:right;"> 90 </td>
   <td style="text-align:right;"> 5.8 </td>
   <td style="text-align:right;"> 448 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2018 </td>
   <td style="text-align:left;"> Mandy </td>
   <td style="text-align:left;"> Red Miller </td>
   <td style="text-align:right;"> 122 </td>
   <td style="text-align:right;"> 6.3 </td>
   <td style="text-align:right;"> 2670 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2018 </td>
   <td style="text-align:left;"> 211 </td>
   <td style="text-align:left;"> Mike Chandler </td>
   <td style="text-align:right;"> 86 </td>
   <td style="text-align:right;"> 6.1 </td>
   <td style="text-align:right;"> 1301 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2018 </td>
   <td style="text-align:left;"> Looking Glass </td>
   <td style="text-align:left;"> Ray </td>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 6.0 </td>
   <td style="text-align:right;"> 742 </td>
  </tr>
</tbody>
</table>

So, now I have some reasonably useful data. Let's take a look at the number of movies per year:

```r
cage_movies %>%
  count(year) %>%
  ggplot(aes(x = year, y = n)) +
  geom_col(color = "#1D1D1D") +
  annotate(
    "text", x = 2005, y = 5.5, label = "2014", color = "#999999", size = 5,
    family = "Lato"
  ) +
  annotate(
    "curve", color = "#999999", curvature = -.25,
    x = 2005.4, y = 5.7, xend = 2013.2, yend = 6,
    arrow = arrow(ends = "last", length = unit(5, "pt"))
  ) +
  scale_y_continuous(breaks = seq(1, 10, 1)) +
  labs(
    title = "Nic Cage Movies per Year",
    subtitle = "Excluding uncredited and voice roles",
    x = "Year", y = "# of Movies",
    caption = plot_caption
  ) +
  theme_trakt()
```

{{<figure src="plots/movies-year-1.png" link="plots/movies-year-1.png">}}

Now the ratings for these movies, with a point size according to the number of votes cast:

```r
cage_movies %>%
  mutate(title_label = glue::glue("{title} ({year})")) %>%
  {
  ggplot(., aes(x = released, y = rating, size = votes)) +
  coord_cartesian(ylim = c(1, 10)) +
  geom_point(
    shape = 21, alpha = .75, fill = "#EA212D", color = "#1D1D1D"
  ) +
  geom_label_repel(
    data = filter(., rating < 4 | rating > 7.5),
    aes(label = title_label), 
    size = 4, color = "white", fill = NA,
    family = "Lato",
    force_pull = .5,
    box.padding = 4,
    point.padding = .7,
    label.padding = .5,
    label.size = 0,
    segment.color = "#999999",
    segment.curvature = -.25,
    segment.ncp = 2,
    segment.angle = 90,
    max.overlaps = Inf, max.iter = 10000,
    seed = 3236, show.legend = FALSE
  ) +
  scale_y_continuous(breaks = seq(1, 10, 1)) +
  scale_size_binned(guide = guide_bins(
    keywidth = unit(15, "mm"),
    axis.colour = "#999999",
    aesthetics = c("size", "point.size")
  )) +
  labs(
    title = "Nic Cage Movie Ratings on trakt.tv",
    subtitle = "By release date and number of votes",
    x = "Release Date", y = "Rating (1-10)",
    size = "Votes",
    caption = plot_caption
  ) +
  theme_trakt()
  }
```

{{<figure src="plots/movies-ratings-1.png" link="plots/movies-ratings-1.png">}}

And yes, I spent *hours* tweaking the {ggrepel} settings here, and at some point I gave up and called it good enough. I thought also mention that this plot highlights some of the weaknesses with the trakt.tv data – when it comes to ratings, especially for older items, it really shows that trakt.tv hasn't been around for nearly as long as IMDb, and doesn't even come close in terms of actively-rating-stuff user base. While I'm still sad about that, it doesn't really matter that much for this little thing, but I thought I'd have to mention it.  

Anyway, let's take a look at the movies that have over 5000 votes, as a more or less arbitrary threshold for popularity:

```r
cage_movies %>%
  filter(votes > 5000) %>%
  mutate(
    title_label = glue::glue("{title} ({year})"),
    title_label = stringr::str_replace(title_label, ":", ":\n")
  ) %>%
  ggplot(aes(x = released, y = rating)) +
  coord_cartesian(ylim = c(1, 10)) +
  geom_point(
    shape = 21, alpha = .75, size = 5,
    fill = "#EA212D", color = "#1D1D1D"
  ) +
  geom_label_repel(
    aes(label = title_label), 
    size = 4, color = "white", fill = NA,
    family = "Lato",
    box.padding = 1,
    point.padding = .7,
    label.padding = .5,
    label.size = 0,
    segment.color = "#999999",
    segment.curvature = -.25,
    max.overlaps = Inf, max.iter = 10000,
    seed = 3236, show.legend = FALSE
  ) +
  scale_y_continuous(breaks = seq(1, 10, 1)) +
  labs(
    title = "Nic Cage Movie Ratings on trakt.tv",
    subtitle = "Excluding movies with a low number of votes",
    x = "Release Date", y = "Rating (1-10)",
    size = "Votes",
    caption = plot_caption
  ) +
  theme_trakt()
```

{{<figure src="plots/movies-ratings-subset-1.png" link="plots/movies-ratings-subset-1.png">}}

It's a little *too* busy with the labels I think, but if you click on the plot to zoom it out, I think it at least does it's job well enough.

Anyway, I think that's about it for now, there's a lot more that could be done with this little dataset, but I just wanted to play around with some stuff.
