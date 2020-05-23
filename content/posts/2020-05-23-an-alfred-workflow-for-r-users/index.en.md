---
draft: true
title: An Alfred Workflow for R Users
author: jemus42
date: "2020-05-23"
slug: []
featured_image: workflow-demo-search.png
tags: 
  - Alfred
  - VS Code
  - RStudio
  - Workflow
  - macOS
description: ""
series:
  - Software
toc: true
math: true # works, "katex: true" doesnt
---

Over the past few years, [Alfred] has become one of my favorite macOS apps.  
It's definitely up there with other apps I wouldn't want to use a Mac without the likes [Bartender], [Typinator] or [iStat Menus].  

When I first started using it, I was pretty overwhelmed by all the things it could so, so I mostly stuck to things that felt like immediate extensions of macOS's built-in Spotlight --- which already made <kbd>⌘+Space</kbd> my reflexive choice to the general problem of "finding things" or even just opening an App --- Alfred was just a lot *better* at it.  
Add better file maneuverability in the search window, custom search providers and some other bits, and there was my fully-featured Spotlight replacement.  

Then I ventured into [workflows] by browsing [packal] a lot and found some neat things here and there, but I never really used all that potential to solve any problems I actually had, they were mostly just nice additions for edge cases I tended to forget I even had access to at my fingertips.

{{< figure src="alfred-color-workflow.png" alt="Alfred color workflow showing a color code in various alternative formats" caption="A neat but rarely useful (to me) color workflow from here: https://github.com/TylerEich/Alfred-Extras" >}}

