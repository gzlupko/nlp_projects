# Sample LDA Pipe 

library(tidytext) 
library(tidyverse)
library(topicmodels) 

# import data and convert to tibble 
docs <- tibble(line = 1:6,
                   decisions = c("start a new job",
                                "eat healthier",
                                "get a gym membership",
                                "learn korean", 
                                "get my dog a membership", 
                                "learn how to cook"))


twitter <- readRDS("sample_twitter_data.rds") 


# create document term matrix
# here choose to remove stop words 
sample_dtm <- twitter %>%
  unnest_tokens(word, tweet_text) %>%
  anti_join(stop_words) %>%
  count(tweet_id, word) %>%
  cast_dtm(document = tweet_id, term = word, value = n) %>%
  as.matrix() 

# run a 3 topic LDA 
lda_1 <- LDA(
  sample_dtm, 
  k = 3, 
  method = "Gibbs"
  
)

# tidy the LDA model output 
 
lda_1_topics <- lda_1 %>%
  tidy(matrix = "beta") 

# arrange topics descending

lda_1_topics %>%
  arrange(desc(beta)) 
