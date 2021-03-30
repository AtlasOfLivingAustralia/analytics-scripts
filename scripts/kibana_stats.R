# Download stats on ALA4R/galah usage from kibana every month

library(httr)
library(jsonlite)
library(lubridate)
library(dplyr)
library(data.table)
setwd('/home/ste748/kibanr/R')

sapply(list.files(path = ".", pattern = "*.R"), source)

out_dir <- '/data/kibana_data'

# get data for the last month
# first day of last month
start <- floor_date(Sys.Date() %m-% months(1), 'month')
# last day of last month
end <- ceiling_date(Sys.Date() %m-% months(1), 'month') %m-% days(1)

##### Which version of the package are people using? #####

body <- request_template('/home/ste748/request_template.json') %>%
  add_date_filter(start = start, end = end) %>%
  add_negative_filter(list(
    "httpd.access.geoasn.as_org.keyword" =
      "WU (Wirtschaftsuniversitaet Wien) - Vienna University of Economics and Business"
  )) %>%
  add_travis_filter()  %>%
  add_filter(list("httpd.access.agent.keyword" = c("ALA4R 1.9.0", "ALA4R 1.8.0", "koala 1.0.0", "galah 1.0.0"))) %>%
  add_negative_filter(filter = list("httpd.access.url_params.email.keyword" =
                                    "ala4r@ala.org.au")) %>%
  aggregate_by("httpd.access.agent.keyword")

result <- squash_buckets(request_data(body))

write_result(result, start, file.path(out_dir, paste0('package_versions_', start, '.csv')))

############################################################

##### How many unique users are downloading data with an email, and how many requests
#are they making? #####

body <- request_template('/home/ste748/request_template.json') %>%
  add_date_filter(start = start, end = end) %>%
  add_negative_filter(list(
    "httpd.access.geoasn.as_org.keyword" =
      "WU (Wirtschaftsuniversitaet Wien) - Vienna University of Economics and Business"
  )) %>%
  add_travis_filter()  %>%
  email_exists_filter() %>%
  add_negative_filter(filter = list("httpd.access.url_params.email.keyword" =
                                      "ala4r@ala.org.au")) %>%
  aggregate_by(c("httpd.access.agent.keyword", "httpd.access.url_params.email.keyword"))

result <- squash_buckets(request_data(body))

# Number of requests 
request_df <- result %>% select(doc_count, key2) %>%
  rowwise() %>% mutate(user_agent_class = user_agent_category(key2)) %>%
  group_by(user_agent_class) %>% 
  summarise(request_count = sum(doc_count))

write_result(request_df, start, file.path(out_dir, paste0('requests_by_ua_', start, ".csv")))

# Number of unique users
user_df <- result %>% select(key, key2) %>%
  rowwise() %>% mutate(user_agent_class = user_agent_category(key2)) %>%
  group_by(user_agent_class) %>%
  summarise(unique_users = n_distinct(key))

write_result(user_df, start, file.path(out_dir, paste0('unique_users_by_ua_', start, '.csv')))


########### Which endpoints are R/Python users using ############

# for some reason need to do break this into small chunks
body <- request_template('/home/ste748/request_template.json') %>%
  add_date_filter(start = start, end = end) %>%
  add_negative_filter(list(
    "httpd.access.geoasn.as_org.keyword" =
      "WU (Wirtschaftsuniversitaet Wien) - Vienna University of Economics and Business"
  )) %>%
  add_travis_filter() %>%
  add_negative_filter(filter = list("httpd.access.url_params.email.keyword" =
                                      "ala4r@ala.org.au")) %>%
  aggregate_by(c("httpd.access.agent.keyword", "httpd.access.url_path.keyword"))


result1 <- squash_buckets(
  request_data(body %>% add_filter(
    list("httpd.access.agent.keyword" = c("ALA4R 1.9.0",
                                          "ALA4R 1.8.0",
                                          "koala 1.0.0",
                                          "galah 1.0.0"
                                          )))))
# for now don't include this because it is messy + not sure if we can get any meaningful 
# info from it
#result2 <- squash_buckets(
#  request_data(body %>% add_filter(
#    list("httpd.access.agent.keyword" = "*python*")
#  ))
#)

result3 <- squash_buckets(
  request_data(body %>% add_filter(
    list("httpd.access.agent.keyword" = "*r-curl*")
  ))
)

result <- bind_rows(result1, result3) %>%
  rowwise() %>%
  mutate(path_type = classify_url_paths(key))

write_result(result, start, path = file.path(out_dir, paste0('request_paths_', start, '.csv')))
