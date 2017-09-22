library(httr)
library(tidyverse)

url <- "https://community.rstudio.com/directory_items.json?period=weekly&order=likes_received"

req <- httr::GET(url)
stop_for_status(req)
con <- httr::content(req)

users_raw <- con$directory_items

users <- tibble(
  name = users_raw %>% map_chr(c("user", "username")),
  likes = users_raw %>% map_int("likes_received"),
  title = users_raw %>% map_chr(c("user", "title"), .default = NA)
)

users %>%
  filter(is.na(title)) %>%
  select(-title) %>%
  sample_n(5, weight = likes)
