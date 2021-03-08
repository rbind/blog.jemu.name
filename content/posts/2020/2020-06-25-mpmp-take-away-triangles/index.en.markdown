---
title: 'MPMP: Take-Away Triangles'
author: jemus42
date: '2020-06-25'
slug: mpmp-take-away-triangles
categories: []
tags:
  - MPMP
  - maths
  - puzzle
featured_image: "plots/takeaway-runs-plot-1.png"
description: "In which I fiddle around with this weeks Matt Parker's Maths Puzzle"
externalLink: ''
series:
  - R
packages: 
  - ggplot2
  - purrr
  - dplyr
  - tidyr
  - hrbrthemes
  - kableExtra
toc: yes
math: yes
editor_options: 
  chunk_output_type: console
---



It finally happened! In this weeks *Matt Parker's Maths Puzzles* (MPMP), the challenge proposed was finally something I had a quick idea for on how to solve it in R.  

If you're unfamiliar with the MPMP series, or specificially the current challenge (posted on June 24th), [here's the video with the puzzle which I won't embed because tracking and stuff](https://www.youtube.com/watch?v=WZnVOYGLiy4).

The puzzle submission page with some extra info is [located here](http://www.think-maths.co.uk/trianglepuzzle) if you want to give it a go, but I'll restate the goal here:

> **Puzzle for Submission**: The puzzle this week is to find three starting numbers for a take-away triangle so that eventually each set of the three new numbers generated always adds to 14.

Well then, time to do some takeaways.  

For reproducibility (and since I intend to submit this as "extra working out"), here's the packages I used:

```r 
library(purrr)
library(dplyr)
library(tidyr)
library(kableExtra)
library(ggplot2)
library(hrbrthemes)
theme_set(theme_ft_rc())

plot_caption <- glue::glue("@jemus42 // {Sys.Date()}")
```

## `takeaway()`: The Basic Building Block

First up I'll define a function to do "one round" of takeaway on a set of 3 numbers, e.g. `\(X = \{4, 8, 12\}\)`. I'll use the first digit as the left corner, the right digit as the right corner, and the middle digit as the centered corner of the triangles (it makes sense if you've watched the video I swear), and using `R`'s vectorization this is fairly easy to implement:

```r 
takeaway <- function(x) {
  # New set = [1st minus 2nd; 1st minus 3rd; 2nd minus 3rd]
  # Also making the results positive integers again
  abs(x[c(1, 1, 2)] - x[c(2, 3, 3)])
}

# Demo:
x <- c(5, 8, 12)
takeaway(x)
```

```
#> [1] 3 7 4
```

This should implement the following operation:

{{< figure src="take-away-diagram.png" alt="Diagram showing the take-way triangle operation" caption="Once again, money spent on OmniGraffle very well... underutilized." >}}

I'm not too sure about the notation, but I think if I put it like this should be a roughly correct way to formalize the operation:

`\begin{align}
\operatorname{takeaway}: \mathbb{N}^3 &\to \mathbb{N}^3 \\
\{a,b,c\} &\mapsto \{|a-b|, |a-c|, |b-c|\} \\
\end{align}`

...I can't tell if that's helping. 

Anyway, now I have a function to do "one step". The next *step* (heh) is to iteratively do the take-aways for a set number of steps (I chose 50 here) while also starting off with a random set of integers between 1 and 100 (arbitrarily enough).  
It turns out this is one of the few cases where you need (I think) a `for` loop in `R`, because you need the `\(n\)`th result to calculate the `\(n+1\)`th result --- but if anyone manages a more functional-progamming-y solution via `purrr::map`, I'd be curious to see it.

```r 
takeway_run <- function(steps = 50, max_num = 100) {
  # Not sure how to properly pre-allocate a list
  xls <- map(seq_len(steps), 1)
  
  # 3 random integers between 1 and max_num, with replacement
  xls[[1]] <- sample.int(max_num, size = 3, replace = TRUE)

  # calculate the next step and put it in the next place in the list
  for (i in seq_len(steps)) {
    xls[[i + 1]] <- takeaway(xls[[i]])
  }
  
  # Make it tibbly, add the sum as a column
  tibble::enframe(xls, name = "step", value = "numbers") %>%
    mutate(sum = map_int(numbers, sum))
}

# Looks like this:
takeway_run(10)
```

```
#> # A tibble: 11 x 3
#>     step numbers     sum
#>    <int> <list>    <int>
#>  1     1 <int [3]>   142
#>  2     2 <int [3]>   132
#>  3     3 <int [3]>   122
#>  4     4 <int [3]>   112
#>  5     5 <int [3]>   102
#>  6     6 <int [3]>    92
#>  7     7 <int [3]>    82
#>  8     8 <int [3]>    72
#>  9     9 <int [3]>    62
#> 10    10 <int [3]>    52
#> 11    11 <int [3]>    42
```

Note that the `numbers` column is actually a list column containing a vector with the numbers at that step. I could have pasted them together as a string after I got their sum, but oh well --- I'll do that later.

## Doing Things A Lot

Now that we have a function to generate a random run of 50 steps, we'll do the classic "computer fast brain slow" approach of "just simulating a bunch" by generating 100 successive runs, each with random starting numbers:

```r 
# For reproducibility
set.seed(11235813)
runs <- purrr::map_df(1:100, ~{
  takeway_run(steps = 50) %>%
    mutate(run_id = .x)
})
```





Let's take a quick look:

```r 
runs
```

```
#> # A tibble: 5,100 x 4
#>     step numbers     sum run_id
#>    <int> <list>    <int>  <int>
#>  1     1 <int [3]>   153      1
#>  2     2 <int [3]>   128      1
#>  3     3 <int [3]>    64      1
#>  4     4 <int [3]>    64      1
#>  5     5 <int [3]>    64      1
#>  6     6 <int [3]>    64      1
#>  7     7 <int [3]>    64      1
#>  8     8 <int [3]>    64      1
#>  9     9 <int [3]>    64      1
#> 10    10 <int [3]>    64      1
#> # … with 5,090 more rows
```

Well the first run there did *not* end up with a sequence of 14's, but oh well, there's more to examine.  
I fiddled around a bit when I tried to find a reliable solution to identify "winning" runs, i.e. those that ended up with 14's repeating, but I settled for this condition:

- If the last couple steps (i.e. starting at step 45) are _all equal to 14_, then it's a winner.

...writing it down it really does not seem terribly hard to come up with, but putting it in code took me a minute, thankfully good old `all()` is around. 
So, we check each run for this condition, filter the runs that meet this condition, and then extract the `run_id`, the numeric identifier I gave to each run earlier.


```r 
# Get the run_id with winning condition
winning_runs <- runs %>%
  filter(step >= 45) %>%
  group_by(run_id) %>%
  summarize(ok = all(sum == 14), .groups = "drop") %>%
  filter(ok) %>%
  pull(run_id)

winning_runs
```

```
#> [1] 65 70 95
```

Well then, what where the starting numbers? Did they sum to 14? That would disqualify them.

```r 
runs %>%
  filter(run_id %in% winning_runs, step == 1) %>%
  mutate(numbers = map_chr(numbers, ~paste(.x, collapse = " + "))) %>%
  select(numbers, sum) %>%
  unite(col = winners, numbers, sum, sep = " = ") %>%
  kable()
```
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> winners </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 52 + 17 + 94 = 163 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 + 66 + 80 = 149 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 46 + 53 + 74 = 173 </td>
  </tr>
</tbody>
</table>

Neato, 3 winning runs and each of them qualify. So here's 3 perfectly fine submission for you, for free [^cheat]. 

[^cheat]: But that would be cheating. You monster.

## Bonus Plot

I also couldn't resist to plot all the runs by their number's sums at each step, highlighting the 3 winners:

```r 
runs %>%
  ggplot(aes(x = step, y = sum, group = run_id)) +
  geom_step(aes(color = "sadface"), alpha = 1/3) +
  geom_step(
    data = runs %>% filter(run_id %in% winning_runs),
    aes(color = "Yes!"),
    alpha = 1, size = 1
  ) +
  scale_color_manual(values = c("Yes!" = "#EA212D", "sadface" = "#999999")) +
  labs(
    title = "MPMP: Take-Away Triangles",
    subtitle = "Playing 100 games at 50 steps each with random starting numbers and recording the sum",
    x = "Step (1 = Starting numbers)", y = "Sum of the 3 numbers",
    color = "Does it end at 14 repeating?", captioon = plot_caption
  ) +
    theme(legend.position = "top")
```

{{<figure src="plots/takeaway-runs-plot-1.png" link="plots/takeaway-runs-plot-1.png">}}

## Conclusion

And finally, here are the winning runs in full --- or rather only the first 10 steps. It turns out 50 steps was more than enough given the size of my starting numbers.

```r 
runs %>%
  filter(run_id %in% winning_runs, step <= 10) %>%
  mutate(numbers = map_chr(numbers, ~paste(.x, collapse = " + "))) %>%
  unite(col = numbers, numbers, sum, sep = " = ") %>%
  pivot_wider(
    id_cols = c(step, numbers),
    names_from = run_id, names_prefix = "Run ",
    values_from = numbers
  ) %>%
  rename(Step = step) %>%
  kable() %>%
  kable_styling()
```
<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;"> Step </th>
   <th style="text-align:left;"> Run 65 </th>
   <th style="text-align:left;"> Run 70 </th>
   <th style="text-align:left;"> Run 95 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:left;"> 52 + 17 + 94 = 163 </td>
   <td style="text-align:left;"> 3 + 66 + 80 = 149 </td>
   <td style="text-align:left;"> 46 + 53 + 74 = 173 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:left;"> 35 + 42 + 77 = 154 </td>
   <td style="text-align:left;"> 63 + 77 + 14 = 154 </td>
   <td style="text-align:left;"> 7 + 28 + 21 = 56 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:left;"> 7 + 42 + 35 = 84 </td>
   <td style="text-align:left;"> 14 + 49 + 63 = 126 </td>
   <td style="text-align:left;"> 21 + 14 + 7 = 42 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:left;"> 35 + 28 + 7 = 70 </td>
   <td style="text-align:left;"> 35 + 49 + 14 = 98 </td>
   <td style="text-align:left;"> 7 + 14 + 7 = 28 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> 7 + 28 + 21 = 56 </td>
   <td style="text-align:left;"> 14 + 21 + 35 = 70 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:left;"> 21 + 14 + 7 = 42 </td>
   <td style="text-align:left;"> 7 + 21 + 14 = 42 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:left;"> 7 + 14 + 7 = 28 </td>
   <td style="text-align:left;"> 14 + 7 + 7 = 28 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
   <td style="text-align:left;"> 7 + 7 + 0 = 14 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
   <td style="text-align:left;"> 0 + 7 + 7 = 14 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
   <td style="text-align:left;"> 7 + 7 + 0 = 14 </td>
   <td style="text-align:left;"> 7 + 0 + 7 = 14 </td>
  </tr>
</tbody>
</table>

And I think that's about it?  
I'm tempted to try the same approach but with *large* starting numbers and more steps, but I'll play around with that later for procrastinative reasons.  

