---
title: I just wanted to rewatch Stargate
description: "When one thing leads to another and you accidentally write a small API wrapper"
author: jemus42
date: '2014-06-05'
tags:
  - trakt.tv
shows: 
  - Stargate SG-1
---

Stargate SG-1, while probably a mediocre show in the grand scheme of sci-fi shows, it's the sci-fi show I grew up with, so I tend to enjoy rewatching parts of it occasionally.  
Well, at least I rewatched it twice so far.  
The full thing. 10 seasons.  
Yep. Even those last two.  

So this time, I wanted to cherry-pick the good™ episodes, and of course efficient cherry-picking in 2014 involves [R](https://www.r-project.org), the [trakt.tv API](https://trakt.tv/api-docs/show-episode-summary) and a bunch of plots.  
Because plots.

## Methodology™ <small>(i.e. "Stuff I did")</small>

### Step 1: Acquire data  <small>(You can prepend this step by disregarding something else, if you like)</small>  

Over the past few months, I've grown more and more comfortable using R, spawning a bunch of projects with varying longevity. Naturally, I started this one by thinking "There's an API, JSON falls out, I can do JSON, shouldn't be that hard" and who would have guessed, it really wasn't.

So, where do we start. I suggest you start by getting your API key, which you can see [here, if you're logged in](https://trakt.tv/api-docs/authentication).  
I suggest you put that in a .gitignore'd text file if you intend to publish anything you did, or at least you should know that I did, for it shall make the next stuff more understandable.  
You can read you key from a, for example, JSON file and store it as an `option`, which seems to be the preferred way to store API keys or passwords, since R options don't linger around in your workspace. Or something. To be honest, I have no idea. I've seen it done this way on other projects and thought it was neat. There. I said it. Can we move on now? Okay.

Soo… Now we can start by getting a show overview
I started by creating an empty `object`called `trakt`, which will serve as our collective `thing with the trakt API functions and stuff in it and such ` <small>(patent pending)</small> . 

```r
library(jsonlite) # There are many JSON packages in R, and I chose this one. YMMV.
library(httr)     # Because internetz

options(trakt.apikey = fromJSON("key.json")$apikey) # File "key.json" contains an 'apikey' field

trakt <- list() # Creating the empty object
 
trakt$show.summary <- function(target, apikey = getOption("trakt.apikey"), extended = NULL){
  baseURL <- "https://api.trakt.tv/show/summaries.json/"
  url     <- paste0(baseURL, apikey, "/", target)
  if (!is.null(extended)){
    url   <- paste0(url, "/", extended)
  }
  response <- fromJSON(url)
  return(response)
}

trakt$getSeasons <- function(query, dropspecials = TRUE, apikey = getOption("trakt.apikey")){
  require(plyr)
  baseURL            <- "https://api.trakt.tv/show/seasons.json/"
  query              <- paste0(baseURL, apikey, "/", query)
  show.seasons       <- fromJSON(query)
  if (dropspecials){
    show.seasons     <- show.seasons[show.seasons$season != 0, ] 
  }
  show.seasons       <- show.seasons[!(names(show.seasons) %in% c("url", "poster", "images"))]
  show.seasons       <- arrange(show.seasons, season)
  return(show.seasons)
}
```

That should be enough to get started. The `target`in these functions refers to either the TVDB ID of the show (I'll get to that) or the *slug*, i.e. that part of the show URL that's basically the name, i.e. for `https://trakt.tv/show/stargate-sg1` the slug would be `stargate-sg1`. While that's easy to find and remember, I rather implemented the search API to get basic show info and extract the TVDB ID from that for further use, like this: 

```r
trakt$search <- function(query, apikey = getOption("trakt.apikey"), limit = 1){
  query    <- as.character(query) # Just to make sure…
  query    <- gsub(" ", "+", query) # _Not_ perfect URL normalization
  url      <- paste0("https://api.trakt.tv/search/shows.json/", apikey, "?query=")
  query    <- paste0(url, query, "&limit=", limit)
  response <- fromJSON(query)
  return(response)
}

# Example usage:
SG1                 <- list()
SG1$info            <- trakt$search("Stargate SG1")
SG1$summary         <- trakt$show.summary(target = SG1$info$tvdb_id)
```

As you can see, I only needed to specify the target for the `trakt$show.summary ` function, since I set the default value for the `apikey`parameter to use the `trakt.apikey`option we set earlier.

So, now we got our object called `SG1` which contains the basic show info in the `info`and `summary`fields, which is a good thing, I suppose. We already defined our function to get the season data above, so why don't we just move on to that and ignore the fact that I'm slowly but surely losing control over the structure of this blogpost.

```r
SG1$seasons <- trakt$getSeasons(SG1$info$tvdb_id)

# Now look at dis
> SG1$seasons
   season episodes
1       1       22
2       2       22
3       3       22
4       4       22
5       5       22
6       6       22
7       7       22
8       8       20
9       9       20
10     10       20
```

Wheeee.  
Now we know how many seasons there are and how many episodes each season has, I guess we can use that, for, you know, ~~science~~ the next part: Getting _all_ the episode data.

```r
pad <- function(x, width = 2){
  # Simple function to ease sXXeXX epid format creation
  x <- as.character(x)
  sapply(x, function(x){
    if (nchar(x, "width") < width){
      missing <- width - nchar(x, "width")
      x.pad   <- paste0(rep("0", missing), x)
      return(x.pad)
    } else {
      return(x)
    }
  })
}

library(plyr)
initializeEpisodes <- function(show.seasons){ 
  show.episodes       <- ddply(show.seasons, .(season), summarize, episode = 1:episodes)
  show.episodes$epnum <- 1:nrow(show.episodes)
  
  # Add epid in sXXeYY format, requires pad() 
  show.episodes      <- transform(show.episodes, epid = paste0("s", pad(season), "e", pad(episode)))
  show.episodes$epid <- factor(show.episodes$epid, ordered = TRUE)
  return(show.episodes)
}

trakt$getEpisodeData <- function(query, show.episodes, apikey = getOption("trakt.apikey"), dropunaired = TRUE){
  require(lubridate)
  # Episode summary API https://trakt.tv/api-docs/show-episode-summary
  baseURL <- "https://api.trakt.tv/show/episode/summary.json/"
  
  # Making the API calls and storing the responses as parts of the episode set
  for (epnum in show.episodes$epnum){
    season    <- show.episodes$season[epnum]
    episode   <- show.episodes$episode[epnum]
    query.url <- paste0(baseURL, apikey, "/", query, "/", season, "/", episode)
    response  <- fromJSON(query.url)
    
    show.episodes$title[epnum]          <- response$episode$title
    show.episodes$url.trakt[epnum]      <- response$episode$url
    show.episodes$firstaired.utc[epnum] <- response$episode$first_aired_utc
    show.episodes$id.tvdb[epnum]        <- response$episode$tvdb_id
    show.episodes$rating[epnum]         <- response$episode$ratings$percentage
    show.episodes$votes[epnum]          <- response$episode$ratings$votes
    show.episodes$loved[epnum]          <- response$episode$ratings$loved
    show.episodes$hated[epnum]          <- response$episode$ratings$hated
    show.episodes$overview[epnum]       <- response$episode$overview
  }
  show.episodes$firstaired.posix <- as.POSIXct(show.episodes$firstaired.utc, 
                                              origin = origin, tz = "UTC")
  show.episodes$year             <- year(show.episodes$firstaired.posix)
  
  # Convert seasons to factors because ordering
  show.episodes$season           <- factor(show.episodes$season, 
                                            levels = as.character(1:max(show.episodes$season)), 
                                            ordered = T)
  show.episodes$src  <- "Trakt.tv"
  
  if (dropunaired){
    show.episodes <- show.episodes[show.episodes$firstaired.posix <= now(tzone = "UTC"), ]
  }
  return(show.episodes)
}

# Example usage:
SG1$episodes        <- initializeEpisodes(SG1$seasons)
SG1$episodes        <- trakt$getEpisodeData(query = SG1$info$tvdb_id, show.episodes = SG1$episodes)
```

The second function, `initializeEpisodes`, sounds funky, but really ~~isn't~~ is.  
The idea is to use the `SG1$seasons`object to get a template for the episodes dataset, y'know, one row for every episode with episode number, season, and episode ID in the common sXXeYY format (which requires the `pad`function above). 
The next part is the biggie: Getting the info for each and every episode of the show, which requires a lot of API calls (At least for shows like *SG-1* with >200 episodes). You could probably be smarter about the way the calls are made, like for example making use of the `*apply`family of functions to get rid of the legacy-looking `for`loop (Because if there's one thing I learned about R, it's that for loops are boring and slow and smell funky, and vectorization and `lapply`-like functions are totally fine & dandy & such).  
Also, you probably don't need to inititalize the episode dataset like I did, but I did. And now it's there.

And now, we're pretty much good to go. What you got now is a `data.frame`in `SG1$episodes`that contains all the episode data: Episode number, ID, season, title, rating, url, how many votes it got and whatnot. Even the `overview`field is included, because *#YOLOSWAG* or whatever. 
You also have the season data in `SG1$seasons`, which is kind of boring. Let's throw some more data at that.

```r
SG1$seasons         <- join(SG1$seasons , ddply(SG1$episodes, .(season), summarize, 
                                                   avg.rating.season     = round(mean(rating), 1),
                                                   rating.sd             = sd(rating),
                                                   top.rating.episode    = max(rating),
                                                   lowest.rating.episode = min(rating)))
# Seasons can be viewed as distinct categories, right?
SG1$seasons$season  <- factor(SG1$seasons$season, 
                                   levels = as.character(1:nrow(SG1$seasons)), ordered = T)

```

So, through the power that is [plyr](https://plyr.had.co.nz/), we used `SG1$episodes`to append extra columns to `SG$seasons`, namely `avg.rating.season`(average episode rating of that season), `rating.sd`(standard deviation accompanying that average), `top.rating.episode`(the highest episode rating of that season), and `lowest.rating.epiusode`(you guessed it).  
Wheee.

So, now back to my original plan: Cherry-picking episodes to watch.  
Let's get the highest rated episodes of each season, assuming that I don't want to skip an entire season:

```r
topeps <- rbind.fill(lapply(SG1$seasons$season, function(season){
  sep   <- sg1.episodes[sg1.episodes$season == season, ]
  topep <- sep[sep$rating == SG1$seasons$top.rating.episode[SG1$seasons$season == season], ]
}))

> topeps[c("epid", "title")]
     epid                      title
1  s01e22 Within the Serpent's Grasp
2  s02e15             The Fifth Race
3  s03e06              Point of View
4  s03e22                Nemesis (1)
5  s04e06      Window of Opportunity
6  s05e01                Enemies (2)
7  s05e21                   Meridian
8  s05e22                Revelations
9  s06e11             Prometheus (1)
10 s06e12    Unnatural Selection (2)
11 s06e22                Full Circle
12 s07e22              Lost City (2)
13 s08e02              New Order (2)
14 s09e01                 Avalon (1)
15 s09e02                 Avalon (2)
16 s09e03                 Origin (3)
17 s09e13              Ripple Effect
18 s09e20                    Camelot
19 s10e03        The Pegasus Project
```

Well if that isn't nifty.  


### Step 2: Polishizzle
I wrote the basic outline of this blogpost before I actually started thinking about what/how I wanted to put in it, and it turned out I just documented my finished™ functions, which already include most of the polishizzlage (like making factors out of stuff and constructing list objects form the get go instead of fusterclucking everything up), sooo… There's not much to add here, unless some expansions:

```r
SG1$episodes$series <- SG1$summary$title # Show title (i.e. "Stargate SG-1")
SG1$summary$tpulled <- now(tzone = "UTC") # see lubridate::now
```

### Step 3: Plotting all the things
Note: Plotting and polishing/reorganising your data tend to go hand in hand.  
When I started this, it was a back and forth of 
> "Okay, I got that data now, how do I plot this"  

to  
> "Okay, I wanna plot _that_, now how do I get that data in a usable format"

So, well, here's the basic plot I started with:

```r
#### Set a common theme ####
themes <- list(theme(axis.text  = element_text(size = 14, colour = "black")),
               theme(plot.title = element_text(size = 18, colour = "black")),
               #theme(panel.grid.minor  = element_line(linetype = "dotted")),
               theme(legend.position   = "top"),
               theme(legend.background = element_rect(colour = "black")),
               theme(legend.margin     = unit(1, "cm")),
               theme(legend.key.size   = unit(.9, "cm")),
               theme(legend.text  = element_text(size = 12)),
               theme(legend.title = element_text(size = 14)),
               theme(axis.title.y = element_text(size = rel(1.5), angle = 90, vjust = .9)),
               theme(axis.title.x = element_text(size = rel(1.5), vjust = -.5)))
# see https://docs.ggplot2.org/current/theme.html

#### Color scale for Stargate SG-1 seasons ####
# Thanks to @L3viathan2142 for 'convert file.png -filter box -resize 1x1! -format "%[pixel:u]" info:'
# TL;DR Use average color from season boxset covers, then add 67 because stuff's dark yo.
sg1.cols.num <- list("1"  = c(57,   91, 121),
                     "2"  = c(106,  73,  42),
                     "3"  = c(73,   92,  69),
                     "4"  = c(132,  51,  36),
                     "5"  = c(83,   47,  75),
                     "6"  = c(183, 114,  47),
                     "7"  = c(33,   96, 104),
                     "8"  = c(66,   25,  21),
                     "9"  = c(40,   58,  63),
                     "10"  = c(134, 149, 158))
sg1.cols.num <- lapply(sg1.cols.num, '+', 67)
sg1.cols     <- sapply(sg1.cols.num, function(s){
                        rgb(s[1], s[2], s[3], maxColorValue = 255)
                      })
# Now, the actual plot
p <- ggplot(data = SG1$episodes)
p <- p + aes(x = firstaired.posix, y = rating, colour = season)
p <- p + geom_smooth(method = lm, se = T, size = 2)
p <- p + geom_point(size = 4, colour = "black") + geom_point(size = 3)
p <- p + labs(title = "Stargate SG-1: Trakt.tv Episode Ratings",
              x = "Original Airdate", y = "Ratings (%)")
p <- p + scale_x_datetime(labels = date_format("%Y"),
                          breaks = date_breaks("years"),
                          minor_breaks = date_breaks("months"))
p <- p + scale_colour_manual(name = "Season", values = sg1.cols)
p <- p + themes
```

And that gives you the plot from the post title.  
I did a whole bunch of other plots which you can find [here](https://stuff.wurstmannberg.de/tRakt/)
and look at how I made them [here](https://github.com/jemus42/tRakt).  

It's fun.

### Step 4: Generalizzle

After some testing, restructuring and putting-stuff-into-functions'ing, we can now recreate datasets for any other TV show on Trakt, for example: House, MD:

```r
trakt$getFullShowData <- function(searchquery = NULL, tvdb_id = NULL, dropunaired = TRUE){
  show               <- list()
  if (!is.null(searchquery)){
    show$info        <- trakt$search(searchquery)
    tvdb_id          <- show$info$tvdb_id
  } else if (is.null(searchquery) & is.null(tvdb_id)){
    stop("You must provide either a search query or a TVDB ID")
  }
  show$summary         <- trakt$show.summary(tvdb_id)
  show$seasons         <- trakt$getSeasons(tvdb_id)
  show$episodes        <- initializeEpisodes(show$seasons)
  show$episodes        <- trakt$getEpisodeData(tvdb_id, show$episodes, dropunaired = dropunaired)
  show$seasons         <- join(show$seasons , ddply(show$episodes, .(season), summarize, 
                                                   avg.rating.season     = round(mean(rating), 1),
                                                   rating.sd             = sd(rating),
                                                   top.rating.episode    = max(rating),
                                                   lowest.rating.episode = min(rating)))
  show$seasons$season  <- factor(show$seasons$season, 
                                   levels = as.character(1:nrow(show$seasons)), ordered = T)
  show$episodes$series <- show$summary$title
  show$summary$tpulled <- now(tzone = "UTC")
  
  return(show)
}

# Example usage
house <- trakt$getFullShowData("House MD")
names(house)
# [1] "info"     "summary"  "seasons"  "episodes"
```

(/¯◡ ‿ ◡)/¯ ~ And there you go. 

You can use these new datasets pretty much interchangeably with the SG1 set, so you can plug them in any existing plotting code, adjust the labels and whatever else comes to mind, and you're good to go.

The next step would be to put that stuff in a [shiny](https://shiny.rstudio.com/) app, but before I can do that I need to figure out how to make the plots web-friendly (i.e. labeling dots), the interactivity side of that should be sufficiently covered by shiny itself, and maby [ggvis](https://github.com/rstudio/ggvis/), but Idunno, I kind of have other stuff to do these days.  
Not that this has ever stopped me from procrastinating, but oh well, you know the drill. 

## Conclusion
I just wanted to rewatch Stargate, and then I accidentally built a set of functions that enabled me to easily retrieve show data from Trakt.tv and plot all the things with a few lines of code.  
Whoopsie.  

[Idunnolol](https://twitter.com/ekelias/status/472824579195695105)
