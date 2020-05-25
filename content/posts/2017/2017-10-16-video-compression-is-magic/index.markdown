---
title: Video Compression is Magic
subtitle: "Is *this* a benchmark?"
description: "In which I take an arbitrary sample file to compare x264 and x265 with regards to file size and more-or-less arbitrary quality benchmarks. N = 1 is sufficient, right?"
featured_image: "plots/ssim_by_size_subset2-1.png"
author: jemus42
date: '2017-10-16'
slug: video-compression-is-magic
tags:
  - video-compression
  - x265
  - x264
  - ffmpeg
packages:
  - ggplot2
  - kableExtra
  - dplyr
  - tidyr 
toc: true
editor_options: 
  chunk_output_type: console
---



If you're like me, you probably have a serious issue with digital hoarding, refuse to delete anything and methodically collect and categorize _all the things_.  
We need help, yes.  
In the meantime, there's the option of substituting your carefully hand-encoded AVC video files and give them the ol' modernization treatment with our new best friend, HEVC.  
If you're confused at this point, here's a short glossary:

- **AVC**: *Advanced Video Codec* (or *x264* for the specific encoder): The video codec used in pretty much all modern video.
- **HEVC**: *High Efficiency Video Coding* (or *x265* for the specific encoder): The new(er) kid on the block and successor to AVC.

