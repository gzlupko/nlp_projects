# Sample LDA Pipe 

library(tidytext) 
library(tidyverse)
library(topicmodels) 
library(ldatuning)

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

# arrange top terms by topic

word_probs <- lda_1_topics %>% 
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))


# Plot word_probs, color and facet based on topic
ggplot(
  word_probs, 
  aes(term2, beta, fill = as.factor(topic))
) +
  geom_col(show.legend = FALSE) +
  facet_wrap( ~ topic, scales = "free") +
  coord_flip()

# probably need to remove certain words like klm, de, 2 to refine

#Determine optimal number of topics using ldatuning#
library(ldatuning)

seed<-90178933469
result.gibbs <- FindTopicsNumber(
  sample_dtm,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(result.gibbs)


##### Reasons data 

sample_reasons <- read_csv("sample_reasons_data.csv") 
reasons <- sample_reasons[-c(1:4), ]
colnames(reasons) <- "response"
reasons$participant_id <- 1:length(reasons$response) 
# reorder columns 
reasons <- reasons[, c(2,1)]


# create dtm for TM; remove stop words
reasons_dtm <- reasons %>%
  unnest_tokens(word, response) %>%
  anti_join(stop_words) %>%
  count(participant_id, word) %>%
  cast_dtm(document = participant_id, term = word, value = n) %>%
  as.matrix() 

# determine ideal number of topic models; visualize



seed<- 59127
reasons_gibbs <- FindTopicsNumber(
  reasons_dtm,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009",
              "Arun2010", 
              "Deveaud2014"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(reasons_gibbs) 


reasons_lda <- LDA(
  reasons_dtm, 
  k = 3, 
  method = "Gibbs"
  
)

# tidy the LDA model output 

reasons_lda_topics <- reasons_lda %>%
  tidy(matrix = "beta") %>%
  arrange(desc(beta)) 
reasons_lda_topics 

# arrange top 15 terms by each topic 

reasons_word_probs <- reasons_lda_topics %>% 
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))
reasons_word_probs

# Plot word_probs, color and facet based on topic
ggplot(
  reasons_word_probs, 
  aes(term2, beta, fill = as.factor(topic))
) +
  geom_col(show.legend = FALSE) +
  facet_wrap( ~ topic, scales = "free") +
  coord_flip()


# Correlated Topic Model (CTM)

reasons_ctm <- CTM(reasons_dtm, k = 2, control=list(seed=831))
beta_plot(topic_object = reasons_lda,  
          n = 2)
#Extract topics by document and terms by topic for CTM#
reasons_ctm_topics <- as.matrix(topics(reasons_ctm))
reasons_ctm_terms <- as.matrix(terms(reasons_ctm, 2))
reasons_ctm_terms




# create dtm for TM; remove stop words and not convert to word stems 
library(SnowballC)
reasons_dtm_stemmed <- reasons %>%
  unnest_tokens(word, response) %>%
  anti_join(stop_words) %>%
  mutate(stem = wordStem(word)) %>%
  count(participant_id, stem) %>%
  cast_dtm(document = participant_id, term = stem, value = n) %>%
  as.matrix() 

seed<- 232342 
results_reasons_stemmed <- FindTopicsNumber(
  reasons_dtm_stemmed,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)
FindTopicsNumber_plot(results_reasons_stemmed)


reasons_lda_stemmed <- LDA(
  reasons_dtm_stemmed, 
  k = 3, 
  method = "Gibbs"
  
)

# tidy the LDA model output 

reasons_stemmed_topics <- reasons_lda_stemmed %>%
  tidy(matrix = "beta") %>%
  arrange(desc(beta)) 
reasons_stemmed_topics


reasons_stemmed_word_probs <- reasons_stemmed_topics %>% 
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))
reasons_stemmed_word_probs

# Plot word_probs, color and facet based on topic
ggplot(
  reasons_stemmed_word_probs, 
  aes(term2, beta, fill = as.factor(topic))
) +
  geom_col(show.legend = FALSE) +
  facet_wrap( ~ topic, scales = "free") +
  coord_flip()
