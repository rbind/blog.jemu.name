---
title: R Usability Gimmicks
author: Lukas
date: '2025-03-02'
slug: r-usability-gimmicks
categories:
  - R
tags: [cli, macOS]
featured_image: ~
description: ''
series:
  - R
packages: ''
toc: yes
math: no
---

The other day I [posted on Mastodon about shell script wrappers for common R commands](https://norden.social/@jemsu/114078735407359852).

And I thought I might as well flesh this out a little.
So for context, I should note that in my everyday computing setup, I have configured by terminal [iTerm2] as a hotkey window, meaning that whichever desktop space I'm on and whatever application is currently in focus, I just have to press <kbd>F2</kbd> to pop down my terminal window.
That means that "quickly running a shell command" is a very easy and natural part of my computing experience --- and I guess what I'm talking about here is only useful to you if using the terminal feels similarly natural to you.

Secondly, I should not that by bash scripting skills are a hodgepodge of just over a decade of googling around, trial-and-erroring until it works(ish), and more recently, just asking an LLM to fix my shitty scripts.
Writing neat little wrappers for things is basically my way of practicing and trying out different bits and bops, so feel free to suggest better or more flexible approaches.
That being said, I should also point out that using `Rscript` and / or {{< pkg "littler" >}} are perfectly fine options to write scripts using plain R, and the more I think about it the more it becomes obvious that taking a bash detour is kind of pointless for these things, but... oh well.  
Let's get to it.

[iTerm2]: https://iterm2.com/

## Installing Packages with `{pak}`

I often find myself wanting to "just quickly" install or upgrade a package or two, and usually I don't want to block the R session I have in front of me and kind of need for a project. I used to regularly plop down my terminal (<kbd>F2</kbd>), type `R` and then `install.packages("foo")` or for a GitHub package `remotes::install_github("foo/bar")` and move on. {{< pkg "pak" >}} has simplified this workflow in the sense that `pak::pak()` just does everything:

- Calling `pak::pak()` without arguments install development dependencies in an R package project
- It install packages from CRAN
- It install packages from GitHub and other sources
- It does so using automatic system dependency installation on Linux
- I think it uses [P3M] if appropriate by default if I rememebr correctly? Meaning it gets you Linux binaries for various distributions if available[^hpc]

Long story short, in my day to day work, few recent additions to the R ecosystem have been as much of a bonus for me than {{< pkg "pak" >}} [^rignote], so I thought I'd make it a tiny bit quicker to access from a command line:


```sh
#!/bin/bash

if [[ -z "$1" ]]
then
	echo "Running pak::pak()"
	Rscript --quiet -e "pak::pak()"
  exit 0
fi

result="c("
# Loop through all positional parameters
for arg in "$@"
do
  # Append each argument to the result string, enclosed in single quotes, followed by a comma
  result+="'$arg', "
done
# Remove the trailing comma and space, then add the closing parenthesis
result="${result%, })"
printf "Installing packages: %s\n" "$*"
Rscript --quiet -e "pak::pak(${result})"
```
The only complicated part is parsing positional arguments into a character vector, which ended up needing some freshening up on my bash foo, but otherwise it's fairly straightforward.

The usage is simple:

```sh
# Run pak::pak() to install dependencies
pak
# Install one or more packages, CRAN or GitHub
pak glue stringr
pak r-lib/cli
```

And that's it.

I should also probably point out that another way to quickly install a package or two from wherever context I am in is [this R workflow][patrick-alfred] for [Alfred] by Patrick. I'll come back to Alfred later, but I also ended up adapting that workflow to use {{< pkg "pak" >}} under hood, so I can install either CRAN or GitHub packages using the same `r package install` keyword, so there's that.

[^rignote]: and [rig] for that matter, but that's a different blog post.

[^hpc]: Let's say that as someone who regularly works with HPC systems runnong on RedHat Enterprise Linux, I have come to _really_ appreciate being able to get binary R packages in some cases where system dependencies would have otherwise made compilation from source a huge pain

[P3M]: https://packagemanager.posit.co/client/#/
[rig]: https://github.com/r-lib/rig
[patrick-alfred]: https://github.com/pat-s/alfred-r

## Managing `{renv}` Projects

I mostly work on projects that are dependency-isolated and hopefully reproducible-but-no-really-pinky-promise, so {{< pkg "renv" >}} is in daily use.
{{< pkg "renv" >}} is great, most of the time, until something breaks weirdly and everything is terrible and god is dead and stuff, but hey --- that's just computing for you.
And as I often use the terminal to navigate around projects and do minor edits or git operations, I often also just want to run `renv::restore()` or `renv::snapshot()` in a directory.
Especially on HPC systems I feel like one of the most common patterns I use is 

1) `cd <project-dir>` 
2) `git pull` 
3) `R` 
4) `renv::restore()`

