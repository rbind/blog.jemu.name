---
author: jemus42
categories:
- meta
tags:
- octopress
date: 2015-11-12
title: Oh, It's Octopress. Again.
draft: true
---

Blogging-Systeme auszuprobieren ist über die Jahre wohl zu meinem Sekundärhobby geworden. Diverse Versionen von Blogger/Blogspot, Wordpress (.com und self-hosted), und natürlich jekyll/octopress.  

Ich dachte, jetzt wo ich gerade die frische Version [octopress 3](https://github.com/octopress/octopress) aufgesetzt habe, wäre ein guter Zeitpunkt mal etwas zu reflektieren.

## Wie alles begann

Ich fand bloggen immer irgendwie interessant – gar nicht so, weil ich viel zu erzählen gehabt hätte, eher im Gegenteil – die Idee mir da eine Platform aufzusetzen, auf der ich mich austoben und/oder darstellen kann, schien mir einfach nach Spaß. Zu sagen hatte ich nie viel. Meine ersten Blog-Ansätze liefen damals noch über Blogger/Blogspot – Was ich angenehm zu nutzen, aber wenig spannend zu führen war. Als der Blog einschlief, suchte ich mir etwas später etwas neues. Wordpress. Und Wordpress war damals deutlich schlimmer als jetzt, die älteren unter euch erinnern sich vielleicht noch.  

Auch der Blog schlief ein, weil es mich langweilte. Zu diesem Zeitpunkt lernte ich, dass dieser Terminal auf meinem MacBook ja auch Dinge kann. Ein [Uberspace](https://uberspace.de)-Account später und ich hatte Octopress 2 aufgesetzt, inklusive allem, was daran furchtbar war, und als Bonus noch meine mangelnde Erfahrung obendrauf.

### My first octopress – Pls kill me nao

Okay, was lief damals alles schief, was machte ich alles falsch? Schauen wir uns die Startsituation an:

1. Ich hatte gerade erst angefangen die shell zu nutzen
2. Ich habe mit octopress zum ersten mal git und GitHub genutzt
3. Ich habe zum ersten mal mit ruby/rvm/bundler interagiert und nichts davon verstanden
4. Ich hatte zum ersten mal `jekyll` genutzt (ohne den Unterschied zwischen jekyll und octopress zu verstehen)
5. Es war mein erster Kontakt mit liquid templates, die ich erst seit kurzem so grob verstehe (und sehr mag)
6. Deployment lief über `rsync`, was ich auch praktisch zum ersten mal nutzte

Alles in allem also wunderbare Voraussetzungen für einen octopress Blog. Der Erfolg sah dementsprechend aus. Es ging halt irgendwie. Für eine Weile.  

Nach nicht all zu langer Zeit schmiss ich den Kram jedenfalls, warf alles weg und fing von vorne an. Zu diesem Zeitpunkt mit mehr Erfahrung mit git, einem rudimentären Verständnis der ruby-Welt [^1] und allgemein besserem Verständnis von… Dingen. Glaubte ich.  
Ich setzte also octopress neu auf, versuchte alles richtig und sauber zu machen, und es war immernoch irgendwie krampfig. Es funktionierte, ich konnte sogar das theme anpassen, und solange ich an `bundle exec` dachte lief auch alles ohne Probleme. Es fühlte sich dennoch kaputt an.

## Sooo… what now?

So wirklich begriffen, warum das alles so kaputt war, verstand ich erst als ich [imathis' blogpost zur Ankündigung von octopress 3](http://octopress.org/2015/01/15/octopress-3.0-is-coming/) las.  
Es war gar nicht alles meine Schuld, ich hab gar nicht so viel falsch gemacht, nein, das Ding war einfach in sich schon kaputt.

Also. [Das neue octopress mit all seinen plugins und sowieso](https://github.com/octopress) angeguckt und für okay befunden. Es wirkt alles deutlich besser durchdacht, und insbesondere die vermeintliche Dichotomie zwischen octopress und jekyll fühlt sich jetzt deutlich besser an – Ich habe das Gefühl einen jekyll-Blog zu führen, der durch octopress bedient wird. Insbesondere die Möglichkeiten von *octopress ink* in Bezug auf plugins und themes wirken sehr angenehm. Ich traue mir mittlerweile zu an meinem Blog zu schrauben, ohne irgendwas ganz massiv kaputtzumachen.  

Nachdem ich mir aber [hugo](https://gohugo.io) angeguckt habe, fühlt sich die theme-Situation auf jekyll generell unglaublich rückschrittlich an. Schade eigentlich. Nun denn, ich warte derzeit einfach auf [das genesis theme (derzeit borked)](https://github.com/octopress/genesis-theme/issues/45), aber nun ja.

## Oh, so *this* is how this works

Einer der Grundsätze von octopress 3 war es, die vermeintliche Dichotomie der octopress und der jekyll community zu reduzieren – octopress soll nur als *bonus feature* für jekyll blogs funktionieren, und keine Abspaltung von der jekyll-Grundlage verursachen. In der Konsequenz habe ich mich von Grund auf mit meinem neuen, frischen jekyll Blog auseinandergesetzt, versucht herauszufinden welche Teile wofür gut sind, was es mit `_layouts` und diesen ominösen liquid templates auf sich hat und sowieso und überhaupt.  
Und sieheda, kaum versteht eins was da passiert, schon funktioniert's auch. Sehr schön.  

Als Resultat habe ich jetzt also zwei frische jekyll-basierte Blogs mit kleineren Modifikationen an Theme und Layout, und ich bin erstaunlich zufrieden damit.  

Zusätzlich habe ich durch etwas Ausprobieren auch endlich einen etwas-näher-an-benutzbaren Weg gefunden, meinen R-Kram via RMarkdown/knitr mit meinem jekyll-Blog zu verknüpfen, aber dazu werde ich wohl ein ander mal was erzählen. Also, zum Beispiel wenn ich es zuverlässig und benutzbar hinbekommen habe.

Spontanously written over the course of many days but not read,  
jemsu


[^1]: Danke @mxey <3
