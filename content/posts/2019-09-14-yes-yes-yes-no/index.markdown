---
title: "Yes yes yes... no!"
subtitle: "Exploring the similarities and differences of shows that ended on a controversial note"
description: "This post is not about how I'm still angry about Game of Thrones, but in a way, it is"
author: jemus42
date: '2019-09-14'
slug: yes-yes-yes-no
draft: no
series:
  - R
  - TV Shows
tags:
  - trakt.tv
  - Game of Thrones
  - Dexter
  - Battlestar Galactica (2003)
  - How I Met Your Mother
  - Scrubs
  - Lost
packages:
  - dplyr
  - kableExtra
  - tRakt
  - purrr
  - ggplot2
editor_options: 
  chunk_output_type: console
---



There are some shows that are/were really popular, everyone is excited about them, and then they go down the drain in a both abrupt and spectactular kind of way. Some take their time over a whole season, others have you hoping (and quite possibly in denial) until the end, and then they just kick you in the ol' hope organ.  

I was wondering (for no particular recent-eventsy kind of reason at all, I swear) if some of the shows I recall being considered "bad enders" have something in common, or more interestingly, end badly, differently. 

<details><summary>Code: Data collection</summary>

```r 
library(tRakt)
library(kableExtra)
library(dplyr)
library(ggplot2)

shows <- tribble(
  ~show, ~slug,
  "Dexter", "dexter",
  "Lost", "lost-2004",
  "How I Met Your Mother", "how-i-met-your-mother",
  "Scrubs", "scrubs",
  "Battlestar Galactica (2003)", "battlestar-galactica-2003",
  "Game of Thrones", "game-of-thrones"
)

if (!file.exists("episodes.rds")) {
  episodes <- purrr::pmap_df(shows, ~{
  trakt.seasons.summary(.y, extended = "full", episodes = TRUE) %>%
    pull(episodes) %>%
    bind_rows() %>%
    select(-available_translations)
    mutate(
      show = .x,
      season = as.character(season),
      episode_abs = seq_along(first_aired)
    )
  })
  
  saveRDS(episodes, "episodes.rds")
} else {
  episodes <- readRDS("episodes.rds")
}
```

</details>

Here's the highest rated episodes per show to get started:

```r 
episodes %>%
  group_by(show) %>%
  top_n(3, rating) %>%
  arrange(rating, .by_group = TRUE) %>%
  mutate(
    rating = round(rating, 1)
  ) %>%
  select(
    show, season, episode, title, rating
  ) %>%
  kable(
    col.names = c("Show", "Season", "Episode", "Title", "Rating"),
    caption = "Top 3 episodes per show",
    digits = 2
  ) %>%
  kable_styling(bootstrap_options = c("condensed")) %>%
  collapse_rows(1)
```
<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
<caption>Table 1: Top 3 episodes per show</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Show </th>
   <th style="text-align:left;"> Season </th>
   <th style="text-align:right;"> Episode </th>
   <th style="text-align:left;"> Title </th>
   <th style="text-align:right;"> Rating </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> Battlestar Galactica (2003) </td>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> Daybreak (2) </td>
   <td style="text-align:right;"> 8.5 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> Exodus (2) </td>
   <td style="text-align:right;"> 8.6 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> Crossroads (2) </td>
   <td style="text-align:right;"> 8.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> Dexter </td>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Surprise, Motherfucker! </td>
   <td style="text-align:right;"> 8.7 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> This is the Way the World Ends </td>
   <td style="text-align:right;"> 8.9 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> The Getaway </td>
   <td style="text-align:right;"> 8.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> Game of Thrones </td>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> The Spoils of War </td>
   <td style="text-align:right;"> 8.8 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> The Winds of Winter </td>
   <td style="text-align:right;"> 8.8 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Battle of the Bastards </td>
   <td style="text-align:right;"> 8.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> How I Met Your Mother </td>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:right;"> 24 </td>
   <td style="text-align:left;"> The Magician's Code: Part Two </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Slap Bet </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> The Final Page: Part Two </td>
   <td style="text-align:right;"> 8.6 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> Lost </td>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:right;"> 17 </td>
   <td style="text-align:left;"> The Incident (2) </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> The Constant </td>
   <td style="text-align:right;"> 8.5 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> Through The Looking Glass (2) </td>
   <td style="text-align:right;"> 8.5 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> Scrubs </td>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> My Screw Up </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 18 </td>
   <td style="text-align:left;"> My Finale </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> My Lunch </td>
   <td style="text-align:right;"> 8.4 </td>
  </tr>
