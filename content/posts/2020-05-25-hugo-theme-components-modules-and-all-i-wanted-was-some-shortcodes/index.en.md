---
title: Hugo Theme Components, Modules, and All I Wanted Was Some Shortcodes
author: jemus42
date: '2020-05-25'
slug: hugo-theme-components-modules
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
That's *a lot* of work. Wouldn't it be *much easier* to just type `{{</* pkg "ggplot2" */>}}`?

...What do you mean *"no it wouldn't, that's worse"*?

Well anyway, now I did it. Then I thought "wouldn't it be cool if this was *smarter*" and justified it's syntactic overhead [^snip]?  
Well, my [previous ideas regarding package taxonomies](/2020/05/migrating-themes-and-overhauling-the-rest/#the-quest-for-taxonomies) have since lead to the realization that this is *probably* much better handled via Hugo's [data templates]. 

[^snip]: I should note that I wouldn't be using so many shortcodes if it wasn't for [Alfred](https://www.alfredapp.com/)'s snippet functionality. Seriously, give whatever snippet tool you have access to a go. It's great.

The gist is this: Create a file named `/data/packages.yaml` (could also be `.json`), fill it with package metadata, and now you have access to said data in layout templates and shortcodes via `.Site.Data.packages`.  
What is this for? Well, the current iteration of that `pkg` shortcode looks like this:

Did you hear about {{< pkg "ggplot2" >}}? It's a neat package and has a fancy website. I also like {{< pkg "ggrepel" >}}, which also has a fancy website but my shortcode hasn't figured that out yet. Then there's my own package, {{< pkg "tRakt" >}}, which is not on CRAN so it gets a different icon. 

All of them have a hover-tooltip with the package's `Title:` from their `DESCRIPTION` file though, which probably doesn't work right on mobile. But nobody uses mobile devices these days anyway and this wasn't a totally pointless feature to waste a night over because I couldn't get the CSS right, …right?  
Please validate my bad life choices.  
Thanks.

{{< addendum title="For Posterity" >}}
Depending on when you're reading this, these examples either don't work anymore, or they look completely different because I've changed my mind and/or learned a lot since I wrote this initially, and the shortcode has changed since then.  
That's the blog-post equivalent of a live demo.  
Sorry.
{{< /addendum >}}

This shortcode relies on the existence of the [`packages.yml`](https://github.com/rbind/blog.jemu.name/blob/4415a09997e5e859644b2b8a17e86150099bd317/data/packages.yml). I generated this from the packages' `DESCRIPTION` files installed in my blog's {{< pkg "renv" >}}-library, `available.packages()` for CRAN urls, and [this result of a wasted evening](https://github.com/rbind/blog.jemu.name/blob/master/R/maintenance.R#L47-L103). There's probably better solutions available [as Maëlle suggested](https://twitter.com/ma_salmon/status/1264186424443764736) [^codemeta], but I just wanted to get started with something relatively simple --- after all, I was primarly after three things:

- The package's name
- A CRAN url and (CRAN | Not CRAN)
- A GitHub / source URL

[^codemeta]: The [output of `codemetar`](https://docs.ropensci.org/codemetar/#create-a-codemetajson-in-one-function-call) is a lot more complex, takes a while to generate, and is probably not feasible if I want to generate metadata for *a lot* of packages maybe? But it's cool for what it does --- I'd just need this in *one big file for all packages* form I think.

Additionally, I'm a little bummed out about not having a good method of determining which package has a dedicated documentation website, e.g. via `{pkgdown}`, because preferably I'd like to make the package name link to its website and the associated icon either link to CRAN or to its source / GitHub repository. Guess there's a lot of room for improvement [^pkgdown].  

[^pkgdown]: Wonder why I didn't use the shortcode to refer to `pkgdown`? Well that package isn't installed in my blog's project library, so it's not in the `packages.yaml` (because I didn't want one file for *all packages ever* (yet)), and… yes, I need to find a better solution for that data source. 

But I digress, I wanted to talk about shortcode externalization.  
Focus.  

Anyway, with some new shortcodes in hand, I wondered how I'd get them to be usable with another Hugo site without having to copypaste them over. That's when, once again, [Maëlle *literally pushed me* into another rabbit hole](https://twitter.com/ma_salmon/status/1264192872498290688) about Hugo modules and theme components [^rabbithole].  

I was scared about [Hugo modules] (built upon Go modules) at first because neither this [Go modules] intro nor this [Go modules wiki] was particularly easy to skim through, given my only contact with Go had been the second syllable in my chosen static site generator.

[^rabbithole]: I kid, of course. I'm starting to like the dynamic I'm developing with Maëlle where I have a half-baked idea and she throws enough ideas and suggestions my way to actually make them work (kind of). <br> 🐇🕳️

## Theme Components and `git` Submodules

The first step was to remove my shortcodes from my site's `/layouts/shortcodes` and place them into their own cozy little repository at [jemus42/jemsugo] [^namingthings]. Note the file structure: They still live in `/layouts/shortcodes` so Hugo knows where ~~it can stick them~~ how to merge them into its filesystem during rendering... or something.

Once that what done, I could add this new repository as a secondary `git submodule` in my site's `/theme/` directory, where you'd usually only find your, well, theme:

```bash
# Adding a git submodule
git submodule add https://github.com/jemus42/jemsugo.git themes/jemsugo
````

The next step was to adjust my `config.toml` to tell it about the secondary [theme component][theme components]:

```toml
# Before:
theme = "hugo-coder"
# After:
theme = ["jemsugo", "hugo-coder"]
```

Note that now the `theme` key (or whatever they're called in TOML) is not a single string anymore, but an… array? Again, whatever they're called in TOML. This is cool from Hugo's side, but {{< pkg "blogdown" >}} doesn't seem to like it, at least `blogdown::serve_site` and `blogdown::build_site(..., run_hugo = TRUE)` seem to not expect this being a multi-valued element.  

Besides that, everything seemed to work fine though. You can control the precendence of theme components by adjusting the order in which they appear in the `theme` setting, so in this case my `jemsugo` components take precedence over everything in `hugo-coder` --- which in this case does not matter at all, as `hugo-coder` doesn't provide any shortcodes. If there was a `videofig` shortcode in Coder though, it would be ovewritten by my own.

To update your `git` submodules, you can run `git submodule update --rebase --remote`.  
Which is something that I did quite a lot, because once I externalized my shortcodes, I'd have to push the shortcode repository to GitHub and pull it from my blog's repository locally every time I wanted to preview some changes.  
That's not a terribly nice workflow, and I assume the `git` people will know a better solution --- but the point was moot as soon as I realized that Hugo modules were only a small step away, and not that hard to get into.

[^namingthings]: It turns out naming things is really hard. Have you heard? 😱

## Switching to Hugo Modules

Why [Hugo modules] though? Didn't `git` submodules work *just fine*?  
Yes. Yes they worked *just fine*, and this *just fine* included updating submodules via `git submodule update --rebase --remote` after I first ran `git push` on the repository that contained my shortcodes.  
What Hugo modules allow is to just run `hugo mod get -u` in my blog repo after I git `git push` in --- *wait a minuute* that's not better!  

Okay, there is a decent workaround to ease local testing with modules, but first, let's walk through the steps to use Hugo modules instead of theme components + `git` submodules.

After skimming [this helpful post on the Hugo forums][modules-for-dummies], I realized that the thing I wanted to use as a module didn't even need special configuration, meaning I didn't need to run `hugo mod init` in my `jemsugo` repo (apparently), and I didn't need my theme to be specially configured as well.  
All it took (I think), was to declare *my blog itself* a Hugo module by running this in it's root directory:

{{< codecaption lang="bash" caption="Substitute the repo spec accordingly (or maybe remove it? I'm not sure)" >}}
hugo mod init github.com/rbind/blog.jemu.name
{{< /codecaption >}}

This creates a `go.mod` (and a `go.sum`) file in the site's root that lists the modules you're using, once you have declared any in your `config.toml`.  

Here's my `config.toml` for the theme component configuration from previously:

{{< codecaption lang="toml" caption="Tired: Define theme components like this" >}}
theme = ["jemsugo", "hugo-coder"]
{{< /codecaption >}}

The equivalent configuration using Hugo modules apparently looks like this, while *removing the `theme = ` line*:

{{< codecaption lang="toml" caption="Wired: Using Hugo modules like that" >}}
[module]
  [[module.imports]]
    path = "github.com/jemus42/jemsugo"
  [[module.imports]]
    path = "github.com/luizdepra/hugo-coder"
{{< /codecaption >}}

And the `go.mod` in my blog's root now looks like this:

{{< codecaption lang="go" caption="Satisfyingly self-explanatory" >}}
module github.com/rbind/blog.jemu.name

go 1.14

// For local testing
replace github.com/jemus42/jemsugo => /Users/Lukas/repos/github/jemus42/jemsugo

require (
	github.com/jemus42/jemsugo v0.0.0-20200524200711-6fca0e2b9d66 // indirect
	github.com/luizdepra/hugo-coder v0.0.0-20200521121849-ff8d5364ad00 // indirect
)
{{< /codecaption >}}


That `replace` line is used, as the comment suggests, for local testing. It's mentioned in the Hugo docs, but without much further info about what it really does or if its placement in `go.mod` matters. Thankfully [this blog post](https://thewebivore.com/using-replace-in-go-mod-to-point-to-your-local-module/) was helpful to get the gist, and I *think* it now works as expected. 

And the "local testing" thing really makes the difference in workflows compared to submodules: I can tweak my shortcodes in their local folder outside the blog repo, and when I save changes, the `hugo server` running in my blog repo automatically picks them up. It's almost as if this is the way it's supposed to work in the first place!  
…And what I already had when I still had the shortcodes in my blog rather then external, so… yeah.  
But external though!  

{{< addendum title="From local testing to deployment" >}}
Before you deploy your site by pushing to whereever your site is built from (like Netlify), you'll have to comment out that `replace` line in `go.mod` again, because Netlify won't know that local path of yours.
{{< /addendum >}}

I have now deleted my `themes` directory, ran `git submodule deinit` on both submodules, and *it still works* --- even on netlify! So I'm reasonably confident that yes, this modules thing… it might actually work?  
Just like that?

I'm not sure how to handle the precedence thing though, so what if I wanted to make sure some shortcode in `jemus42/jemsugo` takes precendence over a shortcode with the same name in a different module --- I assume there's a solution for that, but I'll look into that some more once I actually have the need for it.  
In any case, according to [bep, modules are here to stay and the `theme = ` thing is left for compatibility](https://discourse.gohugo.io/t/hugo-modules-for-dummies/20758/3), so I doubt there's something modules *can't* do that was possible before. 


## Conclusion

This whole shift in workflows is still pretty new to me, and I mainly discovered my way through it while I was still writing this post.  

I haven't gathered a lot of experience with the Hugo modules approach yet, and there might be a case or two in which I wish I'd still be using the original approach (using my theme as a `git` submodule and my shortcodes in my site).  
I guess the worst thing that could happen would be learning more about how Go works, especially with regards to module caching (*where are they even stored*?) and versioning, or whatever that `_vendor` thing is all about. 

Well, I'll see how it \*clear's throat\* … *Goes*.

<!-- Links -->

[theme components]: https://gohugo.io/hugo-modules/theme-components/
[use-modules]: https://gohugo.io/hugo-modules/use-modules/
[Hugo modules]: https://gohugo.io/hugo-modules/
[module-config]: https://gohugo.io/hugo-modules/configuration/
[Go modules]: https://blog.golang.org/using-go-modules
[Go modules wiki]: https://github.com/golang/go/wiki/Modules
[modules-for-dummies]: https://discourse.gohugo.io/t/hugo-modules-for-dummies/20758

[data templates]: https://gohugo.io/templates/data-templates/

[curlies]: https://twitter.com/ma_salmon/status/1264191903383392257

[jemus42/jemsugo]: https://github.com/jemus42/jemsugo
[luizdepra/hugo-coder]: https://github.com/luizdepra/hugo-coder
