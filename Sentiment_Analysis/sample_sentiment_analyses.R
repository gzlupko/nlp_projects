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
head(reasons_data)

reasons_data[ ,c(3:12)] <- as.vector(reasons_data[ ,c(3:12)])

reasons_combined$Reasons <- as.vector(reasons_combined$Reasons) 



# load pre-combined reasons data and show correlation with BRT variables

combined_reasons <- read.csv("reasons_and_pc.csv") 

# change combined reasons to vector 

combined_reasons$reasons_combined <- as.vector(combined_reasons$reasons_combined)

# add reason_id to combined_reasons so that after conducting sentiment analysis, can re-join to other varaibles

combined_reasons$reason_id <- paste(1:nrow(combined_reasons)) # may not need this step using sentimnentr pipe 
combined_reasons

# now use sentimentr to calculate an overall sentiment score for the combined reasons 
library(sentimentr) 
sentiment_scores <- combined_reasons %>% 
  unnest(cols = c()) %>% 
  sentimentr::get_sentences() %>% 
  sentimentr::sentiment()
View(sentiment_scores) 
# rename sentiment to reasons_sentiment 

sentiment_scores <- sentiment_scores %>%
   rename(reasons_sentiment = sentiment) 

# clean column names before correlations 

sentiment_scores <- sentiment_scores %>%
  rename(attitude = Att_Ave) %>%
  rename(pc = PC_Ave) %>%
  rename(regret_global_motive = Regret_GlobalMotive_Ave) %>%
  rename(r_comparison= ReasonComparison_3item_Standardized_Ave) %>%
  rename(decision_quality = Dec_Quality_Survey1_T2_Standardized_AVE) %>%
  rename(regret_t2 = Regret_Scale_Survey1_T2_2_items_AVE) 
  


# generate corrplot with reasons_sentiment and BRT variables 
library(corrplot) 

sentiment_cor <- sentiment_scores %>%
  select(attitude, pc, regret_global_motive, r_comparison, decision_quality, regret_t2, reasons_sentiment)

# two  rows in regret_global_motives missing values; remove and re-run 

sentiment_cor <- sentiment_cor %>%
  filter(!is.na(regret_global_motive)) 

sentiment_cor <- cor(sentiment_cor) 
col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))

corrplot(sentiment_cor, method="color", col=col(200),  
         type = "lower", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, title = "\n\n Reason Sentiment Scores Correlation Matrix") 



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


# use get_sentences() from sentimentr library to analyze sentiments by reason
reasons_sentiment <- reasons_combined %>% 
  unnest(cols = c()) %>% 
  sentimentr::get_sentences() %>% 
  sentimentr::sentiment()
# view first few rows 
head(reasons_sentiment) 
