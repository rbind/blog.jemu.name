---
title: Star Trek TV Shows – In Data
subtitle: "Let's just pretend the source data is better, okay?"
author: jemus42
date: '2017-11-23'
slug: star-trek-tv-shows-in-data
categories:
  - R
  - TV Shows
tags:
  - trakt.tv
shows:
  - "Star Trek: The Original Series"
  - "Star Trek: The Animated Series"
  - "Star Trek: The Next Generation"
  - "Star Trek: Deep Space Nine"
  - "Star Trek: Voyager"
  - "Star Trek: Enterprise"
  - "Star Trek: Discovery"
packages:
  - ggplot2
  - tRakt
  - purrr
  - scales
  - dplyr
  - ggrepel
  - tadaatoolbox
draft: no
math: true
editor_options:
  chunk_output_type: console
---



**Star Trek**. It's a thing.
Not only is it a thing, it's also a big franchise. You might have heard of it.
If you happen to fall into my sociodemographic bracket, you might not have particularly strong feelings about it, but you're probably aware that many people do.
I for one do not really care. I didn't grow up with Star Trek like many people did, I grew up watching *Stargate SG-1*.
You might think of that however you wish, but fact of the matter is that the new *Star Trek: Discovery* is the first Star Trek **TV Show** I watch as it airs.
Yes, I've seen the rebooted JJ Abrams movies, and yes they kind of helped to make the franchise more accessible to people like me by basically starting fresh, but in this blogpost I'll only focus on the shows.
Shows I know little about.
Shows I have not seen.
Basically, I'm the perfect person to talk about these shows due to my lack of emotional investment, knowledge and *oh wait I have no business talking about them*.
So, with *Discovery* having made it's first impression, I thought it would be nice to put it into context a little, with all the other Star Trek stuff we had in the past.
As someone who's not *that* familiar with the franchise, I was a little surprised by the length of the *wilderness* years between the original series and the second live-action installment, as well as the relatively larg gap between the latest series and the new *Dicscovery*. I also didn't realize how big the overlap between *Deep Space Nine*, *Voyager* and *The Next Generation* was, I always assumed they were more sequential.
Anyway, I did my usual "pull data from <trakt.tv> and look at it"-thing, and here it goes.

## Preparation

We start by loading our favorite R packages for setup purposes:

```r 
library(tRakt) # remotes::install_github("jemus42/tRakt@v0.13.0")
library(dplyr)
library(ggplot2)
library(scales)
library(purrr)
library(tadaatoolbox)
library(ggrepel)
library(kableExtra)

theme_set(
  hrbrthemes::theme_ipsum_ps() +
    theme(
      plot.title.position = "plot",
      panel.spacing.y = unit(2.5, "mm"),
      panel.spacing.x = unit(2, "mm"),
      # plot.margin = margin(t = 7, r = 5, b = 7, l = 5),
      legend.position = "top",
      strip.text = element_text(hjust = .5)
    )
)

plot_caption <- paste0("@jemus42 @ ", Sys.Date())
```

Next up, we'll gather the data. Since these shows have ridiculously long titles in a world of single-word-shows, we'll keep track of both titles and commonly used abbreviations.
Please note that the data collection step is a little clunky, code-wise, but oh well, it get's the job done.

```r 
# Assemble tibble of names
stshows <- tibble::tribble(
  ~slug, ~show_abr, ~show,
  "star-trek", "TOS", "Star Trek",
  "star-trek-the-animated-series", "TAS", "Star Trek: The Animated Series",
  "star-trek-the-next-generation", "TNG", "Star Trek: The Next Generation",
  "star-trek-deep-space-nine", "DS9", "Star Trek: Deep Space Nine",
  "star-trek-voyager", "VOY", "Star Trek: Voyager",
  "star-trek-enterprise", "ENT", "Star Trek: Enterprise",
  "star-trek-discovery", "DSC", "Star Trek: Discovery"
)
```

