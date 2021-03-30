library(googleAuthR)
library(googleAnalyticsR)
library(lubridate)


gar_auth(email ="analytics@ala.org.au")

end_date <- Sys.Date() - days(day(Sys.Date()))
# 1 month ago
start_date <- floor_date(Sys.Date() %m-% months(3), 'month')
#
start_month <- month.abb[month(start_date)]
end_month <- month.abb[month(end_date)]

total_users <- google_analytics(Sys.getenv("GAR_VIEW_ID"),
                   date_range = c(start_date, end_date),
                   metrics = "users")

paste0("total users ", total_users)
write.csv(data.frame(total_users = total_users, start_month = start_month, end_month = end_month), '/data/google_analytics/ga_data.csv')