Your standard run-of-the-mill video file that obviously fell from a truck will usually come in either an *mp4* or *mkv* **container** with *AVC* video and some kind of audio.  
If you want to reduce the file size of the video and keep the quality reasonably high, re-encoding the file into HEVC seems to be a valid plan. Obviously it would be technically better to rip the source medium again into HEVC directly instead of transcoding an existing lossily-encoded file, but… yeah, that would be more work and less bashscriptable.  
On a side note, if you want a little primer on video compression, I heartily recommend [Tom Scott's video on a related issue](https://www.youtube.com/watch?v=r6Rp-uo6HmI).

Anyway, long story short:  
so I took the first episode of [Farscape](https://en.wikipedia.org/wiki/Farscape), which I had conveniently lying around in a neat little matroska-packaged AVC+DTS combo, cut out 15 minutes, and then re-encoded this 15 minute clip in a bunch of ways.  
Why? Well, initially I wanted to figure out how best to transcode my existing Farscape rips to save the most space while maintaining a reasonable amount of quality, so I did the scientific(ish) thing and created a bunch of samples.  
And yes, HEVC encoding without proper hardware support is a *pain* and I spent way too much CPU time on this little project, but soon™ we will have reached the point were HEVC is the new de-facto standard and when that point comes *I will be ready*.

## Methodology <small>i.e. "stuff I did"</small>

Look, I'm not an expert on video encoding, I'm not familiar with the internals of the encoders, which means I know shit about the standards _and_ the software implementations. I'm just some guy who wanted to save disk space and decided to do some testing in the process.  

I re-encoded the aforementioned video clip using the following settings:

- **Codecs**: x264 and x265
- **CRF**: 1, 17, 18, 20, 21, 25, 26, 51
- **Presets**: placebo, slower, medium, veryfast, ultrafast

The result is 80 files of varying quality and size.  
Judging file size is pretty straight-forward: Just compare the file sizes. Magic.  
As for quality, that's a difficult one, and since I lack a proper testing setup and about three dozen people to judge the subjective quality of each clip, I'll just be using the [SSIM](https://en.wikipedia.org/wiki/Structural_similarity) as calculated by comparing each clip with the original clip, and see how far that gets me.

So to start, here are the first five rows:

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Table 1: Sample data</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> file </th>
   <th style="text-align:left;"> codec </th>
   <th style="text-align:left;"> preset </th>
   <th style="text-align:right;"> CRF </th>
   <th style="text-align:right;"> size </th>
   <th style="text-align:right;"> ssim </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> farscape_sample_x264.AAC2.0.CRF01-medium.mkv </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> medium </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2097.20 </td>
   <td style="text-align:right;"> 0.935785 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> farscape_sample_x264.AAC2.0.CRF01-placebo.mkv </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> placebo </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1484.04 </td>
   <td style="text-align:right;"> 0.935858 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> farscape_sample_x264.AAC2.0.CRF01-slower.mkv </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> slower </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1530.13 </td>
   <td style="text-align:right;"> 0.935846 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> farscape_sample_x264.AAC2.0.CRF01-ultrafast.mkv </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> ultrafast </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3887.30 </td>
   <td style="text-align:right;"> 0.935909 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> farscape_sample_x264.AAC2.0.CRF01-veryfast.mkv </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> veryfast </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 2315.65 </td>
   <td style="text-align:right;"> 0.935663 </td>
  </tr>
</tbody>
</table>

## File Size

To start of, here's some tables:

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Table 2:  File size (MiB) by CRF and codec used</caption>
 <thead>
<tr>
<th style="border-bottom:hidden" colspan="2"></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="5"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Preset</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> CRF </th>
   <th style="text-align:left;"> codec </th>
   <th style="text-align:left;"> placebo </th>
   <th style="text-align:left;"> slower </th>
   <th style="text-align:left;"> medium </th>
   <th style="text-align:left;"> veryfast </th>
   <th style="text-align:left;"> ultrafast </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 1 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(69, 56, 130, 1) !important;">1484.04</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 33, 115, 1) !important;">1530.13</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">2097.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">2315.65</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">3887.3</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">1852.19</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">1725.59</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 41, 122, 1) !important;">1796.31</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(69, 55, 129, 1) !important;">1868.92</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(31, 154, 138, 1) !important;">1279.54</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 17 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(65, 190, 113, 1) !important;">259.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(60, 187, 117, 1) !important;">271.1</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(67, 190, 113, 1) !important;">280.49</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(76, 194, 108, 1) !important;">253.99</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(63, 188, 115, 1) !important;">545.81</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(83, 197, 105, 1) !important;">180.46</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(81, 197, 105, 1) !important;">176.28</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(89, 200, 100, 1) !important;">172.7</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(94, 201, 98, 1) !important;">157.22</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(109, 205, 89, 1) !important;">120.96</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 18 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(73, 193, 109, 1) !important;">222.7</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(67, 190, 113, 1) !important;">233.1</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(75, 193, 109, 1) !important;">242.13</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(83, 197, 105, 1) !important;">216.36</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 192, 111, 1) !important;">481.01</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(88, 199, 101, 1) !important;">155.92</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(86, 198, 103, 1) !important;">153.02</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(92, 200, 99, 1) !important;">150.45</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(98, 203, 95, 1) !important;">138.04</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">108.97</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 20 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(84, 197, 104, 1) !important;">169</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(81, 197, 105, 1) !important;">175.89</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(86, 198, 103, 1) !important;">184.06</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(94, 201, 98, 1) !important;">160.7</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(81, 197, 105, 1) !important;">372.08</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(96, 202, 96, 1) !important;">119.82</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(94, 201, 98, 1) !important;">118.64</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(100, 203, 95, 1) !important;">117.38</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(103, 204, 92, 1) !important;">108.76</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(114, 208, 86, 1) !important;">89.14</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 21 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(89, 200, 100, 1) !important;">149.09</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(86, 198, 103, 1) !important;">154.72</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(91, 200, 100, 1) !important;">162.14</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(98, 203, 95, 1) !important;">140.05</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(86, 198, 103, 1) !important;">328.22</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(100, 203, 95, 1) !important;">106.38</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(98, 203, 95, 1) !important;">105.71</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(103, 204, 92, 1) !important;">104.65</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(107, 205, 91, 1) !important;">97.42</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(114, 208, 86, 1) !important;">80.92</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 25 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(101, 203, 94, 1) !important;">97.14</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(101, 203, 94, 1) !important;">98.39</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(103, 204, 92, 1) !important;">102.9</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(109, 205, 89, 1) !important;">87.7</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(100, 203, 95, 1) !important;">199.32</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(109, 205, 89, 1) !important;">70.44</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(109, 205, 89, 1) !important;">70.63</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">70.62</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(112, 207, 87, 1) !important;">66.04</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(118, 208, 84, 1) !important;">57.58</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 26 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(105, 205, 91, 1) !important;">88.53</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(103, 204, 92, 1) !important;">89.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(105, 205, 91, 1) !important;">93.12</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">79.28</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(103, 204, 92, 1) !important;">176.59</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">64.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">64.65</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(112, 207, 87, 1) !important;">64.74</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(114, 208, 86, 1) !important;">60.57</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(118, 208, 84, 1) !important;">53.38</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 51 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">24.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">24.05</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">23.77</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">23.38</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">27.59</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">21.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">21.61</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">22.56</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">21.44</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(122, 209, 81, 1) !important;">22</span> </td>
  </tr>
</tbody>
</table>

That's… accurate, yet not very visually stimulating.  
Needs more plot.


{{<figure src="plots/sizes_by_codec-1.png" link="plots/sizes_by_codec-1.png">}}

Okay, let's zoom in a little by ignoring CRF 51 and CRF 01, as they're silly anyway.


{{<figure src="plots/sizes_by_codec_subset-1.png" link="plots/sizes_by_codec_subset-1.png">}}

Hm, yes, quite.  
Now a breakdown to compare codecs across presets:


{{<figure src="plots/sizes_by_preset-1.png" link="plots/sizes_by_preset-1.png">}}

{{<figure src="plots/sizes_by_preset-2.png" link="plots/sizes_by_preset-2.png">}}

As you might have noticed, absolute file sizes might not be as interesting and/or generalizable as relative size changes, so here we go:


{{<figure src="plots/sizes_relative-1.png" link="plots/sizes_relative-1.png">}}


## SSIM (Approximate Quality)

To start, let's do the raw data table thing again:

<table class="table table-condensed" style="margin-left: auto; margin-right: auto;">
<caption>Table 3:  SSIM (x 100) by CRF and codec used</caption>
 <thead>
<tr>
<th style="border-bottom:hidden" colspan="2"></th>
<th style="border-bottom:hidden; padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="5"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Preset</div></th>
</tr>
  <tr>
   <th style="text-align:right;"> CRF </th>
   <th style="text-align:left;"> codec </th>
   <th style="text-align:left;"> placebo </th>
   <th style="text-align:left;"> slower </th>
   <th style="text-align:left;"> medium </th>
   <th style="text-align:left;"> veryfast </th>
   <th style="text-align:left;"> ultrafast </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 1 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(68, 1, 84, 1) !important;">93.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(69, 4, 87, 1) !important;">93.5</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 17 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 8, 91, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 13, 96, 1) !important;">93.2</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(69, 5, 88, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 10, 93, 1) !important;">93.3</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 18 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 8, 91, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 13, 96, 1) !important;">93.2</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 6, 90, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(69, 5, 88, 1) !important;">93.5</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 13, 96, 1) !important;">93.2</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 20 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 8, 91, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 18, 101, 1) !important;">93</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 8, 91, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.1</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 21 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.3</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 18, 101, 1) !important;">93.3</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.3</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 18, 101, 1) !important;">93</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 11, 94, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(70, 8, 91, 1) !important;">93.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.1</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 25 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 21, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 17, 100, 1) !important;">93.3</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 32, 112, 1) !important;">92.5</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 21, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">92.8</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 26 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 21, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 36, 117, 1) !important;">92.3</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 21, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 104, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(71, 16, 99, 1) !important;">93.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(72, 23, 105, 1) !important;">92.8</span> </td>
  </tr>
  <tr>
   <td style="text-align:right;vertical-align: middle !important;" rowspan="2"> 51 </td>
   <td style="text-align:left;"> x264 </td>
   <td style="text-align:left;"> <span style="     color: rgba(187, 223, 39, 1) !important;">86.9</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(187, 223, 39, 1) !important;">87.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(187, 223, 39, 1) !important;">87.1</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(187, 223, 39, 1) !important;">84</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(187, 223, 39, 1) !important;">81.9</span> </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> x265 </td>
   <td style="text-align:left;"> <span style="     color: rgba(55, 184, 120, 1) !important;">88.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(110, 206, 88, 1) !important;">88.4</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(92, 200, 99, 1) !important;">88.2</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(31, 159, 136, 1) !important;">87.6</span> </td>
   <td style="text-align:left;"> <span style="     color: rgba(39, 173, 129, 1) !important;">85.5</span> </td>
  </tr>
