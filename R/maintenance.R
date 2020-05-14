# Maintenance: Updating third party assets like littlefoot.js etc.

# Minify custom CSS (probably doesn't matter but might as well)
# system("cd static/css; minify --output jemsu.min.css jemsu.css")

# Third party assets ----
get_asset_unpkg <- function(package, version, file) {
  url <- glue::glue("https://unpkg.com/{package}@v{version}/{file}")
  type <- stringr::str_extract(file, "(css|js)$")
  target_dir <- here::here("static", type)
  dest_file <- glue::glue("{target_dir}/{package}-{version}.{type}")

  # Downloading
  download.file(
    url = url,
    destfile = dest_file
  )

  # Symlinking
  command <- glue::glue(
    "cd {target_dir}
    ln -sf {package}-{version}.{type} {package}.{type}"
  )
  system(command)
}

# littlefoot.js -----
# https://github.com/goblindegook/littlefoot/releases
littlefoot_version <- "3.2.4"

get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.js")
get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.css")

# prism.js ----

# No direct download link for specific config available :(
# Assemble link to desired configuration and download manually

make_prismjs_url <- function(theme = "prism-okaidia", languages, plugins) {
  baseurl <- "https://prismjs.com/download.html"
  languages <- paste0(languages, collapse = "+")
  plugins <- paste0(plugins, collapse = "+")

  glue::glue("{baseurl}#themes={theme}&languages={languages}&plugins={plugins}")
}

primsjs_languages <- c(
  "markup", "css", "clike", "javascript", "bash", "json", "json5", "latex",
  "makefile", "nginx", "regex", "sas", "shell-session", "sql", "toml", "yaml"
)

prismjs_plugins <- c(
  "line-highlight", "line-numbers", "autolinker", "show-language", "toolbar",
  "copy-to-clipboard", "download-button", "match-braces"
)

prism_config_download <- make_prismjs_url("prism-okaidia", primsjs_languages, prismjs_plugins)
browseURL(prism_config_download)

# Copy files to static/css and /static/js
# Minify CSS
system("cd static/css; minify --output prism.min.css prism.css")

# Make chroma style ----

chroma_gen <- function(style = "monokai") {
  cmd <- glue::glue("hugo gen chromastyles --style={style} > static/css/syntax-{style}.css")
  system(cmd)
}

# chroma_gen("api")
# chroma_gen("fruity")
# chroma_gen("monokailight")
