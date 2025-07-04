options(scipen=999)

source("dataFunctions.R")
source("dataPaths.R")
source("plots.R")


dataBase <- read.csv(path_main_db)
accidentsDB <- read.csv(path_accidents_db)
#exchangeRateIsraelBank <- read.csv(path_exchange_rates)

# accidentsDB <- fixTradingDates(accidentsDB)  #should already be fixed by python!


# set all categorical data types...
dataBase$DOW <- as.factor(dataBase$DOW)
dataBase$TAX <- as.factor(dataBase$TAX)
dataBase$after_holiday <- as.factor(dataBase$after_holiday)
dataBase$afterAccidentDays <- as.factor(dataBase$afterAccidentDays)


# calculate mean return on every day vs days after accident
simple_avg <- mean(dataBase$revenue, na.rm = TRUE)
day_accident <- mean(dataBase[dataBase$afterAccidentDays == -1, 'revenue'], na.rm = TRUE)
first_day_after_accident <- mean(dataBase[dataBase$afterAccidentDays == 1, 'revenue'], na.rm = TRUE)
sec_day_after_accident <- mean(dataBase[dataBase$afterAccidentDays == 2, 'revenue'], na.rm = TRUE)
third_day_after_accident <- mean(dataBase[dataBase$afterAccidentDays == 3, 'revenue'], na.rm = TRUE)

# calculate mean return on every day vs days after accident
simple_avgNYSE <- mean(dataBase$NYSE_revenue, na.rm = TRUE)
day_accidentNYSE <- mean(dataBase[dataBase$afterAccidentDays == -1, 'NYSE_revenue'], na.rm = TRUE)
first_day_after_accidentNYSE <- mean(dataBase[dataBase$afterAccidentDays == 1, 'NYSE_revenue'], na.rm = TRUE)
sec_day_after_accidentNYSE <- mean(dataBase[dataBase$afterAccidentDays == 2, 'NYSE_revenue'], na.rm = TRUE)
third_day_after_accidentNYSE <- mean(dataBase[dataBase$afterAccidentDays == 3, 'NYSE_revenue'], na.rm = TRUE)

dataBase$firstDayAfterAccident <- ifelse(dataBase$afterAccidentDays == "1", 1, 0)
dataBase$secondDayAfterAccident <- ifelse(dataBase$afterAccidentDays == "2", 1, 0)
dataBase$thirdDayAfterAccident <- ifelse(dataBase$afterAccidentDays == "3", 1, 0)
# 
# id <- 1
# for (x in dataBase$DayOfAccident) {
#   if(dataBase$afterAccidentDays[id]==1){
#     dataBase$firstDayAfterAccident[id] <- 1
#   }
#   if(dataBase$afterAccidentDays[id]==2){
#     dataBase$secondDayAfterAccident[id] <- 2
#   }
#   if(dataBase$afterAccidentDays[id]==3){
#     dataBase$thirdDayAfterAccident[id] <- 3
#   }
#   id <- id+1
# }

Israel.first_tTest <- t.test(revenue ~ firstDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)
Israel.sec_tTest <- t.test(revenue ~ secondDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)
Israel.third_tTest <- t.test(revenue ~ thirdDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)


USA.first_tTest <- t.test(NYSE_revenue ~ firstDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)
USA.sec_tTest <- t.test(NYSE_revenue ~ secondDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)
USA.third_tTest <- t.test(NYSE_revenue ~ thirdDayAfterAccident, data = dataBase, alternative = "two.sided", var.equal = TRUE)

#Plot
stat_ecdfPlot(dataBase, "israel")
geom_histogramPlot(dataBase, "israel")

stat_ecdfPlot(dataBase, "usa")
geom_histogramPlot(dataBase, "usa")

#CAR - Israel
car_days <- c(-5:10)*0

for (date in accidentsDB$Israel.Date) {
    current_car <- 0
    for (i in c(-5:10)) {
      current_day <- add_days_to_date(date,i)
      daily_revenue <- get_revenue_at_date(dataBase,current_day,"Israel")
      if(daily_revenue==-999){
        daily_abnormal_revenue <- 0 # days without revenue don't effect the CAR!
        # should cover also dates that don't exist in the TA125 DB!
      }else{
        daily_abnormal_revenue <- daily_revenue - simple_avg
      }
      current_car <- current_car + daily_abnormal_revenue
      car_days[i+6] <- car_days[i+6] + current_car
    }
}



# plot CAR results
x_name <- "x"
y_name <- "y"
days  <- c(-5:10)
df <- data.frame(days,car_days)
names(df) <- c(x_name,y_name)

ggplot(df, aes(x = x, y = y)) + geom_line()+
  labs(x="Days relative to disaster date (t = 0)" , y = "Cumulative abnormal rate of return")


#CAR - USA
car_days <- c(-5:13)*0

for (date in accidentsDB$Israel.Date) { # note: for accuracy of day alignment take usa date!
  current_car <- 0
  for (i in c(-5:13)) {
    current_day <- add_days_to_date(date,i)
    daily_revenue <- get_revenue_at_date(dataBase,current_day,"USA")
    if(daily_revenue==-999){
      daily_abnormal_revenue <- 0 # days without revenue don't effect the CAR!
    }else{
      daily_abnormal_revenue <- daily_revenue - simple_avg
    }
    
    current_car <- current_car + daily_abnormal_revenue
    car_days[i+6] <- car_days[i+6] + current_car
  }
}



# plot CAR results
x_name <- "x"
y_name <- "y"
days  <- c(-5:13)
df <- data.frame(days,car_days)
names(df) <- c(x_name,y_name)

ggplot(df, aes(x = x, y = y)) + geom_line()+
  labs(x="Days relative to disaster date (t = 0)" , y = "Cumulative abnormal rate of return USA")


set.seed(1)
# Split data to training and validation
idx <- sample(seq(1, 2), size = nrow(dataBase), replace = TRUE, prob = c(.4, .6))
validation <- dataBase[idx == 1,]
training <- dataBase[idx == 2,]

# 4.2 build reg object
reg <- lm(revenue ~ afterAccidentDays + DOW + R.t.1+ R.t.2+ R.t.3+ R.t.4+ R.t.5+TAX+after_holiday, data = training[, ]) 
#reg <- lm(revenue ~ afterAccidentDays, data = training[, ]) 

summary(reg)
# 4.3 test reg on training Vs. validation
library(forecast)
pred <- predict(reg, newdata = training)
accuracy(pred, training$revenue)

pred_validation <- predict(reg, newdata = validation)
accuracy(pred, validation$revenue)

