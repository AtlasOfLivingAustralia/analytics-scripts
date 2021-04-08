library(httr)
library(jsonlite)
library(paws)

# grab the data and store it locally
today <- format(Sys.time(), format="%Y%m%d%H%M")
get <- GET("https://dashboard.ala.org.au/dashboard/data")
content <- fromJSON(content(get,as="text"))

# Write to a temporary file
tmp <- tempfile()
out_path <- paste0("dashboard_data/", today, ".json")
write_json(content,tmp)

# Send file to S3
bucket_id <- Sys.getenv("AWS_BUCKET_ID")

# Create an object to interact with S3
s3 <- paws::s3()

s3$put_object(
  Bucket = bucket_id,
  Body = tmp,
  Key = out_path
)
