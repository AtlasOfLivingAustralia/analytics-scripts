# Note: there was a bug with the script until 15/01/21 which meant the date didn't come
# out in the results csv. It would theoretically be possible to reconstruct the dates,
# from the difference between the files.

library(galah)

dr_counts <- ala_counts(group_by = 'data_resource_uid', limit = 10000)
dr_counts$date <- Sys.Date()

file <- paste0(as.character(Sys.Date()), "_dr_counts.csv")

write.csv(dr_counts, file.path('/data/data_resource_counts', file),
                                row.names = FALSE)
