---
author: jemus42
categories:
- meta
date: 2017-07-18
slug: blogging-still-sucks-but-now-i-can-tolerate-it
tags:
- Hugo
packages:
- blogdown
title: Blogging still sucks, but now I can tolerate it
---

I've [talked about it here and there](/categories/meta/), and it's still true:  
Blogging still sucks.  
Not for everyone, not for everything, but for at least some people, there's always either something missing or some ridiculous hoops to jump through to just write a blog.  
Sure, many people will be perfectly happy with WordPress, tumblr, ghost, medium and whatnot, and the nerdier folk will swear by their Jekyll blogs auto-deployed via GitHub pages, and it's all fine, but then there's me: Someone who's used to writing in [Rmarkdown](https://rmarkdown.rstudio.com) in [RStudio](https://rstudio.com) because that's where I do my data analysis and my page generation, from simple [single-page reports](https://metadon.jemu.name) to [multi-page websites](https://podcasts.jemu.name) all built inside RStudio using Markdown with R sprinkled through it. Automatically generated and embedded plots, tables and all that jazz. Like it should be.  
But it didn't work so well with Jekyll — or at least I lacked the knowledge and willingness to hack it together myself.  
So for a time, I wrote my post in RMarkdown, rendered it to markdown, did some manual shenanigans to make it work with the Jekyll infrastructure, and then let Jekyll plow over it to suck it up into a blog post.  
It worked, but it sucked. Wanted to update some part of the post? Rerender the thing, do manual copypasting of the changed elements and let Jekyll (or later Hugo) do its thing again.  
That's not nice. That's not what I'm used to.  

And then [Yihui Xie](https://yihui.name/en/about/) came along, perhaps one of the most influential people in the modern R ecosystem. He brought us knitr, the basis of RMarkdown's flexibility, and extensions like [bookdown](https://bookdown.org/yihui/bookdown/) which take the whole thing to another level.  
And then came [blogdown](https://github.com/rstudio/blogdown), which made Hugo and RMarkdown play nicely together.  
And it works.  
I can write my stuff in RStudio as I'm used to, I can render and preview all the things, I can update posts and rerender them seamlessly, plots and images are integrated without any hiccups and bind by the usual knitr conventions, and even chunk caching seems to work just fine, so more complex blogposts don't have to fully re-render during each site generation.  

So far, it truly seems like the best of both worlds, and for the first time in years I actually feel like my blogging infrastructure *just works*, and I'm even slightly confident that it might still work in a year or so.  
That's new.
