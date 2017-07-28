---
author: Jemus42
categories:
- meta
date: 2016-10-01
title: Oh Great, Another Blogging Engine
---

Es ist noch nichtmal [ein Jahr her, dass ich zuletzt alles wegwarf und neu machte](/2015/11/oh-its-octopress.-again./), demnach ist es höchste Zeit, dass ich mal wieder alles wegwerfe und neu mache.

Damals dachte ich, dass mit octopress 3 und etwas mehr Verständnis für die inner workings von Jekyll alles besser werden würde, aber das war wohl etwas optimistisch.  

An [octopress](https://github.com/octopress/octopress) hat sich seitdem nicht wirklich etwas getan, und die darauf basierenden Jekyll-plugins, das immer noch nicht fertige(?) genesis-theme und die fortschreitende Entwicklung von Jekyll an sich führten jedenfalls Alles in Allem zu einer eher unangenehmen Gesamtsituation.  

Einer der Nebeneffekte war zum Beispiel, dass ich auf Jekyll 2 festhing – Versuche in meinem Gemfile Jekyll auf Version 3 zu setzen führten bei darauffolgenden `bundle exec jekyll build`s zu einer Kaskade aus deprecation warnings und errors.  
Natürlich hätte ich die alle irgendwie fixen können, aber das hätte zum Einen vorausgesetzt, dass ich mich mit den Innereien diverser ruby gems auseinandersetze, für jedes einzelne Nachforschungen anstelle was da jetzt womit nicht mehr kompatibel ist, wie der aktuelle Stand aussieht und sowieso und überhaupt. Fuck this. Zum Anderen hätte ich meine alten Blogposts aktualisieren müssen, liquid tags austauschen müssen, hier mal was ändern, da mal was anpassen. Auch hier, fuck this. Seriously. Fuck this.  

Ich will einen Blog führen, aber mit octopress/jekyll fühlte es sich eher so an, als würde ich ein stetig wachsenden repository an code maintainen müssen. Ich will nicht alte posts auf deprecated tags untersuchen müssen.  

Naja, jedenfalls sieht es nicht so aus als würde sich bei octopress in absehbarer Zeit irgendwas tun, deswegen habe ich beschlossen den ganzen Scheiß endgültig sein zu lassen und mich [hugo](http://gohugo.io/) zu widmen.  
Hugo frisst auch Markdown und spuckt statisches HTML aus, es kann auch template partials, es ist (für meinen Geschmack eigentlich viel zu) customizable, aber es funktioniert einfach.  
Es ist einfach nur ein in Go geschriebenes binary, es hat keine external dependecies, ich muss keine externen libraries aktuell halten oder in einem gegenseitig kompatiblen Zustand halten, ich muss einfach nur `hugo` in die Shell klöppeln und BÄM, Blog.  
Derzeit arbeite ich daran meine alten Blogposts (hoffentlich zum letzten Mal) zu überarbeiten um sie sauber von hugo rendern zu lassen, aber so insgesamt kommt mir das ganz brauchbar vor.  

Ein weiterer Bonus von Hugo ist, dass scheinbar aktiv entwickelt wird, und nicht wie octopress die Karteileiche eines Open-Source-Projekts ist. Sorry [imathis](https://github.com/imathis), aber octopress ist nicht "jekyll's ferrari", octopress ist ein Krampf. Ein deprimierend unzureichend maintainter Krampf. Klar habe ich kein Recht auf Entwicklung, weil wegen Open Source und ich könnt's ja selber machen, ihr kennt die Leier, aber am Ende des Tages will ich einfach nur 'nen funktionierenden Blog und ich bin dieses elende Gehacke unheimlich leid.  

Da sind so Kleinigkeiten, wie etwas mein WUnsch nach einem Theme, für das ich mich nicht schämen muss. Ich dachte ja, ich wäre mit dem jekyll default theme ganz zufriedne, habe hier und da ein paar tweaks eingebaut und dachte, das kann so langsam wachsen, aber dann sehe ich, dass hugo es, im Gegensatz zu Jekyll, sehr einfach macht verschiedene themes auszuprobieren. Was bei Jekyll ein Krampf exorbitanten Ausmaßes ist, ist bei hugo ein commandline parameter oder ein Zeile in der config.  

Mal ganz zu schweigen von der Performance. Hugo rendert einen ganzen Haufen posts einfach so weg während man blinzelt, vermutlich nicht zuletzt, weil es nicht von einem Dutzend plugins und third party dependencies aufgehalten wird (und Go vs. Ruby yadda yadda).

Das Ende vom Lied ist jedenfalls, dass blogging in 2016 immer noch scheiße ist und ich *so kurz* davor war einfach wieder auf tumblr zu bloggen.
