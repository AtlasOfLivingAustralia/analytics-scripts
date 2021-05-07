# Capture data from logger on the last day of each month
# Run on 1st of every month

library(jsonlite)
library(lubridate)
library(dplyr)
library(tibble)
library(paws)

date <- format(Sys.Date(), "%d-%m-%y")


events <- c("1000", "1001", "1002", "1003", "2000")

resp <- fromJSON("https://logger.ala.org.au/service/totalsByType",)

rows <- bind_rows(lapply(events, function(x) {
  counts <- resp$totals[[x]]
  tibble(date = format(Sys.Date(), "%Y-%m"), count = c(counts$events, counts$records),
         count_type = c("event", "record"), event_type = as.character(x))
}))

path <- file.path('/data/logger_data',
                  paste0('logger_data_', Sys.Date(), '.csv'))

write.csv(new_data, path, row.names = FALSE)

bucket_id <- Sys.getenv("AWS_BUCKET_ID")

# Create an object to interact with S3
s3 <- paws::s3()

s3$put_object(
  Bucket = bucket_id,
  Body = '/data/logger_data',
  Key = paste0('logger_data_', Sys.Date(), '.csv')
)
