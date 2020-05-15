---
draft: true
title: Migrating Themes and Overhauling the Rest
author: jemus42
date: '2020-05-15'
slug: migrating-themes-and-overhauling-the-rest
tags:
  - blogdown
  - knitr
description: ''
series:
  - Blogging
packages: ''
math: yes
editor_options:
  chunk_output_type: console
---

Oh boy.  
I really did it again. The procrastinative energy was too strong.

{{< figure src="migration-github-diff.png" title="" alt="GitHub diff summary showing 180 changed files with 6570 additions and 1807 deletions." caption="This is fine." >}}

I really should have been working on my master's thesis lately. I should have done a lot more reading than I did, I should have done a lot more prep work than I did, and most of all, I should really just focus on my thesis these days rather than losing myself in various side-projects [^sideproj].  
I tend to get these ideas stuck in my head that end up consuming me, forcing me down one rabbit hole after the other and I can only focus on something more important again after it's done, in one way or another.  

Anyway, somehow I got my blog on my mind again, maybe because I realized there were many bits around the theme I didn't like, stuff I never really got working right, and an overall desire to just revamp the hole thing.  
In situations like this, I often think about this line from Terry Pratchett's *[Going Postal](https://en.wikipedia.org/wiki/Terry_Pratchett%27s_Going_Postal)*, the first Discworld book I ever read:

> "Sometimes things smash so bad it’s better to leave it alone than try to pick up the pieces. I mean, where would you start?"
>
> --- Toliver Groat