</tbody>
</table>

Per-episode ratings are always neat to look at.

```r 
ggplot(episodes, aes(x = episode_abs, y = rating)) +
  geom_point(alpha = .75) +
  scale_y_continuous(breaks = 0:10, minor_breaks = seq(0, 10, .5)) +
  facet_wrap(~show, ncol = 1) +
  labs(
    title = "Episode Ratings per Show",
    subtitle = "Ratings on trakt.tv",
    x = "Absolute Episode #",
    y = "Rating (1-10)"
  )
```
{{<figure src="plots/ratings-plot-1.png" link="plots/ratings-plot-1.png">}}

Since I'm primarily interested in the rating of the ending compared to the average for the specific show, we'll standardize the ratings using mean and standard deviation of each show. Just in case, we'll get both centered _and_ standardized ratings.

```r 
episodes <- episodes %>%
  group_by(show) %>%
  mutate(
    rating_c = rating - mean(rating),
    rating_z = rating_c / sd(rating)
  )

episodes %>%
  group_by(show) %>%
  filter(rating == max(rating) | rating == min(rating)) %>%
  arrange(rating, .by_group = TRUE) %>%
  mutate_at(
    vars(starts_with("rating")), ~round(.x, 1)
  ) %>%
  select(
    show, season, episode, title, starts_with("rating")
  ) %>%
  kable(
    col.names = c("Show", "Season", "Episode", "Title", 
                  "Rating", "Rating (centered)", "Rating (standardized)"),
    caption = "Best and worst episode by show with centered/standardized ratings"
  ) %>%
  kable_styling(bootstrap_options = c("condensed")) %>%
  collapse_rows(1)
```
<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
<caption>Table 2: Best and worst episode by show with centered/standardized ratings</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Show </th>
   <th style="text-align:left;"> Season </th>
   <th style="text-align:right;"> Episode </th>
   <th style="text-align:left;"> Title </th>
   <th style="text-align:right;"> Rating </th>
   <th style="text-align:right;"> Rating (centered) </th>
   <th style="text-align:right;"> Rating (standardized) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> Battlestar Galactica (2003) </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:right;"> 14 </td>
   <td style="text-align:left;"> Black Market </td>
   <td style="text-align:right;"> 7.3 </td>
   <td style="text-align:right;"> -0.6 </td>
   <td style="text-align:right;"> -2.5 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> Crossroads (2) </td>
   <td style="text-align:right;"> 8.6 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 2.3 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> Dexter </td>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Remember the Monsters? </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> -1.5 </td>
   <td style="text-align:right;"> -6.0 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> The Getaway </td>
   <td style="text-align:right;"> 8.9 </td>
   <td style="text-align:right;"> 0.7 </td>
   <td style="text-align:right;"> 2.9 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> Game of Thrones </td>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> The Iron Throne </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> -1.6 </td>
   <td style="text-align:right;"> -4.7 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> Battle of the Bastards </td>
   <td style="text-align:right;"> 8.9 </td>
   <td style="text-align:right;"> 0.7 </td>
   <td style="text-align:right;"> 2.1 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> How I Met Your Mother </td>
   <td style="text-align:left;"> 9 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:left;"> Bedtime Stories </td>
   <td style="text-align:right;"> 7.2 </td>
   <td style="text-align:right;"> -0.8 </td>
   <td style="text-align:right;"> -3.9 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> The Final Page: Part Two </td>
   <td style="text-align:right;"> 8.6 </td>
   <td style="text-align:right;"> 0.6 </td>
   <td style="text-align:right;"> 3.2 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> Lost </td>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Fire + Water </td>
   <td style="text-align:right;"> 7.5 </td>
   <td style="text-align:right;"> -0.4 </td>
   <td style="text-align:right;"> -2.4 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:right;"> 23 </td>
   <td style="text-align:left;"> Through The Looking Glass (2) </td>
   <td style="text-align:right;"> 8.5 </td>
   <td style="text-align:right;"> 0.5 </td>
   <td style="text-align:right;"> 3.1 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="2"> Scrubs </td>
   <td style="text-align:left;"> 9 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:left;"> Our Driving Issues </td>
   <td style="text-align:right;"> 6.7 </td>
   <td style="text-align:right;"> -1.0 </td>
   <td style="text-align:right;"> -3.8 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:left;"> My Lunch </td>
   <td style="text-align:right;"> 8.4 </td>
   <td style="text-align:right;"> 0.7 </td>
   <td style="text-align:right;"> 2.5 </td>
  </tr>
</tbody>
</table>

