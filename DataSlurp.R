library(magrittr)
library(dplyr)

# define and set files in scope
setFiles <- function(target=core$target, excludeAny=NULL) {
  # use the file.path() funcition EVER!!! (avoid system, back/fwrd slash and encoding hell)
  files <- list.files(file.path(target), pattern = ".xlsm", recursive = T)
  
  # excludeAny file paterns, if any
  if (is.null(excludeAny)) {
    files  
  } else {
    files %<>% .[!grepl(paste0(excludeAny, collapse = "|"), .)] # using separator "|" is producing regex patern list
  }
}

# slurp xls function
slurpData <- function(readFn=(function(path, sheet) readxl::read_excel(path, sheet)),
                      target=core$target,
                      files=core$files,
                      ws=core$worksheet) {
  # load all files in folder via loop to data
  data <- data.frame()
  n=0
  for (f in files) {
    
    # use the file.path() funcition EVER!!! (avoid system, back/fwrd slash and encoding hell)
    path <- file.path(target, f)
    dataNow <- readFn(path, ws)
    dataNow$Source <- path
    
    dataNow
    data <- rbind(data, dataNow)
    cat("\014")
    
    # console print with counter loop
    counter=paste0(length(files),"/",length(files)-n,"...")
    print(paste(counter, "slurped:", f))
    n = n + 1
    
  }
  data
}

# UTILS
viewDataSnipet <- function(dt = datas$scr, row = 1) {
  dt %>%
    .[row,] %>%
    unlist %>%
    data.frame %>%
    View
}

writeDataCsv <- function(dt = datas$scr,
                         f = "data_raw.csv") {
  write.csv(dt, f)
}


main <- function() {
  # init settings from JSON
  getSettings <- (function() {RJSONIO::fromJSON("settings.json", encoding = "UTF-8")})()
  core <<- list(
    target = target <- getSettings$dirData,
    out_of_scope = out <- getSettings$outOfScope,
    files = files <- setFiles(target, out),
    worksheet = ws <- getSettings$sheet,
    readFn = read <- (function(path, sheet) readxl::read_excel(path, sheet))
  )
  datas <<- list(
    # raw data
    raw = r <- slurpData(readFn = read,
                         target = target,
                         files = files,
                         ws = ws)
  )
}

# DEV BLOCK
function() {
  
  main()
  core$files
  core$out_of_scope
  core$target
  core$worksheet
  
  View(datas$raw)
  writeDataCsv()
  
  viewDataSnipet()
  
  path <- file.path(getSettings()$dirData)
  path
  
  slurpData(readFn = (function(path, sheet) readxl::read_excel(path, sheet, col_names = FALSE))) %>% View
  slurpData(target = core$target, files = core$files, ws = core$worksheet) %>% View
  
  rm(list = ls())
  source('DataSlurp.R', encoding = 'UTF-8', echo=FALSE)
  
}
