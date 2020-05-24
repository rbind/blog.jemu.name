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

# Make chroma style ----

chroma_gen <- function(style = "monokai") {
  cmd <- glue::glue("hugo gen chromastyles --style={style} > static/css/syntax-{style}.css")
  system(cmd)
}

# Currently used styles are tweaked and refactord to SCSS in /assets/scss/
# chroma_gen("monokai")
# chroma_gen("monokailight")

# Generate package.yaml ----

gen_package_yaml <- function() {
  require(stringr)
  require(dplyr)
  # packages data file ----
  packages <- rownames(installed.packages())

  packages_cran <- available.packages() %>%
    as_tibble() %>%
    transmute(
      package = Package,
      url_cran = glue::glue("https://CRAN.R-project.org/package={package}")
    )


  package_tbl <- purrr::map_dfr(packages, ~{

    description <- desc::desc(package = .x)

    tibble::tibble(
      package = .x,
      title = description$get("Title") %>% as.character(),
      #description = description$get("Description") %>% as.character(),
      urls = description$get_urls(),
      version = description$get_version() %>% as.character(),
      maintainer = description$get_maintainer()
    )

  })

  package_tbl %>%
    mutate(
      name = package,
      maintainer = str_remove_all(maintainer, "\\s*<.*>"),
      urlkind = case_when(
        str_detect(urls, "(github\\.com|gitlab\\.com|bitbucket|[Rr](-)?[Ff]orge|svn\\.r-project)") ~ "git",
        str_detect(urls, "(CRAN|cran|r-project)") ~ "cran",
        str_detect(urls, "(tidyverse|r-lib|tidymodels|github\\.io)\\.org") ~ "pkgdown",
        TRUE ~ "other"
      )
    ) %>%
    filter(urlkind != "cran") %>%
    tidyr::pivot_wider(
      names_from = "urlkind", names_prefix = "url_",
      values_from = "urls", values_fn = first, values_fill = ""
    ) %>%
    left_join(packages_cran, by = "package") %>%
    mutate(url_cran = ifelse(is.na(url_cran), "", url_cran)) %>%
    ungroup() %>%
    nest_by(package) -> pkgslist

  x <- purrr::map(pkgslist$data, unclass)
  names(x) <- pkgslist$package

  yaml::write_yaml(x, here::here("data/packages.yml"))
}

gen_package_yaml()
