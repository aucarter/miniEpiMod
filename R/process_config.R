process_config <- function(config) {
  run <- config$run
  params <- config$params
  data <- get_data(config)
  for (i in seq(length(params))) {
    if("path" %in% names(params[[i]])) {
      params[[i]] <- read.csv(params[[i]]$path, header = T)
    }
  }
  return(list(
    run = run,
    params = params,
    data = data
  ))
}