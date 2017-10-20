library(httr)
library(magrittr)

#http://memecaptain.com/gend_images/new?src=tWljmg
image_id <- "tWljmg"

body <- list(
  src_image_id = image_id,
  private = 'false',
  captions_attributes = list(
    list(
      text = "WHAT????",
      top_left_x_pct = 0.05,
      top_left_y_pct = 0,
      width_pct = 0.9,
      height_pct = 0.20
    ),
    list(
      text = "MORE R HEXSTICkERS!",
      top_left_x_pct = 0.05,
      top_left_y_pct = 0.75,
      width_pct = 0.9,
      height_pct = 0.25
    )
  )
)

res <- httr::POST("https://memecaptain.com/api/v3/gend_images.json", body = body, encode = "json")
parsed <- jsonlite::fromJSON(content(res, 'text'), simplifyVector = FALSE)

# grab status url and parse that
new_img <- httr::GET(parsed$status_url) %>%
  jsonlite::fromJSON(txt = content(x = ., 'text'), simplifyVector = FALSE) %>%
  .[["url"]]
