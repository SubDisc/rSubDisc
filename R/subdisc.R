# Factory function to load Java enum
.jnewEnum <- function(enumclass){
  function(name){.jfield(enumclass, paste("L", enumclass, ";", sep=""), name)}
}



# General function to call a search --------------------------------------------


#' Search a dataset for subgroup
#'
#' @param src The file to load
#' @param targetColumn The column number to use as the target
#' @param targetValue
#' @param targetType
#' @param qualityMeasure
#' @param qualityMeasureMinimum
#' @param searchDepth
#' @param minimumCoverage
#' @param maximumCoverageFraction
#' @param minimumSupport
#' @param maximumSubgroups
#' @param filterSubgroups
#' @param minimumImprovement
#' @param maximumTime
#' @param searchStrategy
#' @param nominalSets
#' @param numericOperatorSetting
#' @param numericStrategy
#' @param searchStrategyWidth
#' @param nrBins
#' @param nrThreads
#'
#' @return
#' @export
#'
#' @examples
subgroupdiscovery <- function(
  src,
  targetColumn,
  targetValue = NULL,
  targetType = "SINGLE_NOMINAL",
  qualityMeasure = "CORTANA_QUALITY",
  qualityMeasureMinimum = 0.1,
  searchDepth = 1,
  minimumCoverage = 2,
  maximumCoverageFraction = 1.0,
  minimumSupport = 0,
  maximumSubgroups = 1000,
  filterSubgroups = TRUE,
  minimumImprovement = 0.0,
  maximumTime = 1000,
  searchStrategy = "BEAM",
  nominalSets = FALSE,
  numericOperatorSetting = "NORMAL",
  numericStrategy = "NUMERIC_BEST",
  searchStrategyWidth = 10,
  nrBins = 8,
  nrThreads = 1
){
  # Loading the data table ---
  # Only from file implemented
  if (is.character(src)) {
    file <- .jnew("java.io.File", src)
    loader <- .jnew("nl.liacs.subdisc.DataLoaderTXT", file)
    dataTable <- J(loader, "getTable")

  } else {
    dataTable <- createtable(src)
  }

  # Java Enum ---
  TargetType      <- .jnewEnum("nl/liacs/subdisc/TargetType")
  SearchStrategy  <- .jnewEnum("nl/liacs/subdisc/SearchStrategy")
  NumOpSetting    <- .jnewEnum("nl/liacs/subdisc/NumericOperatorSetting")
  NumericStrategy <- .jnewEnum("nl/liacs/subdisc/NumericStrategy")
  QualityMeasure  <- .jnewEnum("nl/liacs/subdisc/QM")

  # Setting the target and target concept ---
  target <- if (is.numeric(targetColumn) & length(targetColumn) == 1) {
    # N.B. A float will be cast to int
    .jcall(dataTable,
           "Lnl/liacs/subdisc/Column;",
           "getColumn",
           as.integer(targetColumn))
  } else if (is.character(targetColumn)){
    .jcall(dataTable,
           "Lnl/liacs/subdisc/Column;",
           "getColumn",
           targetColumn)
  } else {
    stop("targetColumn must be an integer or a string")
  }

  targetConcept <- .jnew("nl.liacs.subdisc.TargetConcept")

  setTC <- function(func, value, typefunc=identity){
    if(!is.null(value)){ .jcall(targetConcept, "V", func, typefunc(value)) }
  }

  setTC( "setPrimaryTarget", target                    )
  setTC( "setTargetType"   , TargetType(targetType)    )
  setTC( "setTargetValue"  , targetValue, as.character )


  # Setting the search parameters ----
  searchParameters <- .jnew("nl.liacs.subdisc.SearchParameters")

  setSP <- function(func, value, typefunc=identity){
    if(!is.null(value)){ .jcall(searchParameters, "V", func, typefunc(value)) }
  }

  setSP( "setTargetConcept"          , targetConcept                       )
  setSP( "setQualityMeasure"         , QualityMeasure(qualityMeasure)      )
  setSP( "setQualityMeasureMinimum"  , qualityMeasureMinimum  , .jfloat    )
  setSP( "setSearchDepth"            , searchDepth            , as.integer )
  setSP( "setMinimumCoverage"        , minimumCoverage        , as.integer )
  setSP( "setMaximumCoverageFraction", maximumCoverageFraction, .jfloat    )
  setSP( "setMinimumSupport"         , minimumSupport         , as.integer )
  setSP( "setMaximumSubgroups"       , maximumSubgroups       , as.integer )
  setSP( "setFilterSubgroups"        , filterSubgroups                     )
  setSP( "setMinimumImprovement"     , minimumImprovement     , .jfloat    )
  setSP( "setMaximumTime"            , maximumTime            , .jfloat    )
  setSP( "setSearchStrategy"         , SearchStrategy(searchStrategy)      )
  setSP( "setNominalSets"            , nominalSets                         )
  setSP( "setNumericOperators"       , NumOpSetting(numericOperatorSetting))
  setSP( "setNumericStrategy"        , NumericStrategy(numericStrategy)    )
  setSP( "setSearchStrategyWidth"    , searchStrategyWidth    , as.integer )
  setSP( "setNrBins"                 , nrBins                 , as.integer )
  setSP( "setNrThreads"              , nrThreads              , as.integer )


  # The actual search call ----
  subgroups <- .jcall(
    obj = "nl.liacs.subdisc.Process",
    returnSig = "Lnl/liacs/subdisc/SubgroupDiscovery;",
    method = "runSubgroupDiscovery",
    dataTable,                     # nl.liacs.subdisc.Table theTable
    as.integer(0),                 # int theFold
    .jnull("java.util.BitSet"),    # java.util.BitSet theSelection
    searchParameters,              # nl.liacs.subdisc.SearchParameters theSearchParameters
    FALSE,                         # boolean showWindows
    as.integer(nrThreads),         # int theNrThreads
    .jnull("javax.swing.JFrame")   # javax.swing.JFrame theMainWindow
  )

  # Returning a tiddle
  .subdisc.SubgroupSet.tibble(
    .jcall(subgroups, "Lnl/liacs/subdisc/SubgroupSet;", "getResult")
  )
}


