---
title: Plex and Emby
author: jemus42
date: '2015-11-02'
categories:
  - tech
---

Having a media center and appropriate infrastructure in your own home is a nice thing. Besides questions about hardware specifications, there's also the the matter of software to use.  
Personally, I'm a reasonably satisfied FreeNAS user, so my base of operation is a collection of FreeBSD jails (Think virtual machines, if I understand it correctly).

But what to do once you got your NAS set up and running, ready to serve all the media you have presumably acquired on a strictly legal basis over the course of multiple years?  
Manually selecting files over network shares and playing them with VLC can't be the way to go. Also, pulling files manually to a USB drive and carrying that over to your TV can't be the way to go, either.  

Trust me, I've done both of these things and let me tell you I'm so very thankful for Plex and Emby to make sure I never have to go back again.

## What is Plex, and what is Emby?

-> [Plex](https://plex.tv) <-—-> [Emby](https://emby.media) <-

They're kind of the same(ish) thing. But not really. Well, let's start with Plex, since I've been using that for a long time now (October 2013, according to a quick search through my mail). 

The idea is the following: You have a shitton of media lying around and want to organize and view it comfortably. You then install a media server (Plex Media Server, Emby Media Server) on the machine that has access to the data. You set up your libraries by telling the server where (file path) your media (media type) is located, i.e. the library "Movies" is set up to `/mnt/media/movies` or something like that. This also applies to tv shows, music, and for Emby, even eBooks and games, but don't ask me what Emby is supposed to do with games, I haven't tried that. 

When your server is running, you can use their browser-based interfaces either locally or through their respective web-endpoints (both Plex and Emby have shortcuts to their webapps on their websites when you're logged in). From that, you can manage, organize and view your media. The device you're watching on doesn't have to support the codec, container or whatever of the source media, the media server is a good friend and transcodes your media for you if necessary, according to your settings. You can also adjust the streaming quality if your connection is embarrassingly German.   
In case you have a dedicated media center machine lying around, you'll probably want to install their Home Theater Apps. These are native applications that can be controlled with a remote, and have some nifty settings available like optical audio out and what have you. I don't want to go into too that too far because I don't want the audiohpiles making fun of me.

At this point I should point out that [Emby doesn't have such an app for OS X](http://emby.media/downloads/emby-theater/), so I never used their media center and can only speak for [Plex's Home Theater app](https://plex.tv/downloads#plex-pht), which I like a lot. It's also controllable from their Android app, pretty similar to how chromecast playing works.  

And that brings us to Android. Once again, it should be noted that I don't own an iOS device and have no idea how the iOS versions of their apps are doing. I assume they do fine.  
Bottom line is this: Plex' app is very nicely designed, material themed and functioning very reliably. 
Emby's app is… pretty okay, a bit wonky if you're on the beta program (which I am), and offers pretty much the same level of control as the webinterface of the server, which is very cool and exceeds Plex' capabilities. It also displays very detailed media information for the item you're currently viewing, like file location, codec information and other things.  
Plex doesn't do that, and I can't remember wanting Plex to do this, but now that I know that Emby does this, I kind of want Plex do to this, too.

The previous sentence is pretty much the TL;DR of this whole blogpost, by the way.

## My setup

I'm running the current stable release of [FreeNAS](http://freenas.org) on this [HP MicroServer](http://n40l.wikia.com/wiki/HP_MicroServer_N40L_Wiki). I have installed Plex and Emby in FreeBSD jails, so they're caged from the main OS. Also, I'm running a ZFS storage pool where all my media is located, which is mounted in the respective jails. Note that I don't use the plugins provided by FreeNAS anymore, because they were causing more trouble than benefit. I set up "regular" jails through the FreeNAS webinterface, `ssh`'d into at, and set stuff up that way. 

To view stuff, I open the Plex app on my phone, choose the item, click the chromecast button, my tv chimes to life, and stuff plays. Then the trakt.tv plugin scrobbles peacefully, and trakt remembers my watched progress for me, which is also synced with Plex. And Emby.  
Emby, meanwhile, monitors a folder on my drive where… things are incoming. It then autosorts them in their respective folders, where the auto-updating Plex library picks it up.

As for the Android apps, I should point out that I use the PlexPass version of the Plex app and the beta version of the Emby app, so I might experience problems that are of no concern for you at this point.

## So, let's go through a checklist

### It's free initially, how do they make money? ARE YOU THE PRODUCT?!

Nah. I'm a PlexPass subscriber (best chunk of money I spent in home media comfort), and Emby has a similar thing going. For Plex that means that certain features like cloud sync are only available to subscribers, and for Emby it's similar, just that there are some plugins that are only available to supporters of various levels. However, Emby is open source, so if you really really wanted to, you could probably hack it around until it does what you want, maybe? That's how open source works, right? I don't know, I just watch shows.

### Why Plex or Emby? Don't you know about Kodi/XBMC?

I know it exists, but for some reason I can't think of anymore, I never tried it. A quick search tells me there's no FreeBSD package anyway, so I won't be able to try it as a substitute for my existing setup anyway. Bottom line: If you prefer Kodi over all, good for you, but then this post probably doesn't matter to you, anyway.

### Is it easy to install?

I can only speak for FreeNAS/FreeBSD and OS X for the media server components, but yes. Both are very easy to install via simple `pkg install` calls. Emby additionally requires you to rebuild `ffmpeg` with lame support. That takes a while, but it's not hard to do at all.

### Are there plugins for… you know, stuff?

Yes, there are porn plugins.  
Let's look at them one after the other:

Plex has an index of available plugins, which are all pretty much of no interest to me. As for trakt.tv, I went to the [Unofficial Appstore](https://forums.plex.tv/discussion/151068/unsupported-app-store-as-in-totally-unsupported-is-currently-offline/) and installed the trakt plugin from there. The UAS had to be manually put into the server's plug-in directory, which was kind of annyoing, but at leats it works now. Manually installing plug ins isn't really the kind of future I had in mind, but as long as it's "set up once, forget about it forever", I can live with it. Since there are no other plug ins of interest to me, I haven't really looked into it too much. There are, however, plugins for all kinds of things, from SoundCloud to twitch.tv to YouTube and various other providers. Go have a look around.  
The user experience of Plex' plug in system isn't exactly beautiful, which becomes apparent when you enter a plug in's settings screen.

Emby, on the other hand, has a very nice looking plug in infrastructure, a prettier UI for the plugin management as far as I'm concerned, and has some plug ins only available for supporters. Also, I was very pleased that Emby has a trakt.tv plugin which is installable without any manual file droppings, so that's a bonus. The trakt.tv plugin pretty much covers the functionality of Plex' trakt plugin as far as I can tell, but I'm not sure yet if it supports scrobbling, but I will test that soon™.

### Can it organize my files for me, similar to iTunes?

iTunes gets a lot of hate for all the right reasons, but I always liked its ability to automatically organize my music for me – so I don't have to.

Emby has a similar capability for TV show episodes, and I've been happily using it as a more comfortable substitute for FileBot for a while now.

### Are there media center apps for my desktop?

Plex has the really nice Plex Home Theater app for OS X and many other platforms, and Emby only has a Windows app as of time of this writing. This is one of the reasons I use Plex as my primary media center.

### Are there mobile apps?

<!--{% img left http://dump.jemu.name/x1QZR.png 150px title:'Plex for Android' %} {% img left http://dump.jemu.name/e24wG.png 150px title:'Plex for Android – Episode view' %}-->

Plex has a really nice looking Android app which just adds to the overall polished look of Plex. Emby also has an Android app that, in my opinion, does not look as nice but still works well enough, even though I'm a beta tester and often experience hiccups, but I can't really blame beta software for being beta. It should be noted that Emby's Android app is more powerful as far as server control is concerned, like plugins configuration and an overview of the auto-organization queue. The Emby app feels like an androidified version of the regular Emby webinterface, while the Plex app feels like a separate entity.

{% img right http://dump.jemu.name/1cDYg.png 150px title:'Emby for Android' %} {% img right http://dump.jemu.name/BAJXP.png 150px title:'Emby for Android – Episode view' %}

As for iOS: Yeah, but I don't have any iOS devices.

### Does it have Chromecast support?

Both of them do, but I found Plex to be a little nicer.  
There's not much more to it, I guess.  
Open the app, select the thing you want to watch, click the Chromecast thingy, play, enjoy.  
That's the kind of future I like living in.

### Does it do DLNA?

Yeah, both of them do. Thankfully, I don't have to use it a lot, but it's a decent fallback for when Chromecast is acting up.

### Does it play nicely with trakt.tv?

As you know, I love trakt.tv, and one of the reasons I've been able to use it so comfortably is the unofficial trakt plugin for Plex which enables collection syncing, watched states, and of course, scrobbling. 

Plex: Nice!  
Emby: No scrobbling, but you can schedule sync jobs, soo… at least there's that.

### Misc Remarks

* Emby server restart from the web ui fails occasionally, which is a bummer because it's required for updates. I then have to restart the server from the command line, which is… not ideal. Especially since that happened a bunch of times when I tried a few different plugins, Emby wanting to be restarted after every installation. Imagine you have to restart your computer every time you install a new program.
* If you like to tinker a lot and want full control over everything, Plex might not be your thing. It looks nice and polished on the outside, and for my usecase it's pretty much ideal, but if you're tinkering with different file types across different device types, you may run into a few dead ends where Plex' documentation is just not sufficient. An open source tool like Emby where you can probably `make` all the parts yourself is probably a more tinker-friendly option.