```r 
startrek <- map_df(stshows$slug, ~ {
  seasons_summary(.x, extended = "full", episodes = TRUE) %>%
    pull(episodes) %>%
    bind_rows() %>%
    mutate(slug = .x, epnum = seq_along(first_aired))
})

startrek <- startrek %>%
  left_join(
    stshows,
    by = "slug"
  ) %>%
  arrange(first_aired) %>%
  mutate(
    epid = sprintf("s%02de%02d", season, episode),
    ep_abs = seq_along(episode),
    show = factor(show, levels = stshows$show, ordered = TRUE),
    show_abr = factor(show_abr, levels = stshows$show_abr, ordered = TRUE)
  )
```




## The Data

Here's a randomly chosen sample of two episodes of each show to give you a rough idea of the data I'm working with.
The dataset contains a few more variables, but I won't be using them or they're just variations on the variables below.

```r 
startrek %>%
  select(show, epid, first_aired, rating, votes) %>%
  group_by(show) %>%
  sample_n(2) %>%
  ungroup() %>%
  arrange(first_aired) %>%
  kable(
    digits = 2,
    col.names = c("Show", "Episode", "First Aired", "Rating", "Votes")
  ) %>%
  kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Show </th>
   <th style="text-align:left;"> Episode </th>
   <th style="text-align:left;"> First Aired </th>
   <th style="text-align:right;"> Rating </th>
   <th style="text-align:right;"> Votes </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Star Trek </td>
   <td style="text-align:left;"> s01e02 </td>
   <td style="text-align:left;"> 1966-09-16 00:30:00 </td>
   <td style="text-align:right;"> 7.22 </td>
   <td style="text-align:right;"> 680 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek </td>
   <td style="text-align:left;"> s01e08 </td>
   <td style="text-align:left;"> 1966-10-28 00:30:00 </td>
   <td style="text-align:right;"> 6.87 </td>
   <td style="text-align:right;"> 449 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Animated Series </td>
   <td style="text-align:left;"> s01e06 </td>
   <td style="text-align:left;"> 1973-10-13 04:00:00 </td>
   <td style="text-align:right;"> 6.76 </td>
   <td style="text-align:right;"> 109 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Animated Series </td>
   <td style="text-align:left;"> s02e04 </td>
   <td style="text-align:left;"> 1974-09-28 04:00:00 </td>
   <td style="text-align:right;"> 7.63 </td>
   <td style="text-align:right;"> 87 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Next Generation </td>
   <td style="text-align:left;"> s01e08 </td>
   <td style="text-align:left;"> 1987-11-10 02:00:00 </td>
   <td style="text-align:right;"> 7.30 </td>
   <td style="text-align:right;"> 580 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Next Generation </td>
   <td style="text-align:left;"> s05e06 </td>
   <td style="text-align:left;"> 1991-10-29 02:00:00 </td>
   <td style="text-align:right;"> 7.66 </td>
   <td style="text-align:right;"> 415 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Deep Space Nine </td>
   <td style="text-align:left;"> s03e18 </td>
   <td style="text-align:left;"> 1995-04-10 04:00:00 </td>
   <td style="text-align:right;"> 7.36 </td>
   <td style="text-align:right;"> 240 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Voyager </td>
   <td style="text-align:left;"> s03e21 </td>
   <td style="text-align:left;"> 1997-04-09 04:00:00 </td>
   <td style="text-align:right;"> 7.67 </td>
   <td style="text-align:right;"> 341 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Deep Space Nine </td>
   <td style="text-align:left;"> s07e05 </td>
   <td style="text-align:left;"> 1998-10-28 05:00:00 </td>
   <td style="text-align:right;"> 7.36 </td>
   <td style="text-align:right;"> 265 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Voyager </td>
   <td style="text-align:left;"> s05e23 </td>
   <td style="text-align:left;"> 1999-05-05 04:00:00 </td>
   <td style="text-align:right;"> 6.99 </td>
   <td style="text-align:right;"> 305 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Enterprise </td>
   <td style="text-align:left;"> s02e11 </td>
   <td style="text-align:left;"> 2002-12-12 01:00:00 </td>
   <td style="text-align:right;"> 7.47 </td>
   <td style="text-align:right;"> 412 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Enterprise </td>
   <td style="text-align:left;"> s04e04 </td>
   <td style="text-align:left;"> 2004-10-30 00:00:00 </td>
   <td style="text-align:right;"> 7.60 </td>
   <td style="text-align:right;"> 416 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Discovery </td>
   <td style="text-align:left;"> s02e04 </td>
   <td style="text-align:left;"> 2019-02-08 01:30:00 </td>
   <td style="text-align:right;"> 7.76 </td>
   <td style="text-align:right;"> 2641 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Discovery </td>
   <td style="text-align:left;"> s02e11 </td>
   <td style="text-align:left;"> 2019-03-29 00:30:00 </td>
   <td style="text-align:right;"> 7.92 </td>
   <td style="text-align:right;"> 2510 </td>
  </tr>
</tbody>
</table>

You might notice a few things.
First up, the vote count. While *trakt.tv* is pretty neat, it doesn't have nearly the userbase of bigger sites like IMDb, nor has it been around for as long. Additionally, how many people do you know who not only rewatch older tv shows, but also take the time to rate each episode individually on sites like trakt?
Exactly.
That's the biggest flaw I see in the data, as with all my trakt-data-shenanigans. The data is easy to retrieve, but unfortunately there's not *that* much of it.

But oh well, who cares, I'm just here to put *Discovery* into a little perspective, so on we go.
Throughout this post I'll be shortening the show names to a more plot-friendly size, using these commonly used abbreviations for reference:

```r 
stshows %>%
  select(show, show_abr) %>%
  setNames(c("Title", "Abbreviation")) %>%
  kable() %>%
  kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Title </th>
   <th style="text-align:left;"> Abbreviation </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Star Trek </td>
   <td style="text-align:left;"> TOS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Animated Series </td>
   <td style="text-align:left;"> TAS </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: The Next Generation </td>
   <td style="text-align:left;"> TNG </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Deep Space Nine </td>
   <td style="text-align:left;"> DS9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Voyager </td>
   <td style="text-align:left;"> VOY </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Enterprise </td>
   <td style="text-align:left;"> ENT </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Star Trek: Discovery </td>
   <td style="text-align:left;"> DSC </td>
  </tr>
