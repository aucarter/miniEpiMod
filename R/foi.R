inv_logit <- function(x) {
  y <- exp(x) / (1 + exp(x))
  y[is.nan(y)] <- 1 # Unstable at high values
  return(y)
}

foi_fn <- function(par, N)  {
  if (length(par) == 1) {
    probit_foi <- rep(par, N)
  } else if (length(par) == 2) {
    probit_foi <- par[1] + par[2] * (1:N - 1)
  } else {
    step <- N / (length(par) - 1)
    knots <- seq(0 - 2 *step, N + 2 *step, step)
    x <- seq(1, N)
    bb <- splines::splineDesign(knots = knots, x = x, outer.ok = TRUE)
    probit_foi <- rowSums(sweep(bb, 2, par, "*"))
  }
  foi <- pnorm(probit_foi)
  return(foi)
}
