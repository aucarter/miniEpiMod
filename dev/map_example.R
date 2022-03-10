devtools::load_all()

config <- yaml::read_yaml("config.yaml")
processed_config <- process_config(config)

run <- processed_config[["run"]]
params <- processed_config[["params"]]
data <- processed_config[["data"]]

fit <- fit_sim(params, obj_fun, data)
x_t <- run_fit_sim(fit, params)
plot_x_t(x_t, params, run, data)

fit_foi <- foi_fn(fit, params$N * floor(365 / params$step))
plot(fit_foi, type = 'l')
library(lubridate)
data$month <- month(data$time)

data <- data.table(data)
data <- data[, .(pfpr_mean = mean(mean)), by = .(month)]
ggplot(data, aes(x = as.factor(month), y = pfpr_mean)) + geom_bar(stat = "identity")
