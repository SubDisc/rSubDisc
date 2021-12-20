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

  expect_equal(testdata_single_nominal, testAdult)
})

# Simple functions -------------------------------------------------------------

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
