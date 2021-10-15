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

reasons_word_probs<- reasons_ctm_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>% 
  ungroup() %>%
  arrange(topic, -beta)

reasons_word_probs %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered() + theme(axis.text=element_text(size=12)) 

# assign topic from CTM to observations 
# use the function topics() from topicmodels library to assign the most
# likely topics for each document (in this case combined reasons) 

lda_assignments <- data.frame(topics(lda_two)) 
lda_assignments$decision_id <- rownames(lda_assignments) 
colnames(lda_assignments) <- c("topic_assigned", "decision_id") 

# join topic assignment outputs with original data set using dyply's inner_join() 

topics_assigned <- inner_join(x = survey_dat, 
           y = lda_assignments, 
           by = "decision_id") 
  
# check distribution of topics assigned
# shows even split between two topics 
table(topics_assigned$topic_assigned) 


# return the topic probabilities for each 'document' (e.g. combined reasons)
# using posterior() from the topicmodels library
# afterwards, cleaning df below
# also exporting the table below as a 'loadings' table 

lda_two_probabilities <- as.data.frame(topicmodels::posterior(lda_two)$topics)

lda_two_probabilities$decision_id <- rownames(lda_two_probabilities) 
lda_two_probabilities <- lda_two_probabilities[ , c(3,1,2)] 
#write.csv(lda_two_probabilities, "lda_two_probabilities.csv")





# sample model comparison with categorical predictor 
# first create factor 

topics_assigned$topic_assignedF <- factor(topics_assigned$topic_assigned, levels = c("Work", "Life"))

# model comparison  - e.g. regret regressed on subjective norm and topic 

mod1 <- lm(Regret_Scale_Survey1_T2_2_items_AVE ~ SN_Ave, data = topics_assigned) 
mod1 %>% summary()

mod2 <- lm(Regret_Scale_Survey1_T2_2_items_AVE ~ SN_Ave + topic_assigned, 
           data = topics_assigned) 

anova(mod1, mod2) 

       