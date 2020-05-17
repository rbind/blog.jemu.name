---
title: Debug
type: page
katex: false
math: true
toc: true
---

This page is used for debugging purposes.
One might consider it [a `test` case](/debug).  
Here's some `inline code` without a link.

## Shortcodes

{{< codecaption lang="r" caption="A code caption" >}}
library(ggplot2)

ggplot(iris, aes(x = Sepal.Width, y = Sepal.Length)) +
  geom_point(size = 2)
{{< /codecaption >}}

## Footnotes

This is a footnote in `^[inline format]` as used by [pandoc](https://pandoc.org/MANUAL.html#footnotes) but not supported by [Hugo's Goldmark](https://gohugo.io/getting-started/configuration-markup/#goldmark) ^[Hello there].

This is a footnote in `[^ref]` format as appears to be more widely supported [^ref].

This is a footnote in `[^ref]` format with a lot of text [^longtext].

## Math

This is an equation in $‌$ math $‌$:

$$\beta = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{Y}$$

The same inline: `$\beta = (\mathbf{X}^T \mathbf{X})^{-1} \mathbf{X}^T \mathbf{Y}$`.

How about `align` environments without `$$`?

\begin{align}
f(t) &= \frac{\mathrm{d} F(t)}{\mathrm{d}t} \\
&= \frac{\mathrm{d} (1 - S(t))}{\mathrm{d}t} && \bigg|\ S(t) := 1 - F(t) \Rightarrow F(t) = 1 - S(t) \\
&= \frac{\mathrm{d} (-S(t))}{\mathrm{d}t} \\
&= - \frac{\mathrm{d} S(t)}{\mathrm{d}t}
\end{align}

Now with `$$`:

$$\begin{align}
f(t) &= \frac{\mathrm{d} F(t)}{\mathrm{d}t} \\
&= \frac{\mathrm{d} (1 - S(t))}{\mathrm{d}t} && \bigg|\ S(t) := 1 - F(t) \Rightarrow F(t) = 1 - S(t) \\
&= \frac{\mathrm{d} (-S(t))}{\mathrm{d}t} \\
&= - \frac{\mathrm{d} S(t)}{\mathrm{d}t}
\end{align}$$

Now with `align`:

\begin{align}
f(t) &= \frac{\mathrm{d} F(t)}{\mathrm{d}t} \\
&= \frac{\mathrm{d} (1 - S(t))}{\mathrm{d}t} && \bigg|\ S(t) := 1 - F(t) \Rightarrow F(t) = 1 - S(t) \\
&= \frac{\mathrm{d} (-S(t))}{\mathrm{d}t} \\
&= - \frac{\mathrm{d} S(t)}{\mathrm{d}t}
\end{align}

Now with `$$` but `aligned`:

$$\begin{aligned}
f(t) &= \frac{\mathrm{d} F(t)}{\mathrm{d}t} \\
&= \frac{\mathrm{d} (1 - S(t))}{\mathrm{d}t} && \bigg|\ S(t) := 1 - F(t) \Rightarrow F(t) = 1 - S(t) \\
&= \frac{\mathrm{d} (-S(t))}{\mathrm{d}t} \\
&= - \frac{\mathrm{d} S(t)}{\mathrm{d}t}
\end{aligned}$$

[^ref]: Hello there
[^longtext]: [**Lorem Ipsum**](https://lipsum.com/) is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
