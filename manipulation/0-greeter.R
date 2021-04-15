rm(list = ls(all.names = TRUE)) # Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\014") # Clear the console

# verify root location
cat("Working directory: ", getwd()) # Must be set to Project Directory
# if the line above DOES NOT generates the project root, re-map by selecting
# Session --> Set Working Directory --> To Project Directory location
# Project Directory should be the root by default unless overwritten

# ---- load-sources ------------------------------------------------------------

source("./scripts/common-functions.R")

# ---- load-packages -----------------------------------------------------------
library(magrittr)  # pipes
library(dplyr)     # data wrangling
library(ggplot2)   # graphs
library(janitor)   # tidy data
library(tidyr)     # data wrangling
library(forcats)   # factors
library(stringr)   # strings
library(lubridate) # dates

# ---- declare-functions -------------------------------------------------------
# custom function for HTML tables
neat <- function(x, output_format = "html"){
  # knitr.table.format = output_format
  if(output_format == "pandoc"){
    x_t <- knitr::kable(x, format = "pandoc")
  }else{
    x_t <- x %>%
      # x %>%
      # neat() %>%
      knitr::kable(format=output_format) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed","responsive"),
        # bootstrap_options = c( "condensed"),
        full_width = F,
        position = "left"
      )
  }
  return(x_t)
}
# Note: when printing to Word or PDF use `neat(output_format =  "pandoc")`


prints_folder <- paste0("./analysis/.../prints/")
if(!file.exists(prints_folder)){
  dir.create(file.path(prints_folder))
}

ggplot2::theme_set(
  ggplot2::theme_bw(
  )+
    theme(
      strip.background = element_rect(fill="grey95", color = NA)
    )
)
quick_save <- function(g,name,...){
  ggplot2::ggsave(
    filename = paste0(name,".jpg"),
    plot     = g,
    device   = "jpg",
    path     = prints_folder,
    # width    = width,
    # height   = height,
    # units = "cm",
    dpi      = 'retina',
    limitsize = FALSE,
    ...
  )
}
# ---- declare-globals ---------------------------------------------------------
path_file <- "./data-public/raw/open-alberta/2021-04/goasharedcssspqpqara_research-strategiesopen-data00-open-data-asset-packages-2021aish-monthlyais.csv"

# ---- load-data ---------------------------------------------------------------
ds_raw <- readr::read_csv(path_file)

# ---- inspect-data ------------------------------------------------------------



# ---- tweak-data --------------------------------------------------------------
ds0 <- ds_raw %>% janitor::clean_names()

ds1 <- ds0 %>%
  mutate()

# ----- measure-type-coverage -------------
# What measures types are available in what months of observation?
d <- ds0 %>%
  distinct(ref_date, measure_type) %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = measure_type
    ,values_from = value
  ) %>%
  mutate(
    across(everything(),~as.character(.x))
    ,across(everything(), ~ replace_na(.x,"."))
    ,across(setdiff(names(.), "ref_date"), ~ str_replace(., "1", "x"))
  )

library(gt)
gt(d)

# ---- factors -------------

ds0 %>% distinct(measure_type)

ds0 %>%
  group_by(
    ref_date
  ) %>%
  summarize(
    measure_count = n_distinct(measure_type)
  ) %>%
  print(n=nrow(.))



# ---- table-1 -----------------------------------------------------------------


# ---- graph-1 -----------------------------------------------------------------


# ---- graph-2 -----------------------------------------------------------------

# ---- save-to-disk ------------------------------------------------------------

# ----- publish ----------------------------------------------------------------
path <- "./analysis/.../report-isolated.Rmd"
rmarkdown::render(
  input = path ,
  output_format=c(
    "html_document"
    # "word_document"
    # "pdf_document"
  ),
  clean=TRUE
)
