library(jsonlite)

image_count <- fromJSON("https://images.ala.org.au/ws/repositoryStatistics")$imageCount

taxa_image_count <- fromJSON("https://biocache.ala.org.au/ws/occurrence/facets?facets=taxon_name&pageSize=0&q=multimedia:Image")$count

sp_image_count <- fromJSON("https://biocache.ala.org.au/ws/occurrence/facets?q=multimedia:Image%20AND%20(rank:species%20OR%20rank:subspecies)&facets=taxon_name&pageSize=0")$count

today <- format(Sys.time(), format="%Y%m%d%H%M")


# Write to a temporary file
tmp <- tempfile()
out_path <- paste0("image_counts/", today, ".json")

write_json(data.frame(image_count = image_count,
                      taxa_image_count = taxa_image_count,
                      species_image_count = sp_image_count), path = tmp)

# Send file to S3
bucket_id <- Sys.getenv("AWS_BUCKET_ID")

# Create an object to interact with S3
s3 <- paws::s3()

s3$put_object(
  Bucket = bucket_id,
  Body = tmp,
  Key = out_path
)