# Note: there was a bug with the script until 15/01/21 which meant the date didn't come
# out in the results csv. It would theoretically be possible to reconstruct the dates,
# from the difference between the files.

library(galah)

dr_counts <- ala_counts(group_by = 'dataResourceUid', limit = 10000)
dr_counts$date <- Sys.Date()

# Write to a temporary file
tmp <- tempfile()
out_path <- paste0("data_resource_counts/", Sys.Date(), "_dr_counts.csv")
write.csv(dr_counts,tmp, row.names = FALSE)

# Send file to S3
bucket_id <- Sys.getenv("AWS_BUCKET_ID")

# Create an object to interact with S3
s3 <- paws::s3()

s3$put_object(
  Bucket = bucket_id,
  Body = tmp,
  Key = out_path
)
