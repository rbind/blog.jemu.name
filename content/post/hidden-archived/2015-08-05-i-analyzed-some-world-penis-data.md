---
author: jemus42
categories:
  - rstats
date: 2015-08-05
tags: 
  - Penis Data
packages:
  - rvest
  - dplyr
  - ggplot2
  - pixiedust
title: I analyzed some world penis data - because why not
draft: true
---

![](https://worldpenis.tadaa-data.de/assets/plots/length_method_state-1.png)


**Edit: 2016-12-18 02:13:19**

> Please note that this analysis is out of date and the code to acquire the data no longer works, since the source website has restructured and I have not found a way to reproduce the old behavior. Also, the current analysis is located at https://worldpenis.tadaa-data.de, so please go there for up to date code and analysis. It's prettier. And better.


If there's one thing I just can't resist, it's publicly available tabular data containing adequate amounts of numeric values. Naturally, I couldn't resist the [World Penis Data](http://www.everyoneweb.com/worldpenissize) I stumbled upon somewhere over at Reddit. 

So, let's suck that data out of the web and put it into our favorite data structure.

<!--more-->


```r 
library(rvest)
library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(pixiedust)

penis        <- html("http://www.everyoneweb.com/worldpenissize") %>% html_table(fill = T)
penis        <- penis[117] # Fish out the correct table
penis        <- penis[[1]] # Subset because nested list
names(penis) <- penis[2, ] # Get the names out of the second row
penis        <- penis[c(-1, -2), ] # The first two rows are trash

names(penis) <- c("Country", "Region", "length_flaccid", "length_erect", "length_erect_in",
                  "circumf_flaccid", "circumf_erect", "circumf_erect_in", "volume", "Method",
                  "N", "Source")

# Convert comma decimal seperator to dot so it can be as.numeric'd
penis[c(3:9, 11)] <- as.data.frame(lapply(penis[c(3:9, 11)], function(x){
                                            as.numeric(gsub(",", ".", x = x))
                                          }))
penis$Method      <- factor(penis$Method)
penis$Region      <- factor(penis$Region)

# More informative volumes
penis <- penis %>% 
  mutate(volume_erect   = length_erect * (circumf_erect/pi/2)^2 * pi,
         volume_flaccid = length_flaccid * (circumf_flaccid/pi/2)^2 * pi) %>% 
  select(-Method, -Source, -N, everything(), N, Method, Source) %>%
  select(-volume)

knitr::kable(head(penis))
```

|Country     |Region        | length_flaccid| length_erect| length_erect_in| circumf_flaccid| circumf_erect| circumf_erect_in| volume_erect| volume_flaccid|Method        |    N|Source                                                         |
|:-----------|:-------------|--------------:|------------:|---------------:|---------------:|-------------:|----------------:|------------:|--------------:|:-------------|----:|:--------------------------------------------------------------|
|Afghanistan |Central Asia  |            9.5|        13.69|             5.4|             9.1|         11.42|             4.50|       142.08|          62.60|Measured      |  100|Journal of Urology (mentioned in 2011)                         |
|Albania     |Europe        |            9.8|        14.19|             5.6|             9.7|         12.16|             4.79|       166.97|          73.38|Self reported |   95|Journal of Sexology 2006                                       |
|Algeria     |Africa        |            9.9|        14.49|             5.7|             8.9|         10.97|             4.32|       138.76|          62.40|Self reported |  738|https://www.surveymonkey.com - 2015                            |
|Angola      |Africa        |           10.0|        15.73|             6.2|             9.6|         11.82|             4.65|       174.89|          73.34|Measured      |  978|University Agostinho Neto 2001                                 |
|Argentina   |South America |            9.4|        14.88|             5.9|             8.9|         11.45|             4.51|       155.24|          59.25|Self reported | 1669|Journal of Urology 2013                                        |
|Armenia     |Europe        |           10.5|        13.12|             5.2|             8.6|         10.78|             4.24|       121.33|          61.80|Measured      |  469|Ուրոլոգիայի Առողջության  Պահպանման Ծառայություն Armenia - 2015 |

So, with that data, what can we look at? How about we look at the relation between flaccid and erect penis length across the different regions, that seems like a reasonable thing to do.


```r
ggplot(data = penis, aes(x = length_flaccid, y = length_erect, colour = Region)) +
  geom_point(size = 5, colour = "black") +
  geom_point(size = 4) +
  geom_smooth(method = lm, se = F) +
  labs(title = "World Penis Data", y = "Erect Length (cm)", x = "Flaccid Length (cm)")
```

![](/images/flaccid_erect-1.png) 

But wait, maybe we should take a look at the general distributions before we dive any deeper, shall we?


```r
penis %>% gather(State, Length, length_erect, length_flaccid) %>%
  mutate(State = factor(State, labels = c("Erect", "Flaccid"))) %>%
  ggplot(aes(x = Length, fill = State)) +
  geom_histogram(binwidth = .5, alpha = .6) +
  geom_density(aes(y = ..count..), alpha = .7) +
  labs(title = "Penis Length", x = "Length (cm)", y = "Count")
```

![](/images/distributions-1.png) 

```r
penis %>% gather(State, Circumference, circumf_erect, circumf_flaccid) %>%
  mutate(State = factor(State, labels = c("Erect", "Flaccid"))) %>%
  ggplot(aes(x = Circumference, fill = State)) +
  geom_histogram(binwidth = .5, alpha = .6) +
  geom_density(aes(y = ..count..), alpha = .7) +
  labs(title = "Penis Circumference", x = "Circumference (cm)", y = "Count")
```

![](/images/distributions-2.png) 

```r
penis %>% gather(State, Volume, volume_erect, volume_flaccid) %>%
  mutate(State = factor(State, labels = c("Erect", "Flaccid"))) %>%
  ggplot(aes(x = Volume, fill = State)) +
  geom_histogram(binwidth = 1, alpha = .6) +
  geom_density(aes(y = ..count..), alpha = .7) +
  labs(title = "Penis Volume", x = "Volume (cm^3)", y = "Count")
```

![](/images/distributions-3.png) 

```r
penis %>% mutate(Growth = length_erect / length_flaccid) %>%
  ggplot(aes(x = Growth)) +
  geom_histogram(binwidth = .01, alpha = .9) +
  labs(title = "Penis Growth Factor (Length)", x = "Growth: Erect by Flaccid Length (cm)", y = "Count")
```

![](/images/distributions-4.png) 

```r
penis %>% mutate(Growth = volume_erect / volume_flaccid) %>%
  ggplot(aes(x = Growth)) +
  geom_histogram(binwidth = .01, alpha = .9) +
  labs(title = "Penis Growth Factor (Volume)", x = "Growth: Erect by Flaccid Volume (cm^3)", y = "Count")
```

![](/images/distributions-5.png) 

Wait a minute, that last one seems odd. Apparently, there's a country with a massive volume growth rate. Let's find out which one that is.


```r
penis %>% mutate(Growth = volume_erect / volume_flaccid) %>%
  select(Country, contains("volume"), Growth, N, Source) %>%
  arrange(desc(Growth)) %>% head(1) %>% knitr::kable
```



|Country                  | volume_erect| volume_flaccid|   Growth|  N|Source                                                           
|:------------------------|------------:|--------------:|--------:|--:|:----------------------------------------------------------------
|Buzzfeed Motion Pictures |          198|          51.65| 3.833495| 11|Keith Habersberger, Los Angeles, BuzzFeed Motion Pictures - 2015 

Uhm… Buzzfeed Motion Pictures, eh? Well, whatever they are doing in that dataset, at least they have something to show for it.

Let's forget about that and get to the next thing: You may have noticed that column labelled "Method", containing information as to how the data has been obtained, i.e. via a presumably objective measurement, or self reported, presumably by the penis owners. Naturally, we assume there's a discrepancy in length between the two categories, so let's get on with the analysis.


```r
penis %>% gather(State, Length, length_erect, length_flaccid) %>%
  mutate(State = factor(State, labels = c("Erect", "Flaccid"))) %>%
  ggplot(data = ., aes(x = Length, fill = Method)) +
  geom_histogram(binwidth = .5, position = "dodge") +
  geom_density(colour = "black", alpha = 0.5, aes(y = ..count..)) +
  facet_grid(. ~ State, scales = "free_x") +
  labs(title = "Penis Length by Measure of Reporting", y = "Count", x = "Length (cm)")
```

![](/images/plot_length_method-1.png) 

Well, that sure comes as a surprise. But we don't want to jump the gun here, let's pretend we know what we're doing and throw some statistics at it. We'll t-test both erect and flaccid length in both measurent groups and see if we get a significant result.


```r
t.test(length_erect ~ Method, data = penis, var.equal = TRUE) %>% 
  tidy %>% select(-contains("conf")) %>% dust %>%
  sprinkle_colnames(estimate1 = "Mean (Measured)", 
                    estimate2 = "Mean (Self Reported)",
                    statistic = "t",
                    parameter = "df") %>% 
  sprinkle(col = c(1:3), round = 2) %>% 
  sprinkle(col = 4, fn = quote(pvalString(value))) %>%
  sprinkle_print_method("markdown")
```



| Mean (Measured)| Mean (Self Reported)|     t| p.value|  df
|---------------:|--------------------:|-----:|-------:|---:
|           13.46|                14.74| -4.39| < 0.001| 144

```r 
t.test(length_flaccid ~ Method, data = penis, var.equal = TRUE) %>% 
  tidy %>% select(-contains("conf")) %>% dust %>%
  sprinkle_colnames(estimate1 = "Mean (Measured)", 
                    estimate2 = "Mean (Self Reported)",
                    statistic = "t",
                    parameter = "df") %>% 
  sprinkle(col = c(1:3), round = 2) %>% 
  sprinkle(col = 4, fn = quote(pvalString(value))) %>%
  sprinkle_print_method("markdown")
```



| Mean (Measured)| Mean (Self Reported)|    t| p.value|  df
|---------------:|--------------------:|----:|-------:|---:
|            9.26|                 9.99| -4.1| < 0.001| 144

It turns out the difference is actually statistically significant. Yes, this might not be methodologically sound, but come on, I'm throwing code at penis data. 

One last thing I'd like to look at is the length growth factor in relation to the flaccid length across different regions:

```r
penis %>% mutate(growth = length_erect / length_flaccid) %>%
  ggplot(data = ., aes(x = length_flaccid, y = growth, color = Region)) +
  geom_point(size = 5, colour = "black") +
  geom_point(size = 4) +
  geom_smooth(method = lm, se = F) +
  labs(title = "World Penis Data",
       y = "Growth: Erect by Flaccid Length (cm)",
       x = "Flaccid Length (cm)")
```

![](/images/growth_length_regions-1.png) 

Well, I certainly didn't expect that amount of vertical grouping and ambivalent trend lines. If anyone as an idea how that can be explained, let me know.

**Edit 2015-08-06 00:47**

[Here's a bonus plot with a world ranking](http://dump.jemu.name/3bolP.png)
