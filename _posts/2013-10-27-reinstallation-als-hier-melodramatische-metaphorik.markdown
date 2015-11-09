---
layout: post
title: "Reinstallation als HIER_MELODRAMATISCHE_METAPHORIK"
date: 2013-10-27 21:00
comments: true
categories: tech
published: true
---
<small>*Ermagehrd tabula rasa herpderp Neuanfang HODOR me so deep*</small>

Eigentlich wollte ich nur mein 2011er MBP wieder etwas… weniger unbenutzbar machen, indem ich die HDD durch ein s/HD/SS/ in eine SSD konvertierte. Konkret [dieses](http://www.amazon.de/gp/product/B009LI7C5I/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1) Modell, 120GB, nichts abgefahrenes. Immerhin habe ich mir lang genug angehört, dass Computer jeder Art ja ohne SSD eigentlich gar nicht mehr benutzbar sind und sowieso und überhaupt, und wie ich mittlerweile festgestellt habe, stimmt das auch.
<!-- more -->
Vielleicht lag die Trägheit meines Systems aber auch einer, ähm… historisch gewachsenen Kaputtkonfiguriertheit. Immerhin war es das System, auf dem ich anfing etwas powerusereskere Dinge zu tun. Natürlich hätte ich mit ausreichend fehlerdiagnostischer Kompetenz und Geduld auch einfach alles irgendwie fixen können, aber ein kompletter clean install war mir dann doch lieber, auch wenn mir #echtehacker™  davon abgeraten haben. Bin halt Rebell.

## Früher war alles schlechter

Mein System war… besonders. Ich fing darauf an die Shell regelmäßig zu benutzen, was darin endete, dass ich ich ZSH und [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) benutzte. Wirklich verstanden hatte ich beides noch nicht wirklich, was dann wiederum zur Folge hatte, dass meine .zshrc ein Zeugnis exorbitanter Clusterfuckery war. Mein homedir war ein git repo, und ich habe keine Ahnung mehr wieso. Meine manuell gesetzte Prompt funktionierte nur, wenn ich vorher ein oh-my-zsh-theme geladen hatte. Meine Ordnerstruktur war… *historisch gewachsen*, und ~/test war neben ~/Dropbox/Scripts auch einer der Orte, den ich "irgendwann mal auf-/wegräumen" wollte. Um Devices auszuwerfen benutzte ich eine Bashfunction, die <code>diskutil unmountDisk /dev/disk$1 && diskutil eject /dev/disk$1</code> ausführte, weil weder die eject-buttons im Finder noch der entsprechende Tastaturbutton ihre Funktion erfüllten.  
Homebrew funktionierte nur manchmal, irgendwann war da mal was mit fehlgeschlagenem linking, weshalb ich *irgendwas* dann *irgendwelche* permissions gab, und heute keine Ahnung mehr habe was da passierte. Bevor ich Homebrew nutzte, versuchte ich mal *irgendwas* mit MacPorts, was anscheinend auch nicht gut mit Homberew koexistiert, aber gut. Das ist alles schon 'ne Weile her.  
Klar, das hätte man alles irgendwie fixen können und die coolen Kinder lachen mich jetzt auch bestimmt in der Pause aus, aber nun gut.

Außerhalb des Terminals war zwar alles einigermaßen sauber, aber langsam. Und ruckelig. Und ich weiß nicht wieso. Sobald ich Chrome auch nur mit einem harmlosen Tab öffnete war alles ganz schlimm, und wenn ich für die Uni mal Powerpoint öffnen musste war gleich Apokalypse. Um meine letzte Hausarbeit zu schreiben bin ich dann von Texmaker auf eine Mischung aus Sublime Text und ein paar Zeilen Bashscript zum texen umgestiegen. Hauptsache schlank.  
Ich weiß nicht wie viel der Trägheit jetzt einer Ansammlung verwahrloster installierter/kaputtkonfigurierter Software geschuldet war und wie viel einfach mit der Hardwareperformance zu tun hatte, aber alles in allem fühlte ich mich auf dem System nicht mehr wohl, und ich hatte eh mal Lust alels von Grund auf weniger falsch zu machen, statt >9000 Sachen auszuprobieren, bis ich das gewünschte Ergebnis habe, und die Leichen auf dem Weg liegen zu lassen.

## Kaum macht man's weniger falsch funktioniert's sogar

Frische SSD, frische Mavericks-Installation, Keychain und Chrome gesycnt und fast wieder zu Hause. Nur schneller.  
So eine Neuinstallation ist mittlerweile auch unerwartet schnell erledigt. Ich erinnere mich an Zeiten des angestrengten exportierens von Einstellungen, Bookmarks oder sonstwelcher Daten, nur um diese dann irgendwohin auszulagern und manuell wieder zu importieren. Das musste ich dieses Mal immerhin nur mit einem Steam-Savegame und meiner TeamSpeak-identity machen <small>(Ja, ich weiß)</small>.  
Und ja, so'ne SSD ist super. Ich kann sogar Steam starten ohne von der Ladezeit Depressionen zu kriegen, und boot/shutdown ist kein "Geh ich halt in der Zeit mal 'ne Stunde um den Block flanieren"-Angelegenheit mehr. Okay, möglicherweise findet eine leichte Gegenwartsverklärung statt.  
Was ich noch nicht tat ist das optische Laufwerk durch ne HDD für platzverbrauchsdaten wie Musik zu substituieren, aber ich gehe einfach mal davon aus, dass das schon irgendwie okay funktionieren wird.

## Nachhaltigkeit ist der heiße Scheiß

Da ich mittlerweile auf mehr als einem System Dinge tue habe ich dann auch mal angefangen ein git repo für syncwürdige Dinge anzulegen. Darunter zum Beispiel mein oh-my-zsh-theme, das aufgeräumt auch gleich viel handlicher ist. Um einen separaten Blogpost mir "So hab ich mein System eingerichtet" vorwegzunehmen, hier eine Ansammlung von Dingen, die ich benutze:

* [Homebrew](brew.sh) für h4xX0rigen Terminalkram und Paketmanagement und sowieso.
* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), wie schon mehrfach erwähnt, zusammen mit [Kram](https://github.com/jemus42/syncbin/tree/master/zsh) aus meinem neu angelegten [syncbin](https://github.com/jemus42/syncbin).
* Einige gesetzte [defaults und "hacks"](https://github.com/jemus42/syncbin/blob/master/defaults.sh), die ich zum Teil [hier](https://github.com/mathiasbynens/dotfiles) klaute.
* [Flux](http://justgetflux.com), because sleep.
* [Sublime Text](http://www.sublimetext.com), weil es immer noch besser ist als Textedit.
* [Mou](http://mouapp.com), weil es [Dinge angenehmer macht](http://dump.quantenbrot.de/DBGwUayQkx.png)
* [Fileshuttle](https://github.com/michaelvillar/fileshuttle), weil mein screenshots-zu-imgur-autoupload-shellscript auf der Clusterfuckskala auch zu weit oben lag.
* [Ecoute](http://pixiapps.com/home/), weil iTunes starten auch einfach zu viel Arbeit ist.
* [Beets](http://beets.radbox.org/) als Musikorganosationsdings. Benutze ich *noch* nicht, plane es aber, jetzt wo ich die Gelegenheit habe meine iTunes-Mediathek mal umzustrukturieren.
* [iTerm2](http://www.iterm2.com), zumindest wenn Terminal.app + [tmux](http://tmux.sourceforge.net/) nicht ausreichen oder ich zu faul bin meine tmux-config gescheit zu setzen.
* [Typinator](http://www.ergonis.com/products/typinator/) für Textexpansions. Wer Alfred oder sowas benutzt kann darauf verzichten, aber ich brauche™ nicht mehr als Typinator kann. Immerhin benutze ich es primär eh nur für schnellen Zugriff auf " ¯\\\_(ツ)_/¯ "
* [iStat Menus](http://bjango.com/mac/istatmenus/), nachdem ich ewig iStat Pro als Dashboardwidget nutzte, aber das mittlerweile wohl tot ist. Eigentlich will ich nur einen schnellen Überblick auf die allgemeine Systemauslastung und Bandbreitennutzung. Die Illusion von Kontrolle und sowas.
* [Adium](http://adium.im). Alter Hut, ich weiß. Aber derzeit macht es noch Google Hangouts parallel zum Facebook-Chat und Jabber, und mit [diesem Theme](http://www.adiumxtras.com/index.php?a=xtras&xtra_id=8410) <sup><small>(Danke @bl1nk)</small></sup> geht's auch ganz gut.
* [Textual](http://www.codeux.com/textual/), weil IRC.
* Als Font für Textual, Terminal und alle Texteditoren: [Madmaliks monoOne](https://github.com/madmalik/monoOne). Allein schon weil so im IRC Nickchangewitze auf "l=I"-Basis weniger nerven.

In erster Linie das.  
So viel nur dazu.
