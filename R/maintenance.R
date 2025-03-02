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
littlefoot_version <- "4.1.2"

get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.js")
get_asset_unpkg("littlefoot", littlefoot_version, "dist/littlefoot.css")

# Make chroma style ----

chroma_gen <- function(style = "monokai") {
  cmd <- glue::glue(
    "hugo gen chromastyles --style={style} > static/css/syntax-{style}.css"
  )
  system(cmd)
}

# Currently used styles are tweaked and refactored to SCSS in /assets/scss/
# chroma_gen("monokai")
# chroma_gen("monokailight")
