library(dplyr)
library(forecast)

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
  # note: this function is not needed. corrected in python!
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

NYSEadd_revenue <- function(NYSE_DB){ # not needed! done in python!
  NYSE$revenue <- 0
  for (precent in NYSE$Change) {
    index <- which(NYSE$Change == precent)
    NYSE$revenue[index] = as.numeric(sub("%", "", NYSE$Change[index]))/100  
  }
  return (NYSE)
}


get_revenue_at_date <- function(dataBase, date, country = "Israel"){ # date - "%d/%m/%Y"
  date_parts <- strsplit(date, "/")[[1]]
  year <- as.integer(date_parts[3])
  month <- as.integer(date_parts[2])
  day <- as.integer(date_parts[1])
  new_date <- paste(year, month, day, sep = "-")
  if(new_date %in% dataBase$Date){ # compare to string "1993-09-23"
    index <- which(dataBase$Date == new_date)
    if(country=="Israel"){
      return(dataBase$revenue[index])
    }else{
      return(dataBase$NYSE_revenue[index])
    }
    
  }
  return (-999)
}


get_revenue_at_date_reg <- function(regModel, dataBase, date){ # date - "%d/%m/%Y"
  date_parts <- strsplit(date, "/")[[1]]
  year <- as.integer(date_parts[3])
  month <- as.integer(date_parts[2])
  day <- as.integer(date_parts[1])
  new_date <- paste(year, month, day, sep = "-")
  # new_date <- formatted_date <- format(as.Date(date, format = "%d/%m/%Y"), "%Y-%m-%d")
  if(new_date %in% dataBase$Date){ # compare to string format "1993-09-23"
    index <- which(dataBase$Date == new_date)

    return(predict(regModel, newdata = dataBase[index,]) )# for reg prediction!
  }
  return (-999)
}

# CAR_AVG <- function(accidentDB, STOCKdb,country = "Israel"){
# 
#   #CAR - by avg.
#   car_days <- c(-5:13)*0
#   car_days_count <- c(-5:13)*0
# 
#   for (date in accidentDB$Israel.Date) {
#     current_car <- 0
#     for (i in c(-5:13)) {
#       current_day <- add_days_to_date(date,i)
#       if(country=="Israel"){
#         daily_revenue <- get_revenue_at_date(STOCKdb,current_day,"Israel")
#       }else{
#         daily_revenue <- get_revenue_at_date(STOCKdb,current_day,"USA")
#       }
# 
#       if(daily_revenue==-999){
#         daily_abnormal_revenue <- 0 # days without revenue don't effect the CAR!
#         # should cover also dates that don't exist in the TA125 DB!
#       }else{
#         daily_abnormal_revenue <- daily_revenue - simple_avg
#         current_car <- current_car + daily_abnormal_revenue
#         car_days[i+6] <- car_days[i+6] + current_car
#         car_days_count[i+6] <- car_days_count[i+6] + 1
#       }
# 
#     }
#   }
#   for (i in c(-5:13)) { # this step is to get the average CAR between the events.
#     # note that each date relative to the accident appears in different count due to
#     # non market days and holidays!
#     car_days[i+6] <- car_days[i+6]/car_days_count[i+6]
#   }
# 
#   car_days
# }

CAR_AVG <- function(accidentDB, STOCKdb, country = "Israel"){
  
  # CAR - by avg.
  car_days <- c(-5:13)*0
  car_days_count <- c(-5:13)*0
  
  for (date in accidentDB$Israel.Date) {
    for (i in c(-5:13)) {
      current_day <- add_days_to_date(date, i)
      if (country == "Israel") {
        daily_revenue <- get_revenue_at_date(STOCKdb, current_day, "Israel")
      } else {
        daily_revenue <- get_revenue_at_date(STOCKdb, current_day, "USA")
      }
      
      if (daily_revenue == -999) {
        next  # skip days without data
      } else {
        expected_return <- simple_avg
        daily_abnormal_revenue <- daily_revenue - expected_return
        car_days[i + 6] <- car_days[i + 6] + daily_abnormal_revenue
        car_days_count[i + 6] <- car_days_count[i + 6] + 1
      }
    }
  }
  
  for (i in c(-5:13)) {
    if (car_days_count[i + 6] > 0) {
      car_days[i + 6] <- car_days[i + 6] / car_days_count[i + 6]
    }
  }
  car_days
}

CAR_REG <- function(regModel, accidentDB, STOCKdb, country="Israel"){

  #CAR - by reg
  car_days <- c(-5:13)*0
  car_days_count <- c(-5:13)*0

  for (date in accidentDB$Israel.Date) {
    current_car <- 0
    for (i in c(-5:13)) {
      current_day <- add_days_to_date(date,i)
      
      if (country == "Israel") {
        daily_revenue <- get_revenue_at_date(STOCKdb, current_day, "Israel")
      } else {
        daily_revenue <- get_revenue_at_date(STOCKdb, current_day, "USA")
      }
      
      if(daily_revenue==-999){
        next # days without revenue don't effect the CAR!
        # should have covered also dates that don't exist in the TA125 DB!
      }else{
        expected_return <- get_revenue_at_date_reg(regModel,STOCKdb,current_day)
        
        daily_abnormal_revenue <- daily_revenue - expected_return
        car_days[i + 6] <- car_days[i + 6] + daily_abnormal_revenue
        
        # daily_abnormal_revenue <- daily_revenue - simple_avg
        # current_car <- current_car + daily_abnormal_revenue
        # car_days[i+6] <- car_days[i+6] + current_car
        car_days_count[i+6] <- car_days_count[i+6] + 1
      }

    }
  }
  
  for (i in c(-5:13)) { # this step is to get the average CAR between the events.
    # note that each date relative to the accident appears in different count due to
    # non market days and holidays!
    car_days[i+6] <- car_days[i+6]/car_days_count[i+6]
  }

  car_days
}

plot_car <- function(car_days, y_label){
  # plot CAR results
  x_name <- "x"
  y_name <- "y"
  days  <- c(-5:13)
  df <- data.frame(days,car_days)
  names(df) <- c(x_name,y_name)
  
  ggplot(df, aes(x = x, y = y)) + geom_line()+
    scale_x_continuous(breaks = seq(-5,13,by=1)) + 
    labs(x="Days relative to disaster date (t = 0)" , y = y_label)
  
}