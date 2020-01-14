library(magrittr)
library(dplyr)
library(readxl)
library(RJSONIO)

# init setup function
getSettings <- function() {fromJSON("settings.json", encoding = "UTF-8")}

# define and set files in scope
setFiles <- function(dir, exclude=NULL) {
  files <- list.files(dir, pattern = ".xlsm", recursive = T)
  
  # exclude file paterns, if any
  if (is.null(exclude)) {
    files  
  } else {
    files %<>% .[!grepl(paste0(exclude, collapse = "|"), .)] # using separator "|" is producing regex patern list
  }
}

# slurp xls function
slurpData <- function(target, files, ws) {
  # load all files in folder via loop to data
  data <- data.frame()
  n=0
  for (f in files) {
    
    path <- paste0(target, "/", f)
    # the path in read_excel is hiding encoding hell,-it must not include non-standard characters
    dataNow <- read_excel(path, sheet = ws)
    ## dataNow %<>% filter(.$'app-list'!="!")
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

# data scrubbing and formating
scrubbing <- function(dt) {
  dt %<>% filter(!is.na(.$`price-extra`))
  dt$end=NULL
  dt$`date-saved` %<>% as.character
  dt
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
                         f = "data_scrubbed.csv") {
  write.csv(dt, f)
}

filterDataScrubbed <- function(filterNow) {
  # TODO
  filter(dataScrubbed, filterNow)
}


main <- function() {
  core <<- list(
    target = target <- getSettings()$dir,
    out_of_scope = out <- getSettings()$outOfScope,
    files = files <- setFiles(target, out),
    worksheet = ws <- getSettings()$sheet
  )
  datas <<- list(
    # raw data
    raw = r <- slurpData(target, files, ws),
    # scrubbed
    scr = r %>% scrubbing
  )
}

# DEV BLOCK
function() {
  
  main()
  core$files
  core$target
  core$worksheet
  
  viewDataSnipet(10)
  
  printFileNames(core$files)
  
  datas$scr$release %>% table %>%  data.frame %>% View
  
  rm(list = ls())
}