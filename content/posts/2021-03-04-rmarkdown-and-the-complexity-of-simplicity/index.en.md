---
title: RMarkdown and the Complexity of Simplicity
author: jemus42
date: '2021-03-04'
slug: rmarkdown-and-the-complexity-of-simplicity
series:
  - R
tags:
  - RMarkdown
  - knitr
  - pandoc
featured_image: ~
description: ''
series:
  - R
packages: ''
toc: yes
math: no
draft: yes
---

[RMarkdown](https://rmarkdown.rstudio.com/) is the greatest thing since sliced bread (for the R community at least).
But it's not really RMarkdown that's great.
RMarkdown is not a monolith, not a single entity.
What makes RMarkdown so great is the ability to merge prose and R code to create a reproducible output with evaluated code and prose around said output.  
Yeah, that's [knitr](https://yihui.org/knitr/)'s magic for you.  
The other thing that makes RMarkdown so great is the ability to write in one single format, namely Markdown + R code chunks, and create HTML, PDF or Word output from that without having to learn the specific syntax of either.  
Welp, that's actually the greatness of [pandoc](https://pandoc.org/).  
In a sense, I don't love RMarkdown --- I love knitr and pandoc.
RMarkdown as a tool is just the glue that holds in together, and .Rmd as a document format is just the single source from which the cascade of tools is kicked off that makes it all happen.

So in the simplest cases, you write your .Rmd file, knit/render it, and you're happy.  
That's great.  
That's amazing.  
That's awesome for beginners who get a simple yet powerful win-scenario as well as experienced users who just want to quickly whip up something useful without any hassle.
That's wonderful, and I'm extraordinarily happy we have this tool(set) at our disposable.

But that's the simplest case, the best case scenario of hassle-freeness.  
Of course, there sits a deep well of possible frustrations, a rabbit hole full of rabbit holes with rabbit holes inside more rabbit holes.
For the remainder of this post, I'll be focusing on HTML and PDF output, because I'm most familiar with them. Word and Powerpoint outputs are a thing as well, but... just no.
Oh, and I'm categorizing xaringan slides as HTML --- the same way ioslides and reveal.js slides are also just HTML output formats. That being said, beamer presentations are also just PDF output, and if you're wondering about `bookdown`: GitBook is HTML, and nobody cares about `.epub` output, honestly.  
At least I don't.  
At least for the purposes of this post.  
For crying out loud, just let me get on with it, will you?

Anyway, the context for this post is [Alison's tweet from the other day](https://twitter.com/apreshill/status/1367240020944441345?s=20) about RMarkdown, and my tongue in cheek reply has sparked some... thoughts. 

{{< figure src="alison-tweet.png" alt="Alison's tweet about how to describe RMarkdown and my reply about how RMarkdown is great unless something goes wrong and you don't know how to debug it" caption="The feels" link="https://twitter.com/Jemus42/status/1367241043146604546" >}}

## The Promise

So, imagine you're talking to a beginner -- someone with limited experience using R and no experience with RMarkdown, HTML or LaTeX or even plain Markdown for that matter.  
How do you explain to them how RMarkdown works and why it's great?  
Presumably, you'd start simple and show them what they have to write (i.e. an .Rmd file) and what they can get from that (i.e. HTML or PDF output).  
You would probably not start with this diagram from RStudio's RMarkdown docs:

{{< figure src="rmarkdownflow.png" alt="Diagram showing the flow from Rmd to knitr to md to pandoc to multiple output formats" caption="The RMarkdown flow from the official RStudio materials" link="https://rmarkdown.rstudio.com/lesson-2.html" >}}

Don't get me wrong, this diagram is neat, and it's perfectly spiffy for someone who wants to know how the sausage is made, and especially neat for people who are familiar (or have at least heard of) the components of the flow.  
But what does a beginer actually get from that?  
Do they even care whatever the heck a *pandoc* is supposed to be?  
Nope.  
They're mental model of RMarkdown is going to be like this, for at least a while:

{{< figure src="rmarkdownflow-simple.png" alt="Diagram showing the flow from Rmd to MAGIC to output formats" caption="What beginners actually see (or care about)" >}}

## The Pain

What happens when something goes wrong and how tough it is to figure out where the problem actually lies and how to fix it

diagram: standard mode

{{< figure src="rmarkdownflow.png" alt="" caption="" >}}


## The Abyss

diagram: most detailed mode feasible

The deepest interrelationships of all the tools
