library(ggplot2)

geom_histogramPlot <- function(dataBase, country){
  midBase <- dataBase[ which(dataBase$afterAccidentDays == 1 | dataBase$afterAccidentDays == 3) , ]

  
  if(country == "israel"){
    ggplot(midBase, aes(x = revenue, fill=afterAccidentDays)) + geom_histogram(bins = 10,position = "dodge", alpha = 0.7)
  }else{
    ggplot(midBase, aes(x = NYSE_revenue, fill=afterAccidentDays)) + geom_histogram(bins = 10,position = "dodge", alpha = 0.7)
  }
}

stat_ecdfPlot <- function(dataBase, country){
  midBase <- dataBase[ which(dataBase$afterAccidentDays == 1 | dataBase$afterAccidentDays == 3) , ]
  
  if(country == "israel"){
    ggplot(midBase, aes(x=revenue)) + stat_ecdf(aes(color = afterAccidentDays,linetype = afterAccidentDays), 
                                              geom = "step", size = 1.5) +
    scale_color_manual(values = c("#00AFBB", "#E7B800"))+
    labs(y = "Cumulative probability")
  }else{
    ggplot(midBase, aes(x=NYSE_revenue)) + stat_ecdf(aes(color = afterAccidentDays,linetype = afterAccidentDays), 
                                                geom = "step", size = 1.5) +
      scale_color_manual(values = c("#00AFBB", "#E7B800"))+
      labs(y = "Cumulative probability")
  }
  
  
  }

