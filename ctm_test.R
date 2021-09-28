### Correlated Topic Model test 


library(tidytext) 
library(tidyverse)
library(topicmodels) 
library(ldatuning)

# load data set with pre-combined reasons data 
# all reasons stated have been merged into the column 'reasons combined' 
survey_dat <- read.csv("reasons_and_pc.csv") 

# change combined reasons to vector 
survey_dat$reasons_combined <- as.vector(survey_dat$reasons_combined)

# add a decision id column to tag each decision
survey_dat$decision_id <- paste(1:nrow(survey_dat))


View(survey_dat) 
# create a column and store combined counterarguments in it
# (come back to this after running ctm on reasons for data) 



# create dtm for TM; remove stop words
reasons_dtm <- survey_dat %>%
  unnest_tokens(word, reasons_combined) %>%
  anti_join(stop_words) %>%
  count(decision_id, word) %>%
  cast_dtm(document = decision_id, term = word, value = n) %>%
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

# it appears that an optimal number of topics are 2 or 6
FindTopicsNumber_plot(reasons_gibbs) 


# run a correlated topic model with k = 2
ctm_two <- CTM(reasons_dtm, 
    k = 2, 
    method = "VEM")

# create similar LDA 

lda_two <- LDA(reasons_dtm, 
               k = 2) 


# tidy the CTM model output 

reasons_ctm_topics <- ctm_two %>%
  tidy(matrix = "beta") %>%
  arrange(desc(beta)) 

reasons_ctm_topics

# arrange top 15 terms by each topic 

reasons_word_probs <- reasons_ctm_topics %>% 
  group_by(topic) %>% 
  top_n(15, beta) %>% 
  ungroup() %>%
  mutate(term2 = fct_reorder(term, beta))

reasons_word_probs


# assign topic from CTM to observations 

lda_assignments <- data.frame(topics(lda_two)) 
lda_assignments$decision_id <- rownames(lda_assignments) 
colnames(lda_assignments) <- c("topic_assigned", "decision_id") 

# join topic assignment outputs with original data set using dyply, join_by 

topics_assigned <-survey_dat %>% 
  left_join(lda_assignments) 

View(topics_assigned) 
