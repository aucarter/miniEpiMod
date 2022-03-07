library(sf)

# Pull in Uganda shapefile and simplify
shape <- st_read("~/Downloads/gadm40_UGA_shp/gadm40_UGA_1.shp")
shape <- st_simplify(shape, preserveTopology = T, dTolerance = 1000)
plot(shape$geometry)

# Read in MAP data and fill DHS coordinates
map_data <- malariaAtlas::getPR("Uganda", species = "Pf")
map_data <- malariaAtlas::fillDHSCoordinates(map_data, email = "aucarter@uw.edu", project = "Burden of HIV")
map_data_sf <- st_as_sf(map_data, coords = c("longitude", "latitude"), crs = st_crs(shape))

plot(shape$geometry)
plot(map_data_sf$geometry, pch = 19, cex = 0.1, add = T)


# Connect MAP data with the shapefile
join_dt <- st_join(map_data_sf, shape)
tororo_dt <- join_dt[join_dt$NAME_1 == "Tororo", ]

map_data <- tororo_dt
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
