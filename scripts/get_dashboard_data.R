library(httr)
library(jsonlite)

# grab the data and store it locally
today <- format(Sys.time(), format="%Y%m%d%H%M")
get <- GET("https://dashboard.ala.org.au/dashboard/data")
content <- fromJSON(content(get,as="text"))
write_json(content,paste0("/data/daily_downloads/",today,".json"))
