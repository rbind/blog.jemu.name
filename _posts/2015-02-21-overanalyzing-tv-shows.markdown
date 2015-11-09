---
layout: post
title: "Overanalyzing TV Shows"
date: 2015-02-21 00:10
comments: true
categories: [rstats, tvshows]
published: true
   
---

Overanalyzing tv shows has kind of become my jam. So why not totally overdo it.  
Note that everything I describe in this blogpost is purely for the lulz, and I don't 
pretend there's any scientific merit to it. I just like throwing maths at data.

After I more or less succesfully [plotted all the things](http://trakt.jemu.name), I wanted to 
go full blown statisticy on the subject. While my knowledge of statistics isn't nearly as extensive as I'd like it to, I at least know a little about comparing groups. So, that's pretty much the plan.

## Methodology(ish)

The basic idea is simple: I pull the episode data from [trakt.tv](https://trakt.tv) and receive a nice `data.frame` with episode numbers, season number, ratings (0-10) and much more. Assuming that seasons are a decent way of dividing a tv show into groups, I'll be using them exactly as such. The variable we're interested in comparing is the rating, provied by the trakt.tv userbase.  
Using that information we can perform an analysis of variance (ANOVA), with the `aov()` function. If it yields any signicificant results, we then perform the `TukeyHSD` test for post-hoc analysis to find the season comparison with the significant results (i.e. lowest p-value). And yes, I know the p-value in itself is at least a little controversial, and the whole plan might sound completely rubbish to you, but please keep in mind that I'm only doing this for fun.

## Acquiring the Data

This step is pretty simple thanks to the work I did with my [tRakt package](https://github.com/jemus42/tRakt) which allows us to pull the data we want in a few simple steps. I'll also start by loading some packages I intend on using throughout this blogpost. The idea is that you can aggregate all the code in this post and thereby reliably reproduce my results. Because that's how I like to science.


```r
library(tRakt)   # To get the data. Get it via devtools::install_github("jemus42/tRakt")
library(dplyr)   # Because convenience
library(ggplot2) # In case of plot
library(grid)    # For some ggplot2 theme specs
library(scales)  # Primarily for pretty_breaks() in plots
library(broom)   # To pretty up output of tests & models
library(knitr)   # For simple tables via knitr::kable

if (is.null(getOption('trakt.client.id'))){
  get_trakt_credentials(client.id = "12fc1de7671c7f2fb4a8ac08ba7c9f45b447f4d5bad5e11e3490823d629afdf2")
}
```

Now we're all set. At this point, we can pull the episode data via `trakt.getEpisodeData(slug, season_nums)`, so if we were to look at Game of Thrones (and we will), we'd call `trakt.getEpisodeData("game-of-thrones", 1:4)`.  

So, why not get started on that.

## Analyzing all the things

### Game of Thrones. 


```r
got <- trakt.getEpisodeData("game-of-thrones", 1:4)

# Glance at the data
got %>% select(season, episode, rating) %>% head %>% kable
```



|season | episode|  rating|
|:------|-------:|-------:|
|1      |       1| 8.71781|
|1      |       2| 8.69333|
|1      |       3| 8.59980|
|1      |       4| 8.67709|
|1      |       5| 8.71634|
|1      |       6| 8.95462|

Now that we have the data, we can pump it through `aov()` and look at the `broom::tidy`'d data.  
Note that I pump the output through `knitr::kable`, which converts the output to a markdown table suitable for imbedding in this blogpost.


```r
m <- aov(rating ~ season, data = got) 
m %>% tidy %>% kable
```



|term        |  df|     sumsq|    meansq| statistic|   p.value|
|:-----------|---:|---------:|---------:|---------:|---------:|
|season      |  12|  9.727753| 0.8106461|   2.44357| 0.0051971|
|Residuals   | 229| 75.969984| 0.3317467|        NA|        NA|

Well, that's anticlimactic. Anyways, I assume it's safe to say that Game of Thrones is pretty consistency with it's ratings across all seasons. I hope it can keep this up for the following one to five seasons.

A neat way to look at the distributions across multiple groups is via density plots. If you're unfamiliar with them, just imagine a standard histograms (values on the x, frequencies on the y axis), but with interpolation/smoothing to produce curves. I know that's probably not the right way to think of it, but should give you an idea of what's up.


```r
ggplot(data = got, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Game of Thrones Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_got-1.png) 

What I like about this plot is how season 2 seems so neatly grouped around ~8.6 with a bump near the top of the scale, which I assume to be s02e09/s02e10. Especially season 4 on the other hand is pretty spread out, meaning there's a broader range of ratings, or at least a more even spread of ratings.

### The Simpsons 


```r
simpsons <- trakt.getEpisodeData("the-simpsons", 1:26)

m <- aov(rating ~ season, data = simpsons) 
m %>% tidy %>% kable(digits = 20)
```



|term        |  df|    sumsq|   meansq| statistic| p.value|
|:-----------|---:|--------:|--------:|---------:|-------:|
|season      |  25| 29.66348| 1.186539|  6.619908| 2.6e-19|
|Residuals   | 540| 96.78854| 0.179238|        NA|      NA|

Oh, look, a significant value. Nice. Let's throw `TukeyHSD` at it to see what sticks.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(10) %>% kable(digits = 20)
```



|comparison |   estimate|  conf.low|  conf.high|  adj.p.value|
|:----------|----------:|---------:|----------:|------------:|
|19-7       | -1.0785435| -1.548135| -0.6089522| 3.604851e-10|
|19-6       | -1.0528543| -1.522446| -0.5832630| 3.607411e-10|
|19-5       | -0.9291591| -1.412771| -0.4455471| 1.611548e-09|
|19-8       | -0.8384539| -1.308045| -0.3688626| 3.188511e-08|
|26-7       | -0.9158130| -1.438326| -0.3933001| 6.709420e-08|
|26-6       | -0.8901238| -1.412637| -0.3676109| 2.013765e-07|
|19-4       | -0.8100673| -1.293679| -0.3264553| 3.767432e-07|
|19-10      | -0.7993481| -1.277928| -0.3207686| 4.181496e-07|
|19-14      | -0.8057069| -1.289319| -0.3220949| 4.584650e-07|
|19-3       | -0.7836330| -1.257552| -0.3097136| 6.010509e-07|

Welp, that's quite a bunch of significant values. Let's look at everything with a `p < 0.0001`.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% filter(adj.p.value < 0.0001) %>% arrange(adj.p.value) %>% kable(digits = 20)
```



|comparison |   estimate|  conf.low|  conf.high|  adj.p.value|
|:----------|----------:|---------:|----------:|------------:|
|19-7       | -1.0785435| -1.548135| -0.6089522| 3.604851e-10|
|19-6       | -1.0528543| -1.522446| -0.5832630| 3.607411e-10|
|19-5       | -0.9291591| -1.412771| -0.4455471| 1.611548e-09|
|19-8       | -0.8384539| -1.308045| -0.3688626| 3.188511e-08|
|26-7       | -0.9158130| -1.438326| -0.3933001| 6.709420e-08|
|26-6       | -0.8901238| -1.412637| -0.3676109| 2.013765e-07|
|19-4       | -0.8100673| -1.293679| -0.3264553| 3.767432e-07|
|19-10      | -0.7993481| -1.277928| -0.3207686| 4.181496e-07|
|19-14      | -0.8057069| -1.289319| -0.3220949| 4.584650e-07|
|19-3       | -0.7836330| -1.257552| -0.3097136| 6.010509e-07|
|19-11      | -0.7448246| -1.228437| -0.2612126| 6.462662e-06|
|19-9       | -0.7170435| -1.186635| -0.2474522| 8.434475e-06|
|22-7       | -0.6583744| -1.115954| -0.2007951| 4.742263e-05|
|19-12      | -0.7036065| -1.192671| -0.2145421| 4.755084e-05|
|26-5       | -0.7664286| -1.301578| -0.2312797| 5.380228e-05|

I think the result is quite convincing. Seaosn 19 is, statistically speaking, the worst of The Simpsons.

I don't think a density plot would make much sense here, since there are *so many seasons*, so I'll just give you a scatterplot.


```r
ggplot(data = simpsons, aes(x = epnum, y = rating, colour = season)) +
  geom_point(size = 4, colour = "black") +
  geom_point(size = 3) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "The Simpsons Episode Ratings per Season",
       y = "Rating", x = "Episode (absolute)", colour = "Season") +
  theme(legend.position   = "top") +
  theme(legend.key.size   = unit(.3, "cm")) +
  theme(legend.text  = element_text(size = 8))
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_simpsons-1.png) 

If you want to take a closer look, try looking it up on [tRakt-shiny](http://trakt.jemu.name)
        
### Star Trek: Enterprise

As per [request](https://twitter.com/mxey), let's look how that one's doing.


```r
temp <- trakt.getSeasons("star-trek-enterprise")
ste  <- trakt.getEpisodeData("star-trek-enterprise", temp$season)

m <- aov(rating ~ season, data = ste) 
m %>% tidy %>% kable(digits = 20)
```



|term        | df|    sumsq|     meansq| statistic|      p.value|
|:-----------|--:|--------:|----------:|---------:|------------:|
|season      |  3| 1.891143| 0.63038099|   11.2564| 2.239053e-06|
|Residuals   | 94| 5.264191| 0.05600203|        NA|           NA|


Once again a significant result. From what I've been told, s04 is said to be better than the other seasons, so I guess that's what we'll be looking for here.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(10) %>% kable(digits = 20)
```



|comparison |   estimate|    conf.low| conf.high|  adj.p.value|
|:----------|----------:|-----------:|---------:|------------:|
|4-1        | 0.37190070|  0.19259503| 0.5512064| 2.663681e-06|
|4-2        | 0.28035647|  0.10105080| 0.4596621| 5.213069e-04|
|3-1        | 0.22997115|  0.05475904| 0.4051833| 4.850739e-03|
|3-2        | 0.13842692| -0.03678519| 0.3136390| 1.717332e-01|
|4-3        | 0.14192955| -0.04076828| 0.3246274| 1.837277e-01|
|2-1        | 0.09154423| -0.08012788| 0.2632163| 5.057734e-01|

Now let's look at the ratings in density-plot form. 


```r
ggplot(data = ste, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Star Trek: Enterprise Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_ste-1.png) 

Welp, it really looks like s04 was (significantly) more well-received than the other seasons.

### Futurama

A long standing favorite of mine and also a [request](https://twitter.com/l3viathan2142).
I wonder if the many many cancellations had any effect on season reception.


```r
futurama  <- trakt.getEpisodeData("futurama", 1:7)

m <- aov(rating ~ season, data = futurama) 
m %>% tidy %>% kable(digits = 20)
```



|term        |  df|    sumsq|     meansq| statistic|    p.value|
|:-----------|---:|--------:|----------:|---------:|----------:|
|season      |   6| 1.175976| 0.19599596|  2.528499| 0.02447716|
|Residuals   | 117| 9.069227| 0.07751476|        NA|         NA|

Assuming we're working with a $\alpha = 0.05$ (which I'll just say we do), that's a significant result.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(10) %>% kable(digits = 20)
```



|comparison |   estimate|    conf.low|    conf.high| adj.p.value|
|:----------|----------:|-----------:|------------:|-----------:|
|7-5        | -0.2727244| -0.53814332| -0.007305428|  0.03984142|
|7-6        | -0.1950231| -0.42669973|  0.036653574|  0.15979939|
|5-2        |  0.2191674| -0.06100816|  0.499342906|  0.23104948|
|7-3        | -0.2070487| -0.47788914|  0.063791808|  0.25594354|
|7-1        | -0.2351500| -0.55820765|  0.087907654|  0.31224961|
|7-4        | -0.1666675| -0.45818756|  0.124852559|  0.60727333|
|6-2        |  0.1414661| -0.10697945|  0.389911606|  0.61188284|
|2-1        | -0.1815930| -0.51687998|  0.153693979|  0.66656614|
|3-2        |  0.1534917| -0.13182513|  0.438808461|  0.67358861|
|4-2        |  0.1131105| -0.19190598|  0.418126984|  0.92310760|

Welp, at least the first line yields a significant result with the `.05` cutoff, so I guess you could make an argument that s05 was better than s07, but besides that it seems like Futurama was pretty consistent.  
Let's look at a plot to get a feel for that.


```r
ggplot(data = futurama, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Futurama Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_futurama-1.png) 

Yip. Seems pretty consistent to me.

### Lost

Oh screw me. Well, let's do this.


```r
temp <- trakt.getSeasons("lost-2004")
lost  <- trakt.getEpisodeData("lost-2004", temp$season)

m <- aov(rating ~ season, data = lost) 
m %>% tidy %>% kable(digits = 20)
```

|term        |  df|     sumsq|     meansq| statistic|   p.value|
|:-----------|---:|---------:|----------:|---------:|---------:|
|season      |   5| 0.2369409| 0.04738819| 0.9143534| 0.4744214|
|Residuals   | 114| 5.9082767| 0.05182699|        NA|        NA|

Huh. So I guess we'll have to take a closer look.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(5) %>% kable(digits = 20)
```



|comparison |   estimate|   conf.low| conf.high| adj.p.value|
|:----------|----------:|----------:|---------:|-----------:|
|5-2        | 0.14179679| -0.0673998| 0.3509934|   0.3689619|
|5-1        | 0.10354887| -0.1056477| 0.3127455|   0.7057793|
|4-2        | 0.09653994| -0.1253895| 0.3184694|   0.8053864|
|6-2        | 0.07775153| -0.1280154| 0.2835184|   0.8823254|
|3-2        | 0.07244252| -0.1201202| 0.2650052|   0.8842512|

I haven't watched Lost and I don't really care for it, so make of this what you will.


```r
ggplot(data = lost, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Lost Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_lost-1.png) 

### Daria

Everybody loves Daria, so don't pretend you don't know what's up.


```r
temp  <- trakt.getSeasons("daria")
daria <- trakt.getEpisodeData("daria", temp$season)

m <- aov(rating ~ season, data = daria) 
m %>% tidy %>% kable(digits = 20)
```


|term        | df|    sumsq|   meansq| statistic|    p.value|
|:-----------|--:|--------:|--------:|---------:|----------:|
|season      |  4| 172.5359| 43.13398|  3.245318| 0.01778358|
|Residuals   | 60| 797.4684| 13.29114|        NA|         NA|

Oh, well. 


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(5) %>% kable(digits = 20)
```


|comparison |  estimate|  conf.low|  conf.high| adj.p.value|
|:----------|---------:|---------:|----------:|-----------:|
|4-3        | -4.948104| -8.969813| -0.9263944| 0.008545404|
|4-2        | -3.227522| -7.249232|  0.7941872| 0.173426888|
|4-1        | -3.132517| -7.154226|  0.8891925| 0.197325428|
|5-3        | -2.932875| -6.954584|  1.0888348| 0.254974443|
|5-4        |  2.015229| -2.006480|  6.0369387| 0.624188679|

It's been a while since I watched Daria, but season 4 seems… oh wait, nevermind. There are several missing values in the dataset, I don't feel comfortable making assumptions based on insufficient data. I mean, look at this plot of the rating distribution:


```r
ggplot(data = daria, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Daria Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_daria-1.png) 

And then look at the vote distribution:


```r
ggplot(data = daria, aes(x = votes)) +
  geom_histogram(alpha = .6, binwidth = 1) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Daria Episode Votes",
       y = "Density", x = "Vote", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_votes_daria-1.png) 

The peak at $x = 0$ means exactly what you think it means: A large number of episodes with no votes at all.  
So, that's a bummer.

### Person of Interest


```r
temp <- trakt.getSeasons("person-of-interest")
poi  <- trakt.getEpisodeData("person-of-interest", temp$season)

m <- aov(rating ~ season, data = poi) 
m %>% tidy %>% kable(digits = 20)
```


|term        | df|     sumsq|     meansq| statistic|   p.value|
|:-----------|--:|---------:|----------:|---------:|---------:|
|season      |  3| 0.2538903| 0.08463010|  1.385317| 0.2534035|
|Residuals   | 79| 4.8261713| 0.06109078|        NA|        NA|

No post-hoc necessary. 
Courtesy plot:


```r
ggplot(data = poi, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Person of Interest Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

```
## Warning: Removed 3 rows containing non-finite values (stat_density).
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_poi-1.png) 

### Castle


```r
temp   <- trakt.getSeasons("castle")
castle <- trakt.getEpisodeData("castle", temp$season)

m <- aov(rating ~ season, data = castle) 
m %>% tidy %>% kable(digits = 20)
```




|term        |  df|    sumsq|    meansq| statistic|      p.value|
|:-----------|---:|--------:|---------:|---------:|------------:|
|season      |   6| 3.967700| 0.6612833|  10.52991| 1.395306e-09|
|Residuals   | 136| 8.540868| 0.0628005|        NA|           NA|

Huh.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(8) %>% kable(digits = 20)
```



|comparison |   estimate|    conf.low|   conf.high|  adj.p.value|
|:----------|----------:|-----------:|-----------:|------------:|
|7-4        | -0.5195126| -0.76843555| -0.27058967| 1.047652e-07|
|7-3        | -0.4589812| -0.70584864| -0.21211386| 2.785512e-06|
|6-4        | -0.4004187| -0.62159253| -0.17924486| 5.462951e-06|
|6-3        | -0.3398873| -0.55874515| -0.12102952| 1.566458e-04|
|5-4        | -0.3052701| -0.52412792| -0.08641229| 1.021130e-03|
|4-2        |  0.2504164|  0.03155854|  0.46927417| 1.398587e-02|
|5-3        | -0.2447387| -0.46125577| -0.02822173| 1.593289e-02|
|7-2        | -0.2690962| -0.51596364| -0.02222886| 2.306307e-02|

There seems to be quite some disturbance in the force with this one.


```r
ggplot(data = castle, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Castle Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_castle-1.png) 

### Parks & Recreation


```r
temp <- trakt.getSeasons("parks-and-recreation")
prec <- trakt.getEpisodeData("parks-and-recreation", temp$season)

m <- aov(rating ~ season, data = prec) 
m %>% tidy %>% kable(digits = 20)
```

|term        |  df|    sumsq|     meansq| statistic|    p.value|
|:-----------|---:|--------:|----------:|---------:|----------:|
|season      |   6| 5.556017| 0.92600282|  18.19443| 8.4745e-15|
|Residuals   | 116| 5.903802| 0.05089485|        NA|         NA|

Again? Whow, we're on a roll.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(15) %>% kable(digits = 20)
```

|comparison |   estimate|    conf.low|   conf.high|  adj.p.value|
|:----------|----------:|-----------:|-----------:|------------:|
|4-1        |  0.9575623|  0.64577661|  1.26934794| 1.024736e-13|
|3-1        |  0.8613638|  0.53729301|  1.18543449| 2.497436e-11|
|5-1        |  0.7846323|  0.47284661|  1.09641794| 2.249780e-10|
|6-1        |  0.7288673|  0.41708161|  1.04065294| 3.442394e-09|
|2-1        |  0.5984358|  0.28944651|  0.90742516| 1.146804e-06|
|4-2        |  0.3591264|  0.15931238|  0.55894050| 7.596845e-06|
|7-4        | -0.4368441| -0.68682876| -0.18685942| 1.463735e-05|
|7-1        |  0.5207182|  0.17714711|  0.86428925| 2.650872e-04|
|7-3        | -0.3406456| -0.60579435| -0.07549678| 3.507537e-03|
|3-2        |  0.2629279|  0.04443947|  0.48141636| 8.001758e-03|
|6-4        | -0.2286950| -0.43280663| -0.02458337| 1.761697e-02|
|7-5        | -0.2639141| -0.51389876| -0.01392942| 3.135226e-02|
|5-2        |  0.1861964| -0.01361762|  0.38601050| 8.505440e-02|
|5-4        | -0.1729300| -0.37704163|  0.03118163| 1.541539e-01|
|7-6        | -0.2081491| -0.45813376|  0.04183558| 1.694878e-01|

What. It looks like almost every season is rated significantly different than every other.


```r
ggplot(data = prec, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Parks & Recreation Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_prec-1.png) 

Oh yeah. That show is a mess, consistency-wise.  
Interesting how bad s01 seems to be doing.

### Sleepy Hollow

Haven't seen it, not sure if I will.


```r
temp    <- trakt.getSeasons("sleepy-hollow")
shollow <- trakt.getEpisodeData("sleepy-hollow", temp$season)

m <- aov(rating ~ season, data = shollow) 
m %>% tidy %>% kable(digits = 20)
```



|term        | df|    sumsq|     meansq| statistic|      p.value|
|:-----------|--:|--------:|----------:|---------:|------------:|
|season      |  1| 1.133937| 1.13393714|   16.5839| 0.0003460219|
|Residuals   | 28| 1.914522| 0.06837578|        NA|           NA|


Well.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(5) %>% kable(digits = 20)
```


|comparison |   estimate|   conf.low|  conf.high|  adj.p.value|
|:----------|----------:|----------:|----------:|------------:|
|2-1        | -0.3923367| -0.5896844| -0.1949891| 0.0003460219|

Okay, with only two seasons there's not much fun in doing an ANOVA in the first place, a simple t-test would probably have done the trick.


```r
ggplot(data = shollow, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Sleepy Hollow Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_shollow-1.png)

The point being: It doesn't seem to get better. 

### Family Guy

To end this, here comes a favorite of mine.


```r
temp    <- trakt.getSeasons("family-guy")
fguy <- trakt.getEpisodeData("family-guy", temp$season)
m <- aov(rating ~ season, data = fguy) 
m %>% tidy %>% kable(digits = 20)
```


|term        |  df|    sumsq|     meansq| statistic|    p.value|
|:-----------|---:|--------:|----------:|---------:|----------:|
|season      |  12|  7.11123| 0.59260248|  10.23059| 4.9003e-16|
|Residuals   | 228| 13.20680| 0.05792454|        NA|         NA|


Oh well, I'll take it.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(5) %>% kable(digits = 20)
```


|comparison |   estimate|   conf.low|  conf.high|  adj.p.value|
|:----------|----------:|----------:|----------:|------------:|
|13-4       | -0.8049424| -1.0889946| -0.5208902| 8.193446e-14|
|13-10      | -0.8014943| -1.0969160| -0.5060726| 9.037215e-14|
|13-9       | -0.7416574| -1.0500682| -0.4332466| 3.597123e-12|
|13-2       | -0.7156929| -1.0156314| -0.4157544| 5.305978e-12|
|13-3       | -0.6816059| -0.9791919| -0.3840199| 3.886413e-11|

Hm.


```r
fguy$rating[fguy$rating == 0] <- NA
ggplot(data = fguy, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Family Guy Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```


![](/images/overanalyzing-tv-shows_files/figure-html/plot_fguy-1.png) 

### Scrubs

As an afterthought, let's look at the one that got this whole thing started.


```r
temp   <- trakt.getSeasons("scrubs")
scrubs <- trakt.getEpisodeData("scrubs", temp$season)
m <- aov(rating ~ season, data = scrubs) 
m %>% tidy %>% kable(digits = 20)
```



|term        |  df|     sumsq|     meansq| statistic| p.value|
|:-----------|---:|---------:|----------:|---------:|-------:|
|season      |   8| 25.780094| 3.22251181|  105.2815|       0|
|Residuals   | 187|  5.723793| 0.03060852|        NA|      NA|

That's… convincing.


```r
TukeyHSD(m) %>% broom::tidy(.) %>% arrange(adj.p.value) %>% head(8) %>% kable(digits = 20)
```



|comparison |  estimate|  conf.low|  conf.high| adj.p.value|
|:----------|---------:|---------:|----------:|-----------:|
|9-1        | -1.461212| -1.637061| -1.2853627|           0|
|9-2        | -1.577642| -1.769727| -1.3855570|           0|
|9-3        | -1.437780| -1.629865| -1.2456948|           0|
|9-4        | -1.362575| -1.550330| -1.1748194|           0|
|9-5        | -1.438666| -1.627755| -1.2495774|           0|
|9-6        | -1.268856| -1.460941| -1.0767711|           0|
|9-7        | -1.197621| -1.422568| -0.9726742|           0|
|9-8        | -1.299382| -1.499237| -1.0995266|           0|

Once again, pretty convincing. Nobody likes s09.


```r
ggplot(data = scrubs, aes(x = rating, fill = season)) +
  geom_density(alpha = .6) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(title = "Scrubs Episode Ratings per Season",
       y = "Density", x = "Rating", fill = "Season")
```

![](/images/overanalyzing-tv-shows_files/figure-html/plot_scrubs-1.png) 

…yip.

## Limitations

Probably the most important thing to note about all of this is that trakt.tv doesn't nearly have the userbase of other, well established sites like [IMDb](http://www.imdb.com/), so, well, I guess the sample size might be too small, or maybe there are some biases or confounders at work which I can't really adjust for.  
A way around this would probably be to use the `votes` variable in the episode dataset to normalize the ratings across a show, but I don't really know a decent way to do that, since the per-episode ratings already represent the average of all the user votes for that episode.  
 
The other problem is that I never once checked for normality within the ratings, which should be given if you want to perform an ANOVA. If the variable you're looking at is not distributed normally, you should be doing a Kruskal-Wallis, but I'm a lazy man.

Well, there's that and my whole point about how this is all fun and games, and no serious points shall be made.

