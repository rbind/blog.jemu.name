---
title: Hey Buddy! Doing the Dampe Math
author: jemus42
date: '2018-08-02'
slug: hey-buddy-doing-the-dampe-math
categories:
  - Statistics
tags:
  - Speedrunning
  - Ocarina of Time
description: "I'm basically tabulating a cmf here."
math: true
editor_options: 
  chunk_output_type: console
---

If you've ever watched an [*Ocarina of Time* 100% speedrun][oot100], or played the game yourself, you'll probably know about Dampe. As a gravedigger in Kakariko graveyard, he'll offer to dig up graves for you when you go to him as child Link to get a random treasure. If you're mildly lucky, you'll get enough rupees to try again. If you're really lucky, you'll get the heart piece.  
The latter is obviously part of the 100% definition of the game, so hundo speedruns sooner or later have to face dampe and gamble on the 10% chance of him digging up the heartpiece.

As one of the few major rng-dependent[^rng] events in the run he's kind of notorius, especially when he kills multiple runs in a row by needing more than 10 attempts to finally get the heart piece.  
The math itself is pretty straight forward: In a speedrun, runners use a method to reset Dampe to a specific plot, allowing them to dig on the same grave spot over and over again, theoretically ad infinitum. While this method is not as "safe" as the intended method, which is capped at 15 tries maximum, it's significantly faster unless you get "bad Dampe rng". Each time Dampe digs, there's a 10% chance to get the heartpiece, which means in mathy terms we can define `\(p = 0.1\)` and `\(k\)` as the number of tries until success, giving us:

`$$P(k = 1) = p = 0.1$$`

Second try Dampe would be the probability of "failing" the first attempt and *then* succeed afterwards, or:

`$$P(k = 2) = (1-p) \times p = 0.9 \times 0.1 = 0.09$$`

And in general terms:

`$$P(k) = (1-p)^{k-1} \times p$$`