</tbody>
</table>

## The Timeline

```r 
startrek %>%
  group_by(show_abr) %>%
  summarize(
    e_first = min(first_aired),
    e_last = max(first_aired)
  ) %>%
  mutate(show_abr = factor(show_abr, levels = rev(stshows$show_abr))) %>%
  ggplot(aes(x = show_abr, color = show_abr)) +
  geom_errorbar(aes(ymin = e_first, ymax = e_last),
    width = 0, size = 4.5, color = "black"
  ) +
  geom_errorbar(aes(ymin = e_first, ymax = e_last),
    width = 0, size = 4
  ) +
  scale_y_datetime(
    date_breaks = "5 years",
    date_minor_breaks = "1 year",
    date_labels = "%Y",
    limits = c(as.POSIXct("1963-01-01"), NA)
  ) +
  scale_color_brewer(palette = "Dark2", direction = -1, guide = F) +
  coord_flip() +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Show Timeline",
    x = "",
    y = "Show Timespan",
    caption = plot_caption
  )
```

{{<figure src="plots/timeline_bars-1.png" link="plots/timeline_bars-1.png">}}


```r 
ggplot(data = startrek, aes(x = first_aired, y = rating, fill = show_abr)) +
  geom_point(shape = 21, color = "black", size = 3) +
  scale_x_datetime(
    date_breaks = "5 years",
    date_minor_breaks = "1 year",
    date_labels = "%Y",
    limits = c(as.POSIXct("1963-01-01"), NA)
  ) +
  scale_y_continuous(breaks = seq(0, 10, .5), minor_breaks = seq(0, 10, .25)) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv",
    x = "Original Airdate",
    y = "Rating (1-10)",
    fill = "",
    caption = plot_caption
  )
```

