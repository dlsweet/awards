pacman::p_load(tidyverse)

buildTibble <- function(users_raw) {
  tibble(
    id = users_raw %>% map_chr('id'),
    # id = users_raw %>% map_chr(c("user", 'id')),
    username = users_raw %>% map_chr(c("user", "username")),
    name = users_raw %>% map_chr(c("user", "name"), .default = NA),
    likes = users_raw %>% map_int("likes_received"),
    likes_given = users_raw %>% map_int("likes_given"),
    topics_entered = users_raw %>% map_int("topics_entered"),
    topic_count = users_raw %>% map_int('topic_count'), 
    posts_read = users_raw %>% map_int('posts_read'),
    days_visited = users_raw %>% map_int('days_visited'),
    title = users_raw %>% map_chr(c("user", "title"), .default = NA),
    avatar_template = users_raw %>% map_chr(c('user', 'avatar_template'))
  )
  }
  
# let's figure out the number of pages to parse. 
base_url <- 'https://community.rstudio.com'
page_path <- '/directory_items.json?period=weekly&order=posts_read&page=1'
url <- paste0(base_url, page_path)
req <- httr::GET(url)
stop_for_status(req)
con <- httr::content(req)
pages <- seq(0, con$total_rows_directory_items %/% 50)  

# first page is zero, caught me starting at 1 on the first go round.
users <- map(pages, function(i) {
    Sys.sleep(3)  
# I'll pretend like I'm playing nice with the servers, at least in public ;)
    cat(i, '\n')
    base_url <- 'https://community.rstudio.com'
    page_path <- paste0('/directory_items.json?period=weekly&order=posts_read&page=', i)
    url <- paste0(base_url, page_path)
    req <- httr::GET(url)
    stop_for_status(req)
    con <- httr::content(req)
    users_raw <- con$directory_items
    buildTibble(users_raw)
  })
  
  users <- plyr::ldply(users) %>% 
    tbl_df()
  
#Let’s give a big round of applause to folks dropping in eight days a week!
users %>% filter(days_visited == 8) %>% pull(username) %>% sort()

#How active are RStudio employees in the community?
users %>% filter(grepl('rstud', tolower(title))) %>% mutate(id = as.numeric(id)) %>% arrange(id)

