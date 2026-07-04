#!/usr/bin/env Rscript
# Provision a fresh yolobox (or any P3M-configured Linux box) for this blog.
#
# Installs:
#   * blogdown -- as a *binary* from the box's Posit P3M repo, so no compiler and
#                 no system -dev libraries are needed. The global yolobox baseline
#                 (~/.config/yolobox/yolobox.Dockerfile) already provides R via rig
#                 plus the graphics libs ragg/firasans need; blogdown itself is not
#                 in that image, so we add it here.
#   * Hugo     -- the *extended* build at the version pinned in .Rprofile
#                 (options(blogdown.hugo.version = ...)). That pin is the single
#                 source of truth, so there is no second place to bump the version.
#
# Why a script and not a project .yolobox.toml [customize] block:
#   yolobox merges configs by REPLACING each field a project sets (see
#   cmd/yolobox/config.go mergeConfig). The global config sets [customize].dockerfile,
#   so a project dockerfile would clobber the whole R/rig/rv/uv baseline. apt
#   `packages` are unnecessary here because P3M ships binary R packages. That leaves
#   a plain run-once script as the clean way to add blogdown + Hugo.
#
# Idempotent -- safe to re-run. Run once per fresh box (installs persist on the
# box's home volume until `yolobox reset`):
#
#   make sandbox-setup        # or: Rscript R/setup-sandbox.R

message("== blogdown ==")
if (requireNamespace("blogdown", quietly = TRUE)) {
  message("already installed: blogdown ", packageVersion("blogdown"))
} else {
  install.packages("blogdown")  # binary via P3M when configured, source elsewhere
  message("installed: blogdown ", as.character(packageVersion("blogdown")))
}

ver <- getOption("blogdown.hugo.version")
if (is.null(ver) || !nzchar(ver)) {
  stop("blogdown.hugo.version is unset -- run from the repo root so .Rprofile loads.",
       call. = FALSE)
}

message("\n== Hugo (extended) ", ver, " ==")

# Is the *extended* build for this exact version already present? blogdown installs
# to ~/.local/share/Hugo/<version>/hugo on Linux (this script targets the box).
hugo_bin <- Sys.glob(file.path(path.expand("~/.local/share/Hugo"), ver, "hugo"))
already_ok <- length(hugo_bin) == 1L && file.exists(hugo_bin) &&
  any(grepl("extended", system2(hugo_bin, "version", stdout = TRUE), fixed = TRUE))

if (already_ok) {
  message("already installed: ", system2(hugo_bin, "version", stdout = TRUE))
} else {
  # extended = TRUE is REQUIRED on arm64 Linux: blogdown's auto-default only turns
  # extended on for amd64 / macOS, and the non-extended build cannot compile this
  # site's SCSS (assets/scss/jemsu.scss). force = TRUE also replaces a previously
  # installed non-extended build of the same version.
  blogdown::install_hugo(ver, extended = TRUE, force = TRUE)
  message("installed extended Hugo ", ver)
}

message("\nDone. `blogdown::serve_site()` / `blogdown::build_site()` are ready.")
