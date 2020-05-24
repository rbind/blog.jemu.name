---
title: My Summer Spring Cleaning, Part 1
author: jemus42
date: '2016-10-12'
tags:
  - Ubuntu
  - VPS
  - nginx
  - rstats
toc: true
---

Over the past few weeks I've been upgrading large parts of my personal server infrastructure, including new hardware in my home and different hosts in the ~~butt~~ cloud<sup>TM</sup>.  
Since I spent half the time of the setup reading through blogposts/tutorials/documentation to get everything going, I thought it'd be a nice idea to summarize the stuff I set up in one blogpost, also giving me the excuse to brag about the stuff I did, to my surprise, without any lasting damages.


## My Personal VPS {#personal-vps}

My personal VPS was probably the oldest part of my infratsructure. I rented it a few years ago, initially just for shits and giggles, then to run the [wurstmineberg Minecraft server](https://wurstmineberg.de), then to run the wurstmineberg creative server[^1], and in the meantime I was using it to host websites, the occasional [ZNC](https://wiki.znc.in/ZNC), [twitter bots](https://github.com/mispy/twitter_ebooks), Wordpress sites, R scripts that produced things like [this](https://stats.jemu.name/tvshows/trakt/trakt-popular.html)[^2], and of course a [shiny server](https://shiny.rstudio.com) for my [trakt.tv webapp](https://trakt.jemu.name).  

I probably forgot a few things here and there, but that probably just shows that this was my one-for-all hosting box.  
And it also sucked big time. It was a Ubuntu 12.04 LTS machine, a single 32bit CPU core, 1GB of RAM which sometimes could be bumped up to 2GB[^3]. All in all not ideal for pretty much anything that happened after 2012. I vaguely remember that I had to build the shiny server from source because there is no 32bit package, which was *not* a fun thing to do, but alas, I went with it.  
The machine also cost be 8€ per month[^4]. Nowadays, there are much better options for cheaper prices. 

I was expecting to move this server to [DigitalOcean](https://www.digitalocean.com/) because they seem to be popular and I've been using that for the *Tadaa, Data* server (see below), but then [@bl1nk](https://twitter.com/bl1nk) recommended [scaleway](https://www.scaleway.com/) to me, and boy did these prices look good.

Welp, now I'm running a Ubuntu 16.04 LTS VPS with 4  64bit (finally) cores and 4GB of RAM. This has the added bonus that I could use more recent tutorials for stuff, because boy am I thankful for DigitalOcean's extensive community documentation and tutorials[^5].

So here's the gist:

### NGINX, MYSQL, PHP, SSL {#nginx-mysql-php-ssl}

I was very happy to see that most of the basics are apparently covered in the LEMP stack, whatever LEMP stands for, but oh well, I'm only a part-time nerd so I don't have to know everything. Or anything at all. Anyway, [here's the DO tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04) for the basics you need for stuff like wordpress. I prefer nginx over apache for the very intellectually stimulating reason of being used to it and people I trust recommending it.  
When it comes to SSL, I'm proud to say that every webpage I'm kinda responsible for has SSL certificates thanks to the wonderful LetsEncrypt project, and of course [there's a tutorial for that](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04). Getting this set up was much easier than I remember from a few months back where I had to clone a GitHUb repo and build stuff from source. Having an installable package makes things much more pleasant.  

When it comes to mysql for my wordpress sites, I realized I could make my life tremendously less difficult by just writing down the required commands I need for datapase creation and basic user management. Now I don't have to google that every time. It's almost like knowing stuff. For the record, it looks like this:

```sql
CREATE DATABASE project;
CREATE USER projectuser@localhost IDENTIFIED BY 'thanks1passwordforexisting';
GRANT ALL PRIVILEGES ON project.* TO projectuser@localhost;
FLUSH PRIVILEGES;
```

You either already knew that or you know where to find it, but I felt like I should point this out here.

While we're talking about wordpress prerequisites, there's also the issue of PHP. The only things I know about PHP is that most people in my technology-interested social circle either make fun of it or just plain hate it for various reasons I have no opinion of on my own because I only vaguely understand Shell and only comfortably understand R, sooooo… whatever.  
The thing I wanted to mention is the migration from my old wordpress installs to the new host: My new VPS runs php7 instead of php5 on the old one, so when setting up your nginx config for the new host, you need to include something like this:

```nginx
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
}
```

It took me about 5 minutes to figure out I had to change the `fastcgi_pass` path because both the version number and the actualy directory where the `sock` lives are different now.

Anyway, once I figured that out both my wordpress sites and my [h5ai](https://larsjung.de/h5ai/) directories where working fine and I could move on.

### R stuff! Shiny Server! Magic! {#r-stuff}

Now that I have hardware [supported by shiny server](https://docs.rstudio.com/shiny-server/#ubuntu-12.04), setting things up is basically trivial. If you're curious about RStudio Server, you'll be happy to know that setting that up is basically the same process, so if you've [already set up an R installation](https://cran.rstudio.com/bin/linux/ubuntu/README.html), adding the RStudio Server is pretty much 2 lines of Shell.

The thing about an R installation is that you usually have multiple libraries[^6], and if your setup is similar to mine (R used by my own user and the shiny server), you may want to centralize you're installed R packages if you don't have any particular reason for allowing specific users specific packages.  
In my case, I added the following line to `/etc/R/Renviron`:

```sh 
R_LIBS_USER=${R_LIBS_USER-'/opt/R'}
```

I'm still not entirely sure I understand [R's startup process](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html), but as far as I can tell my approach didn't cause any explosions yet. What I did there was just telling R to install packages in `/opt/R`, a path I made accessible for all the users that need it, so every user can install packages and I don't have to run installations via `sudo` every time I add a new dependency to a shiny app or a script I run on the server.  
Another thing you'll want to set is in you `/etc/R/Rprofile.site`:

```r
options(repos = c(CRAN = "https://cloud.r-project.org"))
```

This will set your CRAN mirror so you don't have to manually select one from a menu every time you install a package. The CRAN mirror above will probably work for most locations and uses HTTPS, so if for whatever reason you're having trouble with HTTPS mirrors, just use the above URL with `https://` and you're good to go. Intrinsically wrong because of the lack of SSL, but good to go.

### Is it still called deployment if I just sync stuff? {#sync}

Now that I have the infrastructure set up for filedumps, it's time to think about how I want to deploy these things. I could do some fancy stuff via git and autodeployment via webhooks I don't understand, I could also set up deployments via rsync and scripts and stuff, or I could just go the easy way and continuously sync local folders to remote folders via [syncthing](https://syncthing.net).  

In the past, I tried the rsync approach with octopress, I tried the git thing with… Okay, I didn't really try it, but [wurstmineberg](https://wurstmineberg.de) people set stuff up and it kinda worked? Anyway, I'm a big fan of the whole "just two folders syncing" approach, and I've been a satisfied pro user of [~~BitTorrent Sync~~ Resilio Sync](https://getsync.com/individuals/) in the past, but I ran into a few small issues and inconveniences here and there, so I decided it was time to check out Syncthing.  
Syncthing has the advantage of being open-source, so I can check out GitHub for issues and feature requests, it's a little more flexible because it doesn't require to me handle identities, and it doesn't assume I have a bunch of folders I wanna share with strangers, but rather let's me add a bunch of devices I want to connect to eachother.  

So now I have backups to my local NAS from my laptop, various websites and filedumps from my laptop to my NAS to my VPS, and a bunch of other stuff all running smoothly. It's also very configurable, which is a nice change, and it has this nifty [data page](https://data.syncthing.net/) which you can choose to contribute to by opting in to anonymous data collection. It also works fine on android, providing a fast and reliable way of quickly accessing my phone's photos from my laptop without Dropbox Camera Upload hogging my Dropbox space.  
If I remember correctly, Syncthing is fairly young compared to services like ~~Bittorrent Sync~~ Resilio Sync or even Dropbox, but it's already pretty damn good, so I have high hopes for this one. Please don't crash and burn Syncthing. Please don't.

## Conclusion

I've had this document open for over a week now and it turn's out I don't have the time to finish the rest of it these days, so yeah, first multip-part blogpost, wheee.

[^1]: It's [a long story](https://wiki.wurstmineberg.de/Hosting#History).
[^2]: This reminds me, I really wanted to clean that up, so there's a chance if you're reading this I already moved it somewhere else and I *may* have going to have forgotten to fix the link… Or something.
[^3]: I never really figured this out, but rest assured it sucked.
[^4]: which is probably a different amount in whatever currency you're used to and I'm not going to convert to for you because I'm a lazy fuck, but you get the idea
[^5]: They may not be applicable to my scaleway situation one to one, but they're a good starting point. Scaleway has decent docs as well, but they're not as plentiful as on DO.
[^6]: In R lingo, the *library* is where the *packages* live, and *packages* are the third party code bundles we all love. However, if you're reading this, I expect you to either already know that or not care about that, which causes me to question the merit of this footnote. I could stop writing this footnote now to spare you further rambling, but as it turns out, I quite enjoy filling space and wasting your presumably precious time like this. Are you enjoying our special time together as well? No? You want me to stop? Well I don't want to annoy you any further, I'm afraid this might reflect negatively on me, and I'm very self-conscious when it comes to how other people think of me on the internet. I actually quite enjoy making people laugh and being a pleasant person in the background, so I'll just leave this here and wish you a good day.
