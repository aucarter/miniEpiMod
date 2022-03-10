library(malariaAtlas); library(data.table); library(lubridate); library(ggplot2)
# Pull data 
map_data <- getPR("Uganda", species = "Pf")
# map_data <- fillDHSCoordinates(map_data, email = "aucarter@uw.edu", project = "Burden of HIV")
map_data <- as.data.table(map_data)

# Plot data
ggplot(data = map_data[!is.na(pr)], aes(x = month_start, xend = month_end, y = pr, yend = pr)) + 
  geom_segment(aes(color = year_start)) + theme_bw() +
  ylab("Mean PfPR") + scale_color_viridis(direction = -1) +
  scale_x_discrete("Month", labels = month.abb, limits = month.abb) +
  ggtitle("Observed PfPR by Month in Uganda")

# Distribute positives and examines across the time period
map_data[, n_month := month_end - month_start + 1 + 12 * (year_end - year_start)]
map_data[, examined := examined / n_month]
map_data[, positive := positive / n_month]
map_data <- map_data[!is.na(pr)]
month_dt <- rbindlist(lapply(1:nrow(map_data), function(i) {
  months <- map_data[i,]$month_start:(map_data[i,]$month_start + map_data[i,]$n_month - 1) %% 12
  data.table(month = months, positive = map_data[i,]$positive / map_data[i,]$n_month,
             examined = map_data[i,]$examined / map_data[i,]$n_month)
}))

# Calculate monthly proportions
month_prop <- month_dt[order(month), lapply(.SD, sum), by = month, .SDcols = c("examined", "positive")]
month_prop[, pr := positive / examined]
month_prop[, upper := pr + 1.96 * sqrt(pr * (1 - pr) / examined)]
month_prop[, lower := pr - 1.96 * sqrt(pr * (1 - pr) / examined)]
month_prop[, pr_prop := pr / sum(pr)]

# Fit von Mises
vm_trans <- function(x) {
  y <- (x - 6) * 2 * pi / 12
  return(y)
}
vm_mix <- function(t, par) {
  p <- 1 - plogis(par[1]) / 2
  m1 <- plogis(par[2]) * 12
  k1 <- exp(par[3]) + 0.5
  m2 <- m1 + plogis(par[4]) * 6
  k2 <- exp(par[5])
  (p/(2*pi*besselI(k1, 0))*exp(k1*cos(vm_trans(t)-vm_trans(m1))) + (1-p)/(2*pi*besselI(k2, 0))*exp(k2*cos(vm_trans(t)-vm_trans(m2)))) * 2 * pi / 12
}
obj_fun <- function(par, t, data, n)  {
  val <- vm_mix(t, par)
  obj <- sum((val - data)^2 * n)
}
t <- 0:11
par_init <- c(0, 0, 0, 0, 0)
fit <- optim(par_init, obj_fun, t = t, data = month_prop$pr_prop, n = month_prop$examined)

# Plot fit
t <- seq(0, 12, 0.1)
plot(month_prop$month, month_prop$pr_prop, pch = 19, 
     cex = 4 * month_prop$examined / max(month_prop$examined), 
     ylim = c(0, max(month_prop$pr_prop) + 0.1), xlab = "Month", ylab = "PfPR Proportion")
lines(t, vm_mix(t, fit$par), type = 'l', col = 'red')

y <- vm_mix(t, fit$par)
plot(y / y[1], type = 'l')
