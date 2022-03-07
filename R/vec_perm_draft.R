library(Matrix)
state_order <- c(stage = 5, age = 4, location = 10)
gen_state <- function(state_order) {
  state_array <- array(1:prod(state_order), dim = state_order)
  state <- as.vector(state_array)
  return(state)
}

state_index <- list(location = 1, age = 2:3)


get_state_vals <- function(state_index, state_order, state) {
  if (length(setdiff(names(state_index), names(state_order))) > 0) {
    stop("Dimensions not in state!")
  }
  # Fill in all values for missing indices
  missing_dims <- setdiff(names(state_order), names(state_index))
  missing_indices <- lapply(missing_dims, function(dim) 1:state_order[dim])
  names(missing_indices) <- missing_dims
  state_index <- c(state_index, missing_indices)
  state_index <- state_index[names(state_order)]
  state_vec_idx <- state_index[[1]]
  if (length(state_index) > 1) {
    for(i in 2:length(state_index)) {
      state_vec_idx <- c(outer(state_index[[i]], state_vec_idx))
    }
  }
  array_dim <- unlist(lapply(state_index, length))
  state_array <- array(state[state_vec_idx], dim = array_dim)
  dimnames(state_array) <- state_index
  return(state_array)
}


get_state_vals(state_index, state_order, state)