{{<figure src="plots/timeline-1.png" link="plots/timeline-1.png">}}


```r 
ggplot(data = startrek, aes(x = ep_abs, y = rating, fill = show_abr)) +
  geom_point(shape = 21, color = "black", size = 3, alpha = .75) +
  scale_x_continuous(
    breaks = seq(0, 1e3, 50),
    minor_breaks = seq(0, 1e3, 25)
  ) +
  scale_y_continuous(
    breaks = seq(0, 10, .5),
    minor_breaks = seq(0, 10, .25)
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv",
    x = "Sequential Episode Number",
    y = "Rating (1-10)",
    fill = "",
    caption = plot_caption
  )
```

{{<figure src="plots/unnamed-chunk-1-1.png" link="plots/unnamed-chunk-1-1.png">}}

*But random internet guy*, people will now exclaim, *isn't it bad to use a truncated y-axis?* they will ask, smugly. And yes, in many situations it's a bad idea to truncate axes of quantities with a known range like a 1-10 point scale, so here's the same plot as above with "proper" limits:

```r 
ggplot(data = startrek, aes(x = ep_abs, y = rating, fill = show_abr)) +
  geom_point(shape = 21, color = "black", size = 3) +
  scale_x_continuous(
    breaks = seq(0, 1e3, 50),
    minor_breaks = seq(0, 1e3, 25)
  ) +
  scale_y_continuous(
    breaks = seq(0, 10, 1),
    minor_breaks = seq(0, 10, .5), limits = c(1, 10)
  ) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv",
    x = "Sequential Episode Number",
    y = "Rating (1-10)",
    fill = "",
    caption = plot_caption
  ) 
```

{{<figure src="plots/unnamed-chunk-2-1.png" link="plots/unnamed-chunk-2-1.png">}}

The thing is, it's harder to see differences within individual shows. It's a more or less uniform strip of points, which doesn't really help that much, so I'll probably stick to the truncated axes.

## Within-Show Variation

Next up we'll be looking at the variation within each show's rating, with respect to each show's total number of episodes.

```r 
ggplot(
  data = startrek,
  aes(
    x = show_abr, y = rating,
    color = show_abr, fill = show_abr
  )
) +
  geom_point(alpha = .5, position = position_jitter(width = .5, height = 0)) +
  geom_boxplot(alpha = .5, color = "black", outlier.alpha = 0) +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv: Within-Show Ratings as Boxplots",
    x = "",
    y = "Rating (1-10)",
    caption = plot_caption
  ) +
  theme(legend.position = "none")
```

{{<figure src="plots/within_show_boxplots-1.png" link="plots/within_show_boxplots-1.png">}}

We can see *TNG* with a lot of variation compared to the relatively consistent *Enterprise*. Also, there are quite a few outliers in *TNG*, so apaprently there are some *really good* episodes, and a few *really bad* episodes (relatively speaking).
We'll be looking at the outliers a little later.

Next up I'd like to look at the ratings of individual seasons of each shows, where we'll be using boxplots again, but this time per season.

```r 
ggplot(data = startrek, aes(x = factor(season), y = rating, fill = show_abr)) +
  geom_boxplot(alpha = .5, color = "black") +
  facet_wrap(~show_abr, scales = "free_x", nrow = 1) +
  scale_fill_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv: Within-Show Ratings as Boxplots",
    x = "Season",
    y = "Rating (1-10)",
    caption = plot_caption
  ) +
  theme(legend.position = "none")
```

{{<figure src="plots/with_show_season_boxplots-1.png" link="plots/with_show_season_boxplots-1.png">}}

