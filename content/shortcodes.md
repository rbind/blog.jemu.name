---
title: Shortcode Showcase
slug: shortcodes
type: page
draft: false
katex: false
math: false
toc: true
---

These shortcodes live in a theme-component: [jemus42/jemsugo](https://github.com/jemus42/jemsugo).  
This page exists as a preview and mainly for debugging purposes.

## An extra content box: `addendum`

If I found a solution after the fact:

```go
{{</* addendum title="An Addendum" */>}}
I found out a relevant thing, so here's a relevant thing. Inner content is markownified
{{</* /addendum */>}}
```

{{< addendum title="An Addendum" >}}
I found out a relevant thing, so here's a relevant thing.  
This box has no `type` parameter set, so the "addendum" class is used as a default.
{{< /addendum >}}

{{< addendum title="A Warning" type="warning">}}
This box has type="warning", in case I don't want you to make the same mistake I probably made.
{{< /addendum >}}

{{< addendum title="A Problem" type="problem">}}
This is a box with type="problem", for when something is kind of… a problem?
{{< /addendum >}}

## Maintenance & Borked: `maintenance`

If a post is bork: `{{</* maintenance */>}}`

{{< maintenance >}}

`{{</* maintenance "Custom Title" */>}}`

{{< maintenance "Custom Title" >}}

Styling relies on `note-box` CSS class which is shared by `addendum` shortcodes.

No `.Inner` content for now.


## Blockquotes: `blockquote`

```go
{{</* blockquote author="Terry Pratchett" link="" title="Going Postal" */>}}
Sometimes things smash so bad it’s better to leave it alone than try to pick up the pieces. I mean, where would you start?
{{</* /blockquote */>}}
```

{{< blockquote author="Terry Pratchett" link="" title="Going Postal" >}}
Sometimes things smash so bad it’s better to leave it alone than try to pick up the pieces. I mean, where would you start?
{{< /blockquote >}}

## Code with caption in figure tag: `codecaption`

This wraps hugo's built-in `highlight` function.

```go
{{</* codecaption lang="r" caption="A code caption" */>}}
library(ggplot2)

ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point(size = 2)
{{</* /codecaption */>}}
```

{{< codecaption lang="r" caption="A code caption" >}}
library(ggplot2)

ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point(size = 2)
{{< /codecaption >}}

## Linking GitHub: `gh`

`{{</* gh "user/repo" */>}}`

My blog's repo is at {{< gh "rbind/blog.jemu.name" >}}, and these shortcodes live in {{< gh "jemus42/jemsugo" >}}.

## Figures with responsive images: `picturefig`

To be implemented

## Package decoration: `pkg`

`{{</* pkg "ggplot2" */>}}`: Relies on a `data/packages.yml` file.

Have you heard about {{< pkg "ggplot2" >}}?  
Or {{< pkg "fansi" >}}? Or {{< pkg "colorspace" >}}?

I have this package called {{< pkg "tRakt" >}} and it's not on CRAN.

## Expandable content: `summary`

```go
{{</* summary "Click to expand" */>}}
This is the secret content *they* don't want you to know.
{{</* /summary */>}}
```

{{< summary "Click to expand" >}}
This is the secret content *they* don't want you to know.
{{< /summary >}}

## Shows and movies Trakt.tv: `trakt`

Not sure about proper API yet, currently: 

`{{</* trakt "movies" "inception-2010" "Inception" */>}}` -> {{< trakt "movies" "inception-2010" "Inception" >}}

`{{</* trakt "shows" "devs" "Devs is a very beautiful show" */>}}` -> {{< trakt "shows" "devs" "Devs is a very beautiful show" >}}

This seems more complicated than just doing a quick search on trakt and copypasting the url.


## Videos with caption: `videofig`

`{{</* videofig mp4="my-file.mp4" loop=true autoplay=true alt="" caption="" */>}}`

