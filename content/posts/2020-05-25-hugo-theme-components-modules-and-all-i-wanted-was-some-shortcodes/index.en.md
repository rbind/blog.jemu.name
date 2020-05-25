---
title: Hugo Theme Components, Modules, and All I Wanted Was Some Shortcodes
author: jemus42
date: '2020-05-25'
slug: hugo-theme-components-modules-and-all-i-wanted-was-some-shortcodes
series:
  - Blogging
tags:
  - Hugo
featured_image: ""
description: ""
toc: yes
math: no
---

## Fun With Shortcodes

 I had been playing around with some custom shortcodes, either to fill a gap as far as functionality provided by Hugo's existing (built-in) shortcodes was concerned, for my own convenience to wrap frequently uses elements, or just for fun as a learning exercise (and let's be honest, usually all of the above combined).
 
On the *"filling a need"* side, there's my shortcode to embed videos. It's not perfect, and I already found [a smarter one](https://github.com/martignoni/hugo-video/blob/master/layouts/shortcodes/video.html) in the wild, but it does it's job and works for me:

{{< codecaption lang="go" caption="" >}}
{{</* videofig mp4="my-file.mp4" loop=true autoplay=true caption="A catchy caption" */>}}
{{< /codecaption >}}

This wraps a `<video>` element inside a `<figure>` element inluding a `<figcaption>`, as you might have seen in action already, and the output HTML looks roughly like this:

{{< codecaption lang="html" caption="" >}}
<figure>
  <video loop autoplay muted controls>
    <source src="my-file.mp4" type="video/mp4">
    Your browser does not support the video tag.
  </video>
  <figcaption>
    <p>A catchy caption</p>
  </figcaption>
</figure>
{{< /codecaption >}}

I generally like the added caption over a plain `<video>` tag, and since I learned that the `<figure>` tag is meant to hold all kinds of content including `<pre>` (for code), `<video>` and `<picture>`, I also added a shortcode to wrap highlighted code in `<figure>`, *and* a generalized shortcode to wrap *anything* inside `<figure>` with a caption. Once I copypasted [Hugo's embedded `figure.html`](https://github.com/gohugoio/hugo/blob/aba2647c152ffff927f42523b77ee6651630cd67/tpl/tplimpl/embedded/templates/shortcodes/figure.html) shortcode, the floodgates were open on my shortcoding and `<figure>`-wrapping.

Another more complex thing I'm playing around with is a shortcode to mention R packages in text. You might have seen R packages referred to something like `{ggplot2}`. That's a package name wrapped inside `{ }` for [whatever reason][curlies], _and_ inside `` ` ` `` for the monospaced formatting. And I haven't even linked it to it's website!  
That's *a lot* of work. Wouldn't it be *much easier* to just type `{{</* pkg "ggplot2" */>}}`? [^snip]

...What do you mean *"no it wouldn't, that's worse"*?

[^snip]: I should note that I wouldn't be using so many shortcodes if it wasn't for [Alfred](https://www.alfredapp.com/)'s snippet functionality. Seriously, give whatever snippet tool you have access to a go. It's great.

Well anyway, now I did it. Then I thought "wouldn't it be cool if this was *smarter*" and justified it's syntactic overhead?  
Well, my [previous ideas about package taxonomies](/2020/05/migrating-themes-and-overhauling-the-rest/#the-quest-for-taxonomies) have since lead to the realization that this is *probably* much better handled via Hugo's [data templates]. 

The gist is this: Create a file named `/data/packages.yaml` (could also be `.json`), fill it with package metadata, and now you have access to said data in layout templates and shortcodes via `.Site.Data.packages`.  
What is this for? Well, the current iteration of that `pkg` shortcode looks like this:

Did you hear about {{< pkg "ggplot2" >}}? It's a neat package and has a fancy website. I also like {{< pkg "ggrepel" >}}, which also has a fancy website but my shortcode hasn't figured that out yet. Then there's my own package, {{< pkg "tRakt" >}}, which is not on CRAN so it gets a different icon. All of them have a hover-tooltip with the package's `Title:` from their `DESCRIPTION` file though, which probably doesn't work right on mobile.  

But nobody uses mobile devices these days anyway and this wasn't a totally pointless feature to waste a night over because I couldn't get the CSS right, …right?  
Please validate my bad life choices.  
Thanks.

{{< addendum title="For Posterity" >}}
Depending on when you're reading this, these examples either don't work anymore, or they look completely different because I've changed my mind and/or learned a lot since I wrote this initially, and the shortcode has changed since then.  
That's the blog-post equivalent of a live demo.  
Sorry.
{{< /addendum >}}

This shortcode relies on the existence of the [`packages.yml`](https://github.com/rbind/blog.jemu.name/blob/4415a09997e5e859644b2b8a17e86150099bd317/data/packages.yml). I generated this from the packages' `DESCRIPTION` files installed in my blog's {{< pkg "renv" >}}-library, `available.packages()` for CRAN urls, and [this result of a wasted evening](https://github.com/rbind/blog.jemu.name/blob/master/R/maintenance.R#L47-L103). There's probably better solutions available [as Maëlle suggested](https://twitter.com/ma_salmon/status/1264186424443764736) [^codemeta], but I just wanted to get started with something relatively simple --- after all, I was primarly after three things:

- The package's name
- A CRAN url / CRAN "status"
- A GitHub / source URL

[^codemeta]: The [output of `codemetar`](https://docs.ropensci.org/codemetar/#create-a-codemetajson-in-one-function-call) is a lot more complex, takes a while to generate, and is probably not feasible if I want to generate metadata for *a lot* of packages maybe? But it's cool for what it does --- I'd just need this in *one big file for all packages* form I think.

Additionally, I'm a little bummed out about not having a good method of determining which package has a dedicated website / `{pkgdown}` site, because preferably I'd like to make the package name link to its website and the associated icon either link to CRAN or to its source / GitHub repository. Guess there's a lot of room for improvement [^pkgdown].

[^pkgdown]: Wonder why I didn't use the shortcode to refer to `pkgdown`? Well that package isn't installed in my blog's project library, so it's not in the `packages.yaml` (because I didn't want one file for *all packages ever* (yet)), and… yes, I need to find a better solution for that data source.  

But I digress, I wanted to talk about shortcode externalization.  
Focus.  

Anyway, with some new shortcodes in hand, I wondered how I'd get them to be usable with another Hugo site without having to copypaste them over. That's when, once again, [Maëlle *literally pushed me* into another rabbit hole](https://twitter.com/ma_salmon/status/1264192872498290688) about Hugo modules and theme components [^rabbithole].  

I was scared about [Hugo modules] at first because neither this [go modules] intro nor this [go modules wiki] was particularly easy to skim through given my only contact with go had been the second syllable in my chosen static site generator.

[^rabbithole]: I kid, of course. I'm starting to like the dynamic I'm developing with Maëlle where I have a half-baked idea and she throws enough ideas and suggestions my way to actually make them work. <br> 🐇🕳️

## Theme Components and `git` Submodules

The first step was to remove my shortcodes from my site's `/layouts/shortcodes` and place them into their own cozy little repository at [jemus42/jemsugo] [^namingthings]. Note the file structure: They still live in `/layouts/shortcodes` so Hugo knows where ~~it can stick them~~ how to merge them into its filesystem during rendering... or something.

[^namingthings]: It turns out naming things is really hard. Have you heard? 😱

## Switching to Modules

Why modules though? Didn't submodules work *just fine*?  
Yes. Yes they worked *just fine*, and this *just fine* included updating submodules via `git submodule update --rebase --remote` after I first ran `git push` on the repository that contained my shortcodes. That's… not so nice?  
What Hugo modules allow is to just run `hugo mod get -u` in my blog repo and --- *wait a minuute* that's not better!  

I'm not entirely sure what the benfit is yet besides that dealing with `git` submodules can be a little annoying here and there, but I'll see how it goes --- but let's get to the set up first.

What it took in the end to make it work:

In *my site's* repository: 

{{< codecaption lang="bash" caption="Substitute the repo spec accordingly (or maybe remove it? I'm not sure)" >}}
hugo mod init github.com/rbind/blog.jemu.name
{{< /codecaption >}}


My `config.toml` *used* to contain this line:

{{< codecaption lang="TOML" caption="Tired: Define theme components like this" >}}
theme = ["jemsugo", "hugo-coder"]
{{< /codecaption >}}

You probably also have a line like `theme = "my-theme"`, but you know what? That's for *old people* [^modnew]!

[^modnew]: It should be noted that Hugo modules were introduce in Fall 2019 or so. So yes, obviously you should use them for everything over the previous method, what could go wrong!

The *equivalent*(!) using Hugo modules apparently looks like this:

{{< codecaption lang="r" caption="Wired: Using hugo modules like that" >}}
[module]
  [[module.imports]]
    path = "github.com/luizdepra/hugo-coder"
  [[module.imports]]
    path = "github.com/jemus42/jemsugo"
{{< /codecaption >}}


The `go.mod` in my blog's root now looks like this:

{{< codecaption lang="r" caption="A code caption" >}}
module github.com/rbind/blog.jemu.name

go 1.14

// For local testing
replace github.com/jemus42/jemsugo => /Users/Lukas/repos/github/jemus42/jemsugo

require (
	github.com/jemus42/jemsugo v0.0.0-20200524200711-6fca0e2b9d66 // indirect
	github.com/luizdepra/hugo-coder v0.0.0-20200521121849-ff8d5364ad00 // indirect
)
{{< /codecaption >}}


That `replace` line is used, as the comment suggests, for local testing. It's mentioned in the Hugo docs, but without much further info about what it really does. Thankfully [this blog post](https://thewebivore.com/using-replace-in-go-mod-to-point-to-your-local-module/) was helpful to get the gist, and I *think* it now works as expected.

I have now deleted my `themes` directory, ran `git submodule deinit` on both submodules, and *it still works* --- even on netlify! So I'm reasonably confident that yes, this modules thing… it might actually work?  
Just like that?

I'm not sure how to handle the precedence thing though, so what if I want to make sure some shortcode in `jemus42/jemsugo` takes precendence over a shortcode with the same name in a different module, but I assume there's a solution for that.  
According to [bep, modules are here to stay and the `theme = ` thing is left for compatibility](https://discourse.gohugo.io/t/hugo-modules-for-dummies/20758/3), so I doubt there's something modules *can't* do that was possible before. 


<!-- Links -->

[theme components]: https://gohugo.io/hugo-modules/theme-components/
[use-modules]: https://gohugo.io/hugo-modules/use-modules/
[Hugo modules]: https://gohugo.io/hugo-modules/
[module-config]: https://gohugo.io/hugo-modules/configuration/
[go modules]: https://blog.golang.org/using-go-modules
[go modules wiki]: https://github.com/golang/go/wiki/Modules
[modules-for-dummies]: https://discourse.gohugo.io/t/hugo-modules-for-dummies/20758

[data templates]: https://gohugo.io/templates/data-templates/

[curlies]: https://twitter.com/ma_salmon/status/1264191903383392257


[jemus42/jemsugo]: https://github.com/jemus42/jemsugo
[luizdepra/hugo-coder]: https://github.com/luizdepra/hugo-coder
