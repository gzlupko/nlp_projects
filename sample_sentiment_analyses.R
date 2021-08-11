# Sample Sentiment Analysis 


library(tidytext) 
library(sentimentr)
library(tidyverse) 


airline_tweets <- readRDS("sample_twitter_data.rds") 


# split columns into tokens; one token per row 
tidy_review <- airline_tweets %>% 
  unnest_tokens(word, tweet_text) %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("nrc")) 

# 

tidy_review %>%
  select(word, sentiment) %>% 
  group_by(sentiment) %>% 
  count(sentiment) %>%
  top_n(n) %>%
  arrange(desc(n)) 

tidy_review %>%
  count(sentiment, sort = T) 


tidy_review %>%
  count(word) %>%
  arrange(desc(n)) 

library(kableExtra) 
 
tidy_review %>%
  count(word, sentiment) %>%
  arrange(desc(n)) %>%
  kbl() %>%
  kable_styling() %>%
  save_kable(file = "tidy_review.png")  



# load reasons data 

reasons_data <- read.csv("reasons_data_8.10.csv") 
reasons_combined <- read.csv("reasons_combined.csv") 
# convert to character 

reasons_combined$Reasons <- as.vector(reasons_combined$Reasons) 



# input reasons for data into sentiment pipe 
tidy_reasons <- reasons_combined %>% 
  unnest_tokens(word, Reasons) %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("nrc")) %>%
  select(word, sentiment) %>% 
  group_by(sentiment) %>% 
  count(sentiment) %>%
  top_n(n) %>%
  arrange(desc(n)) 
 
tidy_reasons

# total number of reasons analyzed
sum(tidy_reasons$n) 

# load counterargumnents combined responses 

counters_combined <- read.csv("counterarguments_combined.csv") 
# change response data type to character string 
counters_combined$Counterarguments <- as.vector(counters_combined$Counterarguments) 
# input counterarguments into sentiment pipe 


tidy_counters <- counters_combined %>% 
  unnest_tokens(word, Counterarguments) %>%
  anti_join(stop_words) %>%
  inner_join(get_sentiments("nrc")) %>%
  select(word, sentiment) %>% 
  group_by(sentiment) %>% 
  count(sentiment) %>%
  top_n(n) %>%
  arrange(desc(n)) 

tidy_counters
# total number of counterarguments analyzed 
sum(tidy_counters$n) 

# difference of proportion test: positive 
# first look at sum of positive and overall n size for both 

sum(tidy_reasons$n) 
tidy_reasons 
sum(tidy_counters$n)
tidy_counters
prop_test_positive <- prop.test(x = c(377,232), n = c(1359,1297))
prop_test_positive 


# statement/sentence-level sentiment analysis
library(sentimentr)


reasons_combined %>%
  unnest_sentences(word, Reasons) %>%
  mutate(reason_id = row_number()) %>%
  inner_join(get_sentiments("bing")) 



statement_sentiment <- get_sentences(reasons_combined$Reasons) %>%
  sentiment() %>%
  mutate(reason_id = row_number())

# add reason_id tag to reasons data 
reasons_combined <- reasons_combined %>%
  mutate(reason_id = row_number()) 

merge(x = reasons_combined, y = statement_sentiment, by = reason_id) 


View(statement_sentiment)   
View(reasons_combined)   

