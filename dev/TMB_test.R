devtools::load_all()
dyn.load(TMB::dynlib("src/TMB/miniEpiMod_TMBExports"))

n_data_points <- 20
n_knots <- 7
data <- list()
data$time_steps <- 500
data$data_idx <- sample(seq(data$time_steps - 100), n_data_points)
data$data_mean <- runif(n_data_points) * 0.5 * seq(1, 2, length.out = data$time_steps)[data$data_idx]
data$data_sd <- rep(0.01, n_data_points)

data$second_order_diff_penalty <- 0.0
data$foi_design <- splines::splineDesign(
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

parameters <- list(probit_foi = rep(qnorm(0.5), n_knots))

obj <- TMB::MakeADFun(data, parameters, DLL = "miniEpiMod_TMBExports")

fit <- nlminb(obj$par, obj$fn, obj$gr)


foi <- data$foi_design %*% pnorm(fit$par)
x_out <- simForwardR(foi, data$time_steps, data$tpm_base)$x_out

par(mfrow = c(2, 1))
plot(foi, type = 'l', ylim = c(0, max(foi)), xlab = '')
matplot(t(x_out), type = 'l', ylim = 0:1)
points(data$data_id, data$data_mean, pch = 19, cex = 0.5)

