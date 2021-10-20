### Correlated Topic Model test 


library(tidytext) 
library(tidyverse)
library(topicmodels) 
library(ldatuning)


# load raw data and begin conversion to long data format 
dat <- read_csv("reasons_cons_10.20.csv")

# first add unique participant id 
dat1 <- dat %>%
  mutate(participant_id = 1:length(Decision))

# use duplicated() to check that each participant_id is unique 
duplicated(dat1[ ,c("participant_id")])

# after confirming that all ids are unique
# create one data set of reasons that will be 
# used to convert from wide to long format 

dat2 <- dat1 %>%
  select(participant_id, Reason1, Reason2, Reason3, Reason3, 
         Reason4, Reason5, Reason6, Reason7, Reason8, Reason9, Reason10)  

# first convert reasons to long data format
data_long <- dat2 %>%
  gather(key = "Reason", 
         value = "Reason_Stated", c(-participant_id)) 


# next create a subset of the original data without the reasons data
# instead, retain only the BRT and decision variable scores to reattach
# to the long data frame

scores_to_merge <- dat1 %>%
  select(participant_id, ConfRfor, Att_Ave, PC_Ave, Regret_GlobalMotive_Ave, 
         SN_Ave, ReasonComparison_3item_Standardized_Ave,
         Int_3_Item_AfterTPB_PossiblyLessBiasedOnReasons_Standardized_Ave, 
         MoreInfo_3_items_Ave, Dec_Quality_Survey1_T2_Standardized_AVE, 
         Regret_Scale_Survey1_T2_2_items_AVE)

# now, merge with the long formatted reasons data and merge by participant_id

reasons_formatted <- merge(x = data_long, 
                           y = scores_to_merge, 
                           by = "participant_id", 
                           all.y = T)


# finally remove rows with NA values 

reasons_long <- reasons_formatted %>%
  filter(!is.na(Reason_Stated)) 


# add row_id, which will be used after creating topic model
# to re-assign the topic model output back to the unique row id 
reasons_long$row_id <- paste(1:nrow(reasons_long))



#### Topic Modeling 


# create dtm for TM; remove stop words

reasons_dtm <- reasons_long %>%
  unnest_tokens(word, Reason_Stated) %>%
  anti_join(stop_words) %>%
  count(row_id, word) %>%
  cast_dtm(document = row_id, term = word, value = n) %>%
  as.matrix() 
              
# determine ideal number of topic models; visualize

seed<- 59127
reasons_gibbs <- FindTopicsNumber(
  reasons_dtm,
  topics = seq(from = 2, to = 12, by = 1),
  metrics = c("CaoJuan2009"),
  method = "GIBBS",
  
  control=list(seed = seed),
  mc.cores = 2L,
  verbose = TRUE
)

# it appears that an optimal number of topics are 2 or 6
FindTopicsNumber_plot(reasons_gibbs) 


# run a correlated topic model with k = 6
ctm_two <- CTM(reasons_dtm, 
    k = 3, 
    method = "VEM")

# create similar LDA 

#lda_six <- LDA(reasons_dtm,k = 6) 

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

topicmodels::topics(ctm_two) 
ctm_assignments <- data.frame(topics(ctm_two)) 
ctm_assignments$row_id <- rownames(ctm_assignments) 
colnames(ctm_assignments) <- c("topic_assigned", "row_id") 

# join topic assignment outputs with original data set using dyply's inner_join() 

topics_assigned <- inner_join(x = reasons_long, 
           y = ctm_assignments, 
           by = "row_id") 
  
# check distribution of topics assigned
# shows even split between two topics 
table(topics_assigned$topic_assigned) 



#write.csv(topics_assigned, "topics_assigned.csv") 

# return the topic probabilities for each 'document' (e.g. combined reasons)
# using posterior() from the topicmodels library
# afterwards, cleaning df below
# also exporting the table below as a 'loadings' table 

lda_two_probabilities <- as.data.frame(topicmodels::posterior(lda_two)$topics)

lda_two_probabilities$decision_id <- rownames(lda_two_probabilities) 
lda_two_probabilities <- lda_two_probabilities[ , c(3,1,2)] 
#write.csv(lda_two_probabilities, "lda_two_probabilities.csv")

# next steps....run topic model and assignment on individual reasons
# use a group_by feature to keep the BRT variables tagged by reasons 
# then will use dummy coding scheme to generate regression of topic on
# BRT variables 