You might notice a few trends, like *TOS* getting *technically worse* over time, while *DS9* and *ENT* seem to be getting better over time. I vaguely remember analyzing the seasonal trends of *ENT* in an earlier blogpost, where I also did some simple statistics to "prove" that the show gets better over time.
We can make these trends a little more explicit by using simple linear regression to approximate the ratings over time, where time is just the sequential episode number.
A rising trendline would indicate the show getting better towards the end and vice versa.
It's a little too early to evaluate *Discovery* in this manner, but at least we can see that apparently people really enjoyed the *Fall Finale*™.
In other news, I think it's safe to say that apparently nobody liked *TAS*, so... yeah. There's that.

```r 
ggplot(data = startrek, aes(x = epnum, y = rating, fill = show_abr)) +
  geom_point(shape = 21, color = "black", size = 3, alpha = .25) +
  geom_smooth(aes(color = show_abr), method = lm, se = F) +
  facet_wrap(~show_abr, nrow = 1, scales = "free_x") +
  scale_x_continuous(breaks = pretty_breaks()) +
  scale_y_continuous(
    breaks = seq(0, 10, .5),
    minor_breaks = seq(0, 10, .25)
  ) +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Ratings on trakt.tv",
    x = "Sequential Episode Number",
    y = "Rating (1-10)",
    fill = "Show",
    caption = plot_caption
  ) +
  theme(legend.position = "none")
```

{{<figure src="plots/within_show_scatter-1.png" link="plots/within_show_scatter-1.png">}}

## How Do You Feel About Histograms?

We've seen the individual episode ratings, but how about the general distribution of all the ratings regardless of the show? Just a big distribution which tells us the rough range the ratings seem to be in seems appropriate. It should also be noted that in my experience, ratings on trakt.tv don't seem to vary *that greatly*, but rather seem to fall in the range between *6* and *9*.
My working hypothesis is that people tend to, well, watch and rate things they enjoy at least a bit, and if they really dislike it and *would* rate it *5* or lower, they don't go through to watch and rate the whole shebang.
Anyway, my point being: The ratings might be a little biased, but I think we're already aware that the trakt.tv user ratings are not a perfect cross-section of society as a whole, so... yeah, I'm fine with that.

```r 
mx <- round(mean(startrek$rating), 2)
sx <- round(sd(startrek$rating), 2)

ggplot(data = startrek, aes(x = rating)) +
  geom_histogram(binwidth = .1) +
  geom_vline(
    xintercept = mean(startrek$rating),
    linetype = "dashed", color = "red", size = 2
  ) +
  scale_x_continuous(
    breaks = seq(0, 10, .5),
    minor_breaks = seq(0, 10, .1)
  ) +
  annotate(
    geom = "label",
    x = 6.5, y = 90,
    label = paste(
      "italic(bar(x)) == ", mx,
      "~~italic(s[x]) == ", sx
    ),
    parse = TRUE
  ) +
  annotate("rect",
    xmin = mx - sx,
    xmax = mx + sx,
    ymin = 0,
    ymax = 125,
    fill = "grey70",
    alpha = 0.2
  ) +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Episode Rating Distribution on trakt.tv",
    x = "Rating (1-10)",
    y = "Absolute Frequency",
    caption = plot_caption
  )
```

{{<figure src="plots/histogram_allover-1.png" link="plots/histogram_allover-1.png">}}

In this histogram we see that most ratings fall in a relatively thin range around ~7.6, which is a solid *"yeah, cool"* I guess. There's only one episode below the 6.0 line, which falls into *meh*-territory, so that's interesting.
Besides that we observe a perfectly *"pretty normal"* distribution, which shouldn't be surprising considering we have a total `\(N = 754\)`.

```r 
ggplot(data = startrek, aes(x = rating, fill = show_abr)) +
  geom_histogram(aes(y = ..density..),
    binwidth = .2, position = "dodge"
  ) +
  geom_density(alpha = .5) +
  scale_fill_brewer(palette = "Dark2") +
  facet_wrap(~show_abr, ncol = 2) +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Episode Rating Distribution on trakt.tv",
    x = "Rating (1-10)",
    y = "Absolute Frequency",
    fill = "",
    caption = plot_caption
  ) +
  theme(legend.position = "none")
```

