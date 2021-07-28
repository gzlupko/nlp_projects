# Sample Sentiment Analysis 


library(tidytext) 
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
