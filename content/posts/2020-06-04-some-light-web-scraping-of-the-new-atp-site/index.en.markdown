---
title: Some Light Web-Scraping of the New ATP Site
author: jemus42
date: "2021-06-26"
slug: some-light-web-scraping-of-the-new-atp-site
series:
  - R
tags:
  - "web scraping"
  - "podcasts"
featured_image: "plots/links-histo-1.png"
description: 'Trying my hand at a little more web-scraping. Just gathering some data about ATP podcast episodes, not because it’s useful, but because it’s possible.'
packages:
  - polite
  - rvest
toc: yes
math: no
draft: true
always_allow_html: yes
editor_options: 
  chunk_output_type: console
---
<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />
<script src="{{< blogdown/postref >}}index.en_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index.en_files/lightable/lightable.css" rel="stylesheet" />



## Introduction

{{< addendum title="Note" >}}
I started writing this post in June 2020, and it has been in "I should get back to that"-limbo for over ~~6~~ ~~8~~ 12 months because… well, the year's been busy.

The code for the scrapey bits has since been put into its own [little package](https://github.com/jemus42/poddr) — so if you want to just get some data, you can install that or get the up-to-date data [from my other project's site](https://podcasts.jemu.name/data/).
{{< /addendum >}}

<details><summary>Click to expand: Show packages & setup</summary>

```r 
# For web-scraping
library(polite)
library(rvest)

# For convenience
library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

# Tables
library(kableExtra)

# Plotting
library(ggplot2)
library(tadaathemes) # remotes::install_github("tadaadata/tadaathemes")

plot_caption <- glue::glue("@jemus42 // {Sys.Date()}")
```

</details>

There are two main "tricks" to successful web-scraping (in my admittedly limited experience):

1. Get as close to the information you care about by using / identifying CSS selectors.
2. Whittle down text content as needed by trying to not have regular expressions wear you down.

For step 1, I like using [SelectorGadget], but you may be more comfortable using your favorite browser's developer tools, or looking at the site's HTML source, or being *really* good at guessing.  
For point 2, you'll probably want to spend some time on (and bookmark) [regexr] or [regex101], and maybe you'll like the {{< pkg "rematch2" >}} package. I haven't tried the latter yet, but I tend to think "I should look at that some time" every once in a while before I go back to my regular regexing.

Then there's **step 0** of web scraping:  
*Don't be a jerk to the site you're scraping*.  
In this case I don't think there's too much of a chance of me hammering the site in question too much, as I learned I'm going to need a total of *10* pages.
So… I don't think I could do too much damage even if tried. However, I will still use the {{< pkg "polite" >}} package because I wanted to try it out anyway, and from what I gather it's explicit purpose is to, well, be *polite* with your scraping while still being compatible with your standard {{< pkg "rvest" >}} workflow.

Oh, and I totally forgot **step -1** of web scraping:  
*Make sure you actually have permission*. 
There's plenty of sites out there that don't allow third parties to scrape their content without expressed permission. 
Read the TOS if applicable, and make sure you're not playing the *"but it's a free website why am I not entitled to scraping all its content and use it for my own purposes"* card.  
In this particular case, I'm fairly certain that tabulating podcast episodes and shownote URLs is "safe" [^sorrymarco].    
Things are different for popular scraping targets like [IMDb](https://www.imdb.com/conditions).


> **Robots and Screen Scraping**: You may not use data mining, robots, screen scraping, or similar data gathering and extraction tools on this site, except with our express written consent as noted below.

So, even if you were extra polite in your IMDb scraping, you're still being a jerk by breaking their TOS, so you're going to have to get that data [through their official channel](https://developer.imdb.com/) for your projects. 

[SelectorGadget]: https://selectorgadget.com/
[regexr]: https://regexr.com/
[regex101]: https://regex101.com/
[^sorrymarco]: Please don't hate me Marco 🥺

Anyway, let's get started with a basic scraping setup: I'm going to get the first page of [atp.fm](https://atp.fm) and collect all the links, separated into text and URL:

```r 
session <- bow("https://atp.fm/", force = TRUE)
links <- scrape(session) %>%
  html_nodes("li a") 

atp_links <- tibble::tibble(
  text = html_text(links),
  url = html_attr(links, "href")
)

head(atp_links)
```

```
#> # A tibble: 6 x 2
#>   text                                  url                                     
#>   <chr>                                 <chr>                                   
#> 1 FAA’s TRUST program                   https://www.faa.gov/news/updates/?newsI…
#> 2 FAA Part 107                          https://www.faa.gov/uas/commercial_oper…
#> 3 DJI Mini 2                            https://www.dji.com/mini-2              
#> 4 John’s extension                      https://hypercritical.co/safari-reload-…
#> 5 Finn Voorhees’ experiment             https://twitter.com/finnvoorhees/status…
#> 6 Safari on iOS 15 & Monterey automati… https://www.macrumors.com/2021/06/08/sa…
```

Welp, that's pretty straight forward. It's made fairly easy by the fact that all the shownote links are list items (`<li>`), but of course it would be nicer if we could match links to the episode they belong to.  
We can do that by iterating over all the `<article>` elements in the page, which enclose each episode post. 
As an example, let's get the episode number/titles of the most recent episodes:

```r 
episode_titles <- scrape(session) %>%
  html_nodes("article") %>%
  html_nodes("h2 a") %>%
  html_text()

tibble::tibble(
  number = str_extract(episode_titles, "^\\d+"),
  episode = str_remove(episode_titles, "^\\d+:\\s")
)
```

```
#> # A tibble: 5 x 2
#>   number episode                       
#>   <chr>  <chr>                         
#> 1 436    Eddy Cue Shows Up at Your Door
#> 2 435    A Strong Number Four          
#> 3 434    A Squirmy Soup of Rectangles  
#> 4 433    Before We Leave the Dump      
#> 5 432    I Shouldn't Need to Wiggle
```

This is also the first case of regex making things a little neater in the result but harder to grasp along the way. If you've been spared the regex way of life until now, what we did here breaks down to this:

1. Take the episode title, e.g. `"410: The Comfort Is Killing Me"` from the HTML via `html_text()`
2. *Extract* the number by taking the non-zero amount of digits (`\\d+`) from the beginning of the string (`^`)
3. *Remove* that same number, including a `:` and an extra whitespace (`\\s`) to be left with the episode title.

Thankfully {{< pkg "stringr" >}} makes this nice and readable.  
And now we can… go all out. Figure out all the elements of the site we're interested in regarding episode metadata and links, and put all the scrapey bits into a function for convenience. 
I won't explain each element, but feel free to comment if you don't understand a specific part. In any case, with the minimal amount of setup required you can easily trial-and-error your way through this part if you're into that[^butnote].

[^butnote]: But please note that you don't have to re-read the website in question to scrape it. You can save the website content to a variable and then use that as the base for all your `html_nodes` and regex experiments.

<details><summary>Click to expand: atp_parse_page()</summary>

```r 
# Here, page is an object as returned by polite::scrape()
atp_parse_page <- function(page) {
  rvest::html_nodes(page, "article") %>%
    # Iterate over all the article elements (episodes) on the page
    # Makes it easier to collect elements corresponding to each episode
    purrr::map_dfr(~ {
      # Extract the metadata block, we'll take that apart in steps
      meta <- rvest::html_node(.x, ".metadata") %>%
        rvest::html_text() %>%
        stringr::str_trim()

      date <- meta %>%
        stringr::str_extract("^.*(?=\\\n)") %>%
        lubridate::mdy()

      duration <- meta %>%
        stringr::str_extract("\\d{2}:\\d{2}:\\d{2}") %>%
        hms::as_hms()

      number <- .x %>%
        rvest::html_nodes("h2 a") %>%
        rvest::html_text() %>%
        stringr::str_extract("^\\d+")

      title <- .x %>%
        rvest::html_nodes("h2 a") %>%
        rvest::html_text() %>%
        stringr::str_remove("^\\d+:\\s")

      # Get the sponsor links
      links_sponsor <- .x %>%
        # Shownotes links are in the second <ul> element
        rvest::html_nodes("ul~ ul li") %>%
        rvest::html_nodes("a")

      link_text_sponsor <- links_sponsor %>%
        rvest::html_text()

      link_href_sponsor <- links_sponsor %>%
        rvest::html_attr("href")

      links_sponsor <- tibble(
        link_text = link_text_sponsor,
        link_url = link_href_sponsor,
        link_type = "Sponsor"
      )

      # Get the regular shownotes links
      links_regular <- .x %>%
        # Get the first <ul> element, then the listed links
        # This avoids links in paragraphs and shownotes
        rvest::html_node("ul") %>%
        rvest::html_nodes("li a")

      link_text <- links_regular %>%
        rvest::html_text()

      link_href <- links_regular %>%
        rvest::html_attr("href")

      links_regular <- tibble(
        link_text = link_text,
        link_url = link_href,
        link_type = "Shownotes"
      )
      # Piece it all together all tibbly
      # Links will be a list-column
      tibble(
        number = number,
        title = title,
        duration = duration,
        date = date,
        year = lubridate::year(date),
        month = lubridate::month(date, abbr = FALSE, label = TRUE),
        weekday = lubridate::wday(date, abbr = FALSE, label = TRUE),
        links = list(dplyr::bind_rows(links_regular, links_sponsor)),
        n_links = nrow(links_regular) + nrow(links_sponsor)
      )
    })
}
```

</details>

Now we have a compact way to get all the interesting bits in a neat tibble, including a list-column with shownote links separated into sponsor- and topical URLs:

```r 
scraped_page <- scrape(session) %>%
  atp_parse_page()

glimpse(scraped_page)
```

```
#> Rows: 5
#> Columns: 9
#> $ number   <chr> "436", "435", "434", "433", "432"
#> $ title    <chr> "Eddy Cue Shows Up at Your Door", "A Strong Number Four", "A …
#> $ duration <time> 01:54:47, 02:11:10, 03:04:02, 02:07:47, 02:21:58
#> $ date     <date> 2021-06-24, 2021-06-17, 2021-06-08, 2021-06-03, 2021-05-27
#> $ year     <dbl> 2021, 2021, 2021, 2021, 2021
#> $ month    <ord> June, June, June, June, May
#> $ weekday  <ord> Thursday, Thursday, Tuesday, Thursday, Thursday
#> $ links    <list> [<tbl_df[47 x 3]>, <tbl_df[42 x 3]>, <tbl_df[20 x 3]>, <tbl_d…
#> $ n_links  <int> 47, 42, 20, 29, 38
```

```r 
scraped_page$links[[1]]
```

```
#> # A tibble: 47 x 3
#>    link_text                        link_url                           link_type
#>    <chr>                            <chr>                              <chr>    
#>  1 FAA’s TRUST program              https://www.faa.gov/news/updates/… Shownotes
#>  2 FAA Part 107                     https://www.faa.gov/uas/commercia… Shownotes
#>  3 DJI Mini 2                       https://www.dji.com/mini-2         Shownotes
#>  4 John’s extension                 https://hypercritical.co/safari-r… Shownotes
#>  5 Finn Voorhees’ experiment        https://twitter.com/finnvoorhees/… Shownotes
#>  6 Safari on iOS 15 & Monterey aut… https://www.macrumors.com/2021/06… Shownotes
#>  7 Rauli Rikama’s observations      https://twitter.com/raulirikama/s… Shownotes
#>  8 FLoC                             https://en.wikipedia.org/wiki/Fed… Shownotes
#>  9 Scroll Reverser                  https://pilotmoon.com/scrollrever… Shownotes
#> 10 Mos                              https://mos.caldis.me/             Shownotes
#> # … with 37 more rows
```

Now what's left is to get _all_ the episodes, because why not.

## Getting _All_ the Episodes

Or: This is my first `while`-loop in R since… I think 2014?  
I don't regret *everything* per se, but I think this is actually reasonable.

<details><summary>Click to expand: atp_get_episodes()</summary>

```r 
atp_get_episodes <- function(page_limit = NULL) {

  # If there's no page limit, we set it to infinity
  # because it's easier if it's a number and I'm bad at while loops
  if (is.null(page_limit)) page_limit <- Inf

  # Get the first page and scrape it
  session <- polite::bow(url = "https://atp.fm")

  atp_pages <- list("1" = polite::scrape(session))
  next_page_num <- 2

  # Early return for first page only
  if (page_limit == 1) {
    atp_parse_page(atp_pages[[1]])
  }

  # Find out how many pages there will be in total
  # purely for progress bar cosmetics.
  latest_ep_num <- atp_pages[[1]] %>%
    rvest::html_nodes("h2 a") %>%
    rvest::html_text() %>%
    stringr::str_extract("^\\d+") %>%
    as.numeric() %>%
    max()

  # First page has 5 episodes, 50 episodes per page afterwards
  total_pages <- ceiling((latest_ep_num - 5) / 50) + 1

  # Everything is better with progress bars.
  pb <- progress::progress_bar$new(
    format = "Getting pages [:bar] :current/:total (:percent) ETA: :eta",
    total = total_pages
  )
  pb$tick()

  # Iteratively get the next page until the limit is reached
  # (or of there's no next page to retrieve)
  while (next_page_num <= page_limit) {
    pb$tick()

    atp_pages[[next_page_num]] <- polite::scrape(
      session,
      query = list(page = next_page_num)
    )

    # Find the next page number
    next_page_num <- atp_pages[[next_page_num]] %>%
      rvest::html_nodes("#pagination a+ a") %>%
      rvest::html_attr("href") %>%
      stringr::str_extract("\\d+$") %>%
      as.numeric()

    # Break the loop if there's no next page
    if (length(next_page_num) == 0) break
  }

  # Now parse all the pages and return
  pb <- progress::progress_bar$new(
    format = "Parsing pages [:bar] :current/:total (:percent) ETA: :eta",
    total = length(atp_pages)
  )

  purrr::map_dfr(atp_pages, ~ {
    pb$tick()
    atp_parse_page(.x)
  })
}

# Parse all the pages
atp_episodes <- atp_get_episodes()
```

</details>





## Looking at Links

One of the neat things we can do with this ATP data compared to [other podcast data I've scraped in the past](https://podcasts.jemu.name/) is the inclusion of nicely formatted shownote links. 
So we might as well take a closer look at what we've got there.

```r 
ggplot(atp_episodes, aes(x = n_links)) +
  geom_bar(alpha = .75) +
  scale_x_binned() +
  labs(
    title = "ATP.fm: Number of Links per Episode",
    x = "# of Links in Episode Shownotes",
    y = "Episodes",
    caption = plot_caption
  ) + 
  theme_tadaark()
```

{{<figure src="plots/links-histo-1.png" link="plots/links-histo-1.png">}}

Huh, what's with the right outlier?

```r 
atp_episodes %>%
  slice_max(n_links, n = 5) %>%
  select(date, number, title, n_links) %>%
  kable(caption = "Episodes with most links")
```
<table>
<caption>Table 1: Episodes with most links</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> date </th>
   <th style="text-align:left;"> number </th>
   <th style="text-align:left;"> title </th>
   <th style="text-align:right;"> n_links </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2015-05-29 </td>
   <td style="text-align:left;"> 119 </td>
   <td style="text-align:left;"> Promoretired </td>
   <td style="text-align:right;"> 73 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014-11-14 </td>
   <td style="text-align:left;"> 91 </td>
   <td style="text-align:left;"> Press Agree to Drive </td>
   <td style="text-align:right;"> 58 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2020-06-04 </td>
   <td style="text-align:left;"> 381 </td>
   <td style="text-align:left;"> Uncomfortable Truths </td>
   <td style="text-align:right;"> 52 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2015-02-27 </td>
   <td style="text-align:left;"> 106 </td>
   <td style="text-align:left;"> That’s Slightly Right </td>
   <td style="text-align:right;"> 51 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014-11-07 </td>
   <td style="text-align:left;"> 90 </td>
   <td style="text-align:left;"> Speculative Abandonware </td>
   <td style="text-align:right;"> 51 </td>
  </tr>
</tbody>
</table>

Okay, so [episode 119][e119] *wins*. But it seems unfair to not take episode length into account, so let's try that.

[e119]: https://atp.fm/119

```r 
atp_episodes %>%
  unnest(links) %>%
  count(link_url, link_type, sort = TRUE) %>%
  group_by(link_type) %>%
  slice_max(n, n = 3)
```

```
#> # A tibble: 6 x 3
#> # Groups:   link_type [2]
#>   link_url                         link_type     n
#>   <chr>                            <chr>     <int>
#> 1 http://jonathanmann.net/         Shownotes    87
#> 2 http://neutral.fm/               Shownotes    24
#> 3 https://developer.apple.com/wwdc Shownotes    14
#> 4 http://squarespace.com/atp       Sponsor     168
#> 5 http://hover.com/atp             Sponsor      70
#> 6 http://betterment.com/atp        Sponsor      57
```


```r 
ggplot(atp_episodes, aes(x = duration, y = n_links)) +
  geom_point() +
  labs(
    title = "ATP.fm: Number of Links per Episode",
    x = "Episode Duration (H:M:S)",
    y = "Number of Links in Show Notes",
    caption = plot_caption
  ) +
  theme_tadaark()
```

{{<figure src="plots/links-duration-scatter-1.png" link="plots/links-duration-scatter-1.png">}}

Well okay, there's an unsurprising trend there. Maybe we should take a look at `links / minute`, as a metric of how much linkage there is being done.

```r 
atp_episodes <- atp_episodes %>%
  mutate(lpm = n_links / (as.numeric(duration) / 60))

atp_episodes %>%
  slice_max(lpm, n = 5) %>% 
  select(date, title, duration, n_links, lpm) %>%
  kable(caption = "Episodes with most links per minute")
```
<table>
<caption>Table 2: Episodes with most links per minute</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> date </th>
   <th style="text-align:left;"> title </th>
   <th style="text-align:left;"> duration </th>
   <th style="text-align:right;"> n_links </th>
   <th style="text-align:right;"> lpm </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2015-05-29 </td>
   <td style="text-align:left;"> Promoretired </td>
   <td style="text-align:left;"> 01:39:42 </td>
   <td style="text-align:right;"> 73 </td>
   <td style="text-align:right;"> 0.7321966 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014-11-14 </td>
   <td style="text-align:left;"> Press Agree to Drive </td>
   <td style="text-align:left;"> 01:40:43 </td>
   <td style="text-align:right;"> 58 </td>
   <td style="text-align:right;"> 0.5758729 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2018-03-01 </td>
   <td style="text-align:left;"> Old Potato </td>
   <td style="text-align:left;"> 01:34:24 </td>
   <td style="text-align:right;"> 47 </td>
   <td style="text-align:right;"> 0.4978814 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014-11-07 </td>
   <td style="text-align:left;"> Speculative Abandonware </td>
   <td style="text-align:left;"> 01:44:37 </td>
   <td style="text-align:right;"> 51 </td>
   <td style="text-align:right;"> 0.4874940 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2014-12-26 </td>
   <td style="text-align:left;"> You Have to Know When to Stop </td>
   <td style="text-align:left;"> 01:27:18 </td>
   <td style="text-align:right;"> 42 </td>
   <td style="text-align:right;"> 0.4810997 </td>
  </tr>
</tbody>
</table>


```r 
atp_episodes %>%
  ggplot(aes(x = month, y = n_links)) +
  geom_boxplot(alpha = .25, fill = "#374453") +
  geom_point(stat = "summary", fun = mean, fill = "lightblue", shape = 21, size = 3) + 
  theme_tadaark()
```

{{<figure src="plots/links-duration-monthly-1.png" link="plots/links-duration-monthly-1.png">}}

### URL Protocol

I don't know if you've heard the news yet, but HTTPS is kind of a big deal.  
As a matter of fact, it has become more and more of a big deal over the past few years, and one way to illustrate that is the ratio of HTTP/HTTPS links posted on the web.
So guess what we're doing with the URL data next.


```r 
atp_episodes_links <- atp_episodes %>%
  unnest(links) %>%
  mutate(
    HTTPS = ifelse(str_detect(link_url, "^https"), "https", "http"),
    domain = urltools::domain(link_url) %>%
      str_remove_all("www\\.")
  ) 

atp_episodes_links %>%
  ggplot(aes(x = HTTPS)) +
  geom_bar(alpha = .75, color = "white") + 
  theme_tadaark()
```

{{<figure src="plots/links-proto-1.png" link="plots/links-proto-1.png">}}
```r 
atp_episodes_links %>%
  count(year = lubridate::year(date), HTTPS) %>%
  group_by(year) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = year, y = prop, fill = HTTPS)) +
  geom_col(alpha = .75, color = "white") + 
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  hrbrthemes::scale_y_percent() +
  theme_tadaark()
```

{{<figure src="plots/links-proto-2.png" link="plots/links-proto-2.png">}}
```r 
atp_episodes_links %>%
  count(year = lubridate::year(date), HTTPS, link_type) %>%
  group_by(link_type, year) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = year, y = prop, fill = HTTPS)) +
  facet_wrap(vars(link_type)) +
  geom_col(alpha = .75, color = "white") + 
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  hrbrthemes::scale_y_percent() +
  theme_tadaark()
```

{{<figure src="plots/links-proto-3.png" link="plots/links-proto-3.png">}}


```r 
atp_episodes_links %>%
  filter(year(date) == 2020, HTTPS == "http") %>%
  count(domain, link_type, sort = TRUE) %>%
  head(10) %>%
  kable(
    col.names = c("Domain", "Link Type", "# of HTTP links")
  )
```
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Domain </th>
   <th style="text-align:left;"> Link Type </th>
   <th style="text-align:right;"> # of HTTP links </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> hypercritical.co </td>
   <td style="text-align:left;"> Shownotes </td>
   <td style="text-align:right;"> 27 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:left;"> Shownotes </td>
   <td style="text-align:right;"> 25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> squarespace.com </td>
   <td style="text-align:left;"> Sponsor </td>
   <td style="text-align:right;"> 19 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> drops.caseyliss.com </td>
   <td style="text-align:left;"> Shownotes </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hover.com </td>
   <td style="text-align:left;"> Sponsor </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> neutral.fm </td>
   <td style="text-align:left;"> Shownotes </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5by5.tv </td>
   <td style="text-align:left;"> Shownotes </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> awaytravel.com </td>
   <td style="text-align:left;"> Sponsor </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> getbluevine.com </td>
   <td style="text-align:left;"> Sponsor </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> jamf.com </td>
   <td style="text-align:left;"> Sponsor </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>

### Domains

```r 
atp_episodes_links %>%
  filter(link_type == "Shownotes") %>%
  count(domain, sort = TRUE)
```

```
#> # A tibble: 1,881 x 2
#>    domain                  n
#>    <chr>               <int>
#>  1 twitter.com          1099
#>  2 en.wikipedia.org     1089
#>  3 apple.com             410
#>  4 amazon.com            361
#>  5 youtube.com           286
#>  6 developer.apple.com   205
#>  7 relay.fm              192
#>  8 marco.org             129
#>  9 theverge.com          125
#> 10 caseyliss.com         123
#> # … with 1,871 more rows
```

```r 
atp_episodes_links %>%
  filter(link_type == "Shownotes") %>%
  count(year = year(date), domain, sort = TRUE) %>%
  group_by(year) %>%
  slice_max(n, n = 5) %>%
  kable() %>%
  kable_styling() %>%
  collapse_rows(1)
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> year </th>
   <th style="text-align:left;"> domain </th>
   <th style="text-align:right;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2013 </td>
   <td style="text-align:left;"> marco.org </td>
   <td style="text-align:right;"> 19 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> youtube.com </td>
   <td style="text-align:right;"> 16 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> anandtech.com </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2014 </td>
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 140 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 99 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> 5by5.tv </td>
   <td style="text-align:right;"> 30 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> arstechnica.com </td>
   <td style="text-align:right;"> 27 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> youtube.com </td>
   <td style="text-align:right;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2015 </td>
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 161 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 133 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 80 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 55 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> developer.apple.com </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2016 </td>
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 137 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 90 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 80 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 69 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> jonathanmann.net </td>
   <td style="text-align:right;"> 46 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2017 </td>
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 147 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 80 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 50 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 43 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> jonathanmann.net </td>
   <td style="text-align:right;"> 40 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2018 </td>
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 199 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 132 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 46 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> youtube.com </td>
   <td style="text-align:right;"> 46 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 37 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2019 </td>
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 171 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 109 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 61 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 41 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> relay.fm </td>
   <td style="text-align:right;"> 38 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2020 </td>
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 175 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 168 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 67 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> amazon.com </td>
   <td style="text-align:right;"> 48 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> youtube.com </td>
   <td style="text-align:right;"> 43 </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="5"> 2021 </td>
   <td style="text-align:left;"> en.wikipedia.org </td>
   <td style="text-align:right;"> 148 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> twitter.com </td>
   <td style="text-align:right;"> 72 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> youtube.com </td>
   <td style="text-align:right;"> 40 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> apple.com </td>
   <td style="text-align:right;"> 33 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> developer.apple.com </td>
   <td style="text-align:right;"> 27 </td>
  </tr>
</tbody>
</table>


## Conclusion

<details><summary>Click to expand: Session Info</summary>

```r 
sess <- sessioninfo::session_info()

sess$platform %>%
  unclass() %>%
  tibble::as_tibble() %>%
  t() %>%
  knitr::kable() %>%
  kableExtra::kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
<tbody>
  <tr>
   <td style="text-align:left;"> version </td>
   <td style="text-align:left;"> R version 4.1.0 Patched (2021-05-29 r80415) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> os </td>
   <td style="text-align:left;"> macOS Big Sur 10.16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> system </td>
   <td style="text-align:left;"> x86_64, darwin17.0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ui </td>
   <td style="text-align:left;"> X11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> language </td>
   <td style="text-align:left;"> (EN) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> collate </td>
   <td style="text-align:left;"> en_US.UTF-8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ctype </td>
   <td style="text-align:left;"> en_US.UTF-8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tz </td>
   <td style="text-align:left;"> Europe/Berlin </td>
  </tr>
  <tr>
   <td style="text-align:left;"> date </td>
   <td style="text-align:left;"> 2021-06-26 </td>
  </tr>
</tbody>
</table>

```r 
sess$packages %>%
  tibble::as_tibble() %>%
  dplyr::select(package, version = ondiskversion, source) %>%
  knitr::kable() %>%
  kableExtra::kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> package </th>
   <th style="text-align:left;"> version </th>
   <th style="text-align:left;"> source </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> assertthat </td>
   <td style="text-align:left;"> 0.2.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> blogdown </td>
   <td style="text-align:left;"> 1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bookdown </td>
   <td style="text-align:left;"> 0.21 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> bslib </td>
   <td style="text-align:left;"> 0.2.5.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cachem </td>
   <td style="text-align:left;"> 1.0.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> cli </td>
   <td style="text-align:left;"> 2.3.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> colorspace </td>
   <td style="text-align:left;"> 2.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> crayon </td>
   <td style="text-align:left;"> 1.4.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> curl </td>
   <td style="text-align:left;"> 4.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DBI </td>
   <td style="text-align:left;"> 1.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> digest </td>
   <td style="text-align:left;"> 0.6.27 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> dplyr </td>
   <td style="text-align:left;"> 1.0.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ellipsis </td>
   <td style="text-align:left;"> 0.3.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> evaluate </td>
   <td style="text-align:left;"> 0.14 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> extrafont </td>
   <td style="text-align:left;"> 0.17 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> extrafontdb </td>
   <td style="text-align:left;"> 1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fansi </td>
   <td style="text-align:left;"> 0.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> farver </td>
   <td style="text-align:left;"> 2.0.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fastmap </td>
   <td style="text-align:left;"> 1.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> fs </td>
   <td style="text-align:left;"> 1.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> gdtools </td>
   <td style="text-align:left;"> 0.2.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> generics </td>
   <td style="text-align:left;"> 0.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ggplot2 </td>
   <td style="text-align:left;"> 3.3.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> glue </td>
   <td style="text-align:left;"> 1.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> gtable </td>
   <td style="text-align:left;"> 0.3.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> here </td>
   <td style="text-align:left;"> 1.0.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> highr </td>
   <td style="text-align:left;"> 0.8 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hms </td>
   <td style="text-align:left;"> 1.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> hrbrthemes </td>
   <td style="text-align:left;"> 0.8.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> htmltools </td>
   <td style="text-align:left;"> 0.5.1.9000 </td>
   <td style="text-align:left;"> Github (rstudio/htmltools@ac43afe) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> httr </td>
   <td style="text-align:left;"> 1.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> jquerylib </td>
   <td style="text-align:left;"> 0.1.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> jsonlite </td>
   <td style="text-align:left;"> 1.7.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> kableExtra </td>
   <td style="text-align:left;"> 1.3.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> knitr </td>
   <td style="text-align:left;"> 1.31 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> labeling </td>
   <td style="text-align:left;"> 0.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lifecycle </td>
   <td style="text-align:left;"> 1.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lubridate </td>
   <td style="text-align:left;"> 1.7.10 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> magrittr </td>
   <td style="text-align:left;"> 2.0.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> memoise </td>
   <td style="text-align:left;"> 2.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mime </td>
   <td style="text-align:left;"> 0.10 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> munsell </td>
   <td style="text-align:left;"> 0.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pillar </td>
   <td style="text-align:left;"> 1.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pkgconfig </td>
   <td style="text-align:left;"> 2.0.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> polite </td>
   <td style="text-align:left;"> 0.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> prettyunits </td>
   <td style="text-align:left;"> 1.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> progress </td>
   <td style="text-align:left;"> 1.2.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> purrr </td>
   <td style="text-align:left;"> 0.3.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> R6 </td>
   <td style="text-align:left;"> 2.5.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ratelimitr </td>
   <td style="text-align:left;"> 0.4.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rcpp </td>
   <td style="text-align:left;"> 1.0.6 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> renv </td>
   <td style="text-align:left;"> 0.13.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rlang </td>
   <td style="text-align:left;"> 0.4.10 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rmarkdown </td>
   <td style="text-align:left;"> 2.7 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> robotstxt </td>
   <td style="text-align:left;"> 0.7.13 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rprojroot </td>
   <td style="text-align:left;"> 2.0.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rstudioapi </td>
   <td style="text-align:left;"> 0.13 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rttf2pt1 </td>
   <td style="text-align:left;"> 1.3.8 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rvest </td>
   <td style="text-align:left;"> 0.3.6 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sass </td>
   <td style="text-align:left;"> 0.4.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> scales </td>
   <td style="text-align:left;"> 1.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> selectr </td>
   <td style="text-align:left;"> 0.4.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> sessioninfo </td>
   <td style="text-align:left;"> 1.1.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> spiderbar </td>
   <td style="text-align:left;"> 0.2.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stringi </td>
   <td style="text-align:left;"> 1.5.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stringr </td>
   <td style="text-align:left;"> 1.4.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> svglite </td>
   <td style="text-align:left;"> 2.0.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> systemfonts </td>
   <td style="text-align:left;"> 1.0.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tadaathemes </td>
   <td style="text-align:left;"> 0.0.1 </td>
   <td style="text-align:left;"> Github (tadaadata/tadaathemes@0118fb9) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tibble </td>
   <td style="text-align:left;"> 3.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tidyr </td>
   <td style="text-align:left;"> 1.1.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> tidyselect </td>
   <td style="text-align:left;"> 1.1.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> triebeard </td>
   <td style="text-align:left;"> 0.3.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> urltools </td>
   <td style="text-align:left;"> 1.7.3 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> usethis </td>
   <td style="text-align:left;"> 2.0.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> utf8 </td>
   <td style="text-align:left;"> 1.1.4 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> vctrs </td>
   <td style="text-align:left;"> 0.3.6 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> viridisLite </td>
   <td style="text-align:left;"> 0.3.0 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> webshot </td>
   <td style="text-align:left;"> 0.5.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> withr </td>
   <td style="text-align:left;"> 2.4.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xfun </td>
   <td style="text-align:left;"> 0.21 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> xml2 </td>
   <td style="text-align:left;"> 1.3.2 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> yaml </td>
   <td style="text-align:left;"> 2.2.1 </td>
   <td style="text-align:left;"> CRAN (R 4.1.0) </td>
  </tr>
</tbody>
</table>


</details>
