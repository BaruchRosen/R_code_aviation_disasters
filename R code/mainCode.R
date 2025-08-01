options(scipen=999)

source("dataFunctions.R")
source("dataPaths.R")
source("plots.R")
library(dplyr)

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

car_days <- CAR_AVG(accidentsDB, dataBase,country = "Israel")
plot_car(car_days, "Cumulative abnormal rate of return Israel")

#CAR - USA
car_days <- CAR_AVG(accidentsDB, dataBase,country = "USA")
plot_car(car_days, "Cumulative abnormal rate of return USA")


set.seed(1)
# Split data to training and validation
idx <- sample(seq(1, 2), size = nrow(dataBase), replace = TRUE, prob = c(.4, .6))
validation <- dataBase[idx == 1,]
training <- dataBase[idx == 2,]

# 4.2 build reg object
reg <- lm(revenue ~ afterAccidentDays + DOW + R.t.1+ R.t.2+ R.t.3+ R.t.4+ R.t.5+TAX+after_holiday, data = training[, ]) 
#reg <- lm(revenue ~ afterAccidentDays, data = training[, ]) 

summary(reg)
# 4.3 test reg on validation
library(forecast)

pred_validation <- predict(reg, newdata = validation)
accuracy(pred_validation, validation$revenue)

# do the same for the NYSE
regNYSE <- lm(NYSE_revenue ~ afterAccidentDays + DOW + R.t.1+ R.t.2+ R.t.3+ R.t.4+ R.t.5+TAX+after_holiday, data = training[, ]) 
#reg <- lm(revenue ~ afterAccidentDays, data = training[, ]) 

summary(regNYSE)
# 4.3 test reg on validation

pred_validation_NYSE <- predict(regNYSE, newdata = validation)
accuracy(pred_validation_NYSE, validation$NYSE_revenue)

# check CAR using a reg model as predictor
# build reg object
reg_for_car <- lm(revenue ~ DOW + R.t.1+ R.t.2+ R.t.3+ R.t.4+ R.t.5+TAX+after_holiday, data = training[, ]) 
summary(reg_for_car)


#CAR - Israel
car_days <- CAR_REG(reg_for_car, accidentsDB, dataBase, country="Israel")
plot_car(car_days, "Cumulative abnormal rate of return Israel(reg)")


reg_for_car <- lm(NYSE_revenue ~ DOW + R.t.1+ R.t.2+ R.t.3+ R.t.4+ R.t.5+TAX+after_holiday, data = training[, ]) 
summary(reg_for_car)


#CAR - USA
car_days <- CAR_REG(reg_for_car, accidentsDB, dataBase, country="USA")
plot_car(car_days, "Cumulative abnormal rate of return NYSE(reg)")

