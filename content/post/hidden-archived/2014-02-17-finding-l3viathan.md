---
title: Finding L3viathan
author: jemus42
date: '2014-02-17'
categories:
  - rstats
tags:
  - location data
  - needs revisit
packages:
  - ggplot2
  - maps
draft: true
---

Neulich hatte [L3viathan](https://twitter.com/l3viathan2142) seine [openpaths](http://openpaths.cc)-Locationdaten ver[gist](https://gist.github.com/L3viathan/24a49504c75ef92625a2)ed, und da ich Spaß an R habe und neulich ja schon Dinge zu ebenjenem Anwendungsfall schrob, warf ich dann mal ein paar Dinge drauf. Hier so das Ergebnis.

<!-- more -->
## L3vipaths

This uses l3vi's location data. For ~~science~~ shits 'n giggles.  

### Importing the data in R

```r load it read it rename it convert it factor it sort it attach it
library(rjson)
library(ggplot2)
library(maps)
library(ggmap)

l3vipaths <- fromJSON(file = "l3vi.json")
paths <- do.call("rbind", lapply(l3vipaths, as.data.frame))

names(paths)[names(paths) == "t"] <- "date"
### Date conversion & cleanup
paths$date <- as.POSIXlt(paths$date, origin = "1970-01-01")
paths$weekday <- factor(weekdays(paths$date))
paths$weekday <- factor(paths$weekday, levels(paths$weekday)[c(2, 6, 7, 5, 1, 
    3, 4)])
paths$month <- factor(months(paths$date))
paths$month <- factor(paths$month, levels(paths$month)[c(4, 1, 3, 2)])
paths$alt[paths$alt == 0] <- NA
paths <- paths[c("lon", "lat", "alt", "date", "weekday", "month", "device", 
    "os", "version")]

attach(paths, warn.conflicts = F)
head(paths, 3L)
```

```
##     lon   lat alt                date   weekday    month   device  os
## 1 7.024 49.28  NA 2013-11-12 22:09:35   Tuesday November LGE mako 4.3
## 2 7.024 49.28  NA 2013-11-12 22:49:35   Tuesday November LGE mako 4.3
## 3 7.024 49.28  NA 2013-11-13 08:49:36 Wednesday November LGE mako 4.3
##   version
## 1     1.0
## 2     1.0
## 3     1.0
```

### First up: A summary.

```r
summary(paths)
```

```r
##       lon             lat            alt       
##  Min.   : 6.99   Min.   :48.0   Min.   : 94.6  
##  1st Qu.: 7.02   1st Qu.:49.2   1st Qu.:251.7  
##  Median : 7.02   Median :49.3   Median :265.8  
##  Mean   : 7.25   Mean   :49.3   Mean   :267.7  
##  3rd Qu.: 7.04   3rd Qu.:49.3   3rd Qu.:289.2  
##  Max.   :13.39   Max.   :52.5   Max.   :344.3  
##                                 NA's   :1787   
##       date                          weekday         month    
##  Min.   :2013-11-12 22:09:35   Friday   :351   December:523  
##  1st Qu.:2013-12-05 18:34:47   Monday   :296   February:353  
##  Median :2014-01-11 23:43:33   Saturday :288   January :786  
##  Mean   :2014-01-02 08:30:17   Sunday   :202   November:335  
##  3rd Qu.:2014-01-27 11:27:10   Thursday :410                 
##  Max.   :2014-02-14 13:56:23   Tuesday  :306                 
##                                Wednesday:144  
##               
##       device         os       version   
##  LGE mako:1997   4.3  : 236   1.0:1997  
##                  4.4  : 489             
##                  4.4.2:1272             
```


### A circle-function I stole from some stackoverflow answer

```r Defining a function like a bauhau5  
circleFun <- function(center = c(0, 0), diameter = 1, npoints = 100) {
    r = diameter/2
    tt <- seq(0, 2 * pi, length.out = npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    return(data.frame(x = xx, y = yy))
}
```

…Which is quite handy, because now we can draw a makeshift "circle" around the mean location with the standard deviations of lon / lat as radius.  
The fancy way to do this would be to draw confidence ellipsis, but that would involve either math or actual knowledge of what the fuck I'm doing.

```r
circ <- circleFun(c(mean(paths$lon), mean(paths$lat)), mean(c(sd(paths$lon), 
    sd(paths$lat))), npoints = 100)
```

<small>Always store your circles as a list of points, ma daddy used to say</small>

### Look, a map

```r
map <- get_map(location = "Germany", zoom = 6, scale = "2", maptype = "hybrid", 
    messaging = FALSE)
```


```r
## Brew custom color scale
monthColors <- brewer.pal(5,"Set1")
names(monthColors) <- levels(paths$month)
colScale <- scale_colour_manual(name = "Month",values = monthColors)

## Plot stuff
ggmap(map) +
  geom_point(data=paths, 
            aes_string(y='lat', x='lon', 
            colour='month'), 
            alpha=.7,
            size=2)  +
 geom_path(data=circ, 
            aes_string(x='x',y='y'), 
            colour="black",
            size=1) + colScale
```

![Locationplot](/images/locationplot.png) 

This is nice 'nall, but now…

### ENHANCE

```r
# Getting the map from Google
map.closeup <- get_map(location = "Saarbrücken", zoom = 12, scale = "2", maptype = "roadmap", 
    messaging = FALSE)

ggmap(map.closeup) + geom_point(data = paths, aes_string(y = "lat", x = "lon", 
    colour = "month"), alpha = 0.7, size = 2) + colScale
```

![closeup](/images/closeup.png) 

### MOAR METADATA

```r
# OKAY OKAY
map.days <- get_map(location = "49.2600 7.0200", zoom = 13, scale = "2", maptype = "roadmap", 
    messaging = FALSE, color = "bw")

ggmap(map.days) +
  geom_point(data=paths, 
            aes_string(y='lat', x='lon', 
            colour='paths$weekday'), 
            alpha=.7,
            size=2) +
  scale_colour_discrete(name = "Weekday") + 
  geom_path(data=paths, aes_string(y='lat', x='lon', 
                                   colour='paths$weekday'),
            alpha=.3)
```

![closeup.days](http://dump.quantenbrot.de/byDay.png) 

### MOAAAAAAR!

```r
# Jeez… Calm down.

ggmap(map.closeup2) + geom_point(data = paths, aes_string(y = "lat", x = "lon", 
    colour = "factor(as.numeric(format(paths$date, \"%H\")))"), alpha=.4, size = 2) + 
    scale_colour_discrete(name = "Hour") + theme(legend.position = "top")
```

![closeup.hours](http://dump.quantenbrot.de/byHourAlphaLines.png)   

<small>This graph includes connection lines not produced by the code above, there's a bunch of `geom_path()` missing and I was to lazy to fix that. See the plot above for a code reference</small>

### Getting some arbitrary statisticy-looking values

#### Some means 

* Mean latitude: **49.3317**
* Mean longitude: **7.2546**
* Mean altitude: **267.69**

#### Some standard deviations

* Latitude: **0.5955**
* Longitude: **1.02**
* Altitude: **34.7839**

#### Minimum & maximum values:

* Latitude: From **47.9771** to **52.547** (range: **4.5699**)
* Longitude: From **6.9864** to **13.3907** (range: **6.4043**)
* Altitude: From **94.6** to **344.3** (range: **249.7**)

#### Points at the edges

```r
paths[lon == max(lon), c("lon", "lat", "date")]
```

```
##       lon   lat                date
## 342 13.39 52.49 2013-12-01 03:48:30
```

```r is where
paths[lat == max(lat), c("lon", "lat", "date")]
```

```
##       lon   lat                date
## 355 13.13 52.55 2013-12-01 13:58:05
```

```r 
paths[lon == min(lon), c("lon", "lat", "date")]
```

```
##      lon   lat                date
## 29 6.986 49.23 2013-11-14 15:29:13
```

```r
paths[lat == min(lat), c("lon", "lat", "date")]
```

```
##       lon   lat                date
## 562 7.819 47.98 2013-12-07 11:34:49
```

### Do you even distances?

Looking at the points at the edges from the previous section, I wanted to calcualte the distances between the `max(lon)` and `min(lon)` point, so I did this: 

```r
sqrt(sum((c(lon[342], lat[342]) - c(lon[29], lat[29]))^2))
```

```
## [1] 7.185
```

…Which turned out to be pretty dumb, since, you know, geo-stuff.
So then I used [this](http://www.r-bloggers.com/great-circle-distance-calculations-in-r/) to define this function:

```r 
# Calculate the geodesic distance between two points specified by radian
# latitude/longitude using the Haversine formula (hf)
gcd.hf <- function(long1, lat1, long2, lat2) {
    long1 <- long1 * pi/180  # Converting degrees to radians
    lat1 <- lat1 * pi/180
    long2 <- long2 * pi/180
    lat2 <- lat2 * pi/180
    R <- 6371  # Earth mean radius [km]
    delta.long <- (long2 - long1)
    delta.lat <- (lat2 - lat1)
    a <- sin(delta.lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta.long/2)^2
    c <- 2 * asin(min(1, sqrt(a)))
    d = R * c
    return(d)  # Distance in km
}
```

And now we can do theoretical, non-practical calculations to determine that L3vis longitudinal movement spans…

```r
gcd.hf(lon[342], lat[342], lon[29], lat[29])
```

```
## [1] 576.9
```

…Kilometers.  
Which is nice, I guess?  
So now we do the same for the latitudal min/max points:

```r
gcd.hf(lon[355], lat[355], lon[562], lat[562])
```

```
## [1] 632.5
```

Wheee.  

Now let's sum up the distances between *every* point. Because I just figured out how.

```r
dist = numeric(length = length(paths$lon))

for (i in 1:(length(dist) - 1)) {
    dist[i] = gcd.hf(lon[i], lat[i], lon[i + 1], lat[i + 1])
}

sum(dist)
```

```
## [1] 2679
```

…That's a number (of kilometers, in case you forgot).

Here's some more stuff about the distances, which is… not really meaningful, but lol, have you looked at the rest of this page.

* Mean: **1.3416 km**
* Standard deviation: **8.7683 km**
* median: **29.8299 meters** 

Now we look at monthly distance summaries.

#### November

```r
dist.november = numeric(length = length(paths[paths$month == "November", c(1, 
    2)][, 1]))

for (i in 1:(length(dist.november) - 1)) {
    dist.november[i] = gcd.hf(paths[paths$month == "November", c(1, 2)][i, 1], 
        paths[paths$month == "November", c(1, 2)][i, 2], paths[paths$month == 
            "November", c(1, 2)][i + 1, 1], paths[paths$month == "November", 
            c(1, 2)][i + 1, 2])
}

sum(dist.november)
```

```
## [1] 852.4
```
#### December
```r Do you like titlebars?
dist.december = numeric(length = length(paths[paths$month == "December", c(1, 
    2)][, 1]))

for (i in 1:(length(dist.december) - 1)) {
    dist.december[i] = gcd.hf(paths[paths$month == "December", c(1, 2)][i, 1], 
        paths[paths$month == "December", c(1, 2)][i, 2], paths[paths$month == 
            "December", c(1, 2)][i + 1, 1], paths[paths$month == "December", 
            c(1, 2)][i + 1, 2])
}

sum(dist.december)
```

```
## [1] 1448
```
#### January
```r I do. I really do.
dist.january = numeric(length = length(paths[paths$month == "January", c(1, 
    2)][, 1]))

for (i in 1:(length(dist.january) - 1)) {
    dist.january[i] = gcd.hf(paths[paths$month == "January", c(1, 2)][i, 1], 
        paths[paths$month == "January", c(1, 2)][i, 2], paths[paths$month == 
            "January", c(1, 2)][i + 1, 1], paths[paths$month == "January", c(1, 
            2)][i + 1, 2])
}

sum(dist.january)
```

```
## [1] 211.5
```

____
Und das war's auch schon. Es ist nicht wirklich erkenntnisfördernd, ich weiß. Und ja, bestenfalls funky math an manchen Stellen, aber… Ja, DM;HD.  

Das dazugehörige repository liegt jedenfalls [hier rum](https://github.com/jemus42/L3vipaths).