# Functions to extract the information from the SubgroupSet ----


newGetFunc <- function(getFunc, returnType){
  singleDispatch <- function(obj){ .jcall(obj, returnType, getFunc) }
  function(objVec){ sapply(objVec, singleDispatch) }
}

.subdisc.getString             <- newGetFunc("toString",              "S")
.subdisc.getCoverage           <- newGetFunc("getCoverage",           "I")
.subdisc.getDepth              <- newGetFunc("getDepth",              "I")
.subdisc.getFalsePositiveRate  <- newGetFunc("getFalsePositiveRate",  "D")
.subdisc.getID                 <- newGetFunc("getID",                 "I")
.subdisc.getMeasureValue       <- newGetFunc("getMeasureValue",       "D")
.subdisc.getPValue             <- newGetFunc("getPValue",             "D")
.subdisc.getSecondaryStatistic <- newGetFunc("getSecondaryStatistic", "D")
.subdisc.getTeriaryStatistic   <- newGetFunc("getTertiaryStatistic",  "D")
.subdisc.getTruePositiveRate   <- newGetFunc("getTruePositiveRate",   "D")

#TODO: Handle Java String
#.subdisc.getRegressionModel    <- newGetFunc("RegressionModel",    "S")


# Function to create the tibble (dataframe)
.subdisc.SubgroupSet.tibble <- function(subgroupset){

  sglist = as.list(subgroupset)
  tibble::tibble(
    Subgroup           = .subdisc.getString(sglist),
    Coverage           = .subdisc.getCoverage(sglist),
    Depth              = .subdisc.getDepth(sglist),
    FalsePositiveRate  = .subdisc.getFalsePositiveRate(sglist),
    ID                 = .subdisc.getID(sglist),
    MeasureValue       = .subdisc.getMeasureValue(sglist),
    PValue             = .subdisc.getPValue(sglist),
    #RegressionModel    = .subdisc.getRegressionModel(sglist) # problem with java string
    SecondaryStatistic = .subdisc.getSecondaryStatistic(sglist),
    TertiaryStatistic  = .subdisc.getTeriaryStatistic(sglist),
    TruePositiveRare   = .subdisc.getTruePositiveRate(sglist)
  )
}


# Helper functions for specific search ------------------------------------



