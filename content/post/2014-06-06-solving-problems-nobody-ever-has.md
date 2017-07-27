---
title: Solving problems nobody ever has
author: Jemus42
date: '2014-06-06'
categories:
  - rstats
---

<small>Remember that last post?  
No?  
Good. Then don't scroll down. Or do. Idunno.</small> 

One thing I wanted for my more-or-less-automated TV show plots was appropriate colors to differentiate seasons.  
I assume that's a problem we can all relate to.
<!-- more -->

Of course in the R and ggplot2 bubble, there's the `RColorBrewer` package that provides nice and easy color palettes of varying sizes. But that's boring.  
Also, repetitive.  

So let's fix that.

## What do we have?
We have the season posters, or at least the season boxset covers. Can't be too hard to get a color from those, right?  
As you can see from the [Stargate SG-1 season posters on this page](http://trakt.tv/show/stargate-sg1), they mostly have distinct colors. Mostly. But alas, trakt apparently didn't get a consistent set of season posters, so I had to fill in the blanks via google image searches.  

Like a fucking animal.

Well then. Once I downloaded all the season images, I tried to figure out how to determine the average/most dominant/whatever color for each image. Thankfully I have a full blown [L3viathan](https://twitter.com/l3viathan2142) at my disposal, who pointed me at [imagemagick](http://imagemagick.org).  
And as it turned out, `convert file.png -filter box -resize 1x1! -format "%[pixel:u]" info:` actually did a decent job.  
For the first season cover of *SG1*, the output looks like this: `srgb(57,91,121)` – And I can live with that.  
Blatantly ignoring the leading 's', I used these values to get a list of rgb colors in R, starting by putting numbers in vectors in a list:

```r
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
```

Once again: Manually. Like a fucking animal.

Now I had a bunch of decimal vectors representing rgb colours(ish), how convenient.  

Two problems:  
1. ggplot2 wants rgb hex strings in the common `#RRGGBB`format  
2. The colors were too dark to look nice and be easily distinguishable

The solution to the first problem is simple: R's `rgb()` function in the base tools is sufficient.  
The second problem, however, is funky.  
After messing around with the `hcl` and `hsv` functions, I concluded that the proper™ way to increase the color's luminance ("making it brighter" in fancy terms) wasn't going to work as easy as I thought, and I *really* didn't want to spend another day or two reading about color theory and perception as I did for the *Wurstmineberg people favColor conundrum* of months past – So I did the honorable thing and resorted to L3viathan's original suggestion to just `+50` that shit and walk away.  
And I did.

```r
# Adding enough to not go over 255
sg1.cols.num <- lapply(sg1.cols.num, '+', 67) 
# Converting to rgb
sg1.cols     <- sapply(sg1.cols.num, function(s){
                        rgb(s[1], s[2], s[3], maxColorValue = 255)
                      })
```

Another fine example for the handyness of the `*apply`function family in R, no `for`was shed that day.

# Going the extra mile

That was not enough.  
I can pull the season poster urls from trakt just the same way I pulled the ratings, titles and whatnot in the last post, so why not use them directly?  
Get the poster url, download it, throw imagemagick at it, capture the output, parse it as an R expression so it's used as a vector, throw a bunch of numbers at it so it's "brighter" (yes, color theory, perception, I know, **I KNOW**  <small>don't yell at me I know it's sketchy</small>), convert to rgb and attach to the `data.frame`that contains all the other season data. Should be reasonably useless to do, so I did it, and here it is:  

```r
getSeasonColorsFromPosters <- function(show, coverdir = "covers"){
  if (!file.exists(coverdir)){
    warning("coverdir not found, trying to create it…")
    dir.create(coverdir)
  }
  # Downloading the season posters
  l_ply(show$seasons$poster, function(image){
    showname <- gsub(" ", "_", show$summary$title)
    season   <- as.character(show$seasons$season[show$seasons$poster == image])
    filename <- paste0(showname, "_Season_", season, ".jpg")
    
    if (!file.exists(paste0(coverdir, "/", filename))){
      cmd      <- paste0("cd ", coverdir, "; wget -O ", filename, " ", image)
      print(cmd)
      system(cmd)
    } else {
      message(paste("File", filename, "already exists"))
    }
    # Getting the avg color info
    cmd    <- paste0("convert ", coverdir, "/", filename, " -filter box -resize 1x1! -format '%[pixel:u]' info:")
    avgcol <- system(cmd, intern = TRUE)
    avgcol <- sub("srgb", "c", avgcol)
    avgcol <- eval(parse(text = avgcol))
    
    # Adjusting the color a little, converting to rgb, delivering
    avgcol     <- avgcol + ((255 - max(avgcol))/2)
    avgcol.rgb <- rgb(avgcol[1], avgcol[2], avgcol[3], maxColorValue = 255)
    show$seasons$col.rgb[show$seasons$season == season] <<- avgcol.rgb
  })
  return(show)
}

## Usage: 
got <- trakt$getFullShowData("Game of Thrones")
got <- getSeasonColorsFromPosters(got)

## Example plot
library(ggplot)
p <- ggplot(got$episodes)
p <- p + aes(x = season, y = rating, fill = season)
p <- p + geom_boxplot()
## Using our values stored in got$seasons$col.rgb
p <- p + scale_fill_manual(name = "Season", values = got$seasons$col.rgb)
p <- p + labs(title = "Game of Thrones: Trakt.tv Episode Ratings Per Season",
              y = "Ratings (%)", x = "Season")
print(p)
```

Piece of cake. Glorious, delicious cake.  
As I pointed out before, the *SG1* season posters on trakt are inconsistent, so I'll use the *Game of Thrones* posters as an example. They have nice distinct colors, so that should do well.

![](http://dump.quantenbrot.de/x6CJDvXL2PQ5kQrypbbuHr0.png)
![](http://stuff.wurstmannberg.de/tRakt/GoT_seasons_ratings_boxplots.png)

Well… Good enough.  
I can still adjust how much actually gets added in the makeshift brightness™ adjustion step, but oh well.  
At least it's automated now.  

Of course, the trakt stuff requires the functions of [that thing I did last time](https://github.com/jemus42/tRakt).



