Hook Testing
================
@jemus42
5/16/2020

```` r
knitr::knit_hooks$set(source = function(x, options) {

  # The original source in a fenced code block
  source_orig <- paste(c("```r", x, "```"), collapse = "\n")

  fold_option <- options[["code_fold"]]

  # If option not set or explicitly FALSE, return regular code chunk
  if (is.null(fold_option) | isFALSE(fold_option)) {
   return(source_orig) 
  } 
  
  summary_text <- ifelse(
    is.character(fold_option), # If the option is text,
    fold_option,               # use it as <summary>Label</summary>,
    "Click to expand"          # otherwise here's a default
  )
  
  # Output details tag
  glue::glue(
    "<details>
      <summary>{summary_text}</summary>
      {source_orig}
    </details>"
  )
})
````

### Regular output as usual, `code_fold` not set

``` r
library(dplyr, warn.conflicts = FALSE)
iris %>%
  filter(Sepal.Width > 3) %>%
  head(5)
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.7         3.2          1.3         0.2  setosa
    ## 3          4.6         3.1          1.5         0.2  setosa
    ## 4          5.0         3.6          1.4         0.2  setosa
    ## 5          5.4         3.9          1.7         0.4  setosa

### Hidden source, custom summary, `code_fold="I heard you like flowers"`

<details>

<summary>I heard you like flowers</summary> `r iris %>%
filter(Sepal.Width > 3) %>% head(5)`

</details>

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.7         3.2          1.3         0.2  setosa
    ## 3          4.6         3.1          1.5         0.2  setosa
    ## 4          5.0         3.6          1.4         0.2  setosa
    ## 5          5.4         3.9          1.7         0.4  setosa

### Hidden source, default summary, `code_fold=TRUE`

<details>

<summary>Click to expand</summary> `r iris %>% filter(Sepal.Width > 3)
%>% head(5)`

</details>

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.7         3.2          1.3         0.2  setosa
    ## 3          4.6         3.1          1.5         0.2  setosa
    ## 4          5.0         3.6          1.4         0.2  setosa
    ## 5          5.4         3.9          1.7         0.4  setosa

### Source shown, `code_fold=FALSE`

``` r
iris %>%
  filter(Sepal.Width > 3) %>%
  head(5)
```

    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.7         3.2          1.3         0.2  setosa
    ## 3          4.6         3.1          1.5         0.2  setosa
    ## 4          5.0         3.6          1.4         0.2  setosa
    ## 5          5.4         3.9          1.7         0.4  setosa
