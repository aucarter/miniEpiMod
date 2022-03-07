devtools::load_all()

config <- yaml::read_yaml("config.yaml")
processed_config <- process_config(config)

run <- processed_config[["run"]]
params <- processed_config[["params"]]
map_data <- processed_config[["data"]]


## Sample MAP data
# n_data <- 100
# map_data2 <- map_data[sample(nrow(map_data), n_data),]
map_data2 <- data

## TMB fit
dyn.load(TMB::dynlib("src/TMB/miniEpiMod_TMBExports"))
full_time <- seq(min(map_data2$time), max(map_data2$time), by = "month")
n_knots <- 7
data <- list()
data$time_steps <- length(full_time)
data$data_idx <- match(map_data2$time, full_time)
data$data_mean <- map_data2$mean
data$data_sd <- map_data2$sd

data$second_order_diff_penalty <- 5.0
data$rt_design <- splines::splineDesign(
  knots = seq(
    -3 * data$time_steps / (n_knots - 3), 
    data$time_steps + 3 * data$time_steps / (n_knots - 3), 
    data$time_steps / (n_knots - 3)
  ),
  x = seq(data$time_steps)
)
data$tpm_base <- matrix(c(
  0.95, 0.2, 0.5,
  0.05, 0.75, 0,
  0, 0.05, 0.5
), byrow = T, nrow = 3)
data$model <- "miniEpiMod_tmb"

parameters <- list(log_rt = rep(log(1), n_knots))

obj <- TMB::MakeADFun(data, parameters, DLL = "miniEpiMod_TMBExports")

fit <- nlminb(obj$par, obj$fn, obj$gr)


rt <- data$rt_design %*% exp(fit$par)
x_out <- simForwardR(rt, data$time_steps, data$tpm_base)$x_out

par(mfrow = c(2, 1))
matplot(full_time, sweep(data$rt_design, 2, exp(fit$par), "*"), type = 'l', 
        ylim = c(0, max(rt)), xlab = '', ylab = '')
lines(full_time, rt, type = 'l')
matplot(full_time, t(x_out), type = 'l', ylim = 0:1)
points(full_time[data$data_id], data$data_mean, pch = 19, cex = 0.1 * 1 / data$data_sd)

