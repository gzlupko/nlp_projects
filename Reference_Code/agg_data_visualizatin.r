library(data.table)
library(ggplot2)
library(ggthemes)
library(gridExtra)
library(cowplot)


dt <- read.csv('~/Documents/C/Research/data/state_date_level_twitter_affect_covid_agg_0301_0701_complete.csv')
dt <- data.table(dt)
dt = dt[!is.na(new_cases) ]


################ 
#### Visualization


states_array = c('US total', 'California', 'New York', 'Texas', 'Florida')

setwd('~/Documents/C/Research/tw_covid_remote/tw_covid_wfh/reports/')

dt[, pred_anger := pred_anger * 100]
dt[, pred_sadness := pred_sadness * 100]
dt[, pred_joy := pred_joy * 100]
dt[, pred_disgust := pred_disgust * 100]
dt[, pred_fear := pred_fear * 100]
dt[, pred_surprise := pred_surprise * 100]

for(s in states_array){
  print(paste('State name: ', s, sep = ''))
  upper_bound = dt[state==s, max(new_cases)]
  ## count
  tmp_scale = dt[state==s, mean(new_cases)/mean(count)]* 0.8
  p1 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_line(aes(x = date, y = count * tmp_scale), size = 1.5, color="darkblue", group = 1) +  
    scale_y_continuous(limits=c(0,upper_bound*1.6), sec.axis = sec_axis(~./tmp_scale, name = "Counts of WFH related Tweets"), name = 'Daily New Confirmed Case') +
    theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'))
  p1 
  ggsave(paste(s, 'tw_counts.jpeg', sep='_'), p1, width = 10, height = 8, dpi = 300)
  
  ## anger
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_anger)] * 1
  p2 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_anger * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Anger"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
     theme(axis.title=element_text(size=14))
  p2
  ggsave(paste(s, 'anger.jpeg', sep='_'), p2, width = 10, height = 8, dpi = 300)
  

  ## sadness
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_sadness)] * 1.2
  p3 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_sadness * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Sadness"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
    theme(axis.title=element_text(size=14))
  p3
  ggsave(paste(s, 'sadness.jpeg', sep='_'), p3, width = 10, height = 8, dpi = 300)
  
  
  ## joy
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_joy)]  * 1.2
  p4 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_joy * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Joy"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
    theme(axis.title=element_text(size=14))
  p4
  ggsave(paste(s, 'joy.jpeg', sep='_'), p4, width = 10, height = 8, dpi = 300)
  
  ## disgust
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_disgust)]  * 1.2
  p5 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_disgust * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Disgust"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
    theme(axis.title=element_text(size=14))
  p5
  ggsave(paste(s, 'disgust.jpeg', sep='_'), p5, width = 10, height = 8, dpi = 300)
  
  ## fear
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_fear)]  * 1
  p6 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_fear * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Fear"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
    theme(axis.title=element_text(size=14))
  p6
  ggsave(paste(s, 'fear.jpeg', sep='_'), p6, width = 10, height = 8, dpi = 300)
  
  
  ## surprise
  tmp_scale = dt[state==s, mean(new_cases)/mean(pred_surprise)]  * 1.2
  p7 <- ggplot(dt[state == s,]) + 
    geom_col(aes(x = date, y = new_cases), size = 1, color = "lightblue", fill = "white") +
    geom_point(aes(x = date, y = pred_surprise * tmp_scale), size = 1.8, color="darkblue", group = 1, shape = 17)+
    scale_y_continuous(limits=c(0,upper_bound*1.8), sec.axis = sec_axis(~./tmp_scale, name = "Surprise"), name = 'Daily New Confirmed Case') +
     theme_bw() + scale_x_discrete(breaks =c('2020-03-01', '2020-04-01','2020-05-01', '2020-06-01','2020-07-01'), name = "Date") +
    theme(axis.title=element_text(size=14))
  p7
  ggsave(paste(s, 'surprise.jpeg', sep='_'), p7, width = 10, height = 8, dpi = 300)
  
}