So I decided to start from scratch, more or less, by switching to a different theme ([Coder](https://github.com/luizdepra/hugo-coder)) which has a couple benefits I like or grew to appreciate:

- **Simpler** design. I recently spent some time reading [Yihui's blog](https://yihui.org/) and his advice on choosing a simpler theme and not worrying too much about the fancy stuff really spoke _and_ somehwat offended me, given that worrying too much about irrelevant fancyness is basically my entire energy.
- Built-in support for **light/dark mode** with automatic switching based on the visitor's system preference
- **No bootstrap**/jquery required: Ever done some benchmarks/audits for your blog/website? You start caring about load times and render-blocking elements and whatnot way more than you want to. I thought simpler was better.
- **Actively maintained**. My first hugo theme was stale and caused a lot of frustration when hugo changed the way it handled the home page pagination… or something? I forgot. Anyway, I couldn't figure out how to fix it myself and was kind of stranded.

My previous (second) theme ([beautifulhugo](https://github.com/halogenica/beautifulhugo)) isn't bad, but… well, after a while, I found it *a bit much* [^yihuiadv]. There are also a number of things I wanted to add myself, some I even managed successfully, but it never really quite worked the way I wanted to – and for some of my ideas I would have needed a deep dive into hugo's templating and taxonomy system and overwrite a *lot* of the theme's `layout`.  
And if I've learned one thing about hugo themes over the years, it's that messing with a theme too much will just cause a lot of pain down the road because your local tweaks will inevitably end up being incompatible with the core theme, but your core theme should be kept up to date because of the inevitable changes to hugo itself.

But the theme itself is not all I wanted to change. 

[^sideproj]: Like last week, when I spent *days* trying to figure out a combination o LaTeX, fonts, GitHub Actions, {bookdown}/{ggplot2}/{pkgdown}. It ended up not working right and I gave up.
[^yihuiadv]: Which is, if I remember correctly, basically what Yihui warned about. You'll grow tired of your theme after a while, so you might as well keep it simple.

## Switching to Bundles

Alternative title: *Page Bundles: The Obvious Solution to a Sucky Workflow*

Thanks to [Maëlle's posts on the rOpenSci blog about hugo](https://ropensci.org/tags/hugo) I realized that I had been hugo'ing wrong all this time. I vaguely remember reading about [page bundles](https://gohugo.io/content-management/page-bundles/) in the hugo docs, but never gave it much thought. Reading [Maëlle's post](https://ropensci.org/technotes/2020/04/23/rmd-learnings/) [^ahill] made me realize how useful it would be for me. 

Many of my posts contain some sort of "analysis", or at least some dataset like a TV show's episode data from [trakt.tv]. Of course I want to keep that data locally and don't retrieve it every time I re-render the post, and yes, I know {blogdown} does caching for me, but sometimes it's usefull to nuke the `blogdown` folder, y'know?  
I had this whole set of helper functions to check for, store, and retrieve datasets in blog posts, putting them in `/dataset/slug-of-the-post/data-name.rds` where they would be easily accessible for future rebuilds.  
For posterity, and since I intend to remove them from my blog's repository soon, here they are:

<details><summary>Click to show a bunch of code</summary>

```r
# Caching datasets ----

# Set post-specific cache directiory, create if needed
# Use at beginning of post
# Might take rmarkdown::metadata$slug as input dynamically
make_cache_path <- function(post_slug = "misc") {
  cache_path <- here::here(file.path("datasets", post_slug))
  if (!file.exists(cache_path)) dir.create(cache_path)
  cache_path
}

#' Check if file is not cached
#' @param cache_path As returned by make_cache_path
#' @param cache_data Bare name of data to cache
#' @example
#' if (file_note_cache(cache_path, bigdata)) {
#'   { do expensive stuff }
#' }
file_not_cached <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  !(file.exists(file.path(cache_path, filename)))
}

# Cache a file, just a wrapper for saveRDS
cache_file <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  saveRDS(cache_data, file.path(cache_path, filename))
}

# Read a cached file, just a wrapper for readRDS
read_cache_file <- function(cache_path, cache_data) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  readRDS(file.path(cache_path, filename))
}

# Get date from cached file
cache_date <- function(cache_data, cache_path) {
  filename <- paste0(deparse(substitute(cache_data)), ".rds")
  format(file.mtime(file.path(cache_path, filename)), "%F")
}
```
</details>

It was such an overengineered solution.  
With page bundles, I can now refer to a file `dataset.rds` in the (relative to the post) current working directory, don't have to preprend the post's slug to ensure there's no duplicate file names [^dupfile] and can easily check for it's existence via `file.exists("dataset.rds")`. I can also split my code chunks in three parts so 

- the initial setup chunk loads the file if it exists.
- the chunk that *would* retrieve the data depends on said dataset's existence with the chunk option `eval=!file.exists("dataset.rds")`.
- a one-liner `include=FALSE`'d chunk saves the data if it doesn't exists already.

It's a lot neater and readers won't have to wonder what this 

```r
if (file_not_cached(episodes)) {
  # doing stuff
  cache_file(...)
} 
read_cache_file(...)
``` 

…bit is all about (even though it should be relatively obvious given my affinity for descriptive function names).  
As an added bonus, now I also have a place to store occasional screenshots and diagrams directly with their posts, and all in all I just love that my `/static` folder is a lot cleaner now.  

*However*… there's one tremendous downside to using page bundles.  
\*Pauses for audible gasp from imaginary audience\*  

The blog posts itself are now *all* called `index.Rmarkdown` / `index.md`.  
Let that one marinade [^lk]. Do you use RStudio's `ctrl + .` shortcut to quickly search and open a file in your project? I do. Or at least I did. But now, if I want to refer back to an older post for something, I have to use RStudio's less-than-stellar file browser. Or at least I *would* have to do that, because thankfully I've really *really* grown to like [Visual Studio Code](https://code.visualstudio.com/) for longer text editing (like blog posts!).  
VS Code also has a quick file selector (`⌘+P` on macOS), but in contrast to RStudio's implementation, this one fuzzy-matches the whole file path, which is probably better explained visually:

<video width="100%" height="500" controls loop="true">
  <source src="vscode-file-searcher.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

<small>(If the video can't be displayed, [here's a big ol' gif (18MB)](vscode-file-searcher.gif))</small>

Nice.

The only annoying bit is to actually migrate all the old posts to the new file structure. Since I don't have too many blog posts that survived my occasional "oh glob, did *I* write this?"-sprees, I could have done it manually, but creating a lot of folders with predictable paths and renaming/moving files… that's machine work. Here's my helper function:

```r
move_rmd_post <- function(path) {
  require(fs)
  post_rmd <- path_rel(path)

  post_name <- path_file(post_rmd) %>%
    path_ext_remove() %>%
    stringr::str_remove("\\.en$")

  new_post_dir <- path("content", "posts", post_name)
  dir_create(new_post_dir)

  file_move(post_rmd, path(new_post_dir, "index.Rmarkdown"))
}

move_rmd_post("path-to-old-post.Rmd")
```

I used this (and a variation to handle `.md` posts) to move all posts, first one at a time to make sure it's working, and then using a loop, iterating over all the posts I had previously moved from `content/` to a temporary migration-dump. There's still some cleanup I have to do on older posts for theme reasons, but at least they're all where they should be.

## Embracing (.R)markdown

The next change I decided to make was from writing `.Rmd` posts to `.Rmarkdown` posts to render `.markdown` instead of `.html`. You can read up [on this in the blogdown book](https://bookdown.org/yihui/blogdown/output-format.html) if you want, but in my case there's an easy reason: I don't *need* pandoc's markdown features, but I *would like* for both my regular `.md` posts (such as this one) and my RMarkdown-powered posts to both be handled by hugo, merely for consistency.  
Hugo uses ~~`blackfriday`~~ `goldmark` as its default markdown engine since `v0.60.0` (see [here][hugo-output-formats] and [here](https://gohugo.io/getting-started/configuration-markup/) – this should probably be updated in the blogdown book at some point). There's nothing I really miss using this over `pandoc`'s admittedly very powerful markdown [^pandocfootnotes]. 

In the past I experimented with giving posts a table of contents, something I still plan on adding to my current theme (finger's crossed for upstream theme support). They worked fine on (at the time) `blackfriday`-rendered posts, but not for RMarkdown posts, since `pandoc` produced a different structure (I think), and I still lack the CSS/webdesign skills to make a ToC look nice myself.  
This is just one example from the top of my head where I found the duality of markdown engines in the same blog a little annoying, but I'm sure many people gladly have both `goldmark` and `pandoc` coexist without issues, or heavily rely on some advanced `pandoc` feature or make more use of {htmlwidgets}. But I don't. Yet.

Fun fact: If you've checked [the hugo docs link above][hugo-output-formats], you'll find `pandoc` is listed as an option as well! Why not just use that and have *everything* be handled by `pandoc`?  
Finally, R users across the world rejoice as hugo joyfully integrates with their favorite text processing tool!  
Well, not quite. Hugo's `pandoc` support is fairly limited with regards to the supported extensions, and it doesn't look like it's customizable, i.e. no easy config options to enable arbitrary extensions which would make it behave the same as with {rmarkdown}. Maybe in the future `pandoc` is the only thing we'll need, but until then, I'm quite happy with hugo's default.

*However*… there's another caveat to using `.Rmarkdown`, and it's just the file extension.  
Do you use `styler`? I recently tried to use it to re-format code chunks in older blog posts. Posts I wrote at a time where I thought that 

```r
ggplot(…) +
  … +
  labs(title = …,
       x = …, y = …,
       color = … )
```

was somehow acceptable.  
I have since changed my opinion.  

The problem is that `styler` will happily recognize and format code in `.Rmd` files, but not in `.Rmarkdown` files, so I just used the RStudio addin and selected-then-reformatted offending chunks with the "Style selection" bit.  
Was it necessary? Probably not. Do I wish `.Rmarkdown` was handled as a first-class alias of `.Rmd`? Kind of.  

This also applies to `renv`, which I use for the entirety of my blog repository ([see also ](2020/03/auto-deploying-a-blogdown-blog-the-needlessly-hard-way/)). `renv` doesn't recognize dependencies in `.Rmarkdown` files, and I haven't spent too much time trying to fix it, but I thought it should be noted. Since `renv` is still fairly young, I think there's a decent chance it'll gain that functionality in the future – which in turn is probably also true for `styler` if more and more people were to adopt `.Rmarkdown`.

And if not, and I find it too much of a hassle, I might end up just switching back to `.Rmd` and using `md_document` as the output format. Maybe I should have done that in the first place? Well I guess I'll find out.

[^ahill]: …which in turn refers to [Alison Hill's neat post on the subject](https://alison.rbind.io/post/2019-02-21-hugo-page-bundles/)
[^dupfile]: I have created a lot of `episodes.rds` in my time pulling data from [trakt.tv], okay?
[^pandocfootnotes]: Besides maybe pandoc's syntax for [inline footnotes](https://pandoc.org/MANUAL.html#footnotes). YOu might have noticed I *do* like my footnotes, but we'll get to that later.
[^lk]: [I miss Letterkenny](https://www.youtube.com/watch?v=o5dtu-pbEb8)

[hugo-output-formats]: https://gohugo.io/content-management/formats/#list-of-content-formats

## Syntax Highlighting

Ah yes, syntax highlighting. Another one of the things where I enthusiastically rejected [Yihui's advice](https://yihui.org/en/2017/07/on-syntax-highlighting/) and then backtracked hard. While syntax highlighting can be viewed as merely cosmetic, I find myself having trouble reading / parsing Code in my head without a somewhat familiar highlighting scheme.  

Before I get to how I handle syntax highlighting *now*, I first want to tell a tale of how I handled it previously, and hopefully illustrate why I now very much appreciate the sentiment of "don't worry about it (that much)".

One of the first settings I always change in RStudio whenever I have to set it up on a different machine is the "highlight function calls" checkbox:

{{< figure src="highlighting-RStudio-setting.png" title="" alt="RStudio settings window Code -> Display showing the 'Highlight R function calls' checkbox ticked" caption="Always highlight function calls in R is the hill I'm prepared to die on" >}}

And here's how my regular RStudio code tab looks:

{{< figure src="highlighting-RStudio-example.png" title="" alt="R code highlighting example showing my preferred color scheme" caption="Featuring a teaser for an upcoming section!" >}}

by the way, that theme is based on "*Monokai Spacegray Eighties*", which you can find on [this theme editor](https://tmtheme-editor.herokuapp.com/#!/editor/theme/Monokai%20Spacegray%20Eighties). I'm so very thankful to [Mara](https://twitter.com/dataandme) for posting this site on Twitter a while ago, it has enabled me to waste a lot of time worrying about very small and unecessary details! I mean, what *is* the correct color for a built-in constant anyway, and should it differ form a user-defined constant? :thinking:

I like that theme, and I thought it would be neat if the code on my blog looked similiar.  
At the time I set up my first hugo blog, I really wasn't too happy with highlight.js, but still wanted a fairly good solution with a decent R language support often lacking with highlighting engines.  
I ended up going with [prism.js], which was customizable and had some really neat features.  
Here are examples of what it looked like:

{{< figure src="highlighting-prism-r.png" title="" alt="Code example showing neatly highlighted R code" caption="This fit my preferred color scheme reasonably well and I still like it" >}}

Prism also supported a toolbar that showed the code's language and a "Copy" button, which is always nice for posts where a lot of configuration files are mentioned:

{{< figure src="highlighting-prism-buttons-json.png" title="" alt="JSON with language indicator and 'Copy' button" caption="I like my configs copyable" >}}

So, I used prism.js and all was well.  
But nohohoo, I *also* insisted on using a custom [language deifnition for R][prism-r] I found poking around the internet which came with a tweaked [CSS file][prism-r-css] because the built-in R support wasn't *good enough* for me. Functions calls were not highlighted and the glorious `%>%` was not recognized as an operator and highlighted the way it deserved. These injustices had to be rectified.  
I fiddled with the regex for a while until it *kind of* worked, happily ignoring the caveat I read by the original author about `"strings with # in them"`.  
It took me a while until I actually wrote a post where that issue came up:

{{< figure src="highlighting-prism-r-comments.png" title="" alt="R code example showing the use of hex color strings which are not highlighted correctly due to the # character marking them as comments" caption="Including hex color strings is dangerous, kids" >}}

So to fix it, I would have needed to tweak the language definition regex again, or switch to the default prism.js language definition for R and hope I like it now.  
I did not.  
I was weary of prism.js anyway, because it was another third party JavaScript library I had to load, it was hard to maintain (which is my own fault given the above tweaks), and not easy to update.  
There's no easy CDN-ready solution for prism.js (with extensions) – you have to go to the site, check all the boxes for the languages you want to support, the extensions you want to use, and then you can download the bundle and push it into your `/static/js` folder.  

Manually ticking boxes and clicking a download button doesn't seem nice. Was there a better solution?  
Probably. What was my solution?  
Not much better.

I wrote helper code I put in a `maintenance.R` file that let me define languages and extension (because I didn't remember which extension I chose the first time I installed it), generate a download URL and open it in the browser for me (yes).

<details><summary>Click if you want to have a look</summary>

```r
# No direct download link for specific config available :(
# Assemble link to desired configuration and download manually

make_prismjs_url <- function(theme = "prism-okaidia", languages, plugins) {
  baseurl <- "https://prismjs.com/download.html"
  languages <- paste0(languages, collapse = "+")
  plugins <- paste0(plugins, collapse = "+")

  glue::glue("{baseurl}#themes={theme}&languages={languages}&plugins={plugins}")
}

primsjs_languages <- c(
  "markup", "css", "clike", "javascript", "bash", "json", "json5", "latex",
  "makefile", "nginx", "regex", "sas", "shell-session", "sql", "toml", "yaml"
)

prismjs_plugins <- c(
  "line-highlight", "line-numbers", "autolinker", "show-language", "toolbar",
  "copy-to-clipboard", "download-button", "match-braces"
)

prism_config_download <- make_prismjs_url("prism-okaidia", primsjs_languages, prismjs_plugins)
browseURL(prism_config_download)

# Copy files to static/css and /static/js
# Minify CSS
system("cd static/css; minify --output prism.min.css prism.css")

```

</details>

### TL;DR: How I Do Syntax Highlighting Now

Now I use server-side syntax highlighting powered by `chroma`.  
I generated both `monokai` (dark) and `monokailight` (light) color schemes with `hugo` like so:

```r
chroma_gen <- function(style = "monokai") {
  cmd <- glue::glue("hugo gen chromastyles --style={style} > static/css/syntax-{style}.css")
  system(cmd)
}

chroma_gen("monokai")
chroma_gen("monokailight")
```

I then refactored the two CSS files into one SCSS file and split them into three parts: The `base` theme for the elements common to both light and dark variants (VS Codes file comparison view came in handy there), and a `light` and `dark` variant. They are defined as a `@mixin` which makes them easy to include for my theme's light/dark modes, and when I want to tweak some colors, it's easier to figure out where the changes need to be made and which view (light or dark or both) they affect.  
You can see what the SCSS looks like [here](https://github.com/rbind/blog.jemu.name/blob/26575cb38c44df379da73d8561a7f26094d7e1d7/assets/scss/_monokai.scss).

Now my highlighting is fairly robust, doesn't rely on third party JavaScript libraries, and the color scheme is easily customizable [^hicust]. Neat.  

Thanks again to Maëlle for making me reconsider my approach with her post on [syntax highlighting with hugo](https://ropensci.org/technotes/2020/04/30/code-highlighting/).

[^hicust]: I haven't tweaked the colors a lot yet, but I at least tried to have a high enough contrast according to Chrome's dev tools thingy, so I hope it's at least reasonably accessible? 

## Dark Mode All the Things <small>At least sometimes, if you want</small>

One of the selling features (for me, at least) of the [Coder] theme is the light and dark mode switching based on your system preferences. Whatever your preference, you're probably reading this post in the "correct" color scheme. Unless you're on a system that doesn't have global color scheme preference, or your browser doesn't pick up on it, or you haven't enabled it for some reason. But *technically* it's automatically *correct*.  

The only thing I was missing on the theme side was a user-controllable toggle, just in case their preferences aren't set or some other reason, even just for testing purposes – having a manual override seemed like a good thing to have. 
Thankfully I have a [web-developer friend](https://github.com/zookee1) [^webdevfriend] who came through and cobbled together a fairly simple solution. This one is specific to the [Coder] theme which controls the color scheme via just one `class` of the `<body>` tag, but you can see it [here](https://github.com/rbind/blog.jemu.name/blob/9889fc8ec826e7e91194c8d8b7563a9547f1fbb8/static/js/jemsu.js#L8-L30) if you'd like a reference.  
This javascript is attached to the toggle button you probably see on the top right of the page, which is defined [here](https://github.com/rbind/blog.jemu.name/blob/9889fc8ec826e7e91194c8d8b7563a9547f1fbb8/layouts/partials/header.html#L7-L15) and I copied from [there](https://gitlab.com/clement-pannetier/clementpannetier.dev/-/tree/fedd75b93939f2ed45e9ce9671f684a370572f09/).  
The JS solution used by that last blog only works if the `colorscheme` preference is not set to `"auto"` but fixed to `"light"` or `"dark"`, so I'm glad I have a solution now.  
It's nice to have things both customizable *but also* provide a friendly default.

In that spirit, I thought about light vs. dark {ggplot2} themes, and wondered if it [was possible to automatically render plots with two versions of the same base theme](https://twitter.com/Jemus42/status/1260608125180227585) and have not only the blog itself, but *also* the plots switch color schemes through the use of some `src=` path manipulations possible with JavaScript.  
I haven't tried to make that happen yet, but it would be *oh so so cool*.

[^webdevfriend]: I recommend keeping one of those, they're handy! Even if they tend to recommend you a bazillion frameworks if all you want is some little thing

## Nicer Footnotes: littlefoot.js

If there's on aspect of my previous theme(s) I definitely wanted to keep, it's [littlefoot.js].  
In case you haven't noticed yet, I tend to make *heavy* use of footnotes [^meta] and I like them to be accessible directly where they're placed. Yes, usually footnotes come with links that take you down to the bottom of the post where all the decontextualized footnotes are placed, and yes, these footnotes tend to have "go back to where I was"-links that take you back to… well, where you ~~was~~ where – but I always find that somewhat jarring. It's a minor annoyance, and I wouldn't be surprised to learn that nobody else cares that much, but… have you noticed \*gestures towards entire blog post\*.

{{< figure src="theme-littlefoot.gif" title="" alt="GIF showing littlefoot.js in action. A small button with the footnote number is displayed next to the text, and when the button is clicked the footnote text expands next to the text" caption="littlefoot.js in action: Read a footnote without scrolling or losing your place" >}}

Since littlefoot.js is fairly lightweight and doesn't need a heavy jquery or bootstrap dependency, I'm fairly happy I could just include it again without having to feel a little bad about it.

Also, because I like my weird helper functions, here's my helper to download littlefoot.js from [unpkg.com] and put it where it needs to go

<details><summary>Click to show code</summary>

```r
get_asset_unpkg <- function(package, version, file) {
  url <- glue::glue("https://unpkg.com/{package}@v{version}/{file}")
  type <- stringr::str_extract(file, "(css|js)$")
  target_dir <- here::here("static", type)
  dest_file <- glue::glue("{target_dir}/{package}-{version}.{type}")

  # Downloading
  download.file(
    url = url,
    destfile = dest_file
  )

  # Symlinking
  command <- glue::glue(
    "cd {target_dir}
    ln -sf {package}-{version}.{type} {package}.{type}"
  )
  system(command)
}

# littlefoot.js -----
# https://github.com/goblindegook/littlefoot/releases
littlefoot_version <- "3.2.4"

get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.js")
get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.css")
```

</details>

[^meta]: Hi there. This footnote exists merely for the purposes of being meta. Being *meta* used to be a very cool thing, and I think it's still somewhat interesting in many contexts – maybe not this particular one, I'll give you that, but there's an argument to be made about how current humoristic trends (over-?)use the concept of *meta*-ness for the purpose of coming off as clever instead of actually being funny, but then again, *funnyness* in itself is an inherently fluid concept, which I would *like* to get into at some point, but I should finish this blog post first I guess.

### Auto-Linking Headers with Partials

## Using `knitr` Hooks for Blogging Comfort


```r
# plot output in .Rmarkdown
# see https://ropensci.org/technotes/2020/04/23/rmd-learnings/
knitr::knit_hooks$set(
  plot = function(x, options) {
    hugoopts <- options$hugoopts
    # Link image to itself if there's no explicit link set
    if (!hasName(hugoopts, "link")) hugoopts$link <- x
    paste0(
      "{", "{<figure src=", '"', x, '" ',
      if (!is.null(hugoopts)) {
        glue::glue_collapse(
          glue::glue('{names(hugoopts)}="{hugoopts}"'),
          sep = " "
        )
      },
      ">}}\n"
    )
  }
)
```

```r
# Shamelessly stolen from
# https://github.com/cpsievert/plotly_book/blob/a95fb991fdbfdab209f5f86ce1e1c181e78f801e/index.Rmd#L52-L60
knitr::knit_hooks$set(
  summary = function(before, options, envir) {
  if (length(options$summary)) {
    if (before) {
      return(sprintf("<details><summary>Code: %s</summary>\n\n", options$summary))
    } else {
      return("\n</details>")
    }
  }
}
)
```

## The Quest for Taxonomies



<!-- links -->
[trakt.tv]: https://trakt.tv
[prism.js]: https://prismjs.com/
[prism-r]: https://github.com/rbind/blog.jemu.name/blob/fc7742b21fce64984044be9b6a2e365320db8c2e/static/js/prism.r.js
[prism-r-css]: https://github.com/rbind/blog.jemu.name/blob/fc7742b21fce64984044be9b6a2e365320db8c2e/static/css/prism.okaidia.css
[littlefoot.js]: https://github.com/goblindegook/littlefoot
[unpkg.com]: https://unpkg.com
[Coder]: https://github.com/luizdepra/hugo-coder