#' Title
#'
#' @param src
#' @param targetColumn
#' @param targetValue
#' @param qualityMeasureMinimum
#' @param searchDepth
#' @param minimumCoverage
#' @param maximumCoverageFraction
#' @param minimumSupport
#' @param maximumSubgroups
#' @param filterSubgroups
#' @param minimumImprovement
#' @param maximumTime
#' @param searchStrategy
#' @param nominalSets
#' @param numericOperatorSetting
#' @param numericStrategy
#' @param searchStrategyWidth
#' @param nrBins
#' @param nrThreads
#'
#' @return
#' @export
#'
#' @examples
.subdisc.single_nominal.cortana_quality <- function(
  src,
  targetColumn,
  targetValue,
  qualityMeasureMinimum = 0.1,
  searchDepth = 1,
  minimumCoverage = 2,
  maximumCoverageFraction = 1.0,
  minimumSupport = 0,
  maximumSubgroups = 1000,
  filterSubgroups = TRUE,
  minimumImprovement = 0.0,
  maximumTime = 1000,
  searchStrategy = "BEAM",
  nominalSets = FALSE,
  numericOperatorSetting = "NORMAL",
  numericStrategy = "NUMERIC_BEST",
  searchStrategyWidth = 10,
  nrBins = 8,
  nrThreads = 1
){
  subgroupdiscovery(
    src = src,
    targetColumn = targetColumn,
    targetValue = targetValue,
    targetType = "SINGLE_NOMINAL",
    qualityMeasure = "CORTANA_QUALITY",
    qualityMeasureMinimum = qualityMeasureMinimum,
    searchDepth = searchDepth,
    minimumCoverage = minimumCoverage,
    maximumCoverageFraction = maximumCoverageFraction,
    minimumSupport = minimumSupport,
    maximumSubgroups = maximumSubgroups,
    filterSubgroups = filterSubgroups,
    minimumImprovement = minimumImprovement,
    maximumTime = maximumTime,
    searchStrategy = searchStrategy,
    nominalSets = nominalSets,
    numericOperatorSetting = numericOperatorSetting,
    numericStrategy = numericStrategy,
    searchStrategyWidth = searchStrategyWidth,
    nrBins = nrBins,
    nrThreads = nrThreads
  )
}

#' Title
#'
#' @param src
#' @param targetColumn
#' @param qualityMeasureMinimum
#' @param searchDepth
#' @param minimumCoverage
#' @param maximumCoverageFraction
#' @param minimumSupport
#' @param maximumSubgroups
#' @param filterSubgroups
#' @param minimumImprovement
#' @param maximumTime
#' @param searchStrategy
#' @param nominalSets
#' @param numericOperatorSetting
#' @param numericStrategy
#' @param searchStrategyWidth
#' @param nrBins
#' @param nrThreads
#'
#' @return
#' @export
#'
#' @examples
.subdisc.single_numeric.explained_variance <- function(
  src,
  targetColumn,
  qualityMeasureMinimum = 0.1,
  searchDepth = 1,
  minimumCoverage = 2,
  maximumCoverageFraction = 1.0,
  minimumSupport = 0,
  maximumSubgroups = 1000,
  filterSubgroups = TRUE,
  minimumImprovement = 0.0,
  maximumTime = 1000,
  searchStrategy = "BEAM",
  nominalSets = FALSE,
  numericOperatorSetting = "NORMAL",
  numericStrategy = "NUMERIC_BEST",
  searchStrategyWidth = 10,
  nrBins = 8,
  nrThreads = 1
){
  subgroupdiscovery(
    src = src,
    targetColumn = targetColumn,
    targetType = "SINGLE_NUMERIC",
    qualityMeasure = "EXPLAINED_VARIANCE",
    qualityMeasureMinimum = qualityMeasureMinimum,
    searchDepth = searchDepth,
    minimumCoverage = minimumCoverage,
    maximumCoverageFraction = maximumCoverageFraction,
    minimumSupport = minimumSupport,
    maximumSubgroups = maximumSubgroups,
    filterSubgroups = filterSubgroups,
    minimumImprovement = minimumImprovement,
    maximumTime = maximumTime,
    searchStrategy = searchStrategy,
    nominalSets = nominalSets,
    numericOperatorSetting = numericOperatorSetting,
    numericStrategy = numericStrategy,
    searchStrategyWidth = searchStrategyWidth,
    nrBins = nrBins,
    nrThreads = nrThreads
  )
}

createtable <- function(data) {
  AttributeType <- .jnewEnum("nl/liacs/subdisc/AttributeType")

  nrows = dim(data)[1]
  ncols = dim(data)[2]

  types = sapply(data, typeof)

  dummyfile <- .jnew("java.io.File", "from-r-dataframe.txt")
  table <- .jnew("nl.liacs.subdisc.Table", dummyfile, nrows, ncols)
  columns <- J(table, "getColumns")

  for (idx in 1:ncols){
    col <- data[idx]
    name <- gsub(".", "-", names(col), fixed=TRUE)

    atttype <- switch(types[idx],
                   "integer"   = AttributeType("NUMERIC"),
                   "double"    = AttributeType("NUMERIC"),
                   "character" = AttributeType("NOMINAL"),
                   "logical"   = AttributeType("BINARY"))

    castfunc <- switch(types[idx],
                   "integer"   = .jfloat,
                   "double"    = .jfloat,
                   "character" = as.character,
                   "logical"   = as.logical)

    if (is.null(atttype)){
      stop("Unsupported columns type '", atttype, "' for column '", name, "'")}

    column <- .jnew("nl.liacs.subdisc.Column", name, name, atttype, idx, nrows)
    .jcall(column, "V", "setData", castfunc(data[[idx]]))
    J(columns, "add", column)
  }
  table
}
