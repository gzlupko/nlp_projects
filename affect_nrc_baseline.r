library(data.table)
library(syuzhet)
 a

### Get validation data
dt = data.table(fread('~/Downloads/SemEval2018-Task1-all-data/English/E-c/2018-E-c-En-test-gold.txt'))

affects = c("anger","anticipation","disgust","fear","joy","sadness","surprise","trust", "negative", "positive")  

for(af in affects){
  print(af)
  dt_raw = data.frame(dt)[, c('Tweet', af)]
  dt_raw_pos = dt_raw[dt_raw[, af]>0,]
  dt_raw_neg = dt_raw[dt_raw[, af]==0,]
  
  set.seed(15213)
  dt_balanced = rbind(dt_raw_pos[sample(1:nrow(dt_raw_pos)
                                              , nrow(dt_raw_neg)
                                              , replace = T), ]
                            , dt_raw_neg)
  
  
  predictions = get_nrc_sentiment(dt_balanced$Tweet)
  dt_balanced$predictions = as.integer(predictions[,af]>0)
  print(paste('Accuracy of affect ', af, ': '
              , sum(dt_balanced$predictions == dt_balanced[, af])/nrow(dt_balanced)
              , sep = ''))
}


dt_anger_balanced$predicted_anger = as.integer(predictions$anger>0)
