library(ggplot2)
library(scales)
geom_histogramPlot <- function(dataBase, country){
  days = c(0, 1, 2, 3)
  midBase <- dataBase[ dataBase$afterAccidentDays %in% days, ]
  color_count <- length(unique(midBase$afterAccidentDays))
  color_palette <- hue_pal()(color_count)
  
  if(country == "israel"){
    ggplot(midBase, aes(x = revenue, fill=afterAccidentDays)) + geom_histogram(aes(y = ..density..),bins = 20,position = "dodge", alpha = 0.7)+
      labs(y = "density (Israel)", fill = "After Accident Days")
  }else{
    ggplot(midBase, aes(x = NYSE_revenue, fill=afterAccidentDays)) + geom_histogram(aes(y = ..density..),bins = 20,position = "dodge", alpha = 0.7)+
      labs(y = "density (USA)", fill = "After Accident Days")
  }
}

stat_ecdfPlot <- function(dataBase, country){
  days = c(0, 1, 2, 3)
  midBase <- dataBase[ dataBase$afterAccidentDays %in% days, ]
  color_count <- length(unique(midBase$afterAccidentDays))
  color_palette <- hue_pal()(color_count)
  if(country == "israel"){
    ggplot(midBase, aes(x=revenue)) + stat_ecdf(aes(color = afterAccidentDays,linetype = afterAccidentDays), 
                                              geom = "step", size = 1.5) +
    scale_color_manual(values = color_palette)+
    labs(y = "Cumulative probability (Israel)")
  }else{
    ggplot(midBase, aes(x=NYSE_revenue)) + stat_ecdf(aes(color = afterAccidentDays,linetype = afterAccidentDays), 
                                                geom = "step", size = 1.5) +
      scale_color_manual(values = color_palette)+
      labs(y = "Cumulative probability (USA)")
  }
  
  
  }

