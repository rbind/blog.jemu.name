---
author: jemus42
categories:
- Minecraft
date: 2013-11-08
tags: null
title: Ich wollte doch nur Minecraft spielen
---

<small>This post exists primarily because I couldn't sleep and I accidentally ironblogging</small>   

<img src="https://assets.wurstmineberg.de/img/logo/wurstpick.png" alt="Wurstpick – Courtesy of @katethie" style="width: 200px; text-align: center;"/>  

Blogposts über Minecraft sind jetzt voll im Trend, hab ich beschlossen seit ich [Farthen](http://farthen.de/blog/2013/10/22/minecraft-eine-liebesgeschichte/)s Minecraftpost gelesen habe, jedenfalls, und sowieso.

Es folgt daher ein Versuch <em>The Story of [Wurstmineberg](https://wurstmineberg.de)</em> zu… Beschreiben? Nacherzählen? Naja, irgendwiesowas, was es dann geworden ist lege ich am Ende fest.
<!-- more -->

# Alles begann an einem Abend im August 2012

…Vöglein sangen, Grillen… zirpten?  
[Bene](https://twitter.com/benemitc) nötigte mich mir mal Minecraft anzugucken, weil er unlängst anfing zu spielen und wie Bene so ist wenn Bene so ist wie Bene so ist, ist Bene entsprechend enthusiastisch. Meistens reizt mich das dann nicht sonderlich, aber da ich den Hype schon eine Weile mitbekam, aber nie weiter nachforschte, dachte ich es wäre wohl an der Zeit mir das mal anzugucken. And so it began. Einen Tag später traf ich mich mit Bene und wir starteten unsere erste gemeinsame Welt, im LAN, weil gerade [1.3](http://minecraft.gamepedia.com/Version_history/Minecraft_1.3) frisch rauskam und man nichtmal einen extra Server aufsetzen musste. Und dann spielten wir ein paardutzend Stunden am Stück, vergaßen zwischendurch zu trinken, zu rauchen und Abendessen zu bestellen, weil der "Ich mach das nur noch schnell fertig – Ohwait suddenly 3hrs later"-Effekt so penetrant war. Aber auch ungewohnt großartig, sowas hatte ich schon lange nicht mehr.  
Fast forward ein oder zwei Wochen, ich war wieder in meiner Wohnung, Bene wieder in seiner, zwischen uns ~450km Minimum. Irgendwie wollten wir aber trotzdem unsere Welt weiter fortsetzen, also was macht man da. Natürlich mietet man einen okayen Minecraftserver von einem reputablen Minecraftserverhoster. Oh wait that's not what actually happened. Ich installierte Ubuntu auf mein altes MacBook, funktionierte es zum Quasi-NAS um, um 24/7 Betrieb zu rechtfertigen und installierte einen Minecraftserver darauf, und schon hatten wir einen Minecraftserver. An einer DSL 16k Leitung, weil ich keinerlei Respekt vor mir selbst hatte. Das Resultat war, dass ich spielen konnte wie im Singleplayermodus, und Bene eine minecrafteske Diashow spielen konnte. Wir setzten auch eine neue Welt auf, initial mit einer "Du kriegst den Osten, ich den Westen"-Idee, die sich aber nicht wirklich durchsetzte. Alles war mehr oder weniger derpy.  
Alle gewannen.  

# Expansion heißt Expansion heißt Expansion

Das ganze ging auch erstaunlich lange gut, bis Anfang 2013 sogar.  
Es begab sich durch nicht mehr nachvollziehbare Umstände[^1], dass irgendwann neben Bene und mir noch andere Leute auf dem Server spielten, oder dies zumindest versuchten. Ich sah mich nach okayen Minecraftserverhostern <sup><small>(schönes Wort)</small></sup> um, und stellte erstmal fest in was für einem beschissenen Zustand diese ganze Community in der Richtung ist. Das Minecraftforum war pratkisch nutzlos und reputable Quellen fand ich keine, jedenfalls versuchten ich es mit dem erstbesten Hoster der nicht scheiße aussah, setzte den Server auf, kotzte mir den Rachen wund vor der Hässlichkeit und Unbenutzbarkeit des scheinbar vom Praktikanten zusammengedängelten "Control"-Panels und schämte mich für die verschwendete <s>12 Mark</s> 6€. Als Nächstes versuchte ich [CubedHost](https://www.cubedhost.org/), und was soll ich sagen, es war weniger schlimm als befürchtet. Der kleinste Server im Angebot reichte aus, die Administration erfolgte über [MultiCraft](http://www.multicraft.org/), was zwar nicht perfekt, aber good enough ist, und auch sonst war CubedHost für längere Zeit unser zu Hause.
Zu dieser Zeit fand auch der bisher einflussreichste Mitgliederzuwachs statt, der [Twitteraccount](http://twitter.com/wurstmineberg) entstand und [#wurstmineberg](irc://chat.freenode.net/#wurstmineberg) wurde registriert.  
Suddenly Leben.  
Dinge passierten ganz ohne mein Zutun.  

# There are things, let's use them to make other things!

Wo Daten rumliegen lassen sich Dinge damit tun.  
Mark my words, people.  
Okay, zuerst ging es nur um den [map overview](http://overview.wurstmineberg.de/) – Denn regelmäßige world backups waren zwar nur via FTP möglich, aber sie waren möglich. Und wenn man world backups hat, kann man auch den [Overviewer](http://overviewer.org/) drüberjuckeln lassen und das Output auf einen [Uberspace](uberspace.de) werfen. Das passierte auch eine Weile, und plötzlich war da eine Art Infrastruktur.  
And everything went <s>down</s>uphill from there.  
Stündliche Backups via FTP waren zu wenig, sporadisch gepullte Logfiles zwecks Analyse waren zu wenig, der storage eines Uberspace für den Overview wurde zu wenig, die Performance des Servers war zu wenig… Wir mussten upgraden, oder zumindest die Platform wechseln.  
Und auf einmal hosteten wir alles auf einem vserver. Die Leistung war nicht beeindruckend, das generell Setup war nicht… ideal, aber wir hatten shell / root access und konnten rumbasteln. [Meine ersten Versuche](https://github.com/jemus42/minecraft-management-clusterfuck#minecraft-management-clusterfuck) ein automatisiertes Logparsing zu implementieren waren zwar bedingt erfolgreich, und es war uns auch möglich beispielsweise durch "!tweet Hello World" einen Tweet "Hello World" vom @wurstmineberg Twitteraccount abzusenden, aber… Naja, es war ein <em>Clusterfuck Paved in BASH</em> <sup><small>Patent Pending</small></sup>, aber [Fenhl](https://twitter.com/fenhl) nahm sich dankbarerweise dem Elend an und klöppelte [Wurstminebot](https://github.com/wurstmineberg/wurstminebot) zusammen.  
Auf einmal war alles fancy python vodoo, der ingame chat war mit dem IRC channel in sync, automatisierte Tweets funktionierten immernoch, und sowieso und überhaupt und alles ist besser mit 'nem Bot im Hintergrund.  
Nebenbei registrierten wir auch ein [Subreddit](http://reddit.com/r/wurstmineberg), im Versuch permanentere Diskussions-/Ankündigungsdinge zu etablieren, was mäßig erfolgreich ist/war, aber immerhin. We tried. (Außerdem: Infrastrukturbonus!)  
Parallel führte die Twitteraktivität zu unerwarteter Publicity, und wir hatten auf einmal mehr Leute auf dem Server als ich Finger an einer Hand, was mich vollkommen überfordert(e)[^2]. Zum Glück sammelten wir neben daueraktiven auch ein paar permanente [Karteileichen](https://twitter.com/viirus42) ein, was zumindest die Serverlast etwas in Grenzen hielt, denn die wurde langsam zum größten Problem.  
And then we serious'd.

# Lass da mal Geld draufwerfen

Wir diskutierten ein bisschen rum und guckten wie so die Bereitschaft finanzieller Beteiligung ist, uns einen richtigen echten Server aus echter Hardware statt eines vservers zuzulegen, um das mit der Performance (und dem storage) in den Griff zu kriegen, und sieheda, [ein Server ward geboren](http://www.nessus.at/produkte/rootserver/l). Communityfinanziert, wie sich das gehört, per Überweisung direkt an mich, damit ich mich in ~2814 Jahren in die Karibik absetzen kann. Der Deal ist einfach: Wer mag kann sich beteiligen, ich führe so transparent wie möglich Buch und wer sich beteiligt kriegt keinerlei Boni außer einem Platz in meinem Herzen und vielleicht die Chance von meiner Todesliste gestrichen zu werden.  
Aber es war wohl der bisher Größte Umbruch, zumindest für mich, weil das Ganze nicht mehr dieser 6-8€ Spaß war, den ich for the lulz mal laufen ließ, sondern auf einmal ein (kleiner) Haufen Leute zusammenkam und Geld auf etwas warf und sowieso und überhaupt und das grenzt ja an Verwantwortung. Deshalb war ich auch vorausschauend und gab das root-pw an [L3viathan](https://twitter.com/l3viathan2142), [Fenhl](https://twitter.com/Fenhl) und [Farthen](https://twitter.com/Farthen) weiter. Damit wenigstens <em>irgendjemand</em> weiß, was er da tut[^3].  
Suddenly neben Verantwortung auch noch Vertrauen. Es ist so eklig.
Jedenfalls zogen wir dann vom vserver auf den dedicated server um, Dinge passierten und neben dem Bot gab es nun auch die Website, die wunderbar vom Bot profitierte. Ein Blick auf die Startseite zeigte wer gerade online ist, was für die Maßstäbe eines Vanilla Servers ohne fancy [bukkit](http://dl.bukkit.org/downloads/craftbukkit/) voodoo schon sehr fortgeschritten schien.  
Für die Nichtminecraftenden: Der "normale" Minecraft Server gibt einem außer dem Logfile nicht wirklich viel Output, aber modifizierte Server, wie bukkit als populäres Beispiel, bieten einem die Möglichkeit Plugins zu nutzen, die allerlei Kram anstellen, von dynamischen worldmaps bis… keine Ahnung. Fancy foo jedenfalls. Sowas kam für uns aber nie in Frage, wir waren ein [Snapshot](http://minecraft.gamepedia.com/Snapshot#Snapshots_.26_Pre-releases)-Server, sprich, wir upgradeten so früh wie möglich auf die aktuellste Developmentversion des Spiels, um möglcihst früh Zugang zu neuen Features zu haben und sozusagen dem Spiel bei der Weiterentwicklung zuzuschauen. Die Bukkit-Devs können da schlecht mithalten.  

# Developers, developers, developers!

Irgendwann neulich ist die customization dann etwas… Naja, in Fahrt gekommen.  
Der Bot wurde immer mächtiger, das interne Servermanagement erfolgte nicht mehr über ein generisches, vom Minecraftwiki copypastetes init-Script, sondern über eine [besser angepasste Variante](https://github.com/wurstmineberg/init-minecraft).  
Dann fing auf einmal [irgendjemand](https://twitter.com/farthen) an die world files des Servers direkt anzuzapfen, [auszulesen und JSON drumrumzupacken](https://github.com/wurstmineberg/minecraft-api).  
Zu den glorreichen Früchten dieser Arbeit gehört neben [isitraining.wurstmineberg.de](http://isitraining.wurstmineberg.de) und [time.wurstmineberg.de](http://time.wurstmineberg.de) auch fancy schmanzy [Statistikkram](http://wurstmineberg.de/stats), weil alles besser ist mit Statistiken. Die Änderung in [1.7](http://minecraft.gamepedia.com/The_Update_that_Changed_the_World), dass Playerstatistiken und Achievements jetzt nicht mehr client- sondern serverseitig gespeichert werden hatte so ihre Folgen. Nett.  
Und dann war da noch der map overview. Stetig wachsend, langsam rödeln und irgendwie ein clusterruck exorbitanten Ausmaßes (hab ich mir zumindest von Leuten™  sagen lassen, die Python verstehen). Mir viel [mcmap](https://github.com/zahl/mcmap) ein, ein kleines C++-Tool, das einfach nur ein PNG der map generiert, und das wohl seit etwa einem Jahr mehr oder weniger tot ist. Jedenfalls warf ich den Link dazu in den IRC channel und fragte, ob nicht mal jemand Lust habe das Ding auf den neusten Stand zu bringen, und… Ich hätte wirklich nicht erwartet, dass das passiert, aber [eFrane](https://twitter.com/efrane) so "kann ich machen."  
And then [it was happening](https://github.com/wurstmineberg/mcmap/tree/rewrite).  
And then I lol'd.  

Mittlerweile habe ich den Überblick verloren was so alles passiert oder wie alles funktioniert, aber hey, immerhin. Wir haben einen eigenen Bot mit Logparsing, custom commands, ein custom init-Script, eine managed whitelist/website/whatevs via Bot, eine API die Daten aus den world files lutscht, und an einem "eigenen" map overview generator wird gerade gearbeitet.  

Von allen Vanilla Minecraft Servern die ich je sah (nicht viele, btw), sind wir mit Abstand der most customized, overthaught, over the top, <em>Adjektiv</em>, <em>Adjektiv</em>.  
So fucking awesome.  

Und jetzt sitze ich hier, Pseudo-Admin von etwas, das schon längst genug Fahrt aufgenommen hat um ganz ohne mich oder Bene weiterzuexistieren und weiterzuwachsen.  
Trotzdem haben [Farthen und Naturalismus mich zum Feindbild erklärt.](http://wiki.wurstmineberg.de/Revolutionary_Movement_for_a_Free_Anarchosyndicalistic_Wurstmineberg) <em>Hashtag sadface</em>  
Achja, ein Wiki haben wir auch mittlerweile. Just because Wiki.  
Wir sind sogar an dem Punkt angekommen, wo wir nicht mehr einfach Leute einladen und Leute einladen lassen können, weil wir sonst komplett den Überblick verlören. Das ist kein Qualitätsmerkmal und kein Exklusivitätsgeheuchel, nein, wir sind tatsächlich sonst einfach nur leicht überfordert<sup>[^2] is kind of valid on this one, too</sup>.  
Wir sind ja auch kein generischer Minecraftserver mit Werbung im Minecraftforum, donation-page, bukkit setup und whateverthefuck the rest of the community is doing.  

<pre>We are Wurstmineberg,  
we are too lazy to be legion,  
we do not reference anonymous,  
we accidentally stuff.  
Don't expect us, we probably overslept.

And yes, we know that name is kind of stupid.
</pre>[^4]

So viel nur dazu.  
Ich wollte das nur mal so grob dokumentieren, for <em>the future.</em> <sup><small>(and yet another unneeded use of &lt;em&gt;-Tags)</small></sup>  
Also, ja. Ich danke allen die da mehr Zeit reingesteckt haben als irgendjemand jemals für nötig gehalten hätte.  
[It's been emotional](http://www.youtube.com/watch?v=Ee3Jh5qRDMo). 


[^1]: No srsly, die alten Logs sind kaum nachvollziehbar auswertbar.  
[^2]: To be honest: It still does, kind of.  
[^3]: Immer wenn ich vorher ein unixoides System kaputtkonfiguriert hab, war das wenigstens auf meiner lokalen Hardware und es war egal, aber hier wollte ich doch wenigstens Leute dabei haben, die mit den best practices etwas besser (sprich: überhaupt) vertraut sind.  
[^4]: Actually, funny story. Die Welt hieß schon länger Wurstmineberg, weil Bene und ich *Wurstmannberg* als running gag hatten. Die Geschichte wiederum ist etwas länger, und definitiv zu lang für eine Fußnote. Jedenfalls schien "Wurstmineberg" die logische Minecraftifikation von "Wurstmannberg" zu sein. "Wurstmanncraft" schied völlig aus, denn Minecraftserver die auf "-craft" enden sind etwa wie Podcasts, die auf "-cast" enden. Jedenfalls lief der Server tatsächlich eine Weile auf "wurstmannberg.de", weil ich die Domain halt rumliegen hatte (that's how dedicated I am), aber mit der Servermigration auf den aktuellen Server nahm ich dann noch "wurstmineberg.de" mit, because why the fuck not. And there's that.
