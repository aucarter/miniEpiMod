get_data <- function(config) {
  if (config$data$source == "MAP") {
    data <- get_map_data(config$run)
  }
  return(data)
}
get_map_data <- function(run) {
  map_data <- malariaAtlas::getPR(run$location, species = "Pf")
  map_data <- map_data[!is.na(map_data$pr),]
  map_data <- map_data[!map_data$pr == 0,]
  map_data <- map_data[!map_data$pr == 1,]
  map_data$date_string <- paste0(
    map_data$year_start,
    ifelse(
      nchar(map_data$month_start) == 1,
      paste0("0", map_data$month_start),
      map_data$month_start
    ),
    "01"
  )
  data <- data.frame(
    time = as.Date(map_data$date_string, format = "%Y%m%d"),
    state = "I",
    mean = map_data$pr,
    sd = map_data$pr * (1 - map_data$pr)
  )
  return(data)
}
