TMB::compile("src/TMB/miniEpiMod_TMBExports.cpp")
dyn.load(TMB::dynlib("src/TMB/miniEpiMod_TMBExports"))

data <- list()
data$model <- "miniEpiMod_tmb"
data$N <- 1000
n <- 100
data$data_mean <- runif(n, 0, 0.5)
data$data_sd <- runif(n, 0.05, 0.2)
data$data_idx <- sample(seq(1:data$N), n, replace = T)

par <- list(log_foi = 0)

obj <- TMB::MakeADFun(data = data,
                      parameters = par,
                      DLL = "miniEpiMod_TMBExports")

f <- stats::nlminb(obj$par, obj$fn, obj$gr)
foi <- exp(f$par)
# foi <- 0.1
x_out <- simForwardR(foi, data$N)$x_out
matplot(t(x_out), type = 'l')
points(data$data_idx, data$data_mean, pch = 19)
exp(f$par)
