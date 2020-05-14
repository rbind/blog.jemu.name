---
title: Remember the X-Files?
subtitle: ""
description: ""
image: "/post/2016-02-05-remember-the-x-files_files/figure-html/xfiles_plots_arcs_waffle-1.png"
author: jemus42
date: '2016-02-05'
series:
  - R
  - TC Shows
tags:
  - trakt.tv
shows:
  - X-Files
packages:
  - rvest
  - ggplot2
  - waffle
  - tRakt
  - purrr
  - dplyr
draft: true
editor_options: 
  chunk_output_type: console
---



With the return of the X-Files in form of a miniseries, I was tempted to catch up on the original run of the show, since I had only seen the occasional episode in the late 90's or early 00's (my mom was a big fan).
Being me, I already looked up the X-Files episodes [ratings on trakt.tv](https://trakt.jemu.name) to see if there's something interesting about them, but I didn't think there was. However, when I listened to the [Incomparable talking about the show](https://www.theincomparable.com/theincomparable/284/index.php), I learned that apparently X-Files can be divided into the "myth arc" and regular, more stand-alone episodes. That's when I realized I need to get my tv show analysis boots on and try to see what I could do.
To my delight, I noticed that the [appropriate Wikipedia article](https://en.wikipedia.org/wiki/List_of_The_X-Files_episodes) neatly marks the myth arc episodes, ready for plucking.

And then I started plucking.

### Setup and data retrieval

Here are the R packages I used for the analysis. Some of them are from GitHub, and two of them are my own packages.
It seems I need this stuff a lot.

```r 
library(rvest)
library(dplyr)
library(purrr)
library(stringr)
library(ggplot2)
library(broom)
library(knitr)
library(magrittr)
library(tRakt) # remotes::install_github("jemus42/tRakt")
library(tadaatoolbox) # remotes::install_github("tadaadata/tadaatoolbox")
library(waffle) # remotes::install_github("hrbrmstr/waffle")

theme_set(
  hrbrthemes::theme_ipsum_tw() +
    theme(
      plot.title.position = "plot",
      panel.spacing.y = unit(2.5, "mm"),
      panel.spacing.x = unit(2, "mm"),
      #plot.margin = margin(t = 7, r = 5, b = 7, l = 5),
      legend.position = "top",
      strip.text = element_text(hjust = .5)
    )
)
```

And here is the heart of that whole project. Probably my biggest and most complex `%>%`-chain to date.
I realize that going for big and complex chains is not necessarily a good thing because of readibility and understandability, but at some point I just wanted to know if I could actually do all the data retrieval *and cleanup* in one chain.
I could.

```r 
xfiles <- read_html("https://en.wikipedia.org/wiki/List_of_The_X-Files_episodes") %>%
  # str_replace_all('</a>\"<img', "ARC</a><img") %>%
  read_html() %>%
  html_table(fill = TRUE) %>%
  extract(c(2:6, 8:11))

xfiles <- xfiles %>%
  map_df(~ {
    set_names(.x, c(
      "epnum", "episode", "title", "director",
      "writer", "firstaired", "prod_id", "viewers"
    ))
  })

xfiles <- xfiles %>%
  mutate(
    title = str_replace_all(title, '"', ""),
    plotarc = ifelse(grepl("‡", title), "Mytharc", "Regular"),
    title = str_replace_all(title, "ARC", ""),
    epnum = as.numeric(epnum)
  ) %>%
  mutate(epnum = seq_along(epnum)) %>%
  select(-episode, -title, -firstaired) %>%
  mutate(
    viewers = str_replace_all(viewers, "\\[\\d+]", ""),
    viewers = as.numeric(viewers),
    plotarc = as.factor(plotarc)
  )

# Duplicate last episode because trakt.tv counts the two-parter as two episodes
xfiles <- xfiles %>%
  bind_rows(
    xfiles %>%
      tail(1) %>%
      mutate(epnum = 202)
  )

xfiles_trakt <- seasons_season("the-x-files", seasons = 1:9, extended = "full") %>%
  mutate(episode_abs = seq_along(title))

xfiles <- xfiles %>%
  full_join(xfiles_trakt, by = c("epnum" = "episode_abs"))
```




Maybe I can explain the process a little, because the first half took me ages to get right.
The thing about the episodes in that Wikipedia article being marked is tricky, because they are indeed marked with a double dagger (‡), but no, not a unicode text dagger like this: ‡ — but with an image of the symbol. Therefore, my web scraping only returned the text of the html table, not the image in it. Therefore, I could not easily figure out which episode was being marked, since the marking was now gone. The workaround for that was for me to scrape the raw html with `read_html`, pump it through `str_replace_all` where I looked for occurrences of images being placed directly after text, and then inserted the dummy text `ARC` at the end of the text and before the image. To my surprise, that actually worked quite well (at this point I had tried a dozen different things, including regex-voodoo).
At this point I could simply re-pump the modified html into the same `read_html` function, extract the tables and filter out the elements which corresponded to the episode tables from the Wiki article.
That's it for the first 5 lines.
After that there's only a bunch of modifications to make the output usable, like replacing column names with names that didn't cause weird issues (probably due to weird characters R didn't like), and combining all the episode tables for each season into one coherent `data.frame` (the first `bind_rows`).
The rest is basically your average data munging, until the last line, where I used my [trakt.tv package](https://github.com/jemus42/tRakt) to collect all the X-Files episode with ratings and some other data from [trakt.tv](https://trakt.tv), merge that with the original dataset to produce the show dataset with the most metadata I ever had.
That's nice.

So, on to the actualy analysis.

### So I heard you like plots

Before I start the plottage, here are some numbers: The original run of the serious spanned 9 seasons, 202 episodes (depending on how you count certain two parters, I counted them as two episodes) and just over 3 *billion* views.

That's a lot of views. Let's plot them over the seasons.

```r 
ggplot(data = xfiles, aes(x = episode, y = viewers)) +
  geom_point(size = 4) +
  facet_grid(. ~ season) +
  labs(
    title = "The X-Files US Viewers by Season",
    x = "Episode", y = "Viewers (Millions)"
  )
```
{{<figure src="plots/xfiles_plots_viewers_1-1.png" link="plots/xfiles_plots_viewers_1-1.png">}}

That's beautiful. I bet I could draw a quadratic curve right through those data points and probably even get a good regression fit out of it.

```r 
ggplot(data = xfiles, aes(x = epnum, y = viewers)) +
  geom_point(size = 4) +
  geom_smooth(method = lm, formula = y ~ poly(x, 2), se = F, color = "red") +
  labs(
    title = "The X-Files US Viewers",
    x = "Episode", y = "Viewers (Millions)"
  )
```
{{<figure src="plots/xfiles_plots_viewers_2-1.png" link="plots/xfiles_plots_viewers_2-1.png">}}


```r 
model <- lm(data = xfiles, viewers ~ poly(epnum, 2))

tidy(model) %>%
  kable(digits = 3)
```


|term            | estimate| std.error| statistic| p.value|
|:---------------|--------:|---------:|---------:|-------:|
|(Intercept)     |   15.177|     0.148|   102.419|       0|
|poly(epnum, 2)1 |   -9.268|     2.116|    -4.381|       0|
|poly(epnum, 2)2 |  -43.175|     2.107|   -20.495|       0|


```r 
glance(model) %>%
  kable(digits = 3)
```


| r.squared| adj.r.squared| sigma| statistic| p.value| df|   logLik|     AIC|     BIC| deviance| df.residual|
|---------:|-------------:|-----:|---------:|-------:|--:|--------:|-------:|-------:|--------:|-----------:|
|     0.691|         0.688| 2.096|   219.979|       0|  3| -430.246| 868.492| 881.686|  865.149|         197|

…And I actually did. Nice.
These measures indicate that that curve I drew is a pretty decent approximation of the viewership numbers, meaning that in the beginning, there were little, then a peak through season 5, and then a steady decline throughout the end.

Let's look at the averages for each season and throw some confidence intervals in for good measure.

```r 
xfiles %>%
  ggplot(aes(x = season, y = rating)) +
  stat_summary(
    geom = "errorbar", fun.data = mean_cl_boot, 
    size = 2
  ) +
  geom_point(size = 3, color = "red", stat = "summary", fun = mean) +
  scale_color_brewer(palette = "Set1", guide = F) +
  labs(
    title = "Average Viewers per Season with 95% CI",
    x = "Season", y = "Average Viewers (Millions)"
  )
```
{{<figure src="plots/xfiles_plots_viewers_3-1.png" link="plots/xfiles_plots_viewers_3-1.png">}}

It's probably quite telling that season 9 got less viewers than the first season.

### So, plot arcs

Let's start looking at these plot arcs I keep hearing about. First of all, I classified all the episodes according to the Wikipedia episode list in "Mytharc" and "Regular", and now let's see how many of each there are.

```r 
waffle(table(xfiles$plotarc),
  rows = 10, size = .5,
  title = "Number of Episodes by Plot Arc", xlab = "1 Square == 1 Episode",
  legend_pos = "top", colors = RColorBrewer::brewer.pal(3, "Set1")[1:2]
)
```
{{<figure src="plots/xfiles_plots_arcs_waffle-1.png" link="plots/xfiles_plots_arcs_waffle-1.png">}}

Yep. That's 62 *mytharc* episodes and 140 remaining episodes.
I'm assuming the plot arcs don't have any influence on the original viewer numbers, but let's check that.

```r 
ggplot(data = xfiles, aes(x = episode, y = viewers, colour = plotarc)) +
  geom_point(size = 4) +
  geom_smooth(method = lm, se = F) +
  facet_grid(. ~ season) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "The X-Files US Viewers\nBy Season and Plot Arc",
    x = "Episode", y = "Viewers (Millions)", color = "Plot Arc"
  ) +
  theme(legend.position = "top")
```
{{<figure src="plots/xfiles_plots_arcs_viewers-1.png" link="plots/xfiles_plots_arcs_viewers-1.png">}}

```r 
xfiles %>%
  group_by(plotarc) %>%
  summarize(
    mean = mean(viewers, na.rm = T),
    lower = mean - confint_t(viewers, na.rm = T),
    upper = mean + confint_t(viewers, na.rm = T)
  ) %>%
  ggplot(aes(x = plotarc, y = mean, colour = plotarc)) +
  geom_errorbar(aes(ymin = lower, ymax = upper), size = 2) +
  geom_point(size = 3, color = "black") +
  scale_color_brewer(palette = "Set1", guide = F) +
  labs(title = "Average Viewers with 95% CI", x = "Plot Arc", y = "Average Viewers (Millions)")
```
{{<figure src="plots/xfiles_plots_arcs_viewers2-1.png" link="plots/xfiles_plots_arcs_viewers2-1.png">}}

Huh, it actually looks like there is a mild increase in viewers for the *mytharc*, but nothing significant (the CIs overlap a lot).

So, what's next? How about we look at the trakt.tv episode ratings to compare the plot arcs:

```r 
ggplot(data = xfiles, aes(x = episode, y = rating, colour = plotarc)) +
  geom_point(size = 4) +
  geom_smooth(method = lm, se = F) +
  facet_grid(. ~ season) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "The X-Files Ratings on trakt.tv\nBy Season and Plot Arc",
    x = "Episode", y = "Rating (0-10)", color = "Plot Arc"
  ) +
  theme(legend.position = "top")
```
{{<figure src="plots/xfiles_plotarcs_episodes-1.png" link="plots/xfiles_plotarcs_episodes-1.png">}}

That seems… oddly conclusive. The mytharc appear to be consistently more well-received than non-mytharc episodes, but that might be due to people on rewatches (remember trakt.tv wasn't around during the 90s) only watch and/or rate the mytharc episodes more often?

```r 
ggplot(data = xfiles, aes(x = episode, y = votes, colour = plotarc)) +
  geom_point(size = 4) +
  geom_smooth(method = lm, se = F) +
  facet_grid(. ~ season) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "The X-Files Votes on trakt.tv\nBy Season and Plot Arc",
    x = "Episode", y = "Votes", color = "Plot Arc"
  ) +
  theme(legend.position = "top")
```
{{<figure src="plots/xfiles_plotarcs_votes-1.png" link="plots/xfiles_plotarcs_votes-1.png">}}

Well, nope. That seems pretty uniform and resembles the same kind of vote distribution I commonly see on shows on trakt.tv.

So let's take a closer look at the episode ratings by plot arc: Here's a histogram with overlaid density distribution and the means with confidence intervals.

```r 
ggplot(data = xfiles, aes(x = rating, fill = plotarc)) +
  geom_density(alpha = .5) +
  # geom_histogram(aes(y = stat(density)), position = "dodge", alpha = .6) +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Rating Distribution by Plot Arc",
    x = "Rating", y = "Density", fill = "Plot Arc"
  ) +
  theme(legend.position = "top")
```
{{<figure src="plots/xfiles_plotarc_ratingfrq_1-1.png" link="plots/xfiles_plotarc_ratingfrq_1-1.png">}}


```r 
xfiles %>%
  group_by(plotarc) %>%
  summarize(
    mean = mean(rating),
    lower = mean - confint_t(rating),
    upper = mean + confint_t(rating)
  ) %>%
  ggplot(aes(x = plotarc, y = mean, colour = plotarc)) +
  geom_errorbar(aes(ymin = lower, ymax = upper), size = 2) +
  geom_point(size = 3, color = "black") +
  scale_color_brewer(palette = "Set1", guide = F) +
  labs(title = "Average Rating with 95% CI", x = "Plot Arc", y = "Rating (0-100)")
```
{{<figure src="plots/xfiles_plotarc_ratingfrq_2-1.png" link="plots/xfiles_plotarc_ratingfrq_2-1.png">}}

As you can see, there's quite a nice distinction. Especially the second plot shows an obvious difference which is so big a statistical test for significance would be entirely pointless. But who am I to judge, here's a t-test.

```r 
tadaa_t.test(xfiles, rating, plotarc, print = "markdown")
```
Table 1: **Two Sample t-test** with alternative hypothesis: `\(\mu_1 \neq \mu_2\)`


| Diff | `\(\mu_1\)` Mytharc | `\(\mu_2\)` Regular |  t   |  SE  | df  |  `\(CI_{95\%}\)`  |   p   | Cohen\'s d | Power |
|:----:|:---------------:|:---------------:|:----:|:----:|:---:|:-------------:|:-----:|:----------:|:-----:|
| 0.36 |      7.97       |      7.61       | 2.35 | 0.15 | 200 | (0.06 - 0.66) | < .05 |    1.06    | 0.65  |


<br>


<br>

If you're not familiar with t-tests and power analysis: That's ridiculous. The p-value indicates significance by it's own right, and the effect size of `\(d = 1.421\)` tells use the effect is *huge*, with effect sizes greater than 0.8 commonly referred to as large. Also, the power is 1 (rounded value, so *very close to 1*), which basically means that with that data it's theoretically next to impossible no not spot that difference if our data was a sample of a larger "population" of episodes.

Anyway, let's continue.
The next thing I'm curious about is if that difference in ratings is seen throughout the series, or possibly limited to some seasons.

```r 
xfiles %>%
  group_by(plotarc, season) %>%
  summarize(
    mean = mean(rating),
    lower = mean - confint_t(rating),
    upper = mean + confint_t(rating)
  ) %>%
  ggplot(aes(x = season, y = mean, colour = plotarc)) +
  geom_errorbar(aes(ymin = lower, ymax = upper), size = 2) +
  geom_point(size = 3, color = "black") +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Average Rating with 95% CI", x = "Season", y = "Rating (0-100)", color = "Plot Arc") +
  theme(legend.position = "top")
```
{{<figure src="plots/xfiles_plotarc_rating_season-1.png" link="plots/xfiles_plotarc_rating_season-1.png">}}

Here we have the mean rating with a 95% CI for each season, and who would have guessed, the overall trend is the same. Besides season 6 and maybe season 5, there's a significant difference in ratings within each season per plotarc.

### Conclusion

So, take this to mean whatever you want, but let's just say that if you were to rewatch *X-Files* to get in the mood for the new miniseries, there's a chance you'll be fine if you select your sample from the mytharc episodes.
Or maybe not, as Siracusa argued in that Incomparable episodes.
Anyways, I just wanted to make some plots.

So to end this, let's take a quick look at the writers who brought us this show (filtered for at leats 2 episode credits):

```r 
xfiles %>%
  group_by(plotarc, writer) %>%
  tally() %>%
  filter(n > 1) %>%
  ggplot(aes(x = reorder(writer, n), weight = n)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~plotarc) +
  labs(
    title = "Writers with at Least Two Episode Credits",
    x = "Writer", y = "Number of Episodes"
  )
```
{{<figure src="plots/xfiles_plot_writers-1.png" link="plots/xfiles_plot_writers-1.png">}}
