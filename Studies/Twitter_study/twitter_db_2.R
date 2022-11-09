
# load library for Academic API endpoint 
#devtools::dev_mode(on=T) # run if dev mode needed for dev version of academictwitteR for exact_phrase
library(academictwitteR) 
library(tidyverse)



# store bearer in .Renviron as needed
#set_bearer() 
#get_bearer()
# create search terms for query 

terms <- c("telework", "teleworking", "teleworked", "remote work", "remote working", 
           "remotework", "remoteworking", "work remote", "remoteworking", "work remote", 
           "working remotely", "working remotely", "worked remotely", "workremote",
           "workingremote", "workedremote", "workremotely", "workingremotely",
           "workedremotely", "teleworker", "teleworkers", "remote worker", "remoteworkers", 
           "work from home", "working from home", "worked from home", "workfromhome", 
           "workingfromhome", "workedfromhome", "wfh", "return to work", "returntowork", 
           "return to office", "returning to offices", "returning to workplace", "returned to office", 
           "returning to in person work", "working in-person", "in-person work", "working in-person") 



# build search terms for query 
search_terms <- build_query(query = terms, 
                            is_retweet = F, 
                            remove_promoted = T, 
                            country = "US", 
                            lang = "en")

# use the search term parameters in the data pull 

wfh_df <- get_all_tweets(
  query = search_terms,
  "2020-08-02T00:00:00Z",
  "2020-08-03T00:00:00Z",
  n = 500)


# subset the data frame to only contain non-commercial twitter sources 
wfh_sub <- wfh_df %>% 
  filter(source %in% c("Twitter for iPhone", 
                        "Twitter for Android", 
                        "Twitter for iPad", 
                        "Twitter for Mac"))


# to store likes and retweets data, 
# use unnest() from dplyr to unlist the metric variables 

wfh_metrics <- wfh_sub %>%
  unnest(public_metrics)


# clean the mined tweets data to the columns that I want 
df_export <- wfh_metrics %>%
  select(author_id, text, id, source, created_at, retweet_count, 
         reply_count, like_count, quote_count) 

# following write.table() code tells R to attach the newly mined df_export data frame to a data set 
# that I have in the path that is specified. This effectively adds the new set of tweets to the data set. 
write.table(df_export, "/Users/gianzlupko/Desktop/Workgroup/dnl_nlp/Studies/Twitter_study/wfh_twitter_data.csv", 
            append = T, row.names = T, col.names = T, sep = ",") 