At least the latter part of that can be simplified by wrapping the `renv::restore()` call:

```sh
#!/bin/bash

usage() {
  echo "Usage: $(basename "$0") [-s] [-r] [-i]"
  echo "  -s    Snapshot"
  echo "  -r    Restore (without prompt)"
  echo "  -i    Initialize"
  echo "  -h    Show this help"
  exit 1
}

# If no arguments are supplied
if [[ -z "$1" ]]
then
	echo "Running renv::status()"
	Rscript --quiet -e "renv::status()"
	exit 0
fi

# Otherwise parse command line options, select function to run
while getopts "srih" opt; do
  case $opt in
    s)
      CMD="renv::snapshot()"
      ;;
    r)
      CMD="renv::restore(prompt = FALSE)"
      ;;
    i)
      CMD="renv::init()"
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

Rscript --quiet -e "$CMD"
```

So I can run either `renv` to just show `renv::status()`, do a quick restore with `renv -r` and so on. 
I should probably extend this to also wrap `renv::install()`, which would require parsing multiple arguments into a character vector similar to the `pak` wrapper.
The more annoying part to handle would be the clash of the `-i` flag, so that's going to need some disambiguation, but using keywords (`renv install <pkg>`) or long options (`renv --install <pkg>`) would also work.

In any case, this was my most recent attempt at using `getopts`, and it made me think about how I have a completely unrelated project where I'm using the {{< pkg "docopt" >}} package to create a fully R-based command line utility and... huh.
I usually start my small scripts with bash, because that's what I can assume to be always available on any system I use, but when it comes to explicitly wrapping R functionality I do have to admit that wrapping `Rscript` in bash quickly loses its appeal.

Oh well. Another blog post then.

{{< addendum title="Note" >}}
By the way, can you tell that this is the more recent script, with a `usage()` block and everything?  
Yeah.  
Documenting stuff is great, but of course the "meh, it's just for me anyway and there's barely anything to it anyway"-fairy often bestows us with the gift of not giving a fuck.  
Don't be like me.  
Resist the fairy.
{{< /addendum >}}

## Navigating Positron Projects

This is not about shell scripts, but it is limited to macOS via the launcher apps [Alfred] and [Raycast] [^linuxtip].  
I've used [ULauncher] on Ubuntu a few years ago but I have since given up on trying to use desktop-Linux (again) and it's been ages since I actively used Windows.

[^linuxtip]: If you know about tools similar to Alfred and Raycast for Linux or Windows, maybe drop them in the comments

I have previously talked about [using Alfred to quickly open RStudio projects][alfred_post], and I still use it as my primary app launcher, snippet tool, search extension, and for its workflows.
[Raycast] is also cool I guess, and all the young'uns have been switching to it lately, but I haven't quite bothered to make the jump even if I do see it has some nice features and its extension scene seems to be quite a bit more vibrant than Alfreds, but that mightjust be my impression.

So long story short: I recently started using [Positron] as my primary R IDE after never really finding VSCode's extension-driven R support to be quite to my liking [^vscodenote].
One of the minor things that I tripped over however was how Positron behaves when you have multiple instances running (as in: Multiple projects open in different windows, likely across different virtual desktops).  
Here's a screenshot of my dock with two projects opened in both RStudio and Positron:

{{< figure src="dock-rstudio.png" alt="MacOS dock with 2 adjacent RStudio icons with small text indicating projects names, next to it a single Positron icon" caption="Now imagine this but with 4-5 projects across different virtual desktops and very different contexts and tell me which IDE seems easier to navigate the hell you have brought upon yourself by having a minuscule attention span and and a tendency to work on half a dozen things in rotation" >}}

