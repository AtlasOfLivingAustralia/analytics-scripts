# Script to backup all metrics data to S3

library(paws)
library(jsonlite)

bucket_id <- Sys.getenv("AWS_BUCKET_ID")

# Create an object to interact with S3
s3 <- paws::s3()

backup_data <- function(in_path, out_path) {
  files <- list.files(in_path)
  res <- lapply(files, function(f) {
    body <- file.path(in_path, f)
    key <- file.path(out_path, f)
    s3$put_object(
      Bucket = bucket_id,
      Body = body,
      Key = key
    )
  })
}

# Backup dashboard data
message("Backing up dashboard data... ")
backup_data(in_path = '/data/daily_downloads',
            out_path = 'dashboard_data/')
message("Dashboard data backed up successfully")

# Backup Kibana data
message("Backing up kibana data... ")
backup_data(in_path = '/data/kibana_data/',
            out_path = 'kibana_data/')
message("Kibana data backed up successfully")

# Backup images data
message("Backing up image counts... ")
backup_data(in_path = '/data/daily_image_stats/',
            out_path = 'image_counts/')
message("Image counts backed up successfully")
