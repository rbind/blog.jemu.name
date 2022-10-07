---
title: How to Make the Most of (my) Plex Server
author: jemus42
date: '2017-10-25'
slug: how-to-make-the-most-of-my-plex-server
tags:
  - plex
  - NAS
---

If you're reading this, chances are I redirected you here because I share my Plex server with you.  
If you don't know me and don't care about my Plex experience, move along now and watch something good on YouTube.

For a decent Plex experience, we first have to cover some of the basics of how this stuff actually works, so bear with me.  
At the beginning of it all is a file on my NAS. Usually a lovingly encoded Matroska (`.mkv`) file filled with minutes of joy organized in neat little streams of audio and video.  
When you play something from my Plex server, it will look at your device, let's say a Kindle Fire TV whateverthefuck stick with a cherry on top, and then it looks at the file. Plex keeps a list of possible client (that's you) devices where it looks up what each device is capable of. So let's say the file in question is a standard run of the mill AVC (h.264) video with AAC audio, and let's say the configuration file says your device can play that back natively.  
That's nice, because that means your device can either **Direct Play** or **Direct Stream** the file to your device and the only limit on your experience is my upstream and your downstream bandwidth.  
There's a distinction between the **Play** and **Stream** part of the equation, but it doesn't matter that much for our purposes.  

So that's what's going on when things are cool.  
But then there's the case (which happens pretty much constantly) of **transcoding**.  
That's what my Plex server has to do when the file in question doesn't play nice with whatever device you're watching on. 
Maybe the video codec is not AVC, which would require video transcoding – the worst kind of transcoding.  
In other cases it might just be that the audio track is 5.1 DTS and your device can only play stereo, so the audio track has to be transcoded. 
Still not ideal, but transcoding audio is way cheaper than transcoding video as far as CPU usage is concerned.  

Why do we care about transcoding?  
Well, my server is beefy enough to handle a transcode of a decently-HD movie, but let's say three people are watching some TV show and 2 other people try to watch a movie from my server. That happened in the past, and it wasn't pretty.  
Sure, by bandwidth isn't sufficient to support that anyway, but besides that the CPU was bombarded with video to transcode and it just couldn't keep up, resulting in a bunch of streams that stuttered because of both bandwidth _and_ transcode buffering.  

Then there's another thing: I recently started my crusade to switch all my largest TV shows with HEVC encodes (which is not necessarily a fun process), but the space I save is very welcome.  
Chances are your device can't play HEVC natively (note from the future: That most likely has changed. If your device can play 4K, it can usually deal with HEVC).  
That's a bummer.  
If your device can play 4K video, like the Chromecast Ultra, it'll do fine with HEVC since as far as I can tell 4K relies on HEVC (because otherwise those files would be just… just too big.).  

So here's a list of things you can try and/or do to ensure the least aggravating Plex experience:

1. Avoid transcoding if you can.
    - Use any native client if possible, this includes the [Plex Media Player for desktops](https://www.plex.tv/media-server-downloads/#plex-app) if you're watching on a laptop.
    - The browser client is **not great** for format support. Doesn't matter if you use Chrome or Firefox or whatever. Just avoid the browser player please.
    - Ensure the player is set to play the original quality instead of a converted version
2. If you need a transcode, time it right
    - Use the sync feature to pre-transcode and download files to any mobile device (iOS/Android) with the Plex app (the app itself is a one time purchase and doesn't require a Plex Pass subscription). You can then use said device for playback, e.g. with a Chromecast if you want it on a big screen.
    - If the server is under heavy load and things stutter all the time, you might just have to wait.
3. If you have sucky bandwidth, maybe _enforce_ transcoding?
    - If the server has the capacity, handling a transcode is easier than waiting for the magic bandwidth fairy.
    - A downscaled transcode of a file will have lower quality, but will therefore be smaller and more bandwidth-friendly

And then, lastly, there's the sledgehammer method:  
Come over, give be the largest hard drive you can find, wait a while, and go home. You then set up your own Plex server with your newly filled hard drive and move on with your life.  
We can still be friend probably.

{{< addendum title="Note from the future" >}}
As of 2022, this post is still mostly relevant, but a few things have changed.  
Fore one, I can now personally vouch for the Apple TV 4K as a Plex client - my experience has vastly improved over the Chromecast Ultra.  
And the CC Ultra was already a lot better than the previous Chromecast.

As for media formats: Most of my library consists of 1080p HEVC files now, so a client that supports HEVC is more or less a must now.
Transcoding HEVC to AVC in software (my server doesn't support hardware-accelerated transcoding) is quite expensive and I would very much like to avoid it.

The most important piece of advice remains: Don't use the browser player. It's bad for my server, bad for other people who have a worse experience due to the increased server load, and bad for your own experience.
{{< /addendum >}}
