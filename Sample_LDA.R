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
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(reasons_gibbs) 


reasons_lda <- LDA(
  reasons_dtm, 
  k = 2, 
  method = "Gibbs", 
  
  
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


#Set parameters for Gibbs sampling
burnin <- 4000
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE

# use info priors values pre-set for Gibbs sampling based research recommendations and as seen in 
# Finch et al. (2018) 
lda_gibbs_2 <- LDA(reasons_dtm,k = 2, method="Gibbs", control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))
lda_gibs_2.topics <- as.matrix(topics(lda_gibbs_2))

# Calculate perplexity statistic using LDAs for multiple solutions
# lowest perplexity value indicates best topic model solution 
# follows R code method used by Finch et al. (2018) 


lda_vem2  <-LDA(reasons_dtm,2, method="VEM")
lda_vem3 <-LDA(reasons_dtm,3, method="VEM")
lda_vem4  <-LDA(reasons_dtm,4, method="VEM")
lda_vem5  <-LDA(reasons_dtm,5, method="VEM")
lda_vem6  <-LDA(reasons_dtm,6, method="VEM")

perplexity(lda_gibbs_2) 
perplexity(lda_vem2) 
perplexity(lda_vem3) 
perplexity(lda_vem4) 
perplexity(lda_vem5) 
perplexity(lda_vem6) 





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
decisions_dtm_stemmed <- reasons %>%
  unnest_tokens(word, response) %>%
  anti_join(stop_words) %>%
  mutate(stem = wordStem(word)) %>%
  count(participant_id, stem) %>%
  cast_dtm(document = participant_id, term = stem, value = n) %>%
  as.matrix() 

seed<- 232342 
results_decisions_stemmed <- FindTopicsNumber(
  decisions_dtm_stemmed,
  topics = seq(from = 2, to = 10, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)
FindTopicsNumber_plot(results_decisions_stemmed)

# run LDA on k = 3 based on density 
decisions_lda_stemmed <- LDA(
  decisions_dtm_stemmed, 
  k = 3, 
  method = "Gibbs"
  
)

# tidy the LDA model output 

decisions_stemmed_topics <- decisions_lda_stemmed %>%
  tidy(matrix = "beta") %>%
  arrange(desc(beta)) 
decisions_stemmed_topics


decisions_stemmed_word_probs <- decisions_stemmed_topics %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))
decisions_stemmed_word_probs
# save as .csv file 
#write.csv(decisions_stemmed_word_probs, "decisions_lda_topics.csv") 

# Plot word_probs, color and facet based on topic
ggplot(
  decisions_stemmed_word_probs, 
  aes(term2, beta, fill = as.factor(topic))
) +
  geom_col(show.legend = FALSE) +
  facet_wrap( ~ topic, scales = "free") +
  coord_flip()


#Extract topics by document and terms by topic for LDA#
lda_three_topics <- as.matrix(topics(decisions_lda_stemmed))
lda_three_terms <- as.matrix(terms(decisions_lda_stemmed,10))
colnames(lda_three_topics) <- "topic_number"
lda_three_topics <- data.frame(lda_three_topics) 
# generate count of number of words by topic in the corpus 
lda_three_topics %>%
  group_by(topic_number) %>%
  count(topic_number) 
#probabilities associated with each topic assignment
topicProbabilities_lda_three_topics <- as.data.frame(decisions_lda_stemmed@gamma)
sapply(topicProbabilities_lda_three_topics, mean)
