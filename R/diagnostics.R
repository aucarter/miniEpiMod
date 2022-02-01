plot_x_t <- function(x_t, params, run = NULL, data = NULL) {
  date_vec <- seq.Date(
    as.Date(paste0(params$year_start, "-01-01")),
    as.Date(paste0(params$year_start + params$N, "-01-01")),
    length.out = params$N * floor(365 / params$step)
  )
  matplot(date_vec, t(x_t), type = "l", lty = 1, ylim = 0:1,
          main = run$location, xlab = "", ylab = "")
  legend("topright", rownames(x_t), col=seq_len(nrow(x_t)),
         cex=0.8,fill=seq_len(nrow(x_t)))
  if(!is.null(data)) {
    points(data$time, data$mean, pch = 19, col = palette()[2], cex = 1 / data$sd / 40)
    # arrows(
    #   x0 = data$time, y0 = data$mean - 1.96*data$sd,
    #   x1 = data$time, y1 = data$mean + 1.96*data$sd,
    #   code = 3, angle = 90, length = 0.1,
    #   col = palette()[which(rownames(x_t) == "I")]
    # )
  }
}
