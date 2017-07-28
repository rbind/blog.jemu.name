---
author: Jemus42
categories:
- tech
date: 2016-11-05
title: My Summer Spring Cleaning, Part 2
type: post
---

Since it's now November, I think it's about time to finish talking about my summer spring cleaning. If you missed [part 1 about my personal VPS](https://blog.jemu.name/post/2016/10/my-summer-spring-cleaning-part-1/), you didn't really miss anything.

In this part I'll talk about my home-server, which is both part of my backup solution and my media storage and server. This post should be considered as both me showing off about setting stuff up without any major explosions, as well as a rough reference for anyone who might want to try a similar setup.

## PPTH: My NAS {#nas}

Home is where my NAS is. That's not only a shitty modification of an even shittier platitude, it also used to be the name of my home back when FourSquare was usable. Remember FourSquare? Me neither. Good.  

Also, my NAS is traditionally called **PPTH**, after the *Princeton Plainsboro Teaching Hospital*, the hospital where [House](https://trakt.tv/shows/house) took place. Why? Because House is my personal happy place and nothing else has shaped my humor, philosophical outlook or opinion on sneakers in such a way as House did. I'd like to point out that my phone is called *House*, my tablet is called *Wilson*, my Chromecast is *Thirteen* and my Chromecast Audio is *Foreman*.  

But enough of that.

### Hardware

This [fancy little bugger](https://www.cyberport.de/hp-proliant-gen8-microserver---xeon-e3-1220l-v2-2-3ghz-8gb-0gb-4x-8-9cm-3-5-lff-1503-27K_548.html) is now my roomate. It lives in my living room, its name is PPTH, and we're friends.  
I chose the version with the bumped CPU because I tend have a lot of video transcoding jobs running, hence the upgrade from the previous generation ProLiant in the first place.  
As of now, I'm still using the preinstalled 8GB of RAM, but I assume I need to upgrade them sooner or later because both FreeNAS and ZFS tend to like their RAM, not to mention Plex.

Drive-wise, I went all out and got 4 of [these WD Red 8TB](https://www.cyberport.de/wd-red-wd80efzx-8tb-5400rpm-128mb-3-5zoll-sata600-3404-24D_404.html) drives, because when I upgrade, I like to grade up a lot.

### Operating System

I'm still pretty happy with [FreeNAS](http://www.freenas.org/), even though it looks like other solutions like NAS4free and unRAID have become quite popular in the past few years, but I never bothered to check them out. You know what they say about running systems and how you're not supposed to touch them. Also, lazyness. Vast amounts of lazyness.  
If you primarily need an OS to handle your storage pool (ZFS), some file shares (CIFS/AFP/NFS), maybe even account management (Active Directory and other things I never used), or some network voodoo, you're probably fine using FreeNAS. 

The [FreeNAS docs](http://doc.freenas.org/9.10/) are usually sufficient for my needs, and the installation on a [small USB drive like this one](https://www.amazon.de/SanDisk-Ultra-Flash-Drive-150MB/dp/B00LLER2CS/) is very handy and keeps your storage disks OS-free. If you don't know how to dump the FreeNAS installer on a thumb drive, [look here](http://doc.freenas.org/9.10/install.html#preparing-the-media). Keep in mind that you will need one drive to hold the installer and *one additional* drive as the target for the installation.   

Since I'm on a Mac, I could just download the image, `dd` it to a stick, plug it in the ProLiant, boot, and install FreeNAS in a matter of minutes. It's pretty easy, and after I've had a boot drive fail because I used an old thumb drive that probably wasn't cut out for the task, I've had my share of FreeNAS re-installs.

#### Storage configuration

If you're not familiar with ZFS, you're basically in the same boat as me. [FreeNAS has some docs for that](http://doc.freenas.org/9.10/zfsprimer.html#), but the gist is that I use RAIDZ1. In short that means that my 4 disks are aggregated as one storage pool, I have 75% of the total capacity as usable storage, and one disk at a time may die on me without overall data loss. If your data is more precious than mine, you might obviously consider a 2 to 2 disk mirror.

#### Backups, please

As a responsible data hoarder, I run multiple backup strategies for my personal data.  
For once, there's Time Machine, obviously. Since FreeNAS allows AFP shares via netatalk, setting up one or more Time Machine shares is fairly [easy and quite popular](http://doc.freenas.org/9.10/sharing.html?highlight=time%20machine#apple-afp-shares). Just create a dataset for your Time Machine data, share it via AFP, check the "Time Machine" box and your Mac should find it in the Time Machine system menu.

Now that my laptop is all safe[^1], let's back up some more. 
 As I previously [mentioned, I use syncthing for all of my non-interpersonal syncing](https://blog.jemu.name/post/2016/10/my-summer-spring-cleaning-part-1/#sync).  
I have my reasons for using Syncthing over [~~Bittorrent~~ Resilio Sync](https://www.resilio.com/individuals/), the last straw was the Mac app being a laggy, annoying piece of annoyances. Your mileage may vary, but I don't have any fucks left to give, so Syncthing it is.
I use it to sync some individual folders between my laptop and my NAS, or between my laptop, NAS and servers, or various other permuations of $\{NAS, laptop, server_i \}$ $(i \in 1, 2, 3)$.

It's solid. I like it.

### Services

When it comes to additional services, your best course of action largely depends on how familiar you are with unix-like systems, the command line, and how much time you're willing to invest in the short- and long term.

Personally, I've reached the point where I just use two standard FreeBSD (the OS FreeNAS is based on) jails[^2] to install various packages in and manage from, and I'm pretty happy so far. 

When I first started using FreeNAS, I installed a few [plug-ins](http://doc.freenas.org/9.10/plugins.html) which seemed nice, but if you have to tinker with some config file manually or figure out the correct path to some assets, using a standard FreeBSD jail is easier to manage (and to google). I've also had a few issues with the Plex plug-in dying on me, forcing me to reinstall the Plex plug-in and recreating my whole database[^3]. Also, the plug-ins tend to take a while to be updated after the underlying packages release new versions, and if you're like me, you probably like running the newest version of everything, all the time.

#### Plex and NGINX

So how do you install [Plex](https://plex.tv) in a FreeNAS jail?  
Well glad you asked, because it's frikkin' easy.

Just [add a new jail](http://doc.freenas.org/9.10/jails.html#adding-jails) (it will be a standard FreeBSD jail by defailt afair), use the GUI to open a shell, and either enable *sshd* to `ssh` from your machine or just use the FreeNAS GUI for maintenance. If you have your shell open, just 

```sh
pkg install plexmediaserver         # install the package
sysrc plexmediaserver_enable="YES"  # Enable it in the OS' rc.conf (/etc/rc.conf)
service plexmediaserver start       # Start the service

```
and you're good to go. From this point on, you can use Plex' webinterface at port `32400` to manage your media library.

If you're too lazy to memorize your jail IP and/or the Plex port and can't be bothered to use browser bookmarks, you may want to go the extra mile and set up an *nginx reverse proxy* for bonus convenience and pretty URLs. Take mine for example:

```nginx
server {
        listen       80;
        server_name  plex.ppth.local plex.ppth;

        location / {
                proxy_pass http://127.0.0.1:32400;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
```

Combined with the following entry in my MacBook's `/etc/hosts`:

`192.168.2.230 lounge.ppth couchpotato.ppth plexpy.ppth plex.ppth sonarr.ppth syncthing.ppth`

As you might be able to tell, I'm runnung various services with webinterfaces on the same jail I named *lounge* (i.e. the PPTH doctor's lounge), and with this method each webinterface has it's own domain name specific to my local network. When I want to access the Plex webinterface at port 32400, I can simply point my browser to `plex.ppth` and stuff works. Same thing for Sonarr, CouchPotato, Syncthing, and PlexPy.

I should point out that even though I'm also running Syncthing behind a proxy like this, Syncthing itself doesn't seem to like it that much. I've had trouble with GUI settings not being applied when accessed via the proxy'd URL, but maybe that's just a misconfiguration on my part.

Once you have your Plex up and running, I recommend also setting up [PlexPy](https://github.com/JonnyWong16/plexpy) as a very handy Plex management companion, providing watch logs, library statistics, and an overview of currently active streams. The latter might only be of interest to you if you share your Plex server with friends, but all in all it's a nice add-on.

#### All the media

So, now we have a storage pool and a media server/library, but how do we actually get and/or manage media?

I'd like to introduce you to [Sonarr](https://sonarr.tv/) and [CouchPotato](https://couchpota.to/), two marvellous tools for tv show and movie management, respectively. Both are installable as FreeNAS plug ins, but as I mentioned earlier I went the other way and installed them in my general-purpose jail.

For Sonarr, you just have to play the `pkg install sonarr` game, but for CouchPotato you have to clone the repo (to be FreeBSD-y, use `/usr/local/`), but [there are instructions for that](https://github.com/CouchPotato/CouchPotatoServer#couchpotato).

I won't be going into that much detail regarding the two tools, because if you're at this point, you probably already have opinions on how to obtain your favorite Linux distributions day to day.

## Conclusion

So, did I forget anything? We have a nice piece of hardware running FreeNAS, a ZFS storage pool, a media server and various ways of media management.  
I think I'm done now.

¯\\\_(ツ)_/¯


[^1]: Well, there's also my portable TM drive I plug in ocassionally via USB, my [backblaze](https://link.jemu.name/backblaze) and all that jazz.
[^2]: A Jail is basically a virtual machine running on the host machine, with it's own IP adress and own packages.
[^3]: To be fair, if I had known back then what I know now, I probably could have saved the database, but oh well.
