library(dplyr)

add_days_to_date <- function(date_string, days_to_add){
  date <- as.Date(date_string, format="%d/%m/%Y")
  new_date <- date + days_to_add
  return (format(new_date, "%d/%m/%Y"))
}

check_in_time_range<- function(time_string){
  time_parts <- strsplit(time_string, ":")[[1]]
  minuts <- as.integer(time_parts[2])
  hours <- as.integer(time_parts[1])
  if(hours < 16 || (hours==16 && minuts <= 50)){
    return(TRUE)
  }else{
    return(FALSE)
  }
}

fixTradingDates<- function(accidentsDB){
  accidentsDB$correctDate <- 0
  for (date in accidentsDB$Israel.Date) {
    # check for the need to skip a date because of market working hours
    index_accident <- which(accidentsDB$Israel.Date == date)
    hour <- accidentsDB$Israel.Time[index_accident]
    if(check_in_time_range(hour)==FALSE){
      new_date <- add_days_to_date(date, 1)
    }else{
      new_date <- date
    }
    accidentsDB$correctDate[index_accident] <- new_date
  }
  return (accidentsDB)
}

NYSEadd_revenue <- function(NYSE_DB){
  NYSE$revenue <- 0
  for (precent in NYSE$Change) {
    index <- which(NYSE$Change == precent)
    NYSE$revenue[index] = as.numeric(sub("%", "", NYSE$Change[index]))/100  
  }
  return (NYSE)
}


get_revenue_at_date <- function(dataBase, date){
  if(date %in% dataBase$Date){
    index <- which(dataBase$Date == date)
    return(dataBase$revenue[index])
  }
  return (0)
}