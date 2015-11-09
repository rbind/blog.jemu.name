---
layout: post
title: "Locationdaten von Foursquare und Openpaths.cc in R plotten"
date: 2014-01-29 08:30
comments: true
categories: rstats
published: true
   
---
<small>Neu aus der Reihe "Originelle Blogposttitel aus denen sich sicherlich erfolgreiche Jingles produzieren lassen würden"</small>

Im Rahmen dieses Psychologiestudiumsgedöns fällt auch Statistik an, und wo Statistik und größere Datenmengen gepaart mit einer Aversion gegenüber [proprietärer Software aus der Hölle][SPSS] ist, da ist auch [R][R]. Und da ich das mit dem Lernen für die anstehenden Klausuren *wirklich hart* prokrastiniere, spiele ich lieber etwas mit R rum. 
<!-- more -->

### Here: Long preface not really relevant to succeeding with plot stuff. Sorry.

Als ich schließlich eines Nachts so durch reddit scrollte, stieß ich in [/r/dataisbeautiful][] auf [diese nette kleine Karte][redditpost], auf der jemand seine Foursquare-Checkins auf eine US-Karte plottete. Und sieheda, das ganze war sogar in R realisiert, und in den Kommentaren fand sich sogar ein Link auf das entsprechende [gist][redditgist]. Neat.  
Für mach war das die erhoffte Gelegenheit mal etwas anderen Kram mit R zu machen, ohne dabei direkt zu viel Voodoo blind zu copypasten. Auch wenn ich erstmal genau das tat. Codecopypasta is where learning begins, folks.

Die Vorlage war nur leider nicht besonders hilfreich, da sie auf der Nutzung eines Pakets für die Kartendaten aufbaut, das primär US-zentrisch ist. Es gibt zwar auch ein "world"-Subset, aber an diesem Punkt des Prozesses konnte ich damit nur bedingt etwas anfangen. Zudem nutzte es map projections, sowohl der map an sich als auch der jeweiligen Daten, was zwar naheliegend ist, aber Dinge verkompliziert.  
Aber nun gut, kommen wir zum interessanten Teil.

### Set up R / Rstudio (just in case)

[R][] ist das Framework, komplett mit binary zum Terminalvoodoo machen, vermutlich auch scriptbar und sowieso, während [Rstudio][] dann etwas mehr Bedienbarkeit drumrumpakt. Unter anderem ein Vorschaufenster für Plots, was uns hier sehr entgegen kommt. R könnt ihr auch via homebrew installieren, siehe dazu auch [hier so][rsetup].  
Sinnvoll wäre schonmal sich einen Ordner für den kommenden Foo zu suchen und ihn als working directory festzulegen (Filebrowser rechts, "more"-Menü).

### IMMA GET SOME DATA YO

First up: Here's the [gist][].  
I mean, literally. Kind of. You'll need that.

Zuerst braucht ihr eure Foursquare-Daten, für die ihr wiederum etwas Zeug in R braucht, um an die Daten zu kommen, und natürlich einen API-Key. Ersteres bekommt ihr mit [RPI][], wo ihr auch eine Anleitung für letzteres findet.

Wenn ihr mein gist unverändert ausführen wollt, müsst ihr rpi.R in eurem working directory liegen haben, wenn nicht, dann wisst ihr vermutlich eh besser was ihr tut als ich ¯\\\_(ツ)_/¯  

Nun eure openpaths.cc-Daten. Die könnt ihr recht dankbar aus eurem Account als .csv runterladen und ins working dir packen. Ja, direkter Pull über API-Kram wäre vermutlich möglich, aber… Ja. TBI.  
Tragt also jetzt euren API-Key und den Dateinamen eures openpaths-Exports ein und… Ja, im Grunde war's das.  
Run stuff and stuff will happen!

![ITSAMAP][mapfinal]

Joa. Nett. Aber im Grunde langweilig.  
Dasselbe Ergebnis in schöner und interaktiv bekommt ihr über etliche andere Tools, aber darum geht's hierbei ja eigentlich nicht. Der eigentliche Sinn dieser Übung ist ja, eure eigenen Locationdaten in der metaphorischen Hand zu haben und Dinge damit zu tun.  
Zum Beispiel habe ich mal den Mittelwert meiner lon/lat coords berechnet, dazu die Standardabweichung, dann die lon/lat Standardabbweichungen gemittelt und das als Radius für einen Kreis um die gemittelte Koordinate benutzt. Wieso? Weil es geht. Einfach nur weil es geht. Wirklich interessant könnte zum Beispiel auch die Verwendung der zu euren Koordinaten gehörenden Timestamps sein, die ihr für eure openpaths-Daten über  

    paths$date
    
ausgeben lassen könnt.  
Eine Gesamtvorschau eurer Datenstruktur bekommt ihr per  

    head(paths)

### Und, sonst so?

Der nächste Schritt wäre jetzt zum Beispiel statt Google Maps eine andere Kartengrundlage zu wählen, idealerweise etwas, was mehr Metadaten bietet, wie etwa in diesem [Beispiel][germanymapstuff]. Allgemein sind wohl Karten in Polygonform statt reiner Bildchen wohl der heiße Scheiß in der allgemeinen… Äh, allgemein halt. Mit [ggplot2][] bzw. dem verwandten ggmap lässt sich in dem Bereich wohl jedenfalls sehr viel realisieren, und sobald ich eine schönere Alternative gefunden habe, die sich auf Europa/Deutschland übertragen lässt, werde ich das wohl ausprobieren.  
Alles in Allem war das hier aber eine schöne Übung mich etwas mehr mit R und verschiedenen Paketen vertraut zu machen.


<!-- Links -->
[SPSS]: http://www-01.ibm.com/software/de/analytics/spss/
[R]: http://www.r-project.org/
[Rstudio]: http://www.rstudio.com/
[rsetup]: http://hackr.se/setup-r-and-rstudio-on-mac-os-x/
[gist]: https://gist.github.com/jemus42/d0d01aabe77b17623344
[/r/dataisbeautiful]: http://www.reddit.com/r/dataisbeautiful
[redditpost]: http://www.reddit.com/r/dataisbeautiful/comments/1w7tse/everywhere_ive_been_in_the_last_35_years/
[RPI]: https://github.com/johnschrom/RPI
[redditgist]: https://gist.github.com/johnschrom/8638763
[othermapstuff]: http://rstudio-pubs-static.s3.amazonaws.com/10823_e15ce99b55424ac9ad57c2ca11bf636c.html
[ggplot2]: http://ggplot2.org/
[germanymapstuff]: http://ryouready.wordpress.com/2009/11/16/infomaps-using-r-visualizing-german-unemployment-rates-by-color-on-a-map/

[mapfinal]: http://dump.quantenbrot.de/4sq_opp_small.png
