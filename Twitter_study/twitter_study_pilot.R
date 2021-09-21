# twitter sample 


# create Twitter connection 


library(ROAuth)
library(twitteR)
#api_key <- "jcf0K4bRqDrTVLD1sSZmsdWLI"
#api_secret <- "ZTU2urYwNj8RMXqSYZJXi5Gveb8GbSP0zITT9vqLJ2mOUgh7po"
access_token <- "363179894-ZuN7k6hrw8SucTZtwKQXxcp3aZ2EUg1onZWcMvwx"
access_secret <- "WRHp26YYyOyq01GrA9kSJvj8tx9enGWg9UiiPNehf4BIW"
consumer_key <- "eq3R1STvoYHXkqGuHoeQpAzmU"
consumer_secret <- "R2RYGZbAcDFbA1a34kssLk3mnRClrvjvQcd2nc0d0cRco4l2bj" 

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret) 

###### Store searchString

terms <- c("telework", "teleworking", "teleworked", "remote work", "remote working", 
           "remotework", "remoteworking", "work remote", "remoteworking", "work remote", 
           "worked remote", "work remotely", "working remotely", "worked remotely", 
           "workremote", "workingremote", "workedremote", "WFH", "workfromhome", "work from home", 
           "teleworker", "worked from home", "workedfromhome") 
terms_search <- paste(terms, collapse = " OR ")
wfh_search<- searchTwitter(terms_search, n = 10, lang="en")
wfh_df <- twListToDF(wfh_search)
View(wfh_df) 
?searchTwitteR