{{<figure src="plots/histogram_byshow-1.png" link="plots/histogram_byshow-1.png">}}

In a by-show plot of distributions, we can now use the width of the distributions to estimate the variance within each show, but we kind of did that already earlier. It could be nice to look at the skew of each distribution, but I don't think there's that much to gain here.

## The First Seasons

If I remember correctly, [Jason Snell mentioned](https://www.theincomparable.com/teevee/discovery/) that the first season of any Star Trek tended to be *not that great*, which is why you should probably not jump to conclusions regarding *Discovery's* quality just by the first few episodes. So I plotted all the first seasons in one handy graph, where I rescaled the x-axis to a relative number of *percentage of episodes of first seaosn*, which allows a better comparison. Note that at the time of this writing the first season of *Discovery* is not yet concluded, but we already saw the silly named *Fall Finale*™ and know the season will consist of 15 episodes, so I adjusted appropriately.

```r 
startrek %>%
  filter(season == 1) %>%
  group_by(show) %>%
  mutate(
    season_progress = episode / max(episode),
    season_progress = ifelse(grepl(x = show, pattern = "Discovery"),
      episode / 15, season_progress
    )
  ) %>%
  ggplot(aes(
    x = season_progress, y = rating,
    color = show_abr, fill = show_abr
  )) +
  geom_point(shape = 21, color = "black", size = 3, alpha = .25) +
  geom_smooth(method = loess, se = F, span = 1.5) +
  scale_x_continuous(breaks = pretty_breaks(), labels = percent) +
  scale_y_continuous(
    breaks = seq(0, 10, .5),
    minor_breaks = seq(0, 10, .25)
  ) +
  scale_fill_brewer(palette = "Dark2", guide = F) +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "First Season Ratings on trakt.tv",
    x = "Relative Episode Position in Show's First Season",
    y = "Rating (1-10)",
    color = "",
    caption = plot_caption
  ) +
  theme(legend.position = "bottom")
```

{{<figure src="plots/firsteasons_scatterlines-1.png" caption="First-season episode ratings. The x-axis is computed by dividing the episode number by the total number of episodes in each season" link="plots/firsteasons_scatterlines-1.png">}}

Or, if you prefer the boxplot way of life:

```r 
startrek %>%
  filter(season == 1) %>%
  ggplot(aes(x = show_abr, y = rating, color = show_abr, fill = show_abr)) +
  geom_point(alpha = .5, position = position_jitter(width = .2, height = 0)) +
  geom_boxplot(alpha = .5, color = "black", outlier.alpha = 0) +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "First Season Ratings on trakt.tv",
    x = "",
    y = "Rating (1-10)",
    caption = plot_caption
  ) +
  theme(legend.position = "none")
```

{{<figure src="plots/firstseason_boxplots-1.png" caption="First season episode ratings as boxplots with background dots" link="plots/firstseason_boxplots-1.png">}}

I guess it's fair to say that *Discovery* is doing pretty well *so far*, but it should also be noted that most of the ratings of previous shows were presumably made during rewatches, since trakt hasn't been around that long. So either *DSC* is doing pretty good or it's impossible to actually make a statement about the first-season-hypothesis based on the data, so I opt for the interpration that makes it interesting.

## The Best and the Worst Episodes

Ah yes, the thing with the outliers.
In the following plot, I've labelled each episode with regards to whether or not is in an *outlier*, which I have defined in this case to be any value that deviates more than two IQR from the median. What an IQR range is a thing that you either know or are googleing now, and well let's face it, it's not important. Anyway, I labelled the outliers with their episode ID (e.g. *s02e03*) and the episode title.

```r 
startrek %>%
  group_by(show) %>%
  mutate(
    median = median(rating),
    q1 = quantile(rating, probs = 0.25),
    q3 = quantile(rating, probs = 0.75),
    outlier_max = median + 2 * (q3 - q1),
    outlier_min = median - 2 * (q3 - q1),
    is_outlier = if_else(rating < outlier_min | rating > outlier_max,
      "Outlier", "No Outlier"
    )
  ) %>%
  ungroup() -> temp

ggplot(data = temp, aes(
  x = ep_abs, y = rating,
  fill = show_abr, alpha = is_outlier
)) +
  geom_point(shape = 21, color = "black") +
  geom_label_repel(
    data = filter(temp, is_outlier == "Outlier"),
    aes(label = paste0(epid, ": ", title)),
    alpha = .75, size = 3, show.legend = FALSE
  ) +
  scale_fill_brewer(palette = "Dark2") +
  scale_alpha_discrete(range = c(0.1, 1), guide = FALSE) +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Outliers of Episode Ratings on trakt.tv (Within Show)",
    x = "Sequential Episode Number",
    y = "Rating (1-10)",
    fill = "",
    caption = plot_caption
  ) +
  theme(legend.position = "bottom")
```

{{<figure src="plots/outliers-1.png" caption="Positive and negative outliers of each show. Outliers are defined in this case as deviating more than two IQR from the median." link="plots/outliers-1.png">}}

It's nice how *DS9* seems to have a lot of positive outliers with only two negative outliers, which indicates that *DS9* is not that great on average, but a couple of episodes are *pretty good*. At least that's the way I interpret it, not sure if that's a realistic assessment.
Additionally we can see that *TNG* takes the cake for both the best and the worst liked episodes all over, so... yay *TNG* I guess? Idunno.

## Inter-Show Comparisons

Let's compare all the shows in the *statsy* way with a simple *ANOVA* by show.
If this results in a significant result, which it probably will, it indicates that at least one show has a significantly different variation than the other shows.

```r 
tadaa_aov(rating ~ show_abr, data = startrek, print = "markdown")
```
Table 1: **One-Way ANOVA**: Using Type III Sum of Squares


|   Term    | df  |  SS   |  MS  |   F   |   p    | `\(\eta^2\)` | Cohen's f | Power |
|:---------:|:---:|:-----:|:----:|:-----:|:------:|:--------:|:---------:|:-----:|
| show_abr  |  6  | 16.5  | 2.75 | 25.11 | < .001 |   0.17   |   0.45    |   1   |
| Residuals | 747 | 81.82 | 0.11 |       |        |          |           |       |
|   Total   | 753 | 98.32 | 2.86 |       |        |          |           |       |


<br>


<br>

Welp, I don't have to look at the pariwise comparisons to tell you that *TAS* is the odd one out because it's obviously rated consistently lower than the others.
To make it more interesting, we'll look at the remaining shows if we kick out *TAS*:

```r 
startrek %>%
  filter(show_abr != "TAS") %>%
  tadaa_aov(rating ~ show_abr, data = ., print = "markdown")
```
Table 2: **One-Way ANOVA**: Using Type III Sum of Squares


|   Term    | df  |  SS   |  MS  |  F   |   p    | `\(\eta^2\)` | Cohen's f | Power |
|:---------:|:---:|:-----:|:----:|:----:|:------:|:--------:|:---------:|:-----:|
| show_abr  |  5  | 8.54  | 1.71 | 15.8 | < .001 |   0.1    |   0.33    |   1   |
| Residuals | 726 | 78.5  | 0.11 |      |        |          |           |       |
|   Total   | 731 | 87.04 | 1.82 |      |        |          |           |       |


<br>


<br>

Well I'll be damned. Who'da thunk.
The effect ($\eta^2$ and `\(f\)`) is much smaller than before, but we have a *lot* of statistical power, presumably due to the large sample size.
Let's look at the pairwise comparisons:

```r 
startrek %>%
  filter(show_abr != "TAS") %>%
  aov(rating ~ show_abr, data = .) %>%
  TukeyHSD() %>%
  broom::tidy() %>%
  tadaa_plot_tukey() +
  theme(legend.position = "none")
```

{{<figure src="plots/tukeyhsd-1.png" link="plots/tukeyhsd-1.png">}}

These errorbars indicate which pairwise comparison (e.g. "mean rating of *ENT* minus mean rating of *DS9*" in the first row) results in a significant difference from 0, assuming that if the shows have the same mean rating, the difference would be 0. The direction of the difference is determined by the labels to the left, as mentioned, so we can say that *TOS* is "significantly worse" than *Voyager*, at least according to mean episode ratings and variation.

The lasr thing I'd like to take a look at is the possible difference between the total show rating on trakt and the mean episode rating of each show. Since you have the option to give each show an over-all rating without rating each episode, I'm assuming that the nostalgia factor is strong in that regard and many people might give *TNG* a nostalgia-inflated rating compared to people who rewatched each episode and rated them as they judge them *today*(ish).
Long story short, here's the over-all show ratings, sorted by rating:

```r 
stshows$rating <- map_dbl(stshows$slug, ~ {
  shows_ratings(.x)$rating
})

ggplot(data = stshows, aes(
  x = reorder(show_abr, rating),
  y = rating, fill = show_abr
)) +
  geom_col(color = "black", alpha = .75) +
  coord_flip() +
  scale_fill_brewer(palette = "Dark2") +
  scale_y_continuous(
    breaks = seq(0, 10, 1),
    minor_breaks = seq(0, 10, .5)
  ) +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Show Ratings on trakt.tv",
    x = "",
    y = "Rating (1-10)",
    fill = "Show",
    caption = plot_caption
  )
```

{{<figure src="plots/show_overall-1.png" link="plots/show_overall-1.png">}}

Now we can use that plot and build upon it. I'll draw the mean episode rating for each show including errorbars on top of the previous plot, so hold my beer:

```r 
stshows %>%
  transmute(
    show_rating = rating,
    show_abr = show_abr
  ) %>%
  full_join(startrek, by = "show_abr") %>%
  ggplot() +
  geom_col(
    data = stshows,
    aes(
      x = reorder(show_abr, rating),
      y = rating, fill = show_abr
    ),
    color = "black", alpha = .75
  ) +
  stat_summary(aes(
    x = reorder(show_abr, show_rating),
    y = rating
  ),
  fun.data = mean_ci_t,
  geom = "errorbar", width = .5
  ) +
  stat_summary(aes(
    x = reorder(show_abr, show_rating), y = rating,
    color = show_abr
  ),
  fun = mean,
  geom = "point", shape = 21, color = "black"
  ) +
  coord_flip() +
  scale_fill_brewer(palette = "Dark2") +
  scale_color_brewer(palette = "Dark2") +
  scale_y_continuous(
    breaks = seq(0, 10, 1),
    minor_breaks = seq(0, 10, .5)
  ) +
  labs(
    title = "Star Trek TV Shows",
    subtitle = "Show Ratings on trakt.tv",
    x = "",
    y = "Rating (1-10)",
    fill = "Show",
    caption = plot_caption
  )
```

{{<figure src="plots/show_episodes_meanci-1.png" link="plots/show_episodes_meanci-1.png">}}

Neat. These little tie-fighters (wrong franchise, I know) represent the mean episode rating with its confidence interval. What we can learn from that plot is how *TNG* has a high show rating, but individual episodes tend to be rated lower on average when compared to the over-all show rating.
Interestingly, it's the other way around fpr *TAS*, where the average episode rating is higher than the show rating, so apparently people who *remember* it liked it better than the people who *watched* it? Not quite sure, but I'm certain you can figure out a way to rationalize this effect, I'm out ¯\\\_(ツ)_/¯

On the other hand, *Discovery* is very consistent with its mean episiode rating CI enclosing the current show rating over all.
That's neat.
If you disagree, don't email me.
