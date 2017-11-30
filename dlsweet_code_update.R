library(httr)
library(dplyr)
library(purrr)

url_users <- function(page = 0, domain = "https://community.rstudio.com"){
  paste(
    domain,
    
    "/directory_items.json?",
    "&period=all&order=likes_received",
    "&page=",
    page,
    sep = ""
  )
}


url <- url_users()

req <- httr::GET(url)
stop_for_status(req)
con <- httr::content(req)

users <- data.frame() %>% tbl_df
user_cnt = 0
page = 0

while (length(con$directory_items) > 0){
  
  users_raw <- con$directory_items
  
  users = bind_rows(
    users,
    tibble(
      id = users_raw %>% map_int(c("user", "id")),
      name = users_raw %>% map_chr(c("user", "username")),
      likes = users_raw %>% map_int("likes_received"),
      title = users_raw %>% map_chr(c("user", "title"), .default = NA),
      time_read = users_raw %>% map_chr(c("time_read"), .default = NA),
      likes_given = users_raw %>% map_int(c("likes_given"), .default = NA),
      topics_entered = users_raw %>% map_int(c("topics_entered"), .default = NA),
      post_count = users_raw %>% map_int(c("post_count"), .default = NA),
      days_visited = users_raw %>% map_int(c("days_visited"), .default = NA)
    )
  )
  
  
  
  page = page + 1
  req <- httr::GET(url_users(page))
  stop_for_status(req)
  con <- httr::content(req)
  
  user_cnt = users %>% nrow
  print(paste(
    "Page:", page, 
    "- users:", user_cnt
  ))
}

users = users %>%
  distinct(name, .keep_all = TRUE) %>%
  mutate(
    DateTime = Sys.time()
  ) %>%
  filter(likes > 5)

winners <- c(
  "mara", "alistaire", "daattali", "emilyriederer", "eric_bickel", "nick", "jessemaegan", "raybuhr", "billr", "mmuurr", "apreshill", "pavopax", "mfherman","rensa", "tomtec", "pssguy", "cdr6934", "rpodcast", "Andrea", "timpe", "cderv", "PirateGrunt", "mungojam", "rkahne", "DaveRGP", "danr", "jim89", "nakamichi", "Ranae", "jasonserviss", "FlorianGD", "Damian", "jtr13", "RStudioUser", "robertmitchellv" 
)

users %>%
  filter(is.na(title), !name %in% winners) %>%
  select(-title) %>%
  sample_n(10, weight = likes) %>%
  arrange(desc(likes))
