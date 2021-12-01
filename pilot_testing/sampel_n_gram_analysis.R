# n-gram analysis 


# import data
sample_reasons <- read_csv("sample_reasons_data.csv") 
reasons <- sample_reasons[-c(1:4), ]
colnames(reasons) <- "response"
reasons$participant_id <- 1:length(reasons$response) 
# reorder columns 
reasons <- reasons[, c(2,1)]


# create dtm for TM; remove stop words
reasons_bigrams <- reasons %>%
  unnest_tokens(bigram, response, token = "ngrams", n = 2)

# count bigrams
reasons_bigrams %>%
  count(bigram, sort = T) 


# remove most common words to refine

library(tidyr)

bigrams_separated <- reasons_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% stop_words$word) %>%
  filter(!word2 %in% stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ")
bigrams_filtered
#write.csv(bigram_counts, "decision_data_bigram.csv") 

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(bigram, sort = TRUE)

bigram_counts


# tri-gram analysis 

trigram_filtered <- reasons %>%
  unnest_tokens(trigram, response, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>%
  count(word1, word2, word3, sort = TRUE) %>%
  unite(trigram, word1, word2, word3, sep = " ")
#write.csv(trigram_filtered, "decision_data_trigram.csv") 

# create a tri_gram separated list to examine preceeding and succeeding words 

trigram_separated <- reasons %>%
  unnest_tokens(trigram, response, token = "ngrams", n = 3) %>%
  separate(trigram, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% stop_words$word,
         !word2 %in% stop_words$word,
         !word3 %in% stop_words$word) %>%
  count(word1, word2, word3, sort = TRUE) 


# bigram - word succeeding for target words 

move_bigram <- bigrams_separated %>%
  filter(word1 == "move") %>%
  count(word1, word2, sort = T) %>%
  mutate(proportion_overall = (n /sum(n)))
#write.csv(move_bigram, "move_bigram.csv") 
job_bigram <- bigrams_separated %>%
  filter(word1 == "job") %>%
  count(word1, word2, sort = T) %>%
  mutate(proportion_overall = (n /sum(n)))
#write.csv(job_bigram, "job_bigram.csv") 

start_bigram <- bigrams_separated %>%
  filter(word1 == "start") %>%
  count(word1, word2, sort = T) %>%
  mutate(proportion_overall = (n /sum(n)))
#write.csv(start_bigram, "start_bigram.csv") 

# trigram words preceeding

trigram_separated %>%
  filter(word1 == "move") %>%
   count(word1, word2, word3, sort = T) 

trigram_filtered



# bi-gram network visualization 
library(igraph) 
library(ggraph) 
bigram_graph <- bigram_counts %>% 
  filter(n > 1) %>%
  graph_from_data_frame()

set.seed(2017)
ggraph(bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)


# test push to repo 