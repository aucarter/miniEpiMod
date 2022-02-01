#' Testing if the cpp code is producing any NAs
test_that("cpp code works", {
  j <- 378
  N <- 36 * 45
  x <- runif(j)
  tpm <- matrix(runif(j^2), nrow = j)
  test <- simForward(x, tpm, N)
  expect_true(!any(is.na(test)))
})
