rSubDisc.file <- function(...) system.file(..., package = "rSubDisc")


# General function -------------------------------------------------------------

test_that("Function subgroupdiscovery - single nominal", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")

  testAdult <- subgroupdiscovery(
    src = testdatafile,
    targetColumn = 14,
    targetValue = "gr50K",
    targetType = "SINGLE_NOMINAL",
    qualityMeasure = "CORTANA_QUALITY",
    qualityMeasureMinimum = 0.1,
    searchDepth = 1,
    minimumCoverage = 2,
    maximumCoverageFraction = 1.0,
    maximumSubgroups = 1000,
    maximumTime = 1000,
    searchStrategy = "BEAM",
    nominalSets = FALSE,
    numericOperatorSetting = "NORMAL",
    numericStrategy = "NUMERIC_BEST",
    searchStrategyWidth = 10,
    nrBins = 8,
    nrThreads = 1
  )

  expect_equal(testAdult, testdata_single_nominal)
})


# Simple functions -------------------------------------------------------------

test_that("Test single nominal", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  testAdult <- .subdisc.single_nominal.cortana_quality(
    src = testdatafile,
    targetColumn = 14,
    targetValue = "gr50K"
  )

  expect_equal(testAdult, testdata_single_nominal)
})


test_that("Test single numeric", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  testAdult <- .subdisc.single_numeric.explained_variance(
    src = testdatafile,
    targetColumn = 0,
  )

  expect_equal(testAdult, testdata_single_numeric)
})


# Column target input tests ----------------------------------------------------

test_that("Using column name", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  testAdult <- .subdisc.single_nominal.cortana_quality(
    src = testdatafile,
    targetColumn = "target",
    targetValue = "gr50K"
  )

  expect_equal(testAdult, testdata_single_nominal)
})

test_that("Wrong columnTarget type", {
  testdatafile = rSubDisc.file("extdata", "adult.txt")
  expect_error(.subdisc.single_nominal.cortana_quality(
    src = testdatafile,
    targetColumn = c(10, 10),
    targetValue = "gr50K"
  ), "targetColumn must be an integer or a string")

})


# Using dataframe/tibble

#test_that("Using dataframe", {
#  testdatafile = rSubDisc.file("extdata", "adult.txt")
#  dataframe = read.csv(testdatafile)
#  testAdult <- .subdisc.single_nominal.cortana_quality(
#    src = dataframe,
#    targetColumn = "target",
#    targetValue = "gr50K"
#  )
#
#  expect_equal(testAdult, testdata_single_nominal)
#})

#test_that("Using tibble", {
#  testdatafile = rSubDisc.file("extdata", "adult.txt")
#  tibble = tibble::tibble(read.csv(testdatafile))
#  testAdult <- .subdisc.single_nominal.cortana_quality(
#    src = tibble,
#    targetColumn = "target",
#    targetValue = "gr50K"
#  )
#
#  expect_equal(testAdult, testdata_single_nominal)
#})