</tbody>
</table>

Please note that I had to multiply the SSIM values by 100 to get them to display as something other than a flat *1* because rounding is hard, apparently.  
Also, *yes* I know the "sum" column/row doesn't make sense, but it's the default and I couldn't be bothered to try to remove it.

And now, the plotty thing.


{{<figure src="plots/ssim_by_codec-1.png" link="plots/ssim_by_codec-1.png">}}

{{<figure src="plots/ssim_by_codec-2.png" link="plots/ssim_by_codec-2.png">}}




{{<figure src="plots/ssim_by_preset-1.png" link="plots/ssim_by_preset-1.png">}}

{{<figure src="plots/ssim_by_preset-2.png" link="plots/ssim_by_preset-2.png">}}

Now let's do that thing again where we compare all the *CRF* by *preset* cells in a grid, but now using SSIM as a metric:


{{<figure src="plots/SSIM_relative-1.png" link="plots/SSIM_relative-1.png">}}

Well that's not very enlightening, is it?  
Bummer.

## Quality(ish) versus Size


{{<figure src="plots/ssim_by_size-1.png" link="plots/ssim_by_size-1.png">}}

I've tried log scales on this one, but it didn't really help.  
Let's look at the subset of reasonable CRFs:


{{<figure src="plots/ssim_by_size_subset-1.png" link="plots/ssim_by_size_subset-1.png">}}

Well if there's a lesson here, it seems that *ultrafast* is probably not the way to go.  
Let's take another look, ignoring the *ultrafast* data.


{{<figure src="plots/ssim_by_size_subset2-1.png" link="plots/ssim_by_size_subset2-1.png">}}

## Conclusion

Keep in mind that this is not a scientific study.  
The results might be limited to my version of HandBrake (`1.0.7 (2017040900)`), or it might be limited to re-encoding a lossily-encoded file, or it might be limited to encoding SD content and behave slightly differently with 4k content. My point is: I don't know. I have *no* idea how generalizable these results are, but with the limited amount of certainty I can muster, I'll give you this:

- Don't use *ultrafast*. *veryfast* is fast as well, and apparently better(ish)
- Also, don't use *placebo*. Why would you even do that to yourself[^1].
- Keep your CRF around the 20's. Seems reasonable.

¯\\\_(ツ)_/¯

Note: If you have anything else you want to try with the data, you can grab it [here](samples.rds).

[^1]: If I do this again, I will track the encoding time. Seriously, don't to *placebo*.
