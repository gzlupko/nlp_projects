# twitter sample 



##### Libraries 

library(ROAuth)
library(twitteR)
library(tidyverse) 
library(tidytext) 
library(tidyverse)
library(topicmodels) 
library(ldatuning)

# create Twitter connection 

#api_key <- "jcf0K4bRqDrTVLD1sSZmsdWLI"
#api_secret <- "re_load"
#access_token <- "re_load"
#access_secret <- "re_load"
#consumer_key <- "re_load"
#consumer_secret <- "re_load" 

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret) 

###### Store searchString 
# search terms include Zhang et. al (2021) and terms coresponding with our variables: 
# our variables include: work-family conflict, perceived org support, LMX

terms <- c("telework", "teleworking", "teleworked", "remote work", "remote working", 
           "remotework", "remoteworking", "work remote", "remoteworking", "work remote", 
           "working remotely", "working remotely", "worked remotely", "workremote",
           "workingremote", "workedremote", "workremotely", "workingremotely",
           "workedremotely", "teleworker", "teleworkers", "remote worker", "remoteworkers", 
           "work from home", "working from home", "worked from home", "workfromhome", 
           "workingfromhome", "workedfromhome", "wfh") 


terms_search <- paste(terms, collapse = " OR ")
wfh_search<- searchTwitter(terms_search, n = 10, lang="en")
wfh_df <- twListToDF(wfh_search)
View(wfh_df) 


##### Pre-Processing: Text Cleaning 

tidy_twitter <- wfh_df %>%
unnest_tokens(word, text) %>%
  anti_join(stop_words) 



# text pre-processing 


clean_tweets <- function(x) {
  x %>%
    # Remove URLs
    str_remove_all(" ?(f|ht)(tp)(s?)(://)(.*)[.|/](.*)") %>%
    # Remove mentions e.g. "@my_account"
    str_remove_all("@[[:alnum:]_]{4,}") %>%
    # Remove hashtags
    str_remove_all("#[[:alnum:]_]+") %>%
    # Replace "&" character reference with "and"
    str_replace_all("&amp;", "and") %>%
    # Remove puntucation, using a standard character class
    str_remove_all("[[:punct:]]") %>%
    # Remove "RT: " from beginning of retweets
    str_remove_all("^RT:? ") %>%
    # Replace any newline characters with a space
    str_replace_all("\\\n", " ") %>%
    # Make everything lowercase
    str_to_lower() %>%
    # Remove any trailing whitespace around the text
    str_trim("both")
}

clean_tweets(tidy_tweets$word) 


# remove unwanted terms 



remove_reg <- "&amp;|&lt;|&gt;"

tidy_tweets <- wfh_df %>% 
  filter(!str_detect(text, "^RT")) %>%
  mutate(text = str_remove_all(text, remove_reg)) %>%
  unnest_tokens(word, text) %>%
  filter(!word %in% stop_words$word,
         !word %in% str_remove_all(stop_words$word, "'"),
         str_detect(word, "[a-z]"))

tidy_tweets$word


# create Document Term Matrix for LDA 

sample_dtm <- tidy_tweets %>%
  count(id, word) %>%
  cast_dtm(document = id, term = word, value = n) %>%
  as.matrix() 

#sample_dtm <- wfh_df %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words) %>%
  count(id, word) %>%
  cast_dtm(document = id, term = word, value = n) %>%
  as.matrix() 

# run LDA 
lda_1 <- LDA(
  sample_dtm, 
  k = 2, 
  method = "Gibbs"
  
)


lda_1_topics <- lda_1 %>%
  tidy(matrix = "beta") 

# arrange topics descending

lda_1_topics %>%
  arrange(desc(beta)) 

