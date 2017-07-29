---
title: I Just Wanted to Serve Images
author: Jemus42
date: '2017-07-30'
slug: i-just-wanted-to-serve-images
categories:
  - meta
  - rstats
tags:
  - knitr
  - snippet
  - html
enable_mathjax: no
enable_katex: no
---

Ever since my blog has been migrated to [blogdown], blogging is kind of fun again.  
Not only do I slowly feel like I've understood the basics of [Hugo], but now tweaking my blog feels like an extended R project -- which I'm quite fond of.

To recap: My blog is built using [blogdown], which borrows ideas from [bookdown], to prepare things for [Hugo] to built the site, all while [bookdown] (and in turn [blogdown]) harness the power of [RMarkdown], which in turn uses [knitr] for basically all its glory.  

So… yeah. It's not as bad as it seems, trust me.  
That might also be what the Ruby people will tell you about Jekyll and the likes, but don't trust them -- they're all wrong and I'm the only one who's right.  

Now that we've established what we all knew beforehand, let's talk about the part where blogdown falls short. Don't get me wrong, [Yihui](https://yihui.name/) did a great job in basically putting together a package that does what I assumed was possible but not knowdledgable enough to pull off myself, however, it's still basically a hack [^1], so it's to be expected that in some parts, Hugo and RMarkdown (and/or knitr) won't be the best of friends.

## Plots for the people

