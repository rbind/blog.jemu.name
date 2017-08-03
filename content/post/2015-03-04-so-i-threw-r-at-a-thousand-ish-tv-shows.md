---
title: So I threw R at a thousand(ish) TV shows
author: jemus42
date: '2015-03-04'
categories:
  - rstats
  - tvshows
tags:
  - needs revisit
  - trakt.tv
packages:
  - tRakt
  - plyr
  - ggplot2
---

Analyzing TV shows seems to be what I do these days.  
So I wanted to keep my newfound calling going and sucked the data for about a thousand shows out of the trakt.tv API, which was nice enough to only fail on me, like, twice.  

So, after some time of intense data pulling, I found myself with the more or less complete data (show info, season info, episode data) for **988 shows** (and that's why I keep referring to *1000(ish)*).
I don't know what went wrong with the remaining 12 shows, but trakt didn't even give me a title of those.
I posted about it in the [API G+ community](https://plus.google.com/communities/103111515647012208243), so I see where it goes. If you are wondering,
[these are the shows missing](https://paste.xinu.at/qcuo/)

So, since I'm here to talk #Rstats, let's get going.

## Pulling a f#%$§ton of data (maybe metric)

**TL;DR** [Here's the dataset (~12mb), .rds](http://dump.jemu.name/trakt.popular.large.rds)

First up, I have to urge you to please not run the following code for the lulz (that's what I did, but disregard my hypocrisy), because that'll probably make the trakt API be all （。々°）


```r
library(tRakt)

# Pulling the 1000 most popular shows
popshow <- plyr::ldply(1:10, function(p){trakt.shows.popular(limit = 100, page = p, extended = "min")})

# And now to pull summary, season and episode data
list.popular <- list()
i <- length(list.popular)
for (show in popshow$slug){
  cat(paste0(i, ". ", show, "\n"))
  # In case of restart, skip what's already there
  if (!(is.null(list.popular[[show]]))){
    message(paste0("Skipping ", show))
    next
  }
  if (is.na(show)){next} # Happened more often than you'd think
  list.popular[[show]][["info"]]      <- trakt.show.summary(show, extended = "full")
  list.popular[[show]][["seasons"]]   <- trakt.seasons.summary(show, extended = "min")
  list.popular[[show]][["episodes"]]  <- trakt.getEpisodeData(show,
                                              list.popular[[show]][["seasons"]][["season"]])
  list.popular[[show]][["timestamp"]] <- lubridate::now(tzone = "UTC")
  Sys.sleep(.5) # To be nice
  i <- i + 1
}

# Save that stuff because boy I don't wanna pull that data agin anytime soon
saveRDS(list.popular, file = "trakt.popular.large.rds")
```

## Soooo… That's nice data, huh?

The next part will all be code that's actually being executed as I `knit` this blogpost, just to be extra reproducible with you people.

We'll start with a little aggregation, because so far we've only got a huge list (okay, RStudio says it's only [a large list](http://dump.jemu.name/pgleT.png)) with each entry consisting of summary, season and episode info. We'll at least want a `data.frame` of show info and episode data, so that's what we'll do now.


```r
suppressPackageStartupMessages(library(dplyr)) # We'll need that later

# First well load that cached data
list.popular <- readRDS("trakt.popular.large.rds")

# Episode data summarization
episodes.popular <- plyr::ldply(list.popular, function(x) x$episodes)
# Rating == 0 almost always means no votes yet, so discard that
episodes.popular <- episodes.popular[episodes.popular$rating != 0, ]
```

Now we have a nice `data.frame` of episodes. To be exact, **36827** observations.
With the episodes all tightly aggregated, let's get started on that show metadata.


```r
shows.popular <- plyr::ldply(list.popular, function(x){
  show <- data.frame(title         = x$info$title,
                     year          = ifelse(is.null(x$info$year), NA, x$info$year),
                     slug          = x$info$ids$slug,
                     rating        = x$info$rating,
                     runtime       = ifelse(is.null(x$info$runtime), NA, x$info$runtime),
                     votes         = x$info$votes,
                     network       = ifelse(is.null(x$info$network), NA, x$info$network),
                     certification = ifelse(is.null(x$info$certification), NA, x$info$certification),
                     first_aired   = ifelse(is.null(x$info$first_aired), NA, x$info$first_aired)
                     )
  return(show)
})

# A quick glance
head(shows.popular[c(2, 3, 5, 6, 7, 8)]) %>% knitr::kable(.)
```



|title            | year|  rating| runtime| votes|network |
|:----------------|----:|-------:|-------:|-----:|:-------|
|Band of Brothers | 2001| 9.43810|      60|  5985|HBO     |
|Planet Earth     | 2006| 9.43988|      60|  1705|BBC One |
|Sherlock         | 2010| 9.28540|      90| 18108|BBC One |
|House of Cards   | 2013| 9.03910|      50| 10001|Netflix |
|Breaking Bad     | 2008| 9.45861|      45| 31057|AMC     |
|Game of Thrones  | 2011| 9.40609|      60| 35475|HBO     |

Well then. **988** shows as promised.  
Oh, I can already here you yell "Come on man, give us some plots already!" — And indeed plots shall be delivered.

## Plotting all the things

Let's start with the show metadata and then work our way through to that episode data.

### Show metadata

#### Runtime

```r 
library(ggplot2)

temp <- dplyr::filter(shows.popular, runtime < 150)
ggplot(data = temp, aes(x = runtime)) +
  geom_bar(binwidth = 1) +
  scale_x_continuous(breaks = seq(0, 150, by = 15)) +
  labs(title = "Runtime of the 1000(ish) Most Popular Shows on trakt.tv",
       x = "Runtime (mins)", y = "Count")
```

![](/images/shows_files/figure-html/plots_show1-1.png)

So far, so unsurprising. Clearly ~60 min shows are in the majority, as you'd probably expect.  
Interestingly enough I had to filter out a few outliers, let's look what that was all about.


```r
suppressPackageStartupMessages(library(dplyr))

shows.popular %>% filter(runtime > 150) %>% select(title, year, rating, runtime) %>% knitr::kable(.)
```



|title                       | year|  rating| runtime|
|:---------------------------|----:|-------:|-------:|
|The Colour of Magic         | 2008| 8.30120|     189|
|Dune                        | 2000| 8.03810|     360|
|Terry Pratchett's Hogfather |   NA| 8.76147|     189|
|Great Expectations          | 2011| 7.83636|     155|

Oh, uh… well. I didn't know those Pratchett adaptations counted as TV shows, but I certainly had to exhale through my nose quickly when I saw Dune pop up there.

### Networks

I'm not all that familiar with the (US/UK) TV landscape as far as networks are concernced, but so far I've learned a few things:

* BBC good (Doctor Who, Orphan Black, lots of other stuff)
* HBO good (Duh)
* Netflix good (House of Cards, Orange is the New Black)
* CBS probably meh because of lame sitcoms? Idunno.

So let's take a closer look.


```r 
temp <- shows.popular %>% group_by(network) %>% tally %>%
           arrange(desc(n)) %>% filter(!is.na(network)) %>% filter(n >= 5)
ggplot(data = temp, aes(x = reorder(network, n), y = n)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_y_continuous(breaks = seq(0, 70, by = 5)) +
  labs(title = "Networks Distribution of the 1000(ish) Most Popular Shows on trakt.tv",
       x = "Newtork", y = "Count")
```

![](/images/shows_files/figure-html/networks-1.png)

Huh, seems like BBC has a couple players in the mix (or something sports-metaphor-y).  
Nice to see Channel 4 up there, too. They've brought us the glorious [Utopia](http://trakt.tv/shows/utopia), and I should really start paying attention to them more, I guess.
Then of course there are the big networks like ABC and NBC which are pretty much a given.  
Interesting that even YouTube pops up there. Also, I wonder what all these Netflix shows are, I can't think of more than 10 for them.


```r
shows.popular %>% filter(network == "Netflix") %>% select(title, year, runtime) %>% knitr::kable(.)
```



|title                          | year| runtime|
|:------------------------------|----:|-------:|
|House of Cards                 | 2013|      50|
|Orange Is the New Black        | 2013|      60|
|Arrested Development           | 2003|      22|
|Dr. Horrible's Sing-Along Blog | 2008|      14|
|Lilyhammer                     | 2012|      45|
|Marco Polo                     | 2014|      60|
|The Killing                    | 2011|      45|
|Longmire                       | 2012|      45|
|DreamWorks Dragons             | 2012|      22|
|BoJack Horseman                | 2014|      25|
|Trailer Park Boys              | 2001|      22|
|Hemlock Grove                  | 2013|      60|

Well… I guess I learned something new today. Or maybe the data is wrong here, but I don't know enough about Netflix or these shows to be the judge of that.

### (Show) Ratings

That's probably the interesting part. Pulling the most popular shows would suggest you'd get only high ratings, since that's pretty much what the trakt algorithm is based on (I guess), but since I pulled almost a thousand shows, I expect to dip a toe in the spheres of mediocrity.


```r
ggplot(data = shows.popular, aes(x = rating)) +
  geom_bar(binwidth = .1) +
  scale_x_continuous(limits = c(0,10), breaks = seq(0, 10, by = .5)) +
  labs(title = "The 1000(ish) Most Popular Shows on trakt.tv",
       x = "Rating", y = "Count")
```

![](/images/shows_files/figure-html/show_ratings-1.png)

…Or not? Maybe a closer look will do:  



```r
temp <- data.frame(mean   = mean(shows.popular$rating),
                   median = median(shows.popular$rating),
                   q25    = quantile(shows.popular$rating, .25),
                   q75    = quantile(shows.popular$rating, .75))

rownames(temp) <- NULL # Just to pretty up the table
knitr::kable(temp)
```

|     mean|  median|     q25|      q75|
|--------:|-------:|-------:|--------:|
| 8.347283| 8.34365| 8.05066| 8.634018|

If sleeping through my early stats education taught me anything, it's that those numbers say that a lot of these other numbers are bigger than 8.  
Okay, maybe I just underestimated how many awesomesauce shows there are. Or people only bother to rate the stuff they like. Or everyone just goes for a default rating of 8 with slight variations.  
Until trakt let's me have a go on their full database, I won't really know for sure how the vast majority of trakt users votes, but oh well, the result is good enough for me.

#### Ratings by year

Let's plot that same data again, but this time… we'll do a density plot (for smoothness), focus the x-axis and colour that stuff up by decade.


```r
# Recoding years to decades
shows.popular$decade <- car::recode(shows.popular$year, as.factor.result = TRUE,
                              recodes = "2011:2015='2010s'; 2001:2010='2000s'; 1991:2000='90s';
                              1981:1990='80s';1971:1980='70s';1961:1970='60s'; 1951:1960='50s';
                              else='old'",
                              levels = c("2010s", "2000s", "90s", "80s", "70s", "60s", "50s", "old"))

ggplot(data = shows.popular, aes(x = rating, fill = decade)) +
  geom_density(alpha = .5) +
  labs(title = "The 1000(ish) Most Popular Shows on trakt.tv",
       x = "Rating", y = "Density", fill = "Decade")
```

![](/images/shows_files/figure-html/show_ratings_filled-1.png)

That turned out to be a lot of manual recode typing for pretty much nothing. At least I can't really get anything out of this, except for the fairly penis-shaped blob in the front.
I need numbers.


```r
shows.popular %>% group_by(decade) %>%
  summarize(mean = mean(rating), sd = sd(rating), median = median(rating),
            min = min(rating), max = max(rating), range = diff(range(rating))) %>% knitr::kable(.)
```



|decade |     mean|        sd|   median|     min|     max|   range|
|:------|--------:|---------:|--------:|-------:|-------:|-------:|
|2010s  | 8.184918| 0.4366706| 8.143545| 7.26897| 9.40609| 2.13712|
|2000s  | 8.403462| 0.3816312| 8.409090| 7.48357| 9.49565| 2.01208|
|90s    | 8.430684| 0.3623506| 8.392670| 7.55072| 9.22754| 1.67682|
|80s    | 8.496819| 0.3764998| 8.482760| 7.80734| 9.31707| 1.50973|
|70s    | 8.680767| 0.4899355| 8.762430| 7.83756| 9.43396| 1.59640|
|60s    | 8.563487| 0.3848874| 8.516060| 7.90580| 9.17351| 1.26771|
|50s    | 8.644407| 0.8009140| 9.082790| 7.72000| 9.13043| 1.41043|
|old    | 8.315951| 0.3374484| 8.331130| 7.56780| 8.98214| 1.41434|

Okay, that still doesn't really tell me anything. I considered doing a quick ANOVA with `aov()`, but since the *n* is so large, I'll get statistically signficiant results of probably little to no actualy significance. But I wouldn't be me if I wouldn't show you that data anyway.


```r
m <- aov(rating ~ decade, data = shows.popular)
TukeyHSD(m) %>% broom::tidy(.) %>% filter(adj.p.value < 0.05) %>% knitr::kable(., digits = 15)
```



|comparison  |   estimate|    conf.low|   conf.high|  adj.p.value|
|:-----------|----------:|-----------:|-----------:|------------:|
|2000s-2010s |  0.2185436|  0.12811087|  0.30897628| 1.204900e-11|
|90s-2010s   |  0.2457656|  0.12238050|  0.36915062| 5.741532e-08|
|80s-2010s   |  0.3119008|  0.13150555|  0.49229611| 5.111494e-06|
|70s-2010s   |  0.4958489|  0.23306893|  0.75862891| 3.689515e-07|
|60s-2010s   |  0.3785686|  0.02054539|  0.73659187| 2.954434e-02|
|70s-2000s   |  0.2773053|  0.01628846|  0.53832222| 2.816479e-02|
|old-70s     | -0.3648157| -0.72398839| -0.00564291| 4.345849e-02|

I guess you *could* really claim that the previous decades yielded some more popular shows than the current one, but first of all I think that's just because trakt.tv hasn't been around forever and it's users probably just went nostalgic on some older shows. Also, the amount of TV shows produced nowadays is pretty incredible, so of course there will be more shows of questionable quality, too, compared with, say, the 60s. But my initial argument still holds: This is not a scientifically sound result and you shouldn't yell at me because of it. Please.

#### Ratings by… runtime, I guess?

Well, maybe the age is not a good way to find noticable differences in a shows rating, but maybe runtime can be an indiciator. Once again I have to admit that doing rating analysis on the most popular shows is probably a pretty useless thing to do, but oh well, why not.


```r
# Recoding runtime
shows.popular$runtime.r <- car::recode(shows.popular$runtime, as.factor.result = TRUE,
                              recodes = "0:14='0-14'; 15:24='15-24'; 25:34='25-34';
                              35:44='35-44'; 45:64='45-64'; 65:74='65-74'; 75:hi='long';
                              else='old'",
                              levels = c("0-14", "15-24", "25-34", "35-44", "45-64", "65-74", "long"))

ggplot(data = shows.popular, aes(x = rating, fill = runtime.r)) +
  geom_density(alpha = .5) +
  labs(title = "The 1000(ish) Most Popular Shows on trakt.tv",
       x = "Rating", y = "Density", fill = "Runtime (min)")
```

![](/images/shows_files/figure-html/ratings_by_runtime-1.png)

```r
shows.popular %>% group_by(runtime.r) %>%
  summarize(mean = mean(rating), sd = sd(rating), median = median(rating),
            min = min(rating), max = max(rating), range = diff(range(rating))) %>% knitr::kable(.)
```



|runtime.r |     mean|        sd|   median|     min|     max|   range|
|:---------|--------:|---------:|--------:|-------:|-------:|-------:|
|0-14      | 8.513247| 0.3098548| 8.523315| 7.93590| 9.31863| 1.38273|
|15-24     | 8.338087| 0.4034589| 8.322110| 7.42417| 9.31707| 1.89290|
|25-34     | 8.386406| 0.3963123| 8.385970| 7.39062| 9.29185| 1.90123|
|35-44     | 8.161442| 0.3827325| 8.096680| 7.48357| 9.31897| 1.83540|
|45-64     | 8.351438| 0.4480599| 8.333330| 7.26897| 9.45861| 2.18964|
|65-74     | 8.544639| 0.3181432| 8.576680| 7.95041| 8.96923| 1.01882|
|long      | 8.465667| 0.4680788| 8.530945| 7.45058| 9.49565| 2.04507|
|NA        | 8.357874| 0.4075416| 8.358545| 7.28220| 9.08612| 1.80392|

That's more like it! Well, kind of. Pretty much. I guess.  

Ah well, let's do networks.

#### Ratings by network

That's tough one, since I can't possibly fit all the networks (and there are apparently 133 of them) in a graph, so I'm not sure whether it's best to just take the n networks with the most shows and run with them, but since being methodologically sound isn't really what this blogpost is about, I'll just go for that.


```r
ntwks <- shows.popular %>% group_by(network) %>% tally %>% arrange(desc(n)) %>% head(10)
temp  <- shows.popular %>% filter(network %in% ntwks$network)

ggplot(data = temp, aes(x = rating, fill = network)) +
  geom_density(alpha = .5) +
  labs(title = "The 1000(ish) Most Popular Shows on trakt.tv\nTop 10 Networks",
       x = "Rating", y = "Density", fill = "Network")
```

![](/images/shows_files/figure-html/show_ratings_network-1.png)

Cursed be you, depressingly yet unsurprisingly evenly distributed ratings.   
Let's try one last thing.

#### Ratings by show status


```r
ggplot(data = shows.popular, aes(x = rating, fill = status)) + 
  geom_density(alpha = .8) +
  labs(title =  "The 1000(ish) Most Popular Shows on trakt.tv\nBy Status",
       x = "Rating", y = "Density", fill = "Status")
```

![](/images/shows_files/figure-html/plots_showstatus-1.png) 

…So I guess some of these cancelled shows were cancelled for a reason.  
Hey, at least it's a noticeable result, and we don't have a lot of those here.

Okay, I don't feel like playing this game anymore, so I'll just move to the episode data, since that's what took most of the time of the initial data collection anyway.

## Episode data

Finally, let's look at those episode ratings.


```r
ggplot(data = episodes.popular, aes(x = rating)) +
  geom_histogram(binwidth = .1) +
  scale_x_continuous(limits = c(0,10), breaks = seq(0, 10, by = .5)) +
  labs(title = "Rating Distribution of the Episodes of the 1000(ish) Most Popular Shows on trakt.tv",
       x = "Rating", y = "Count")
```

![](/images/shows_files/figure-html/episode_ratings-1.png)

That looks a lot like the show rating distribution. Mind. Blown.  

Seriously though, I wonder how big the difference between the two really is. If I've learned anything from looking at shows on [trakt.jemu.name](http://trakt.jemu.name), it's that average episode rating and show rating tend to differ, sometimes even a lot.


```r
eptemp        <- episodes.popular %>% group_by(.id) %>% summarize(mean.rating = mean(rating, na.rm = T))
names(eptemp) <- c("slug", "rating")
eptemp$type   <- "Episode Mean"
showtemp      <- shows.popular[c("slug", "rating")]
showtemp$type <- "Show"
temp          <- rbind(eptemp, showtemp)

ggplot(data = temp, aes(x = rating, fill = type)) +
  geom_density(alpha = .7) +
  labs(title = "The 1000(ish) Most Popular Shows on trakt.tv\nShow vs. Episode Ratings",
       x = "Rating", y = "Density", fill = "Rating Type")
```

![](/images/shows_files/figure-html/episode_show_ratings-1.png)

Hm. I think I might have expected there to be at least a *little* offset, but it's nice to see are the episode averages are a) more widespread but yet b) with a much higher peak there.  
You can read into that whatever you want, I'm just plotting stuff here.

Oh, and you might ask "Well, which shows have the biggest difference in show rating to episode average?"
and I shall gladly deliver.


```r
temp %>% group_by(slug) %>% summarize(diff = min(rating) - max(rating)) %>%
  arrange(diff) %>% filter(diff < -2) %>% knitr::kable(.)
```



|slug                  |      diff|
|:---------------------|---------:|
|the-storyteller       | -2.703490|
|katekyo-hitman-reborn | -2.528830|
|hand-of-god           | -2.462500|
|the-village-2013      | -2.403351|
|the-outer-limits-1963 | -2.093206|
|sherlock-holmes       | -2.012357|

Might as well take it from there and plot the ratings for the shows with the highest difference.


```r
bigdiff <- temp %>% group_by(slug) %>% summarize(diff = min(rating) - max(rating)) %>%
             arrange(diff) %>% filter(diff < -2)
bigdiff <- temp %>% filter(slug %in% bigdiff$slug)

ggplot(data = bigdiff, aes(x = slug, y = rating, fill = type)) +
  geom_bar(stat = "identity", position = "dodge", colour = "black") +
  labs(title = "Show and Episode Rating Averages: The Biggest Differences",
       x = "Show", y = "Rating", fill = "Rating Type")
```

![](/images/shows_files/figure-html/episode_show_diff-1.png)

## Conclusion

Most of this is pretty pointless. But I had fun, and I hope somebody out there had fun, too.  
The limitations with this are fairly obvious, since I'm not analyzing a randomized sample of the trakt.tv data, everything here is biased beyond repair if you were to make generalized statements about *all* shows, but thankfully none of my results actually yielded anything that justified that.  
There could be a lot more in this, for example, I haven't even touched the `votes` variables, which would probably be a good thing to use as a weighting variable.  

Oh well, I'm tired.

## Footnote about that data collection

Just for the record, when I diff the timestamps I included in the pull, apparently this data collection took me about this long:


```r
times <- plyr::ldply(list.popular, function(x) x$timestamp)$V1
max(times) - min(times)
```

```
## Time difference of 48.97511 mins
```

```r
# Subtract that .5 second pause time
as.numeric(max(times) - min(times)) - (1000*0.5)/60
```

```
## [1] 40.64177
```

That's a solid **40 minutes** in total the trakt API has spent throwing data at me. Okay, subtract a little to debug, add in filters and restart the loop, but still. It took a while.

### Full disclosure

* [Here's the .Rmd](http://dump.jemu.name/shows.Rmd)
* [Here's the `knit` html, which looks a little nicer](http://dump.jemu.name/shows.html)

