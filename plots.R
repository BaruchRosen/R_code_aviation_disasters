library(ggplot2)

geom_histogramPlot <- function(dataBase){
  midBase <- dataBase[ which(dataBase$super == 1 | dataBase$super == 3) , ]
  # check return by date after crash
  ggplot(midBase, aes(x = revenue, fill=super)) + geom_histogram(bins = 10,position = "dodge", alpha = 0.7)
}

stat_ecdfPlot <- function(dataBase){
  midBase <- dataBase[ which(dataBase$super == 1 | dataBase$super == 3) , ]
  ggplot(midBase, aes(x=revenue)) + stat_ecdf(aes(color = super,linetype = super), 
                                              geom = "step", size = 1.5) +
    scale_color_manual(values = c("#00AFBB", "#E7B800"))+
    labs(y = "Cumulative probability")
  }