At the core of blogdown, it's still knitr that actually executes the R code in RMarkdown documents, so the assembled Markdown including code output can be converted to HTML, so any limitation knitr may have will trickle down into the finished output. There's also the topic of [pandoc's handling of Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) (did I mention pandoc is involved? Yeah, RMarkdown uses that for the Markdown to HTML conversion), and how it differs from Hugo's Markdown library ([blackfriday](https://github.com/russross/blackfriday)).  
That topic will come up in the next section, but for now we're only concerned with knitr chunk output. 

Knitr is great. You can write a chunk of R code that produces text or image output, and knitr will take that output and stitch it below the code chunk in the resulting output file.  
The thing is, by default plots are rendered using the `png` graphics device, while the file path to the image is encapsulated by a standard HTML `<img>` tag.  
An `<img>` is all we need, right? So where's the problem?  
Well have you heard about [lightbox](http://lokeshdhakar.com/projects/lightbox2/)? There are dozens of JavaScript libraries like this (or rather jQuery plugins, but you get the idea) -- they're nice little additions to any post with multiple images, because they allow you to easily view, zoom and browse multiple images. If you're used to data analysis projects like mine, you'll see your fair share of plot after plot blog posts, so it seemed only natural for me to use something like this for my blog.  
After a little trial and error with lightbox2, I ended up using [fresco] for some minor usability reasons.  

The way most these plugins seem to work is by either writing custom JavaScript (which I can't be bothered to do), or attach secondary attributes to the image via an encloding `<a href=…` to trigger the JS code to fire up the box. Now I could have probably used JS to attach these attributes to the plot after the page has loaded, but that seemed clunky and potentially slow, or at least slower than just baking the stuff into the plot output.  

And that's how I learned about [knitr's hooks](https://yihui.name/knitr/hooks/#output-hooks). You see, to customize the way knitr writes out the `<img>` for the plot, you can't simply set a chunk option or something[^2], you have to substitute the appropriate hook with a function of your own that outputs the HTML you need.  
So once I figured that out, it was fairly easy to get it to work just fine. My plot output was nicely wrapped in a hyperlink to the plot with the right attributes to make use of fresco, and everything was fine and dandy. 

## Images for the web

*But blog guy*, you might say, *that's nice for people, but what about semantic HTML?*.  
Well I've thought of that as well, my dear hypothetical asshat. You see, by default knitr doesn't render plots with captions unless you specifically render directly to HTML instead of Markdown, so I thought I might as well make use of the `<figure>` and `<figcaption>` tags, so know my `<img>`s are wrapped in `<figure>`s with a `<figcaption>` that defaults to the `fig.cap` chunk option… which I'm not used to using, because I usually don't have much use for them. That's why I use the chunk `label` as a fallback for the caption, so all my plots are captioned nice(ish)ly.

*But that's not what I was talking about*, you might continue, and I know, I also learned about the [<picture> tag][picturetag]. It's a neat little HTML addition that lets you define different images for different screen sizes and even offer alternatuve image formats for browsers that know how to handle them.  
The thing with the different sizes [has already been brought up on the blogdown repo](https://github.com/rstudio/blogdown/issues/46) and intrigued me a bit. I'm not very concerned with responsiveness in that regard because my plots are set to width relative to the container size anyway, but a smaller filesize image might be neat.  

And that's, once again, where knitr falls short. Knitr only renders a single image, but of course you could probably write a wrapper for the `png` device and go to town, but I went a much simpler route and just used [`magick`](https://cran.r-project.org/web/packages/magick/vignettes/intro.html#converting_formats) (R bindings to `ImageMagick`) to convert the plot to [WebP](https://developers.google.com/speed/webp/) inside the `plot` hook and boom, multiple image output in knitr, easy as pie.  
Kind of.

## So what do?

So what's going on in the end?  
Basically, it all boils down to this part of my custom `hook` function that produces the plot's HTML:

```r
# Some assembly happening beforehand

glue("<figure><picture>",
     "<source type='image/webp' srcset='{filename_webp}'>",
     "<a href='{filename}' class='fresco' data-fresco-caption='{caption}'
     data-fresco-group='{id}' data-lightbox='{id}' data-title='{caption}'>",
     "<img src='{filename}' {width} {height} alt='{caption}' />",
     "</a></picture>",
     "<figcaption>{caption}</figcaption>",
     "</figure>")
```

<small>Full code [here](https://github.com/jemus42/blog.jemu.name/blob/master/helpers.R)</small>

So the structure is basically like this:

```html
<figure>
  <picture>
    <source type='image/webp' srcset='{filename_webp}'>
    <a href='{filename}' class='fresco' […]>
      <img src='{filename}' […] />
    </a>
    </picture>
  <figcaption>{caption}</figcaption>
</figure>
```

And **in theory**, this is all good now. It has the necessary classes and attributes to work with either lightbox2 or fresco, it uses figure captions, and it has an additional image source in the form of WebP. Neat, right?  
Well if it worked, it would be really neat.  
Fresco works, the hyperlink works, but since the hyperlink is hardcoded to the `.png` version of the file, fresco only knows about that one. Also, viewing a page with a plot inside this HTML seems to only display the PNG version of the image, even if I am certain that my version of Chrome can handle WebP, and the avatar in the left sidebar also gets served correctly as WebP for me since it uses the same `<picture>` structure.  

So… yeah. Either the hyperlink messes it up, or the encapsulating `<figure>` messes it up, or it's some other bullshit, but I'd like to reiterate that **in theory* my RMarkdown posts now generate futuristic WebP/PNG plots.  
Which is nice.  
Also, don't even ask me about SVG[^svg].

[^1]: The Brits will know it as a ["bodge"](https://www.youtube.com/watch?v=lIFE7h3m40U)
[^2]: I mean, you _can_ for something like `out.width=100%` which will set the `width` attribute of the `img`
[^svg]: I **wanted** to use SVG as a default plot output format and render WebP and PNG as alternatives after the fact, however the `svglite` device didn't play along nicely. First `magick` didn't want to convert to PNG, and then I noticed that even vanilla plot output using the `svglite` device still ended up as a PNG in my output folder, so I just decided to open that can of worms some time in the future.


[blogdown]: https://github.com/rstudio/blogdown
[blogdown_book]: https://bookdown.org/yihui/blogdown
[bookdown]: https://github.com/rstudio/bookdown
[RMarkdown]: http://rmarkdown.rstudio.com/
[knitr]: https://yihui.name/knitr/
[Hugo]: https://gohugo.io
[fresco]: http://www.frescojs.com/
[picturetag]: https://www.html5rocks.com/en/tutorials/responsive/picture-element/