Which, conveniently, is known as the [*geometric distribution*](https://en.wikipedia.org/wiki/Geometric_distribution). In R, we can calculate individual probabilities using `dgeom(x, prob = .1)` to get the probability for "failing `x` times before success", meaning we need to use `k = x - 1` to get the number of attempts it took to get the heartpiece, include the last dig.  

So, with a lot of talk about odds and chances and whatnot every time Dampe is misbehaving again, I thought I'd take the opportunity to make a little lookup table to see just *how* unlikely your latest 61st try Dampe really was.

Here's what's included:

- **Attempt**: How often you had to let Dampe dig until the heart piece, `\(k\)`
- **Probability**: The probability for `\(k\)`, as a singular outcome
- **Odds (Singular)**: `\(\frac{1}{\text{Probability}}\)`, the probability for that outcome in human readable terms
- **Probability (cumulative)**: Probability of `\(1\)` *through* `\(k\)` tries, i.e. the probability for getting `\(k\)` *or lower* tries

(So, in statsy terms, I'm basically just printing the *pmf* and *cdf* for `\(k = 1\)` through `\(k = 105\)` in a table. Yip.)

<table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:center;"> Attempt </th>
   <th style="text-align:center;"> Probability </th>
   <th style="text-align:center;"> Odds </th>
   <th style="text-align:center;"> Probability (cumulative) </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:center;"> 1 </td>
   <td style="text-align:center;"> 0.1000000 </td>
   <td style="text-align:center;"> 1 in 10 </td>
   <td style="text-align:center;"> 0.1000000 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 2 </td>
   <td style="text-align:center;"> 0.0900000 </td>
   <td style="text-align:center;"> 1 in 12 </td>
   <td style="text-align:center;"> 0.1900000 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 3 </td>
   <td style="text-align:center;"> 0.0810000 </td>
   <td style="text-align:center;"> 1 in 13 </td>
   <td style="text-align:center;"> 0.2710000 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 4 </td>
   <td style="text-align:center;"> 0.0729000 </td>
   <td style="text-align:center;"> 1 in 14 </td>
   <td style="text-align:center;"> 0.3439000 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 5 </td>
   <td style="text-align:center;"> 0.0656100 </td>
   <td style="text-align:center;"> 1 in 16 </td>
   <td style="text-align:center;"> 0.4095100 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 6 </td>
   <td style="text-align:center;"> 0.0590490 </td>
   <td style="text-align:center;"> 1 in 17 </td>
   <td style="text-align:center;"> 0.4685590 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 7 </td>
   <td style="text-align:center;"> 0.0531441 </td>
   <td style="text-align:center;"> 1 in 19 </td>
   <td style="text-align:center;"> 0.5217031 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 8 </td>
   <td style="text-align:center;"> 0.0478297 </td>
   <td style="text-align:center;"> 1 in 21 </td>
   <td style="text-align:center;"> 0.5695328 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 9 </td>
   <td style="text-align:center;"> 0.0430467 </td>
   <td style="text-align:center;"> 1 in 24 </td>
   <td style="text-align:center;"> 0.6125795 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 10 </td>
   <td style="text-align:center;"> 0.0387420 </td>
   <td style="text-align:center;"> 1 in 26 </td>
   <td style="text-align:center;"> 0.6513216 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 11 </td>
   <td style="text-align:center;"> 0.0348678 </td>
   <td style="text-align:center;"> 1 in 29 </td>
   <td style="text-align:center;"> 0.6861894 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 12 </td>
   <td style="text-align:center;"> 0.0313811 </td>
   <td style="text-align:center;"> 1 in 32 </td>
   <td style="text-align:center;"> 0.7175705 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 13 </td>
   <td style="text-align:center;"> 0.0282430 </td>
   <td style="text-align:center;"> 1 in 36 </td>
   <td style="text-align:center;"> 0.7458134 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 14 </td>
   <td style="text-align:center;"> 0.0254187 </td>
   <td style="text-align:center;"> 1 in 40 </td>
   <td style="text-align:center;"> 0.7712321 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 15 </td>
   <td style="text-align:center;"> 0.0228768 </td>
   <td style="text-align:center;"> 1 in 44 </td>
   <td style="text-align:center;"> 0.7941089 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 16 </td>
   <td style="text-align:center;"> 0.0205891 </td>
   <td style="text-align:center;"> 1 in 49 </td>
   <td style="text-align:center;"> 0.8146980 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 17 </td>
   <td style="text-align:center;"> 0.0185302 </td>
   <td style="text-align:center;"> 1 in 54 </td>
   <td style="text-align:center;"> 0.8332282 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 18 </td>
   <td style="text-align:center;"> 0.0166772 </td>
   <td style="text-align:center;"> 1 in 60 </td>
   <td style="text-align:center;"> 0.8499054 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 19 </td>
   <td style="text-align:center;"> 0.0150095 </td>
   <td style="text-align:center;"> 1 in 67 </td>
   <td style="text-align:center;"> 0.8649148 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 20 </td>
   <td style="text-align:center;"> 0.0135085 </td>
   <td style="text-align:center;"> 1 in 75 </td>
   <td style="text-align:center;"> 0.8784233 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 21 </td>
   <td style="text-align:center;"> 0.0121577 </td>
   <td style="text-align:center;"> 1 in 83 </td>
   <td style="text-align:center;"> 0.8905810 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 22 </td>
   <td style="text-align:center;"> 0.0109419 </td>
   <td style="text-align:center;"> 1 in 92 </td>
   <td style="text-align:center;"> 0.9015229 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 23 </td>
   <td style="text-align:center;"> 0.0098477 </td>
   <td style="text-align:center;"> 1 in 102 </td>
   <td style="text-align:center;"> 0.9113706 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 24 </td>
   <td style="text-align:center;"> 0.0088629 </td>
   <td style="text-align:center;"> 1 in 113 </td>
   <td style="text-align:center;"> 0.9202336 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 25 </td>
   <td style="text-align:center;"> 0.0079766 </td>
   <td style="text-align:center;"> 1 in 126 </td>
   <td style="text-align:center;"> 0.9282102 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 26 </td>
   <td style="text-align:center;"> 0.0071790 </td>
   <td style="text-align:center;"> 1 in 140 </td>
   <td style="text-align:center;"> 0.9353892 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 27 </td>
   <td style="text-align:center;"> 0.0064611 </td>
   <td style="text-align:center;"> 1 in 155 </td>
   <td style="text-align:center;"> 0.9418503 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 28 </td>
   <td style="text-align:center;"> 0.0058150 </td>
   <td style="text-align:center;"> 1 in 172 </td>
   <td style="text-align:center;"> 0.9476652 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 29 </td>
   <td style="text-align:center;"> 0.0052335 </td>
   <td style="text-align:center;"> 1 in 192 </td>
   <td style="text-align:center;"> 0.9528987 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 30 </td>
   <td style="text-align:center;"> 0.0047101 </td>
   <td style="text-align:center;"> 1 in 213 </td>
   <td style="text-align:center;"> 0.9576088 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 31 </td>
   <td style="text-align:center;"> 0.0042391 </td>
   <td style="text-align:center;"> 1 in 236 </td>
   <td style="text-align:center;"> 0.9618480 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 32 </td>
   <td style="text-align:center;"> 0.0038152 </td>
   <td style="text-align:center;"> 1 in 263 </td>
   <td style="text-align:center;"> 0.9656632 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 33 </td>
   <td style="text-align:center;"> 0.0034337 </td>
   <td style="text-align:center;"> 1 in 292 </td>
   <td style="text-align:center;"> 0.9690968 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 34 </td>
   <td style="text-align:center;"> 0.0030903 </td>
   <td style="text-align:center;"> 1 in 324 </td>
   <td style="text-align:center;"> 0.9721872 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 35 </td>
   <td style="text-align:center;"> 0.0027813 </td>
   <td style="text-align:center;"> 1 in 360 </td>
   <td style="text-align:center;"> 0.9749684 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 36 </td>
   <td style="text-align:center;"> 0.0025032 </td>
   <td style="text-align:center;"> 1 in 400 </td>
   <td style="text-align:center;"> 0.9774716 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 37 </td>
   <td style="text-align:center;"> 0.0022528 </td>
   <td style="text-align:center;"> 1 in 444 </td>
   <td style="text-align:center;"> 0.9797244 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 38 </td>
   <td style="text-align:center;"> 0.0020276 </td>
   <td style="text-align:center;"> 1 in 494 </td>
   <td style="text-align:center;"> 0.9817520 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 39 </td>
   <td style="text-align:center;"> 0.0018248 </td>
   <td style="text-align:center;"> 1 in 549 </td>
   <td style="text-align:center;"> 0.9835768 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 40 </td>
   <td style="text-align:center;"> 0.0016423 </td>
   <td style="text-align:center;"> 1 in 609 </td>
   <td style="text-align:center;"> 0.9852191 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 41 </td>
   <td style="text-align:center;"> 0.0014781 </td>
   <td style="text-align:center;"> 1 in 677 </td>
   <td style="text-align:center;"> 0.9866972 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 42 </td>
   <td style="text-align:center;"> 0.0013303 </td>
   <td style="text-align:center;"> 1 in 752 </td>
   <td style="text-align:center;"> 0.9880275 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 43 </td>
   <td style="text-align:center;"> 0.0011973 </td>
   <td style="text-align:center;"> 1 in 836 </td>
   <td style="text-align:center;"> 0.9892247 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 44 </td>
   <td style="text-align:center;"> 0.0010775 </td>
   <td style="text-align:center;"> 1 in 929 </td>
   <td style="text-align:center;"> 0.9903023 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 45 </td>
   <td style="text-align:center;"> 0.0009698 </td>
   <td style="text-align:center;"> 1 in 1032 </td>
   <td style="text-align:center;"> 0.9912720 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 46 </td>
   <td style="text-align:center;"> 0.0008728 </td>
   <td style="text-align:center;"> 1 in 1146 </td>
   <td style="text-align:center;"> 0.9921448 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 47 </td>
   <td style="text-align:center;"> 0.0007855 </td>
   <td style="text-align:center;"> 1 in 1274 </td>
   <td style="text-align:center;"> 0.9929303 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 48 </td>
   <td style="text-align:center;"> 0.0007070 </td>
   <td style="text-align:center;"> 1 in 1415 </td>
   <td style="text-align:center;"> 0.9936373 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 49 </td>
   <td style="text-align:center;"> 0.0006363 </td>
   <td style="text-align:center;"> 1 in 1572 </td>
   <td style="text-align:center;"> 0.9942736 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 50 </td>
   <td style="text-align:center;"> 0.0005726 </td>
   <td style="text-align:center;"> 1 in 1747 </td>
   <td style="text-align:center;"> 0.9948462 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 51 </td>
   <td style="text-align:center;"> 0.0005154 </td>
   <td style="text-align:center;"> 1 in 1941 </td>
   <td style="text-align:center;"> 0.9953616 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 52 </td>
   <td style="text-align:center;"> 0.0004638 </td>
   <td style="text-align:center;"> 1 in 2156 </td>
   <td style="text-align:center;"> 0.9958254 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 53 </td>
   <td style="text-align:center;"> 0.0004175 </td>
   <td style="text-align:center;"> 1 in 2396 </td>
   <td style="text-align:center;"> 0.9962429 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 54 </td>
   <td style="text-align:center;"> 0.0003757 </td>
   <td style="text-align:center;"> 1 in 2662 </td>
   <td style="text-align:center;"> 0.9966186 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 55 </td>
   <td style="text-align:center;"> 0.0003381 </td>
   <td style="text-align:center;"> 1 in 2958 </td>
   <td style="text-align:center;"> 0.9969567 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 56 </td>
   <td style="text-align:center;"> 0.0003043 </td>
   <td style="text-align:center;"> 1 in 3286 </td>
   <td style="text-align:center;"> 0.9972611 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 57 </td>
   <td style="text-align:center;"> 0.0002739 </td>
   <td style="text-align:center;"> 1 in 3652 </td>
   <td style="text-align:center;"> 0.9975350 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 58 </td>
   <td style="text-align:center;"> 0.0002465 </td>
   <td style="text-align:center;"> 1 in 4057 </td>
   <td style="text-align:center;"> 0.9977815 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 59 </td>
   <td style="text-align:center;"> 0.0002219 </td>
   <td style="text-align:center;"> 1 in 4508 </td>
   <td style="text-align:center;"> 0.9980033 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 60 </td>
   <td style="text-align:center;"> 0.0001997 </td>
   <td style="text-align:center;"> 1 in 5009 </td>
   <td style="text-align:center;"> 0.9982030 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 61 </td>
   <td style="text-align:center;"> 0.0001797 </td>
   <td style="text-align:center;"> 1 in 5565 </td>
   <td style="text-align:center;"> 0.9983827 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 62 </td>
   <td style="text-align:center;"> 0.0001617 </td>
   <td style="text-align:center;"> 1 in 6184 </td>
   <td style="text-align:center;"> 0.9985444 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 63 </td>
   <td style="text-align:center;"> 0.0001456 </td>
   <td style="text-align:center;"> 1 in 6871 </td>
   <td style="text-align:center;"> 0.9986900 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 64 </td>
   <td style="text-align:center;"> 0.0001310 </td>
   <td style="text-align:center;"> 1 in 7634 </td>
   <td style="text-align:center;"> 0.9988210 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 65 </td>
   <td style="text-align:center;"> 0.0001179 </td>
   <td style="text-align:center;"> 1 in 8482 </td>
   <td style="text-align:center;"> 0.9989389 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 66 </td>
   <td style="text-align:center;"> 0.0001061 </td>
   <td style="text-align:center;"> 1 in 9425 </td>
   <td style="text-align:center;"> 0.9990450 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 67 </td>
   <td style="text-align:center;"> 0.0000955 </td>
   <td style="text-align:center;"> 1 in 10472 </td>
   <td style="text-align:center;"> 0.9991405 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 68 </td>
   <td style="text-align:center;"> 0.0000860 </td>
   <td style="text-align:center;"> 1 in 11635 </td>
   <td style="text-align:center;"> 0.9992264 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 69 </td>
   <td style="text-align:center;"> 0.0000774 </td>
   <td style="text-align:center;"> 1 in 12928 </td>
   <td style="text-align:center;"> 0.9993038 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 70 </td>
   <td style="text-align:center;"> 0.0000696 </td>
   <td style="text-align:center;"> 1 in 14364 </td>
   <td style="text-align:center;"> 0.9993734 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 71 </td>
   <td style="text-align:center;"> 0.0000627 </td>
   <td style="text-align:center;"> 1 in 15960 </td>
   <td style="text-align:center;"> 0.9994361 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 72 </td>
   <td style="text-align:center;"> 0.0000564 </td>
   <td style="text-align:center;"> 1 in 17733 </td>
   <td style="text-align:center;"> 0.9994925 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 73 </td>
   <td style="text-align:center;"> 0.0000508 </td>
   <td style="text-align:center;"> 1 in 19704 </td>
   <td style="text-align:center;"> 0.9995432 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 74 </td>
   <td style="text-align:center;"> 0.0000457 </td>
   <td style="text-align:center;"> 1 in 21893 </td>
   <td style="text-align:center;"> 0.9995889 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 75 </td>
   <td style="text-align:center;"> 0.0000411 </td>
   <td style="text-align:center;"> 1 in 24326 </td>
   <td style="text-align:center;"> 0.9996300 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 76 </td>
   <td style="text-align:center;"> 0.0000370 </td>
   <td style="text-align:center;"> 1 in 27028 </td>
   <td style="text-align:center;"> 0.9996670 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 77 </td>
   <td style="text-align:center;"> 0.0000333 </td>
   <td style="text-align:center;"> 1 in 30031 </td>
   <td style="text-align:center;"> 0.9997003 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 78 </td>
   <td style="text-align:center;"> 0.0000300 </td>
   <td style="text-align:center;"> 1 in 33368 </td>
   <td style="text-align:center;"> 0.9997303 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 79 </td>
   <td style="text-align:center;"> 0.0000270 </td>
   <td style="text-align:center;"> 1 in 37076 </td>
   <td style="text-align:center;"> 0.9997573 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 80 </td>
   <td style="text-align:center;"> 0.0000243 </td>
   <td style="text-align:center;"> 1 in 41195 </td>
   <td style="text-align:center;"> 0.9997815 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 81 </td>
   <td style="text-align:center;"> 0.0000218 </td>
   <td style="text-align:center;"> 1 in 45772 </td>
   <td style="text-align:center;"> 0.9998034 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 82 </td>
   <td style="text-align:center;"> 0.0000197 </td>
   <td style="text-align:center;"> 1 in 50858 </td>
   <td style="text-align:center;"> 0.9998230 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 83 </td>
   <td style="text-align:center;"> 0.0000177 </td>
   <td style="text-align:center;"> 1 in 56509 </td>
   <td style="text-align:center;"> 0.9998407 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 84 </td>
   <td style="text-align:center;"> 0.0000159 </td>
   <td style="text-align:center;"> 1 in 62788 </td>
   <td style="text-align:center;"> 0.9998567 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 85 </td>
   <td style="text-align:center;"> 0.0000143 </td>
   <td style="text-align:center;"> 1 in 69764 </td>
   <td style="text-align:center;"> 0.9998710 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 86 </td>
   <td style="text-align:center;"> 0.0000129 </td>
   <td style="text-align:center;"> 1 in 77516 </td>
   <td style="text-align:center;"> 0.9998839 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 87 </td>
   <td style="text-align:center;"> 0.0000116 </td>
   <td style="text-align:center;"> 1 in 86128 </td>
   <td style="text-align:center;"> 0.9998955 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 88 </td>
   <td style="text-align:center;"> 0.0000104 </td>
   <td style="text-align:center;"> 1 in 95698 </td>
   <td style="text-align:center;"> 0.9999060 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 89 </td>
   <td style="text-align:center;"> 0.0000094 </td>
   <td style="text-align:center;"> 1 in 106331 </td>
   <td style="text-align:center;"> 0.9999154 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 90 </td>
   <td style="text-align:center;"> 0.0000085 </td>
   <td style="text-align:center;"> 1 in 118146 </td>
   <td style="text-align:center;"> 0.9999238 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 91 </td>
   <td style="text-align:center;"> 0.0000076 </td>
   <td style="text-align:center;"> 1 in 131273 </td>
   <td style="text-align:center;"> 0.9999314 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 92 </td>
   <td style="text-align:center;"> 0.0000069 </td>
   <td style="text-align:center;"> 1 in 145859 </td>
   <td style="text-align:center;"> 0.9999383 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 93 </td>
   <td style="text-align:center;"> 0.0000062 </td>
   <td style="text-align:center;"> 1 in 162065 </td>
   <td style="text-align:center;"> 0.9999445 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 94 </td>
   <td style="text-align:center;"> 0.0000056 </td>
   <td style="text-align:center;"> 1 in 180073 </td>
   <td style="text-align:center;"> 0.9999500 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 95 </td>
   <td style="text-align:center;"> 0.0000050 </td>
   <td style="text-align:center;"> 1 in 200081 </td>
   <td style="text-align:center;"> 0.9999550 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 96 </td>
   <td style="text-align:center;"> 0.0000045 </td>
   <td style="text-align:center;"> 1 in 222312 </td>
   <td style="text-align:center;"> 0.9999595 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 97 </td>
   <td style="text-align:center;"> 0.0000040 </td>
   <td style="text-align:center;"> 1 in 247013 </td>
   <td style="text-align:center;"> 0.9999636 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 98 </td>
   <td style="text-align:center;"> 0.0000036 </td>
   <td style="text-align:center;"> 1 in 274459 </td>
   <td style="text-align:center;"> 0.9999672 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 99 </td>
   <td style="text-align:center;"> 0.0000033 </td>
   <td style="text-align:center;"> 1 in 304954 </td>
   <td style="text-align:center;"> 0.9999705 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 100 </td>
   <td style="text-align:center;"> 0.0000030 </td>
   <td style="text-align:center;"> 1 in 338838 </td>
   <td style="text-align:center;"> 0.9999734 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 101 </td>
   <td style="text-align:center;"> 0.0000027 </td>
   <td style="text-align:center;"> 1 in 376487 </td>
   <td style="text-align:center;"> 0.9999761 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 102 </td>
   <td style="text-align:center;"> 0.0000024 </td>
   <td style="text-align:center;"> 1 in 418318 </td>
   <td style="text-align:center;"> 0.9999785 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 103 </td>
   <td style="text-align:center;"> 0.0000022 </td>
   <td style="text-align:center;"> 1 in 464798 </td>
   <td style="text-align:center;"> 0.9999806 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 104 </td>
   <td style="text-align:center;"> 0.0000019 </td>
   <td style="text-align:center;"> 1 in 516442 </td>
   <td style="text-align:center;"> 0.9999826 </td>
  </tr>
  <tr>
   <td style="text-align:center;"> 105 </td>
   <td style="text-align:center;"> 0.0000017 </td>
   <td style="text-align:center;"> 1 in 573825 </td>
   <td style="text-align:center;"> 0.9999843 </td>
  </tr>
</tbody>
</table>


[^rng]: **R**andom **n**umber **g**enerator; in speedrunning terms it's become synonymous with 'random event' or 'specific outcome of an event determined by [pseudo] random number generation'. I know it's kind of weird to use "rng" as an adjective or catch-all term, but oh well. Context and such.

[oot100]: https://www.speedrun.com/oot#100
