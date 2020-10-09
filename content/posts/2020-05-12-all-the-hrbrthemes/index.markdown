---
title: All the {hrbrthemes}
author: jemus42
date: '2020-05-12'
slug: all-the-hrbrthemes
series:
  - R
tags:
  - ggplot2
  - visualization
  - fonts
false: true
subtitle: 'Just laying out some themes.'
description: ''
toc: true
editor_options:
  chunk_output_type: console
---



**Updated** on 2020-10-09 to include `theme_ipsum_gs` with *Goldman Sans*.

Recently, as part of a glorious procrastinative effort, I started trying to build some {ggplot2} themes. It's been years since I really tried tweaking themes, because ever since {hrbrthemes} rolled around I just went for those as a safe default.  
I have been using `theme_ipsum_rc` as my go-to theme with minor tweaks here and there for so long that I almost forgot that there's a lot more where that came from – [the package website](https://hrbrmstr.github.io/hrbrthemes/) however doesn't give a complete preview of all the themes (and it's outdated at the time of this writing).  

So I thought I'll do it myself and put all the themes in one place with some {patchwork}-aided arrangements for a clear overview.

```r 
library(ggplot2)
library(hrbrthemes)
library(patchwork)
```

To use these these themes, you'll have to make sure you have the corresponding fonts installed. You can import them like so:

```r 
import_public_sans()
import_titillium_web()
import_econ_sans()
import_tinyhand()
import_plex_sans()
import_roboto_condensed()
import_goldman_sans()
```

Depending on your output device, you might have to

```r 
extrafont::loadfonts()
```

Check if extrafont knows about your fonts:

```r 
extrafont::fonts()
```

To install them system-wide, you'll want to go to the file path the functions give you (i.e. the path to `hrbrthemes` in your package library) and install the fonts in whichever way you system requires.  
In my experience, that should at least be enough to use them with PNG or PDF output, but your mileage may vary. You may find [{showtext}](https://github.com/yixuan/showtext) helpful, or use [{ragg}](https://ragg.r-lib.org/) as an alternative device, etc. pp.

Anyway, here's a quick list of the included {hrbrthemes} themes as of **v0.8.6**:

```r 
# List all themes in package
pkg_themes <- getNamespaceExports("hrbrthemes")
pkg_themes <- sort(pkg_themes[grepl("^theme\\_", pkg_themes)])

glue::glue("- `{pkg_themes}()`")
```
- `theme_ft_rc()`
- `theme_ipsum()`
- `theme_ipsum_es()`
- `theme_ipsum_gs()`
- `theme_ipsum_ps()`
- `theme_ipsum_pub()`
- `theme_ipsum_rc()`
- `theme_ipsum_tw()`
- `theme_modern_rc()`
- `theme_tinyhand()`

We can group them three ways:

- The `ipsum`-family with its multiple different font variants.
- The dark themes `modern_rc` and `theme_ft_rc`, both using *Roboto Condensed*.
- I don't know why `theme_tinyhand` is there as well.

For comparison, I'll use your standard run of the mill `iris` plot, because at this point I guess this is *the quick brown fox* of ggplots.

```r 
# Example plot
p_facets <- ggplot(iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  facet_wrap(~Species) +
  geom_point(size = 2) +
  labs(
    subtitle = "Something something flowers and stuff",
    x = "Sepal Length", y = "Sepal Width",
    caption = "I am also here!"
  )

p_facets +
  scale_color_ipsum() +
  labs(title = "ggplot2::theme_minimal", subtitle = "Arial, probably?") +
  theme_minimal()
```

{{<figure src="plots/example-plot-1.png" link="plots/example-plot-1.png">}}

I'll also be using the `ipsum` and `ft` color palettes provided by {hrbrthemes}, for the light and dark theme variants respectively – this post is not about color palettes, that's a rabbit hole for another day, but I might as well include them for the themes' presumed "intended look".


## The `ipsum` themes

Light themes with neat fonts and relatively minute axis labels and text, as well as large margins. Call me a phillistine, but I tend to bump up the text size and reduce the strip margins a little because otherwise I can't see anything in certain scenarios, but I if you give the plots enough space, they *do* look really neat.

### `theme_ipsum` <small>(Arial Narrow)</small>

```r 
p1 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum", subtitle = "Arial Narrow") +
  theme_ipsum()
p1
```

{{<figure src="plots/theme_ipsum-1.png" link="plots/theme_ipsum-1.png">}}


### `theme_ipsum_es` <small>(Econ Sans)</small>

```r 
p2 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_es", subtitle = "Econ Sans") +
  theme_ipsum_es()
p2
```

{{<figure src="plots/theme_ipsum_es-1.png" link="plots/theme_ipsum_es-1.png">}}


### `theme_ipsum_ps` <small>(IBM Plex Sans)</small>

```r 
p3 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_ps", subtitle = "IBM Plex Sans") +
  theme_ipsum_ps()
p3
```

{{<figure src="plots/theme_ipsum_ps-1.png" link="plots/theme_ipsum_ps-1.png">}}


### `theme_ipsum_pub` <small>(Public Sans)</small>

```r 
p4 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_pub", subtitle = "Public Sans") +
  theme_ipsum_pub()
p4
```

{{<figure src="plots/theme_ipsum_pub-1.png" link="plots/theme_ipsum_pub-1.png">}}


### `theme_ipsum_rc` <small>(Roboto Condensed)</small>

```r 
p5 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_rc", subtitle = "Roboto Condensed") +
  theme_ipsum_rc()
p5
```

{{<figure src="plots/theme_ipsum_rc-1.png" link="plots/theme_ipsum_rc-1.png">}}


### `theme_ipsum_tw` <small>(Titillium Web)</small>

```r 
p6 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_tw", subtitle = "Titillium Web") +
  theme_ipsum_tw()
p6
```

{{<figure src="plots/theme_ipsum_tw-1.png" link="plots/theme_ipsum_tw-1.png">}}

### `theme_ipsum_gs` <small>(Goldman Sans)</small>

```r 
p7 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_ipsum_gs", subtitle = "Goldman Sans") +
  theme_ipsum_gs()
p7
```

{{<figure src="plots/theme_ipsum_gs-1.png" link="plots/theme_ipsum_gs-1.png">}}

## All the `ipsum` theme variations

```r 
# Plotting them in two rows (<3 patchwork)
((p1 + p2 + p3) / (p4 + p5 + p6))
```

{{<figure src="plots/all-ipsum-themes-1.png" link="plots/all-ipsum-themes-1.png">}}

*(Yes, Goldman Sans is missing, but I couldn't think of a neat way to plot 7 plots in a neat arrangement, sorry)*

## The modern/dark themes

Dark themes are all the rage, and to quote a friend of mine (who still refuses to start a blog for some reason):

> Because, according to Financial Times Datavizard John Burn-Murdoch, ["they look cool"](https://twitter.com/jburnmurdoch/status/1231235791562694659)

Both themes include calls to `ggplot2::update_geom_defaults` to change the default colors (as the function name suggests), which is something to keep in mind if you're using multiple themes in the same R session and don't manually set any colors as I am doing here via `scale_color_*`.

### `theme_modern_rc` <small>(Robot Condensed)</small> (dark)

```r 
p7 <- p_facets + 
  scale_color_ft() +
  labs(title = "theme_modern_rc", subtitle = "Roboto Condensed") +
  theme_modern_rc()
p7
```

{{<figure src="plots/theme_modern_rc-1.png" link="plots/theme_modern_rc-1.png">}}

### `theme_ft_rc` <small>(Robot Condensed)</small> (dark)

```r 
p8 <- p_facets + 
  scale_color_ft() +
  labs(title = "theme_ft_rc", subtitle = "Roboto Condensed") +
  theme_ft_rc()
p8
```

{{<figure src="plots/theme_ft_rc-1.png" link="plots/theme_ft_rc-1.png">}}

### All the dark themes

```r 
(p7 + p8) / (p8 + p7)
```

{{<figure src="plots/all-dark-themes-1.png" link="plots/all-dark-themes-1.png">}}

## Whatever the hell this is

I dunno, man.

### `theme_tinyhand` <small>("Something you should never use")</small>

```r 
p9 <- p_facets + 
  scale_color_ipsum() +
  labs(title = "theme_tinyhand", subtitle = "Tinyhand") +
  theme_tinyhand()
p9
```

{{<figure src="plots/theme_tinyhand-1.png" link="plots/theme_tinyhand-1.png">}}
