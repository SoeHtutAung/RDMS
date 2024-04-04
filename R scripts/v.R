## v #####
# data preparation
# get data from source
endpoint <- paste("https://api.coronavirus.data.gov.uk/v2/data?areaType=nation&areaCode=E92000001&metric=newAdmissions&metric=newCasesByPublishDate&release=2021-03-31&format=csv")
webdata <- read.csv(endpoint)

# Convert the 'date' column to a Date object
webdata$date <- as.Date(webdata$date)
# Filter data for the most recent month
recent_month_data <- webdata %>%
  filter(format(date, "%Y-%m") == format(max(date), "%Y-%m"))


### end of v #####