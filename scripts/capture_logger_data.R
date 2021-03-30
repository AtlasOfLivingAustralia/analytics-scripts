# Capture data from logger on the last day of each month
# Run on 1st of every month

library(jsonlite)
library(lubridate)
library(dplyr)
library(tibble)

date <- format(Sys.Date(), "%d-%m-%y")

events <- c("1000", "1001", "1002", "1003", "2000")

resp <- fromJSON("https://logger.ala.org.au/service/totalsByType",)

#old_data <- as_tibble(read.csv('/data/logger_data/logger_data.csv')) %>%
#  mutate(event_type = as.character(event_type))

rows <- bind_rows(lapply(events, function(x) {
  counts <- resp$totals[[x]]
  tibble(date = format(Sys.Date(), "%Y-%m"), count = c(counts$events, counts$records),
         count_type = c("event", "record"), event_type = as.character(x))
}))

if (!file.exists('/data/logger_data/logger_data.csv')) {
  new_data <- rows
} else {
  old_data <- as_tibble(read.csv('/data/logger_data/logger_data.csv')) %>%
    mutate(event_type = as.character(event_type))
  new_data <- bind_rows(old_data, rows)
}

write.csv(new_data, '/data/logger_data/logger_data.csv', row.names = FALSE)
