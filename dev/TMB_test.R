devtools::load_all()
dyn.load(TMB::dynlib("src/TMB/miniEpiMod_TMBExports"))
# set.seed(7)

n_rt_params <- 10
data <- list()
data$model <- "miniEpiMod_tmb"
data$time_steps <- 36*50

n <- 500
data$data_idx <- sample(seq(1:(data$time_steps - 200)), n, replace = T)
data$data_mean <- runif(n, 0, 0.5) * seq(1, 2, length.out = data$time_steps)[data$data_idx]
data$data_sd <- runif(n, 0.05, 0.2)
data$second_order_diff_penalty <- 0

# Set up  TPM base
state_space_size <- 100
m1 <- diag(rep(0.95, state_space_size))
m2 <- diag(rep(0.05, state_space_size - 1))
m1[2:state_space_size, 1:(state_space_size - 1)] <- m1[2:state_space_size, 1:(state_space_size - 1)] + m2
m1[state_space_size, state_space_size] <- 1
m3 <- matrix(
    c(1.0, 0.3, 0.5,
    0.0, 0.65, 0.0,
    0.0, 0.05, 0.499),
    nrow = 3, byrow = T
)
m1[1:3, 1:3] <- m3
m1[4, 3] <- 0.001
data$tpm_base <- m1

step <- data$time_steps/ (n_rt_params - 3)
knots <- seq(0 - 3 * step, data$time_steps + 3 * step, step)
x <- seq(1, data$time_steps)
data$rt_design <- splines::splineDesign(knots = knots, x = x, outer.ok = TRUE)


par <- list(log_rt = rep(log(0.5), n_rt_params))

message("Preparing TMB model object...")
obj <- TMB::MakeADFun(data = data,
                      parameters = par,
                      DLL = "miniEpiMod_TMBExports")

f <- stats::nlminb(obj$par, obj$fn, obj$gr)
rt <- data$rt_design %*% exp(f$par)
# rt <- c(rep(0.1, 5), rep(0.9, 5))
x_out <- simForwardR(rt, data$time_steps, data$tpm_base)$x_out
par(mfrow = c(2, 1))
matplot(sweep(data$rt_design, 2, exp(f$par), "*"), type = 'l', 
    ylim = c(0, max(rt)), ylab = "", main = "Transmission rate")
lines(rt, type = "l")
matplot(t(x_out[c(2, 1, 3),]), type = "l", ylim = c(0, 1), ylab = "", main = "Prevalence")
points(data$data_idx, data$data_mean, pch = 19, cex = 0.2)

