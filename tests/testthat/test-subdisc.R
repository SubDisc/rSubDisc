rSubDisc.file <- function(...) system.file(..., package = "rSubDisc")

test_that("Test single nominal", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  testAdult <- .subdisc.single_nominal.cortana_quality(
    src = testdatafile,
    targetColumn = 14,
    targetValue = "gr50K"
  )

  expect_equal(testdata_single_nominal, testAdult)
})

test_that("Test single numeric", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  testAdult <- .subdisc.single_numeric.explained_variance(
    src = testdatafile,
    targetColumn = 0,
  )

  expect_equal(testdata_single_numeric, testAdult)
})
