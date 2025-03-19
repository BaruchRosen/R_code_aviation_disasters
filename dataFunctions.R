
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