I mentioned this on BlueSky --- my second favorite Twitter-alternative --- and [was reminded][bluesky-reply] of an [Alfred workflow for Positron][manager-positron] relying on the [project manager extension for VSCode][project-manager-extension], which in turn also works on Positron since they're cousins, and the workflow is based on the very similar [workflwo for VSCode projects][manager-vscode].
I also vaguely remember hearing about the combination of Positron + project manager extension + [analogous Raycast extension][raycast-manager] (configured to open Positron rather than VSCode) from [Garrick Aden-Buie][garrick], but I couldn't find the corresponding post given 5 seconds of searching, sorry.

In any case, the principle is quite neat and similar to my previous RStudio-focused Alfred workflow, just that installing the VSCode/Positron extension lets you define a root folder for your projects based on version control mechanisms, for example:

{{< figure src="project-manager.png" alt="Positron settings screen for the project manager extension showing Git base folders" caption="There's few decisions I have questions so often in the past ten as to whether I want it to be `~/repos` or `~/dev` or `~/git` or something else." >}}

You can also manually add projects to a "favorites" stack, which I actually might end up using primarily.  
It's nice to be able to find _every_ project on my machine quickly, but most of the time I just want to cycle between the _recently used_ projects rather than surfacing my ancient lore.

Anyway, tapping that project list from Alfred is then quickly done with the aforementioned workflow:

{{< figure src="tron-glex.png" alt="" caption="Finding projects with the `tron` keyword: Neat" >}}

Press <kbd>Return</kbd> and the project opens, easy as that.  
And since Positron projects open what feels like orders of magnitudes faster than RStudio does (on macOS at least), it's nice and snappy.

A minor thing I did for deduplication purposes as an also occasional VSCode user was to add a switch in the workflow to make it so that holding <kbd>Alt / ⌥</kbd> will open the project in VSCode rather than Positron, which comes in handy here and there --- especially in rare cases where [Positron can't do something I need that VScode can](https://github.com/posit-dev/positron/issues/6221).
Modifying the Positron-centric workflow seemed easier than also installing the VSCode-centric version of it, so maybe I should also switch the keyword from `tron` to `proj` or something, but that's semantics rather than ergonomics.

{{< figure src="workflow-edit.png" alt="" caption="Raycast is nice and all but Alfred has such _dead simple_ workflow editing, it's really quite neat for simple things" >}}


However, what this extension _does not_ do is what I actually wanted in the first place: A better way to switch between _opened_ Positron projects.  
Guess I'll just have to get used to using Raycasts pretty good <kbd>Alt / ⌥ + Tab</kbd> like a normal person.  
_Sigh_.

<small>I should also point out that my old workflow had a feature where using a modifier key made it so that the git remote was opened in the browser, which also comes in handy quite often. I'll hopefully be able to hack that into this workflow as well though.</small>


[garrick]: https://bsky.app/profile/grrrck.xyz
[raycast-manager]: https://www.raycast.com/MarkusLanger/vscode-project-manager
[blusky-reply]: https://bsky.app/profile/elipousson.bsky.social/post/3lj4j4htklk2t
[manager-positron]: https://github.com/coatless/positron-project-manager-for-alfred/
[manager-vscode]: https://github.com/kopiro/vscode-project-manager-for-alfred
[project-manager-extension]: https://open-vsx.org/extension/alefragnani/project-manager

[^vscodenote]: and a bit heavy on the Linuxy-feel of "if you just spent enough time to tweak all the little things eventually it'll start feeling about as good as the thing you're trying to emulate, but never quite, and you'll eternally be frustrated just ever so slightly while being met with mild disbelief at your apparent ineptitude in the willingness-to-bother department". But I digress.

[previous_post]: {{< ref "/posts/2020/2020-05-23-an-alfred-workflow-for-r-users/index.en.md" >}}
[Alfred]: https://www.alfredapp.com/
[alfred_post]: /2020/05/alfred-workflow-for-r-users/
[Raycast]: https://www.raycast.com/
[Ulauncher]: https://ulauncher.io/
[Positron]: https://positron.posit.co/
