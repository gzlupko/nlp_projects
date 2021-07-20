# Sample LDA Pipe 

library(tidytext) 
library(tidyverse) 

# import data and convert to tibble 
docs <- tibble(line = 1:6,
                   decisions = c("start a new job",
                                "eat healthier",
                                "get a gym membership",
                                "learn korean", 
                                "get my dog a membership", 
                                "learn how to cook"))


# create document term matrix
# here choose to remove stop words 
sample_dtm <- docs %>%
  unnest_tokens(word, decisions) %>%
  anti_join(stop_words) %>%
  count(line, word) %>%
  cast_dtm(document = line, term = word, value = n) %>%
  as.matrix() 




