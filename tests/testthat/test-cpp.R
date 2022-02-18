#' Testing if the cpp code is producing any NAs and is the same as R code
test_that("cpp code works", {
  j <- 1e3
  N <- 1e4
  x <- c(1, rep(0, j - 1))
  tpm <- Matrix::bandSparse(j, j, 0:-1, diag = list(rep(999 / 1000, j), rep(1/ 1000, j - 1)))
  tpm[j, j] <- 1
  tpm <- as(tpm, "dgCMatrix")
  test <- simForwardR(x, tpm, N)
  expect_true(!any(is.na(test)))

  test2 <- sim_forward(x, tpm, N)
  testthat::expect_equal(test, test2)

  # microbenchmark::microbenchmark(simForwardR(x, tpm, N), sim_forward(x, tpm, N))
})
