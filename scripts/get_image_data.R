library(jsonlite)

image_count <- fromJSON("https://images.ala.org.au/ws/repositoryStatistics")$imageCount

taxa_image_count <- fromJSON("https://biocache.ala.org.au/ws/occurrence/facets?facets=taxon_name&pageSize=0&q=multimedia:Image")$count

sp_image_count <- fromJSON("https://biocache.ala.org.au/ws/occurrence/facets?q=multimedia:Image%20AND%20(rank:species%20OR%20rank:subspecies)&facets=taxon_name&pageSize=0")$count

today <- format(Sys.time(), format="%Y%m%d%H%M")

write_json(data.frame(image_count = image_count,
                      taxa_image_count = taxa_image_count,
                      species_image_count = sp_image_count), path = paste0("/data/daily_image_stats/",today,".json"))
