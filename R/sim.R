make_tpm <- function(transitions, foi = NULL) {
  if (!is.null(foi)) {
    transitions <- rbind(
      c("S", "I", as.numeric(foi)),
      transitions
    )
  }
  transitions$prob <- as.numeric(transitions$prob)
  states <- unique(c(transitions$from, transitions$to))
  tpm <- matrix(0, nrow = length(states), ncol = length(states))
  # Add all transitions
  for(i in seq(nrow(transitions))) {
    from_idx <- which(states == transitions[i,"from"])
    to_idx <- which(states == transitions[i,"to"])
    tpm[to_idx, from_idx] <- transitions[i, "prob"]
  }
  # Populate remain prob
  for(i in seq(length(states))) {
    tpm[i, i] <- 1 - sum(tpm[, i])
  }
  colnames(tpm) <- states
  rownames(tpm) <- states
  return(tpm)
}

make_x0 <- function(tpm, eq_x0 = T) {
  if (eq_x0) {
    x0 <- Re(eigen(tpm)$vectors[, 1]) / sum(Re(eigen(tpm)$vectors[, 1]))
  } else {
    s_idx <- which(rownames(tpm) == "S")
    i_idx <- which(rownames(tpm) == "I")
    x0 <- rep(0, nrow(tpm))
    x0[s_idx] <- 0.99
    x0[i_idx] <- 0.01
  }
  return(x0)
}

run_sim <- function(params, foi = NULL) {
  if (is.null(foi)) {
    tpm <- make_tpm(params$transitions)
  } else {
    tpm <- make_tpm(params$transitions, foi[1])
  }
  steps <- params$N * floor(365 / params$step)
  x0 <- make_x0(tpm, params$eq_x0)
  x_t <- matrix(nrow = nrow(tpm), ncol = steps)
  x_t[, 1] <- x <- x0
  for(i in 2:steps) {
    if (is.null(foi)) {
      tpm <- make_tpm(params$transitions)
    } else {
      tpm <- make_tpm(params$transitions, foi[i])
    }
    x <- tpm %*% x
    x_t[, i] <- x
  }
  rownames(x_t) <- rownames(tpm)
  colnames(x_t) <-
  return(x_t)
}

sim_forward <- function(x, tpm, N) {
  x_out <- matrix(nrow = length(x), ncol = N)
  x_out[, 1] <- x
  for (i in 2:N) {
    x_out[, i] <- as.vector(tpm %*% x_out[, i - 1])
  }
  return (x_out)
}