Recently I also started adding some new snippets to Alfred instead of using the aforementioned Typinator for that. I've been using Typinator for a lot longer than Alfred, and while I prefer the "fewest number of apps for the largest amount of functionality" approach, I haven't bothered migrating my Typinator snippets yet. I do generally prefer Alfreds [snippets] functionality & UI though, so that may be in my future. My recent ventures into [making hugo shortcodes](https://gohugo.io/templates/shortcode-templates/) have definitely given me enough reason to add more snippets though.

{{< figure src="alfred-hugo-video.png" alt="Alfred snippets window showing a snippet named 'videofig' which inserts a hugo shortcode" caption="One of my snippets for a video-embedding shortcode" >}}

What I'm actually here to talk about is a small workflow I made to help with my tendency to switch RStudio projects a lot, my frequent need to refer back to older projects, and my secondary desire to open projects in VS Code as well (which is faster to open and makes it easier to work with a lot of files).

It turns out it's *really* easy to get started making Alfred workflows, so here's the gist of what mine does:

- Open the Alfred search window (<kbd>⌘ + Space</kbd> for me)
- Type `rs <keyword>` where `<keyword>` matches the RStudio project file (`.Rproj`)
- Then, depending on modifier keys:
    - **Default**: Open the project in RStudio
    - **Shift ⇧**: Open the enclosing folder in VS Code
    - **Option ⌥**: Open `git`'s `origin` (e.g. GitHub) in the default browser.
    - **Command ⌘**: Open in Finder (not configured in workflow, but ALfred offers this by default apparently)

And here's a video of it in (semi-)action, where I only trigger the keys (see the black centered window thanks to [KeyCastr](https://github.com/keycastr/keycastr)) but don't actually have it open anything to keep the video smaller (dimension-wise):


{{< videofig mp4="alfred-rsproj-comp.mp4" loop=true autoplay=false alt="A demonstration showing the Alfred search bar using the keyword 'rs' to trigger the workflow. The text 'blog' is entered to search for my blog project, and different modifier keys (alt, command, ctr) are pressed to show the change workflow's action." caption="Triggering the workflow with `rs`, showing hints about what it does with different modifier keys" >}}

And under the hood it's only these four elements:

{{< figure src="workflow-schema.png" alt="Alfred workflow structure showing 4 components" caption="The graphical approach makes this nicely intuitive" >}}

## ~~Step by Step~~ The Whole Shebang

Let's start with a new workflow. Open the Workflow pane and add an empty workflow to fill in its details.

{{< figure src="workflow-new.png" alt="" caption="Branding is important." >}}

Once you have an empty workflow, you can add a file filter that will search and find all your `.Rproj` files:

{{< figure src="workflow-demo-add-filter.png" alt="" caption="There may be better solutions, but this one works fine enough" >}}

Configure to new file filter with your desired metadata, like a keyword to trigger it in the Alfred search box (here I chose `proj`). To make it find `.Rproj` files, you only have to drag and drop an existing project file into the lower part of the box:

{{< figure src="workflow-demo-filter.png" alt="" caption="Is this programming?" >}}

You can also give it a nice icon, like the RStudio logo which would then be displayed in the search window. For now our test workflow looks like this:

{{< figure src="workflow-demo-search.png" alt="" caption="A sad workflow of emptiness (functionality-wise)" >}}
  

Now, to have RStudio (or VS Code) open the project, we need the appropriate action elements.  
Instead of doing a screenshot-by-screenshot thing, I thought I might as well show the whole shebang in a short clip, as it's really not that complicated as far as the required number of steps is concerned [^derp]:

[^derp]: This is also *totally* not motivated by my frustration upon realizing that I used the wrong action (Launch App) instead of the "Open File" element and had to re-do/write at least 4 screenshots, 4 paragraphs of text and a ~10 second clip. This was totally planned from the start to be a ~1min clip of the whole thing, yep. Hmmhmm. No questions there.

{{< videofig mp4="workflow-recreation.mp4" loop=true autoplay=false alt="" caption="Looking back, it really is pretty easy to do" >}}

The only tricky bit is to make sure VS Code receives the enclsosing folder of the project and not the `.Rproj` file itself, where this regular expression comes in handy `[a-zA-Z0-9-\.]+\.Rproj$` (along with Alfreds [clipboard history], another feature I never want to use a computer without).

So, start to finish, what's that? Maybe two minutes? Neat.  

## The `git` Bit 

The only bit that's missing from my original workflow is the "open repo in browser" thing, but that's mainly a `bash` thing anyway. Just add a "Run script" action, link it with your preferred modifier key and go to town.

The script I'm using looks like this --- it took me a lot of stackoverflow'ing and I eventually settled on a classic *less-than-optimal but optimal-enough* solution [^lessopt]:

[^lessopt]: Can we make **"LTOBOE"** a thing? No? Bummer.

{{< codecaption lang="bash" caption="You can probably ignore the Gitea-bit" >}}
query=$1
dir=$(dirname ${query})
cd $dir

# Github
if [[ $(git config remote.origin.url | grep github) ]]; then 
  open $(git config remote.origin.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")
fi

# Self-hosted Gitea
if [[ $(git config remote.origin.url | grep gitea) ]]; then 
  open $(git config remote.origin.url | sed "s/ssh:\/\/gitea@/https:\/\//" | sed "s/:54321//" | sed "s/\.git$//")
fi
{{< /codecaption >}}

The gist is to take the `origin` url via `git config remote.origin.url` and check if it's a GitHub repository or not, and then run some good old `sed` find & replace to arrive at a browser-compatible url.  
In the second half, I do the same thing but with the handicap that my self-hosted [Gitea]'s urls look a little different and contain a non-standard port (don't @ me), so you can probably safely ignore that or tweak it to your needs.

## Conclusion

So, what do we learn today?

1. Productivity tools are only productivity tools if you use them for productivity. Installation does not suffice.
2. Not every Alfred Workflow worth installing has to be a massively-featured complexity monster that sat unmaintained on [packal] for 5 years [^packalold].
3. Solving your own problems is worth more than downloading/installing someone else's solutions that work for *them*.

I hope at least someone finds this useful.

[^packalold]: If you find a cool looking workflow on packal (when it's not currently broken), and see that the workflow hasn't been updated in a long time, there are usually two options. A) The workflow is fairly simple and rock-solid, hence no need for updating, or B) Tough luck, it doesn't work anymore and the creator has moved on and abandoned it. I have found examples for both cases, and it's a little frustrating to be honest.

<!-- links -->
[Alfred]: https://www.alfredapp.com/
[workflows]: https://www.alfredapp.com/help/workflows/
[snippets]: https://www.alfredapp.com/help/features/snippets/
[clipboard history]: https://www.alfredapp.com/help/features/clipboard/
[packal]: http://www.packal.org/

[Typinator]: https://www.ergonis.com/products/typinator/
[iStat Menus]: https://bjango.com/mac/istatmenus/
[Bartender]: https://www.macbartender.com/
[Gitea]: https://gitea.io/
