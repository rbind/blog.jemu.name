---
title: 10 Years of Relay.fm Already?
author: Lukas
date: '2023-08-19'
slug: 10-years-of-relay-fm-already
categories:
  - R
tags:
  - "web scraping"
  - "podcasts"
featured_image: null
description: ''
externalLink: ''
series:
  - R
packages: ''
toc: no
math: no
editor_options: 
  chunk_output_type: console
---

Oh boy, has it been 10 years already?  
It feels like only yesterday when I put on my data collection pants and got a whole bunch of data about all the Relay.fm podcasts just for funsies.

<details>
<summary>
Click to expand: show code
</summary>

``` r
relay_shows <- relay_get_shows()
relay_episodes <- relay_get_episodes(relay_shows)

saveRDS(relay_shows, file = "relay_shows.rds")
saveRDS(relay_episodes, file = "relay_episodes.rds")
```

</details>

## All the shows

<details>
<summary>
Click to expand: show code
</summary>

``` r
relay_episodes |>
  group_by(show) |>
  summarise(
    first = min(date),
    last = max(date)
  ) |>
  left_join(relay_shows, by = "show") |>
  mutate(show = fct_reorder(show, first)) |>
  ggplot(aes(color = show_status, fill = show_status)) +
  geom_rect(aes(xmin = first, xmax = last, ymin = show, ymax = show)) +
  geom_vline(xintercept = ymd_hms("2014-01-01")) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top"
  )
```

{{
<figure src="plots/unnamed-chunk-2-1.png" link="plots/unnamed-chunk-2-1.png">

}}

</details>

oh boy

All in all, they published **7210 epispdes** across **47** shows.

All in all, they published **7210 epispdes** across **47** shows.
