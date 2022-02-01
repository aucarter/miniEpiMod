calc_nll <- function(x_t, data, par, params) {
  data_states <- unique(data$state)
  nll <- 0
  for(s in data_states) {
    state_data <- data[data$state == s, ]
    date_vec <- seq.Date(
      as.Date(paste0(params$year_start, "-01-01")),
      as.Date(paste0(params$year_start + params$N, "-01-01")),
      length.out = params$N * floor(365 / params$step)
    )
    times <- unique(unlist(lapply(unique(data$time), function(d) {
      which.min(abs(date_vec - d))
    })))
    sim_vals <- x_t[s, times]
    nll <- nll - sum(
      dnorm(
        qnorm(sim_vals),
        mean = qnorm(state_data$mean),
        sd = sqrt(2*pi*exp(qnorm(state_data$mean)^2)*state_data$sd^2), #
        log = T
      )
    )
  }
  # Second-order difference penalty
  sec_order_diff <- diff(diff(par))
  nll <- nll + params$likelihood$smooth_penalty * sum(sec_order_diff**2)

  return(nll)
}

obj_fun <- function(par, params) {
  foi <- foi_fn(par, params$N * floor(365 / params$step))
  x_t <- run_sim(params, foi)
  nll <- calc_nll(x_t, data, par, params)
  return(nll)
}

fit_sim <- function(params, obj_fun, data) {
  fit <- optim(rep(0, params$foi$n_params), obj_fun,
               params = params)$par
  return(fit)
}

run_fit_sim <- function(fit_par, params) {
  fit_foi <- foi_fn(fit_par, params$N * floor(365 / params$step))
  x_t <- run_sim(params, fit_foi)
  return(x_t)
}

