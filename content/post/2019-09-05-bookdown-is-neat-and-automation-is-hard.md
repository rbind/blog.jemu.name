---
title: Bookdown is neat and automation is hard
author: jemus42
date: '2019-09-05'
slug: bookdown-is-neat-and-automation-is-hard
categories:
  - rstats
tags:
  - travis-ci
packages:
  - bookdown
draft: no
description: ''
editor_options:
  chunk_output_type: console
---


Anyone and their hamster is writing [bookdown](http://bookdown.org/yihui/bookdown) books these days, and that's arguably a good thing – because as long as everything renders nicely, it's a pretty easy way to get some knowledge out there.

<!--more-->

But then there's the case where stuff *doesn't* render nicely, and that's where the fun ends and the "*learning about stuff you didn't know was relevant or come to think of it was particularly interesting to begin with is a required step in the process of making things happen that you kinda want to happen*" game starts. Or, as I like to call it, "the ol' **lasydkwrocttoiwpitbwiarsitpomthtywth**" [^1].

[^1]: still sucking at acronyms

So now that I more or less successfully switched our [R-Intro for psychology undergrads](https://r-intro.tadaa-data.de/book/) (German) over from "auto-built on our server mostly" to "auto-built on [Travis CI](https://travis-ci.org/)", I thought it might be a good time to consolidate some of the things I've learned along the way as someone not terribly familiar with travis outside of R-package testing.

If you're not at all familiar with travis (or the concept of CI), then you might want to [brush up on the basics](https://docs.travis-ci.com/user/for-beginners/) before you continue. For everything else, I'm going to assume that you're at least kind of familiar with with git / GitHub (if not, [this is your go-to reference](https://happygitwithr.com/)) and have dabbled in bookdown already.

## But why though?

The first question one might ask is: Why even bother doing the travis-dance when you can just render your bookdown project locally in your bazillion formats? Then either directly upload that somewhere or commit the whole output to version control and let GitHub Pages or netlify pick it up from there. 
That's certainly a possibility, but it's also prone to some reproducibility issues.  
For example, to render our R-Intro, we were relying (directly or indirectly) on R packages with specific system dependencies – on Ubuntu systems, they needed to be installed via `apt`. Wile I was starting up the project on macOS, I wasn't aware of these dependencies because, well, it worked for me. On my machine. Locally.  
That might be all fine and dandy and good enough, but as soon as you're collaborating with other people, presumably on different operating systems, the dependency hell starts to inch closer and you're beginning to feel the pain of the "it works because I did some stuff here, dunno"-workflow.  

Building your project via services like travis has the neat effect of forcing you to think about what is required to make you project reproducible – that principlie applies to R-packages the same as it does to things we don't usually think about having "dependencies" in this sense: Books, for example. 
The idea is: If you can make it work on travis, you can probably make it work on other people's machines, too.

Besides that, building stuff on travis (and deploying from there) also means that you don't run the risk of making some small changes to your book and then forget to render/upload, or making a change and not realizing that it introcuded an issue that breaks your book.  

The workflow `make changes -> git commit -> git push to GitHub -> travis -> deploy target` ensures that you don't have to worry about anything past the point where you modify the content of your book. Well, at least as long as all the other bits of the pipeline are set up approrpiately.

## Build & deploy to GitHub Pages

Probably the easiest solution as you only need a GitHub account and token.  
The GH pages deplyoment is documented [here](https://docs.travis-ci.com/user/deployment/pages/), and you'll at least need to get a personal access token from GitHub (in R, you can let `usethis::browse_github_token()` take you where you need to go) and add it to your project on travis as an environment variable (perferrably named `GITHUB_PAT`), and make sure it is available to all branches and won't display in the build log.

{{< figure src="https://dump.jemu.name/2019-09-uv5tqwkabimfnik.png" caption="Kind of what it should look like on travis" >}}

Now, to have travis build your project and push to a `gh-pages` branch, you'll first have to create that branch. These bits are explained [in the bookdown book](https://bookdown.org/yihui/bookdown/github.html) already.

You'll also need a dummy `DESCRIPTION` file at the root of your project, just because that's the key component of an R package which travis needs to figure out which R packages need to be installed before anything else can happen. It should look something like this:

```yaml
Type: Book
Package: mybook
Title: Placeholder file for travis
Version: 0.0.1
License: MIT + file LICENSE
Imports:
    bookdown,
    dplyr,
    ggplot2,
    ggthemes
Remotes:
    hrbrmstr/firasans
Encoding: UTF-8
```

Most fields don't matter, except `Imports:` (definitely) and `Remotes:` (probably?).  
Maintaining such a file for your bookdown project is also a good way to keep track of the packages you use along the way.

Your `.travis.yml` might look something like this (for the first 3 lines, refer to [the travis docs](https://docs.travis-ci.com/user/languages/r) for R projects):

```yaml  
sudo: false 
language: r
dist: bionic

# Cache (i.e. persist across builds) some stuff that's not needed to be re-built
cache:
  packages: yes
  directories:
    - $HOME/bin       # Where webshot installs phantomjs
    - $TRAVIS_BUILD_DIR/_bookdown_files # Rendered images cache

# Install phantomjs (needed for htmlwidgets => images in PDF)
before_script:
  - "[ -x \"$HOME/bin/phantomjs\" ] || Rscript -e \"webshot::install_phantomjs()\""

# Render the actual book on at a time
script:
  - "Rscript -e \"bookdown::render_book('index.Rmd', 'bookdown::gitbook')\""
  - "Rscript -e \"bookdown::render_book('index.Rmd', 'bookdown::pdf_book')\""

# Deploy to GitHub pages
# Requires GITHUB_PAT created on GitHub and set in travis
# Also requires a usable gh-pages branch
deploy:
  provider: pages
  local_dir: __book # Or however your book output directory is called
  skip_cleanup: true
  keep_history: true
  github_token: $GITHUB_PAT
  target_branch: gh-pages
```

The steps are executen in order of appearance. As there's only 3, and they're named `before_script`, `script` and `deploy`, they're probably pretty self-explanatory.  
You might stumble over this part though:

```yaml
  # Install phantomjs (needed for htmlwidgets => images in PDF)
  before_script:
    - "[ -x \"$HOME/bin/phantomjs\" ] || Rscript -e \"webshot::install_phantomjs()\""
```

and it's kind of ugly. What this does is "if there's not an executable at `$HOME/bin/phantomjs`, execute this `Rscript` command to install it using the `webshot` package". In general, `phantomjs` is required if you're using some kind of [htmlwidget](https://www.htmlwidgets.org/) in your book, but also render non-interactive output like PDF or epub – it basically makes a snapshot of your widget and pastes the image into your book.  
The first bit of the command is a bash test expression, checking if there's an executable. Read up on tests/conditions/logic in bash if you're interested, or accept that this is a thing that we did [^2]. 

[^2]: It should also be noted that this command is set up so that the overall exit status is `0` in either case, because otherwise travis would consider the build failed, which is kind of annoying.

Anyway – why did we do this again? Well, we told travis to cache `$HOME/bin` for us, where `phantomjs` gets installed to, and we don't want to download and install `phantomjs` every time we trigger a build, so this seems like a neat way to solve that issue.

Anyway, now travis is building your book in two formats, sequentially, and deploys it to GitHub Pages and everything is awesome and you'll never have to worry about anything ev– aaaand it broke.  

## But fonts though

The thing about simple setups is that they only work for simple projects.  
For me, things start breaking around the topic of fonts a lot. Maybe because I like [Fira Sans](https://gitlab.com/hrbrmstr/firasans) in my ggplot2 themes, or maybe because I like [TeX Gyre Pagella](http://www.gust.org.pl/projects/e-foundry/tex-gyre/index_html) in my PDFs.

After diving into the old google rabbit hole of terrible font things, I ended up with this:

```yaml
before_install:
  - |
    # Install TinyTex manually
    Rscript -e "install.packages('tinytex')"
    Rscript -e "tinytex::install_tinytex()"
    mkdir -p $HOME/.fonts
    # Check if fonts are present in cached .fonts dir, if not, download + install
    if [ ! -e $HOME/.fonts/gyre.zip ]; then
     wget http://www.gust.org.pl/projects/e-foundry/tex-gyre/pagella/qpl2_501otf.zip -O $HOME/.fonts/gyre.zip
     unzip $HOME/.fonts/gyre.zip -d $HOME/.fonts/
    fi
    if [ ! -e $HOME/.fonts/gyreheros.zip ]; then
     wget http://www.gust.org.pl/projects/e-foundry/tex-gyre/heros/qhv2.004otf.zip -O $HOME/.fonts/gyreheros.zip
     unzip $HOME/.fonts/gyreheros.zip -d $HOME/.fonts/
    fi
    if [ ! -e $HOME/.fonts/fira.zip ]; then
      wget https://github.com/bBoxType/FiraSans/archive/master.zip -O $HOME/.fonts/fira.zip
      unzip ~/.fonts/fira.zip '*.ttf' -d $HOME/.fonts/
    fi
    # Copy fontconfig for possibly maybe xelatex font issue with spaces in font names
    cp $HOME/.TinyTeX/texmf-var/fonts/conf/texlive-fontconfig.conf ~/.fonts.conf
    # Update font cache for previously installed fonts (+ list fonts for debugging)
    fc-cache -fv
    fc-list
```

This adds a script to the build process using carefully indented `YAML` that you need to be careful about, otherwise it's not recognized by travis and there won't be a build at all.

Anyway, what I did here was, as the comments suggest:

1. Install [TinyTex](https://yihui.name/tinytex/): Maybe I didn't need to, but as far as TeX distributions go, with TinyTex I at least somewhat know how it works.
2. Create a `.fonts` directory where, well, fonts go. Use `mkdir -p` to only create it if it doesn't exist already without throwing an error – we also cache that folder.
3. Manually download fonts as `.zip` files and extract them to `$HOME/.fonts/` – checking if the zip already exists in the cache.
4. Do stuff with `texlive-fontconfig.conf` – I don't know man. It ended up (probably) solving the issue that XeLaTeX didn't find "`TeX Gyre Pagella`" because the font name contained spaces. I think. Honestly at this point I'm too tired of this to do more testing.
5. `fc-cache -fv` makes the new fonts in `.fonts` available to the system. `fc-list` is only there for debugging purposes so the lst of currently available fonts gets printed in the travis build log.

And... it works. Neat.  
This makes `TeX Gyre Pagella` and `TeX Gyre Heros` available to XeLaTeX, and adds [Fira](http://mozilla.github.io/Fira/) fonts for both XeLaTeX (where I use `Fira Mono` as a `monofont`) and ggplot2 plots, where I use `Fira Sans` via the aforementioned theme/package.  

Honestly, this should have been a file called `make-ze-font-stuff-be-good.sh` to keep `.travis.yml` more readable, but I actually prefer to deal with as much as possible in the travis config so it's easier to copy "the travis bits" to a new project than when you have to remember/copy multiple scripts.  
I think.  
I might change my mind later.

Regarding the Fira fonts, I should mention that I had to install the `firasans` manually from GitHub as it's not on CRAN, and for some reason the `Remotes:` filed in `DESCRIPTION` wasn't enough to convince travis to install it for me:

```yaml
before_script:
  - "Rscript -e \"remotes::install_github('hrbrmstr/firasans')\""
```

I also use Asana Math as `mathfont`, but to get this one, you can just get it s a regular ol' apt package.

```yaml
apt_packages:
  - fonts-oflb-asana-math
```

So, at this point you should have working travis deployment to GitHub Pages while also using custom fonts in your PDF output.  
Nice.

## Speeding things up maybe

One thing that annoyed be about this setup was the sequential rendering of the different output formats:

```yaml
# Render the actual book one at a time
script:
  - "Rscript -e \"bookdown::render_book('index.Rmd', 'bookdown::gitbook')\""
  - "Rscript -e \"bookdown::render_book('index.Rmd', 'bookdown::pdf_book')\""
```

What if you also added `bookdown::epub_book` or `bookdown::tufte_book2` or whatever you feel like? That would stretch the build time quite a bit.  
Building multiple formats in parallel on your local machine might not be feasible, because the same intermediate files might be generated and/or deleted simultaneously, but on travis we don't have to care about this. One of the neatest features of travis is that we can spin up 3 different jobs running on 3 different virtual machines doing 3 things totally isolated from each other. 

So what I tried was this:

```yaml
env:
  - BOOKDOWN_FORMAT="bookdown::gitbook"
  - BOOKDOWN_FORMAT="bookdown::epub_book"
  - BOOKDOWN_FORMAT="bookdown::pdf_book"

script:
  - "Rscript -e \"bookdown::render_book('index.Rmd', '$BOOKDOWN_FORMAT')\""
```

Travis will start the parallel jobs for each value of the environment variable `$BOOKDOWN_FORMAT`, and we can access the value of that variable in other sections of the config, like the `script` bit where the fun happens. Here we're throwing `render_book` at whatever format is defined in `$BOOKDOWN_FORMAT`. I suggest looking up bash / shell environment variables if you're not familiar with the concept.

{{< figure src="https://dump.jemu.name/2019-09-d95sg7fpou9u9yp.png" caption="Three parallel build jobs" >}}

The problem with this is, well, kind of a biggie: Each of the three jobs deploys to GH Pages. Each of these jobs overwrites the output of the other job. At the end of the build, your `gh-pages` branch will only contain one of the three formats.  
That's kind of a bummer.

And this is what brings us to server-deployment.

## Deploy stuff to your own server

Servers are relatively cheap, at least the "just webhosting"-level VPS. Ours is hosted on [Scaleway](https://www.scaleway.com) and does the job. It already hosts all of our sites, and I never really intended for our R-Intro to be hosted on GitHub anyway, so it was inevitable to go the ssh-deployment-route anyway.

To get started, I followed (and suggest following) [this blogpost](https://oncletom.io/2016/travis-ssh-deploy/).  
At the end of the day, it was easier to set up than I anticipated. Creating a keypair is simple, and encrypting the private key via the `travis` command line tool isn't exactly rocket science either. 

On the server side, I created a dedicated `travis` user, added the public key to its `authorized_keys` [^3], and made sure the server directory where the output should go is writable by the `travis` user. 

[^3]: if you're doing this manually, make sure the file has `0600` permissions because you won't be able to login if the file is readable by other users

The config bits are as follows:

```yaml
# Target server hostname + port if non-standard
addons:
  ssh_known_hosts: pearson.tadaa-data.de:54321
  
# Decrypt private SSH key, save to /tmp/, add it to ssh-agent
before_deploy:
  - openssl aes-256-cbc -K $encrypted_[will look different for you]_key -iv $encrypted_[will look different for you]_iv -in deploy_rsa.enc -out /tmp/deploy_rsa -d
  - eval "$(ssh-agent -s)"
  - chmod 600 /tmp/deploy_rsa
  - ssh-add /tmp/deploy_rsa

# Actual deployment is just a line of rsync (using a non-standard SSH port)
deploy:
  provider: script
  skip_cleanup: true
  script: rsync -r --quiet $TRAVIS_BUILD_DIR/book -e 'ssh -p 54321' travis@pearson.tadaa-data.de:/srv/r-intro.tadaa-data.de
  on:
    branch: master
```

The whole shebang is located [here](https://github.com/tadaadata/r-intro-book/blob/master/.travis.yml).  

## Conclusion

Using this approach we can have travis render multiple bookdown output formats simultaneously, and after each is finished, `rsync` the output to our server – where each format lives in the same folder without deleting the other output.  
And as long as you don't leak credentials, this is also probably kind of maybe secure™!

...and figuring all that out and making it (kind of) work only cost me a weekend.  
What a steal.