Plot them all together:

```r 
ggplot(episodes, aes(x = episode_abs, y = rating_c, fill = show)) +
  geom_point(alpha = .75, shape = 21) +
  scale_y_continuous(breaks = seq(-10, 10, .5), minor_breaks = seq(-10, 10, .25)) +
  labs(
    title = "Episode Ratings per Show",
    subtitle = "Centered Ratings",
    x = "Absolute Episode #",
    y = "Rating (centered)",
    fill = ""
  )
```
{{<figure src="plots/ratings-plot-standardized-1.png" link="plots/ratings-plot-standardized-1.png">}}

We should also normalize the episode count, so we'll take the absolute episode number and scale them to the interval [0, 100] — then we can interpret it as a percentage of total show run time.

```r 
episodes <- episodes %>%
  group_by(show) %>%
  mutate(
    episode_rel = (episode_abs / max(episode_abs)) * 100
  )

ggplot(episodes, aes(x = episode_rel, y = rating_c, fill = show)) +
  geom_point(alpha = .75, shape = 21) +
  scale_y_continuous(breaks = seq(-10, 10, .5), minor_breaks = seq(0, 10, .25)) +
  labs(
    title = "Episode Ratings per Show",
    subtitle = "Centered Ratings, normalized run time",
    x = "Relative Episode (% of Total Run)",
    y = "Rating (centered)",
    fill = ""
  )
```
{{<figure src="plots/normalize-epcount-1.png" link="plots/normalize-epcount-1.png">}}

For display purposes, we'll categorize the last season and last episode respectively.

```r 
episodes <- episodes %>%
  group_by(show) %>%
  mutate(
    is_last_season = if_else(
      as.numeric(season) == max(season), "Last Season", "Earlier Seasons"
    ),
    is_last_episode = if_else(episode_rel == 100, "Finale", "Earlier Episodes")
  )
```

Now we'll look at the previous plot, but highlight the last seasons of our shows:

```r 
ggplot(episodes, aes(x = episode_rel, y = rating_c, fill = is_last_season)) +
  geom_point(size = 2, alpha = .75, shape = 21) +
  scale_fill_brewer(palette = "Dark2") +
  #scale_y_continuous(breaks = 0:10, minor_breaks = seq(0, 10, .5)) +
  labs(
    title = "Episode Ratings per Show",
    subtitle = "All shows, centered Ratings, normalized episode numbers",
    x = "Relative Episode (% of Total Run)",
    y = "Rating (centered)",
    fill = ""
  )
```
{{<figure src="plots/scatter-last-season-1.png" link="plots/scatter-last-season-1.png">}}

Welp, not for _all_, but for most shows in the mix we're seeing quite a noticable dip at the end there.

```r 
ggplot(episodes, aes(x = is_last_season, y = rating_c, 
                     color = is_last_season, fill = is_last_season)) +
  geom_boxplot(alpha = .25) +
  geom_violin(alpha = .5) +
  geom_point(
    data = episodes %>% filter(is_last_episode == "Finale"),
    shape = 21, size = 4, color = "black", stroke = 1,
    key_glyph = "rect"
  ) +
  facet_wrap(~show, nrow = 1) +
  scale_x_discrete(breaks = NULL) +
  scale_fill_brewer(palette = "Dark2", aesthetics = c("color", "fill")) +
  labs(
    title = "Episode Ratings by Earlier/Last Season",
    subtitle = "The dot is the final episode",
    x = "", y = "Rating (centered)",
    color = "", fill = ""
  )
```
{{<figure src="plots/last-seasons-comparison-boxplot-1.png" caption="Last Seasons: A Boxplot" link="plots/last-seasons-comparison-boxplot-1.png">}}

This is probably the most useful plot so far. Not only can we distinguis between the final season's ratings and the remainder of the show, but we can also see if the finale itself was rated particularly differently.


## Conclusion

I think it's fair to say that "bad endings" and "controversial endings" are different categories. While BSG and Lost both have endings that left many people unsatisfied, they're still not noticably lower rated then the remainder of the show – on the contrary even, they're above average.  

Then there's the case of the bad last season. While Scrubs didn't have a band ending per-se, it's just that the whole last season was just too big of a departure from what people liked about the show before, namely, well, the cast for one thing.

And then there's the "well this is just bullshit" endings. Here we find Dexter, How I Met Your Mother, and of course, Game of Thrones.  
These endings are special – they're not "bad because I didn't like it"-bad, they're "bad because it doesn't make any sense in the context of the hours and hours of previous material".

At least that's my hypothesis.
