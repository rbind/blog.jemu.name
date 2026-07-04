# blog.jemu.name

[![Netlify Status](https://api.netlify.com/api/v1/badges/8feb7af1-daaa-45df-a8f3-6bd9424179d5/deploy-status)](https://app.netlify.com/sites/blog-jemu/deploys)

Just a blog.
Running on [Hugo](https://gohugo.io/) and [blogdown](https://github.com/rstudio/blogdown).

[Development preview](https://develop--blog-jemu.netlify.app/)

## Architecture

- **Hugo** (extended) static site generator, driven by **blogdown** so posts can be
  written as `.Rmarkdown` and rendered through knitr.
- **Hugo Modules, not a classic theme.** Three modules are composed in
  `config/_default/config.toml` (highest priority last):
  1. [`hugo-rstats-pkg-meta`](https://github.com/jemus42/hugo-rstats-pkg-meta) — data for the `{{< pkg >}}` shortcode.
  2. [`jemsugo`](https://github.com/jemus42/jemsugo) — my own theme layer (shortcodes + overrides).
  3. [`luizdepra/hugo-coder`](https://github.com/luizdepra/hugo-coder) — the base theme.

  Modules are pinned in `go.mod` and **vendored** into `_vendor/`, so builds are
  offline and reproducible (Netlify does not fetch modules at build time).
- **Netlify** deploys `main`; branch/deploy previews build with drafts (`-D`).

### Repo layout

| Path | What |
|------|------|
| `config/_default/` | Split Hugo config: `config.toml`, `params.toml`, `menus.toml` |
| `content/posts/` | Posts as page bundles, organised by year |
| `layouts/` | Local overrides (new Hugo template structure: `_partials/`, `_shortcodes/`, `_markup/`, `all.rss.xml`) |
| `assets/scss/jemsu.scss` | Stylesheet; imports `_variables.scss` from hugo-coder |
| `static/` | Verbatim assets (images, favicons, `robots.txt`) |
| `R/` | knitr setup (`post-setup.R`, `helpers.R`) + the sandbox provisioner |
| `_vendor/` | Vendored Hugo modules — **committed** |

## Setup

R is required; Hugo (extended) and blogdown are provisioned per machine:

```sh
make sandbox-setup      # installs blogdown + the pinned extended Hugo (see R/setup-sandbox.R)
```

The Hugo version is read from `.Rprofile` (`blogdown.hugo.version`), so that pin is
the single source of truth for local installs. Extended Hugo is required (the SCSS
build); on arm64 Linux `blogdown::install_hugo()` needs `extended = TRUE` explicitly.

## Local development

```sh
# in R, from the repo root:
blogdown::serve_site()   # live-reload preview on http://localhost:4321 (renders .Rmarkdown)

# or via make:
make server              # hugo server on :1314 (no knitr render)
make build               # blogdown::build_site()
```

## Writing posts

Use the `./newpost` wrapper (around `blogdown::new_post()`); it creates the dated
page-bundle directory, slug, and archetype scaffolding:

```sh
./newpost "My Post Title"          # → content/posts/YYYY-MM-DD-slug/index.md  (plain markdown)
./newpost --rmd "My Post Title"    # → index.Rmarkdown  (knitr setup chunk + Session Info)
# equivalently: make post title="…"  /  make post-rmd title="…"
```

The `--rmd` flag is required for the `.Rmarkdown` scaffold — `blogdown::new_post()`
never selects that archetype on its own.

## Updating dependencies

### Hugo

Bump the version in **two** places, then reinstall locally:

1. `.Rprofile` → `blogdown.hugo.version`
2. `netlify.toml` → `HUGO_VERSION`
3. `make sandbox-setup` (or `blogdown::install_hugo("<version>", extended = TRUE)`)

Skim Hugo's release notes for the span you're jumping; deprecations accumulate.

### Theme modules

```sh
hugo mod get -u github.com/jemus42/jemsugo     # or any module path; @<commit> to pin exactly
hugo mod vendor                                # refresh _vendor/ from the new pins
git add _vendor go.mod go.sum                  # ← stage NEW vendored files, not just changed/deleted
```

> **Gotcha:** `hugo mod vendor` adds *and* removes files under `_vendor/`. `git commit -am`
> only stages modifications/deletions, so newly added vendored files get left behind and the
> pushed build breaks (missing templates/shortcodes). Always `git add _vendor` explicitly and
> confirm `git status` is clean.

> **hugo-coder tags** are `v1.2`, not `v1.2.0`, so Go modules can't resolve `@v1.2` —
> pin to the release commit SHA instead (`hugo mod get …@<sha>`).

After any update, verify a clean build before pushing:

```sh
hugo --gc --minify        # expect 0 errors and 0 deprecation warnings
```
